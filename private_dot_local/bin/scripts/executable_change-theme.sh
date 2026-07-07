#!/usr/bin/env python3
import argparse
import difflib
import os
import re
import shutil
import signal
import subprocess
import sys
import tempfile
import time
from datetime import datetime
from pathlib import Path

HOME = Path.home()
XDG_CONFIG_HOME = Path(os.environ.get("XDG_CONFIG_HOME", HOME / ".config"))
XDG_CACHE_HOME = Path(os.environ.get("XDG_CACHE_HOME", HOME / ".cache"))
SCRIPT_DIR = HOME / ".script_stuff" / "theme-switcher"
BACKUP_DIR = SCRIPT_DIR / "backups"

PATHS = {
    "kitty_conf": XDG_CONFIG_HOME / "kitty" / "kitty.conf",
    "waybar_css": XDG_CONFIG_HOME / "waybar" / "style.css",
    "swaync_css": XDG_CONFIG_HOME / "swaync" / "style.css",
    "wofi_css": XDG_CONFIG_HOME / "wofi" / "style.css",
    "hypr_conf": XDG_CONFIG_HOME / "hypr" / "categories" / "look-and-feel.conf",
    "wlogout_css": XDG_CONFIG_HOME / "wlogout" / "style.css",
    "kitty_schemes": XDG_CONFIG_HOME / "kitty" / "terminal-schemes",
    "waybar_theme_dir": XDG_CONFIG_HOME / "waybar" / "themes",
    "swaync_theme_dir": XDG_CONFIG_HOME / "swaync" / "themes",
    "wofi_theme_dir": XDG_CONFIG_HOME / "wofi" / "themes",
    "wlogout_theme_dir": XDG_CONFIG_HOME / "wlogout" / "themes",
    "pywal_cache": XDG_CACHE_HOME / "wal",
    "waypaper_config": XDG_CONFIG_HOME / "waypaper" / "config.ini",
    "hyprlock_conf": XDG_CONFIG_HOME / "hypr" / "hyprlock.conf",
    "current_theme": XDG_CONFIG_HOME / "theme-current",
}
PYWAL_THEME_NAME = "pywal"
DEFAULT_WALLPAPER_PATH = XDG_CONFIG_HOME / "wall.png"


class CliError(Exception):
    pass


def log(message, quiet=False):
    if not quiet:
        print(message)


def error(message):
    print(f"ERROR: {message}", file=sys.stderr)
    sys.exit(1)


def run_command(cmd, capture_output=False, check=True, timeout=None):
    try:
        return subprocess.run(
            cmd,
            capture_output=capture_output,
            text=True,
            check=check,
            timeout=timeout,
        )
    except FileNotFoundError:
        raise CliError(f"Required command not found: {cmd[0]}")
    except subprocess.CalledProcessError as exc:
        if capture_output:
            raise CliError(f"Command failed: {' '.join(cmd)}\n{exc.stderr or exc.stdout or ''}")
        raise


def which(program):
    return shutil.which(program)


def is_running(name):
    pgrep = which("pgrep")
    if not pgrep:
        return False
    # Use -f to match command line in case waypaper runs under a python interpreter
    result = subprocess.run([pgrep, "-f", name], capture_output=True, text=True)
    return result.returncode == 0


def backup_file(path):
    BACKUP_DIR.mkdir(parents=True, exist_ok=True)
    timestamp = datetime.now().strftime("%Y%m%d%H%M%S")
    backup_path = BACKUP_DIR / f"{path.name}_{timestamp}.bak"
    shutil.copy2(path, backup_path)
    return backup_path


def tidy_backups(path, keep=10):
    backups = sorted(BACKUP_DIR.glob(f"{path.name}_*.bak"), reverse=True)
    for old in backups[keep:]:
        old.unlink(missing_ok=True)


def load_text(path):
    return path.read_text(encoding="utf-8")


def write_text(path, contents):
    path.write_text(contents, encoding="utf-8")


def ensure_paths_exist(paths, quiet=False):
    for key, path in paths.items():
        if key.endswith("_dir"):
            continue
        if key == "current_theme":
            continue
        if not path.exists():
            log(f"WARNING: expected config path missing: {path}", quiet)


def exact_theme_exists(theme):
    if theme == PYWAL_THEME_NAME:
        return can_use_pywal()
    return theme in available_themes(include_pywal=False)


def available_themes(include_pywal=True):
    kitty_dir = PATHS["kitty_schemes"]
    dirs = [PATHS["waybar_theme_dir"], PATHS["swaync_theme_dir"], PATHS["wofi_theme_dir"], PATHS["wlogout_theme_dir"]]

    if not kitty_dir.exists():
        raise CliError(f"Missing Kitty theme directory: {kitty_dir}")

    theme_names = [p.stem for p in kitty_dir.glob("*.conf")]
    themes = []
    for name in sorted(theme_names):
        if all((d / f"{name}.css").exists() for d in dirs):
            themes.append(name)

    if include_pywal and can_use_pywal():
        themes.append(PYWAL_THEME_NAME)

    return themes


def can_use_pywal():
    return PATHS["waypaper_config"].exists() and which("wal") is not None


def choose_theme_interactive(themes, style, quiet=False):
    if not themes:
        raise CliError("No themes available")

    if style == "wofi":
        if which("wofi") is None:
            raise CliError("Wofi is not installed")
        input_text = "\n".join(themes) + "\n"
        result = subprocess.run(
            ["wofi", "--dmenu", "--prompt", "Select Theme: "],
            input=input_text,
            capture_output=True,
            text=True,
            check=False,
            timeout=30,
        )
        theme = result.stdout.strip()
        if not theme:
            stderr_text = result.stderr.strip()
            if stderr_text:
                raise CliError(f"Wofi selection failed: {stderr_text}")
            raise CliError("Theme selection cancelled")
        return theme

    if style == "fuzzy":
        if which("fzf") is None:
            log("fzf not found, falling back to menu selection", quiet)
            style = "menu"
        else:
            input_text = "\n".join(themes) + "\n"
            result = subprocess.run(
                ["fzf", "--prompt", "Select Theme: "],
                input=input_text,
                capture_output=True,
                text=True,
                check=False,
            )
            theme = result.stdout.strip()
            if not theme:
                stderr_text = result.stderr.strip()
                if stderr_text:
                    raise CliError(f"fzf selection failed: {stderr_text}")
                raise CliError("Theme selection cancelled")
            return theme

    if style == "menu":
        print("Available themes:")
        for index, name in enumerate(themes, start=1):
            print(f"  {index}. {name}")

        choice = input("Choose a theme number: ").strip()
        if not choice.isdigit() or not (1 <= int(choice) <= len(themes)):
            raise CliError("Invalid selection")
        return themes[int(choice) - 1]

    raise CliError(f"Unknown selection style: {style}")


def slugify_theme_name(name):
    slug = name.strip().lower()
    slug = re.sub(r"[\s]+", "-", slug)
    slug = re.sub(r"[^a-z0-9_-]", "", slug)
    slug = re.sub(r"-+", "-", slug)
    return slug


def parse_theme_yaml(path):
    data = {}
    entry_re = re.compile(r"^([A-Za-z0-9_]+)\s*:\s*(?:(['\"])(.*?)\2|([^\s#]+))\s*(?:#.*)?$")
    for line in load_text(path).splitlines():
        line = line.strip()
        if not line or line.startswith("#") or line.startswith("---"):
            continue
        match = entry_re.match(line)
        if not match:
            continue
        key = match.group(1)
        value = match.group(3) if match.group(3) is not None else (match.group(4) or "")
        data[key] = value
    return data


def validate_theme_data(data, source):
    required = ["name", "background", "foreground", "cursor"]
    required += [f"color_{i:02d}" for i in range(1, 17)]
    missing = [key for key in required if key not in data or data[key] == ""]
    if missing:
        raise CliError(f"Missing theme keys in {source}: {', '.join(missing)}")


def theme_css_text(theme_name, data):
    lines = [
        f"/* Theme: {theme_name} */",
        f"@define-color background {data['background']};",
        f"@define-color foreground {data['foreground']};",
    ]
    for index in range(1, 17):
        key = f"color_{index:02d}"
        css_name = f"color{index-1}"
        lines.append(f"@define-color {css_name} {data[key]};")
    lines.append(f"@define-color cursor {data['cursor']};")
    return "\n".join(lines) + "\n"


def kitty_theme_text(theme_name, data):
    lines = [
        f"# Kitty theme: {theme_name}",
        "# Generated from YAML import",
        "",
        f"foreground {data['foreground']}",
        f"background {data['background']}",
        f"selection_foreground {data['foreground']}",
        f"selection_background {data['color_08']}",
        f"url_color {data['color_05']}",
        "",
        f"cursor {data['cursor']}",
        "",
    ]
    for index in range(1, 17):
        key = f"color_{index:02d}"
        lines.append(f"color{index-1}  {data[key]}")
        if index == 8:
            lines.append("")
    return "\n".join(lines) + "\n"


def import_theme_yaml(yaml_path, args):
    yaml_path = Path(yaml_path).expanduser()
    if not yaml_path.exists():
        raise CliError(f"YAML file not found: {yaml_path}")

    data = parse_theme_yaml(yaml_path)
    validate_theme_data(data, yaml_path)
    theme = slugify_theme_name(data.get("name", yaml_path.stem))
    if not theme:
        raise CliError("Invalid theme name in YAML")

    css_text = theme_css_text(theme, data)
    kitty_text = kitty_theme_text(theme, data)

    dirs = [
        PATHS["waybar_theme_dir"],
        PATHS["swaync_theme_dir"],
        PATHS["wofi_theme_dir"],
        PATHS["wlogout_theme_dir"],
    ]
    for d in dirs + [PATHS["kitty_schemes"]]:
        d.mkdir(parents=True, exist_ok=True)

    theme_css_file = PATHS["waybar_theme_dir"] / f"{theme}.css"
    kitty_file = PATHS["kitty_schemes"] / f"{theme}.conf"
    if theme_css_file.exists() or kitty_file.exists():
        if not args.yes:
            answer = input(f"Theme '{theme}' already exists. Overwrite? [y/N]: ").strip().lower()
            if answer != "y":
                raise CliError("Import cancelled")

    for d in dirs:
        target = d / f"{theme}.css"
        if not args.dry_run:
            write_text(target, css_text)
        log(f"{'Would write' if args.dry_run else 'Wrote'} {target}", args.quiet)

    if not args.dry_run:
        write_text(kitty_file, kitty_text)
    log(f"{'Would write' if args.dry_run else 'Wrote'} {kitty_file}", args.quiet)

    if args.dry_run:
        log("Dry-run: no files were written", args.quiet)
    else:
        log(f"Imported theme '{theme}' from {yaml_path}", args.quiet)
    return theme


def remove_theme(theme, args):
    theme_name = slugify_theme_name(theme)
    dirs = [
        PATHS["waybar_theme_dir"],
        PATHS["swaync_theme_dir"],
        PATHS["wofi_theme_dir"],
        PATHS["wlogout_theme_dir"],
    ]
    files = [d / f"{theme_name}.css" for d in dirs]
    files.append(PATHS["kitty_schemes"] / f"{theme_name}.conf")
    existing = [p for p in files if p.exists()]
    if not existing:
        raise CliError(f"Theme '{theme_name}' not found in any target directories")

    if not args.yes:
        print("The following files will be removed:")
        for p in existing:
            print(f"  {p}")
        answer = input(f"Remove theme '{theme_name}'? [y/N]: ").strip().lower()
        if answer != "y":
            raise CliError("Removal cancelled")

    for p in existing:
        if not args.dry_run:
            p.unlink()
        log(f"{'Would remove' if args.dry_run else 'Removed'} {p}", args.quiet)

    if args.dry_run:
        log("Dry-run: no files were removed", args.quiet)
    else:
        log(f"Removed theme '{theme_name}'", args.quiet)


def parse_arguments():
    parser = argparse.ArgumentParser(description="Theme switcher for Kitty, Waybar, SwayNC, Wofi, Wlogout, Hyprland, and Pywal.")
    parser.add_argument("theme", nargs="?", help="Theme name to apply")
    parser.add_argument("-q", "--quiet", action="store_true", help="Suppress progress output")
    parser.add_argument("-y", "--yes", action="store_true", help="Apply changes without confirmation")
    parser.add_argument("-m", "--menu", action="store_true", help="Use numbered menu selection")
    parser.add_argument("-w", "--wofi", action="store_true", help="Use Wofi selection instead of fzf/menu")
    parser.add_argument("--list", action="store_true", help="List available themes and exit")
    parser.add_argument("--dry-run", action="store_true", help="Show changes without applying them")
    parser.add_argument("--waypaper-pywal", action="store_true", help="Open waypaper, select wallpaper, and run pywal on it")
    parser.add_argument("--force-waypaper", action="store_true", help="Spawn a new waypaper instance even if one is running")
    parser.add_argument("--remove-theme", "--delete-theme", dest="remove_theme", metavar="THEME", help="Remove an existing imported theme from all configs")
    parser.add_argument("--import-theme", "--add-theme", dest="import_theme", metavar="YAML", help="Create a new theme from a YAML definition")
    return parser.parse_args()


def prompt_confirm(quiet=False):
    if quiet:
        return True
    answer = input("Apply these changes? [y/N]: ").strip().lower()
    return answer == "y"


def update_import(path, pattern, replacement, dry_run=False):
    original = load_text(path)
    updated, count = re.subn(pattern, replacement, original, flags=re.MULTILINE)
    if count == 0:
        log(f"WARNING: no matching line in {path}")
    if not dry_run and updated != original:
        backup_file(path)
        write_text(path, updated)
        tidy_backups(path)
    return original, updated


def apply_text_updates(updates, dry_run=False):
    diffs = []
    for path, updated in updates.items():
        original = load_text(path)
        if original != updated:
            diff = difflib.unified_diff(
                original.splitlines(keepends=True),
                updated.splitlines(keepends=True),
                fromfile=str(path),
                tofile=f"{path} (new)",
            )
            diffs.append("".join(diff))
            if not dry_run:
                backup_file(path)
                write_text(path, updated)
                tidy_backups(path)
    return diffs


def patch_file(path, pattern, replacement, dry_run=False):
    text = load_text(path)
    updated, count = re.subn(pattern, replacement, text, flags=re.MULTILINE)
    if count == 0:
        log(f"WARNING: no matching line in {path}")
    return updated if dry_run or updated != text else text


def update_hypr_border_colors(theme_css, quiet=False, dry_run=False):
    text = load_text(theme_css)
    active = re.search(r"@define-color\s+color0\s+(#[0-9A-Fa-f]{6})", text)
    inactive = re.search(r"@define-color\s+background\s+(#[0-9A-Fa-f]{6})", text)
    active_color = active.group(1) if active else "#3f4451"
    inactive_color = inactive.group(1) if inactive else "#23272e"

    active_rgba = hex_to_rgba(active_color, alpha="aa")
    inactive_rgba = hex_to_rgba(inactive_color, alpha="aa")

    hypr_path = PATHS["hypr_conf"]
    if hypr_path.exists():
        original = load_text(hypr_path)
        updated = original

        # Replace existing keys if present
        updated, a_count = re.subn(r"^(\s*col\.active_border\s*=).*", f"\\1 {active_rgba}", updated, flags=re.MULTILINE)
        updated, i_count = re.subn(r"^(\s*col\.inactive_border\s*=).*", f"\\1 {inactive_rgba}", updated, flags=re.MULTILINE)

        # If replacements didn't occur, insert lines after 'border_size' or after 'general {'
        if a_count == 0 or i_count == 0:
            insert_lines = []
            if a_count == 0:
                insert_lines.append(f"\tcol.active_border = {active_rgba}")
            if i_count == 0:
                insert_lines.append(f"\tcol.inactive_border = {inactive_rgba}")

            if insert_lines:
                # Try to place after border_size
                if re.search(r"^\s*border_size\s*=", updated, flags=re.MULTILINE):
                    updated = re.sub(r"(^\s*border_size\s*=.*$)", lambda m: m.group(1) + "\n" + "\n".join(insert_lines), updated, flags=re.MULTILINE)
                else:
                    # Fallback: insert after 'general {' block start
                    if re.search(r"^\s*general\s*\{", updated, flags=re.MULTILINE):
                        updated = re.sub(r"(^\s*general\s*\{\s*$)", lambda m: m.group(1) + "\n" + "\n".join(insert_lines), updated, flags=re.MULTILINE)
                    else:
                        # As last resort, append to file
                        updated = updated + "\n" + "\n".join(insert_lines) + "\n"

        if updated != original:
            if not dry_run:
                backup_file(hypr_path)
                write_text(hypr_path, updated)
                tidy_backups(hypr_path)
            log(f"Updated Hyprland border colors to {active_rgba} / {inactive_rgba}", quiet)
    else:
        log(f"WARNING: Hyprland config not found: {hypr_path}", quiet)

    if not dry_run and which("hyprctl"):
        try:
            run_command(["hyprctl", "reload"], capture_output=True)
            log("Reloaded Hyprland", quiet)
        except CliError:
            log("WARNING: Could not reload Hyprland", quiet)


def update_hyprlock_colors(theme_css, quiet=False, dry_run=False):
    if not PATHS["hyprlock_conf"].exists():
        log(f"WARNING: Hyprlock config not found: {PATHS['hyprlock_conf']}", quiet)
        return

    text = load_text(theme_css)
    bg = re.search(r"@define-color\s+background\s+(#[0-9A-Fa-f]{6})", text)
    fg = re.search(r"@define-color\s+(?:color15|foreground)\s+(#[0-9A-Fa-f]{6})", text)
    bg_color = bg.group(1) if bg else "#1e1e2e"
    fg_color = fg.group(1) if fg else "#cdd6f4"

    hyprlock_path = PATHS["hyprlock_conf"]
    original = load_text(hyprlock_path)
    updated = original

    # Replace existing keys
    updated, c1 = re.subn(r"^(\s*color\s*=).*", f"\\1 {fg_color}", updated, flags=re.MULTILINE)
    updated, c2 = re.subn(r"^(\s*background_color\s*=).*", f"\\1 {bg_color}", updated, flags=re.MULTILINE)
    updated, c3 = re.subn(r"^(\s*ring_color\s*=).*", f"\\1 {fg_color}", updated, flags=re.MULTILINE)
    updated, c4 = re.subn(r"^(\s*circle_color\s*=).*", f"\\1 {fg_color}", updated, flags=re.MULTILINE)
    updated, c5 = re.subn(r"^(\s*text_color\s*=).*", f"\\1 {fg_color}", updated, flags=re.MULTILINE)

    # If any key was missing, ensure it's present by appending (safe fallback)
    append_lines = []
    if c1 == 0:
        append_lines.append(f"color = {fg_color}")
    if c2 == 0:
        append_lines.append(f"background_color = {bg_color}")
    if c3 == 0:
        append_lines.append(f"ring_color = {fg_color}")
    if c4 == 0:
        append_lines.append(f"circle_color = {fg_color}")
    if c5 == 0:
        append_lines.append(f"text_color = {fg_color}")

    if append_lines:
        # Append inside existing config block if possible; otherwise append at EOF
        if re.search(r"^\s*\[?lock\]?|^\s*#|^\s*color\s*=", updated, flags=re.MULTILINE):
            updated = updated + "\n" + "\n".join(append_lines) + "\n"
        else:
            updated = updated + "\n" + "\n".join(append_lines) + "\n"

    if updated != original:
        if not dry_run:
            backup_file(hyprlock_path)
            write_text(hyprlock_path, updated)
            tidy_backups(hyprlock_path)
        log(f"Updated Hyprlock colors to {fg_color} / {bg_color}", quiet)


def hex_to_rgba(color, alpha="aa"):
    if not re.match(r"^#[0-9A-Fa-f]{6}$", color):
        return color
    r = int(color[1:3], 16)
    g = int(color[3:5], 16)
    b = int(color[5:7], 16)
    return f"rgba({r},{g},{b},{int(alpha, 16) / 255:.2f})"


def generate_pywalfox_json(theme_css_path, quiet=False):
    if not PATHS["pywal_cache"].exists():
        log("WARNING: pywal cache not found", quiet)
        return

    text = load_text(theme_css_path)
    bg = re.search(r"@define-color\s+background\s+(#[0-9A-Fa-f]{6})", text)
    fg = re.search(r"@define-color\s+(?:color15|foreground)\s+(#[0-9A-Fa-f]{6})", text)
    bg_value = bg.group(1) if bg else "#000000"
    fg_value = fg.group(1) if fg else "#ffffff"
    colors = {}
    for i in range(16):
        key = f"color{i}"
        match = re.search(rf"@define-color\s+{re.escape(key)}\s+(#[0-9A-Fa-f]{{6}})", text)
        colors[key] = match.group(1) if match else (bg_value if i == 0 else "#000000")

    wal_json = PATHS["pywal_cache"] / "colors.json"
    payload = {
        "wallpaper": str(DEFAULT_WALLPAPER_PATH),
        "special": {"background": bg_value, "foreground": fg_value, "cursor": fg_value},
        "colors": colors,
    }
    if not dry_run_mode():
        PATHS["pywal_cache"].mkdir(parents=True, exist_ok=True)
        wal_json.write_text(json_dump(payload), encoding="utf-8")
        log(f"Generated {wal_json}", quiet)
        if which("pywalfox"):
            try:
                run_command(["pywalfox", "update"], capture_output=True)
                log("Updated Firefox theme via pywalfox", quiet)
            except CliError:
                log("WARNING: pywalfox failed to update", quiet)


def json_dump(payload):
    import json

    return json.dumps(payload, indent=2)


def dry_run_mode():
    return getattr(dry_run_mode, "value", False)


def update_imports(theme, dry_run=False, quiet=False):
    updates = {}
    path_updates = {
        PATHS["kitty_conf"]: (r"^include terminal-schemes/.*$", f"include terminal-schemes/{theme}.conf"),
        PATHS["waybar_css"]: (r"^@import\s+\"\.\/themes\/.*\";$", f"@import \"./themes/{theme}.css\";"),
        PATHS["swaync_css"]: (r"^@import\s+\"\.\/themes\/.*\";$", f"@import \"./themes/{theme}.css\";"),
        PATHS["wofi_css"]: (r"^@import\s+url\(.*wofi/themes/.*\);$", f"@import url('file://{PATHS['wofi_theme_dir']}/{theme}.css');"),
        PATHS["wlogout_css"]: (r"^@import\s+url\(\"themes/.*\.css\"\);$", f"@import url(\"themes/{theme}.css\");"),
    }

    for path, (pattern, replacement) in path_updates.items():
        if not path.exists():
            log(f"WARNING: path missing and skipped: {path}", quiet)
            continue
        original = load_text(path)
        updated, count = re.subn(pattern, replacement, original, flags=re.MULTILINE)
        if count == 0:
            log(f"WARNING: no import line found in {path}", quiet)
        if updated != original:
            updates[path] = updated

    return apply_text_updates(updates, dry_run=dry_run)


def parse_waypaper_wallpaper(config_path, quiet=False):
    text = load_text(config_path)
    match = re.search(r"^\s*wallpaper\s*=\s*(?:\"|')?(.*?)(?:\"|')?\s*$", text, flags=re.MULTILINE)
    if not match:
        raise CliError(f"No wallpaper line found in {config_path}")
    wallpaper = Path(match.group(1).strip()).expanduser()
    if not wallpaper.is_absolute():
        wallpaper = (config_path.parent / wallpaper).resolve()
    if not wallpaper.exists():
        raise CliError(f"Wallpaper path does not exist: {wallpaper}")
    log(f"Selected wallpaper: {wallpaper}", quiet)
    return wallpaper


def wait_for_waypaper_config(config_path, quiet=False, timeout=120):
    # Wait for the waypaper config to be modified (or created). Prefer inotifywait if available.
    if which("inotifywait"):
        try:
            run_command(["inotifywait", "-q", "-e", "close_write,modify", str(config_path)], capture_output=True, check=False, timeout=timeout)
            return
        except subprocess.TimeoutExpired:
            raise CliError("Timed out waiting for waypaper to save config")

    # Fallback: poll for mtime change or file creation
    deadline = time.time() + timeout
    initial_mtime = None
    if config_path.exists():
        try:
            initial_mtime = config_path.stat().st_mtime
        except Exception:
            initial_mtime = None

    while time.time() < deadline:
        if not config_path.exists():
            time.sleep(0.5)
            continue
        try:
            mtime = config_path.stat().st_mtime
        except Exception:
            mtime = None
        if initial_mtime is None or (mtime is not None and mtime != initial_mtime):
            return
        time.sleep(0.5)

    raise CliError("Timed out waiting for waypaper config file to be written/modified")


def ensure_directory(path):
    path.mkdir(parents=True, exist_ok=True)


def apply_pywal_theme(quiet=False, dry_run=False, force=False):
    if which("waypaper") is None:
        raise CliError("waypaper is required for the pywal workflow")
    if which("wal") is None:
        raise CliError("pywal (wal) is required for the pywal workflow")

    config_path = PATHS["waypaper_config"]
    if not config_path.exists():
        raise CliError(f"Waypaper config missing: {config_path}")

    start_waypaper = force or not is_running("waypaper")
    process = None
    try:
        if dry_run:
            log("Dry-run: would open waypaper and run pywal on selected wallpaper", quiet)
            # Attempt to report current wallpaper if possible
            if PATHS["waypaper_config"].exists():
                try:
                    wallpaper = parse_waypaper_wallpaper(PATHS["waypaper_config"], quiet=quiet)
                    log(f"Dry-run selected wallpaper: {wallpaper}", quiet)
                except CliError:
                    pass
            return

        if start_waypaper:
            process = subprocess.Popen(["waypaper"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            log("Started waypaper for wallpaper selection", quiet)
            log("Please select a wallpaper in Waypaper (script will wait for the change)", quiet)

        wait_for_waypaper_config(config_path, quiet=quiet)
        wallpaper = parse_waypaper_wallpaper(config_path, quiet=quiet)
        run_command(["wal", "-i", str(wallpaper), "--backend", "hex", "--saturate", "0.7"], capture_output=True)

        app_css = PATHS["pywal_cache"] / "colors-apps.css"
        kitty_conf = PATHS["pywal_cache"] / "colors-kitty.conf"
        if not app_css.exists() or not kitty_conf.exists():
            raise CliError("pywal did not generate the expected cache files")

        for target_dir in [PATHS["waybar_theme_dir"], PATHS["swaync_theme_dir"], PATHS["wofi_theme_dir"]]:
            ensure_directory(target_dir)
            shutil.copy2(app_css, target_dir / f"{PYWAL_THEME_NAME}.css")
            log(f"Copied pywal theme to {target_dir}", quiet)

        ensure_directory(PATHS["kitty_schemes"])
        shutil.copy2(kitty_conf, PATHS["kitty_schemes"] / f"{PYWAL_THEME_NAME}.conf")
        log(f"Copied pywal Kitty theme to {PATHS['kitty_schemes']}", quiet)

    finally:
        if process is not None and process.poll() is None:
            process.terminate()
            time.sleep(0.5)
            if process.poll() is None:
                process.kill()


def apply_theme(theme, args):
    if theme == PYWAL_THEME_NAME:
        apply_pywal_theme(quiet=args.quiet, dry_run=args.dry_run, force=getattr(args, 'force_waypaper', False))
    diffs = update_imports(theme, dry_run=args.dry_run, quiet=args.quiet)
    for diff in diffs:
        print(diff, end="")

    if args.dry_run:
        return

    PATHS["current_theme"].write_text(theme + "\n", encoding="utf-8")
    theme_css = PATHS["waybar_theme_dir"] / f"{theme}.css"
    if theme == PYWAL_THEME_NAME and not theme_css.exists():
        theme_css = PATHS["waybar_theme_dir"] / f"{PYWAL_THEME_NAME}.css"

    if theme_css.exists():
        update_hypr_border_colors(theme_css, quiet=args.quiet)
        update_hyprlock_colors(theme_css, quiet=args.quiet)
        generate_pywalfox_json(theme_css, quiet=args.quiet)
    else:
        log(f"WARNING: theme CSS not found: {theme_css}", args.quiet)

    if which("kitty") and which("pkill") and is_running("kitty"):
        run_command(["pkill", "-SIGUSR1", "kitty"], capture_output=True)
        log("Signaled Kitty to reload", args.quiet)

    if which("swaync"):
        subprocess.run(["killall", "swaync"], check=False)
        time.sleep(0.5)
        subprocess.Popen(["swaync"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        log("Restarted SwayNC", args.quiet)

    if which("pywalfox"):
        try:
            run_command(["pywalfox", "update"], capture_output=True)
            log("Updated Firefox via pywalfox", args.quiet)
        except CliError:
            log("WARNING: pywalfox update failed", args.quiet)

    if which("notify-send"):
        subprocess.run(["notify-send", "Theme Applied", f"{theme} has been activated."], check=False)


def main():
    args = parse_arguments()
    dry_run_mode.value = args.dry_run

    if args.remove_theme:
        remove_theme(args.remove_theme, args)
        return

    if args.import_theme:
        import_theme_yaml(args.import_theme, args)
        return

    if args.list:
        themes = available_themes()
        print("\n".join(themes))
        return

    # If user requested waypaper -> pywal workflow, force pywal theme
    if args.waypaper_pywal:
        if not can_use_pywal():
            raise CliError("Waypaper+pywal workflow not available on this system")
        theme = PYWAL_THEME_NAME
        log("Applying waypaper -> pywal workflow", args.quiet)
        apply_theme(theme, args)
        return

    themes = available_themes()
    if args.theme:
        theme = args.theme
        if theme not in themes:
            raise CliError(f"Theme '{theme}' is not available")
    else:
        style = "wofi" if args.wofi else ("menu" if args.menu else "fuzzy")
        theme = choose_theme_interactive(themes, style, quiet=args.quiet)

    if theme not in themes:
        raise CliError(f"Theme '{theme}' is not available")

    log(f"Applying theme: {theme}", args.quiet)
    diffs = []
    try:
        if args.dry_run:
            apply_theme(theme, args)
            return

        if not args.yes and args.theme:
            print("WARNING: no --yes supplied; confirmation will be requested")

        apply_theme(theme, args)

    except CliError as exc:
        error(str(exc))


if __name__ == "__main__":
    try:
        main()
    except CliError as exc:
        error(str(exc))
