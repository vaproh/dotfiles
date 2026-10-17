import json
import subprocess
import sys

def main() -> None:
    target = int(sys.argv[1])
    proc = subprocess.Popen(
        ["niri", "msg", "--json", "event-stream"],
        stdout=subprocess.PIPE,
        text=True,
    )
    assert proc.stdout is not None
    for line in proc.stdout:
        line = line.strip()
        if not line:
            continue
        try:
            ev = json.loads(line)
        except json.JSONDecodeError:
            continue
        wins = []
        if "WindowOpenedOrChanged" in ev:
            wins = [ev["WindowOpenedOrChanged"]["window"]]
        elif "WindowsChanged" in ev:
            wins = ev["WindowsChanged"]["windows"]
        else:
            continue
        for w in wins:
            try:
                if w.get("workspace_id") == target and not w.get("is_floating"):
                    subprocess.run(
                        ["niri", "msg", "action", "move-window-to-floating",
                         "--id", str(w["id"])],
                        check=False,
                    )
            except Exception:
                continue

if __name__ == "__main__":
    main()
