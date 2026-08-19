# Maestria agent permissions - custom override guide

## Why this exists

`@maestria/opencode` loads its agent definitions from `.md` files inside the plugin
package (`node_modules/@maestria/opencode/agents/*.md`) and merges them ON TOP of
your `opencode.jsonc` config (`merge(e.agent, pluginAgents)` in `dist/index.js`).
So permissions in `opencode.jsonc` CANNOT override the plugin's - only the plugin
files themselves win. That is why these files are edited in place.

## When to re-apply

Every time the maestria plugin is updated or reinstalled (`opencode plugin
@maestria/opencode@latest --global`), the package is re-fetched and the edits are
wiped. Check with:

```sh
ls -l ~/.cache/opencode/packages/@maestria/opencode@*/node_modules/@maestria/opencode/agents/
```

If the git/rtk/just/uv lines are missing, re-apply the script below.

## How opencode evaluates permissions

From the bundled source, `evaluate()` uses `findLast` over the rule list: the LAST
matching rule wins, and rules are built in file order (`Object.entries`). Two
consequences:

1. The catch-all (`"*": ask` / `"*": deny`) MUST come FIRST in the bash block, or
   it swallows every specific allow below it.
2. A deny placed after an allow wins - this is how force-push/reset--hard are
   blocked even though `git*` is allowed.

## The patch

```sh
python3 - <<'EOF'
import pathlib, re

base = pathlib.Path(
  [p for p in pathlib.Path.home().glob(
    ".cache/opencode/packages/@maestria/opencode@*/node_modules/@maestria/opencode/agents"
  )][0]
)

BLOCK = """  bash:
    "*": {fallback}
    ls*: allow
    cat*: allow
    echo*: allow
    head*: allow
    tail*: allow
    grep*: allow
    rg*: allow
    wc*: allow
    which*: allow
    diff*: allow
    stat*: allow
    du*: allow
    pwd*: allow
    cd*: allow
    find*: allow
    printf*: allow
    sort*: allow
    test*: allow
    env: allow
    git*: allow
    git push --force*: deny
    git push -f*: deny
    git reset --hard*: deny
    git clean*: deny
    git checkout --*: deny
    git branch -D*: deny
    git stash drop*: deny
    git rm*: deny
    rtk*: allow
    just*: allow
    uv*: allow
    uvx*: allow
    python*: allow
    python3*: allow
    pytest*: allow
    ruff*: allow
    basedpyright*: allow
    pnpm*: allow
    npm*: allow
    npx*: allow
    vitest*: allow
    tsc*: allow
    eslint*: allow
    prettier*: allow
    node*: allow
    mkdir*: allow
"""

EXTRA = {
  "adventurer": ("ask", "    opensrc*: allow\n    agent-browser*: allow\n"),
  "architect":  ("ask", "    opensrc*: allow\n"),
  "builder":    ("ask", "    vp*: allow\n    pnpx*: ask\n"),
  "diagnose":   ("ask", "    git blame*: allow\n"),
  "planner":    ("ask", ""),
  "reviewer":   ("ask", "    vp*: allow\n"),
  "writer":     ("ask", "    vp*: allow\n"),
  "orchestrator": ("deny", '    "* npx --yes skills@latest *": allow\n'),
}

rex = re.compile(r"^  bash:\n(?:    [^\n]*\n)+", re.M)
for name, (fallback, extra) in EXTRA.items():
    f = base / f"{name}.md"
    text = f.read_text()
    text, n = rex.subn(BLOCK.format(fallback=fallback) + extra, text, count=1)
    assert n == 1, f"{name}: no bash block found"
    f.write_text(text)
    print(f"patched {name}")
EOF
```

## Verify

```sh
opencode debug config          # loads, agents registered
# or, for each agent file, confirm the catch-all is the FIRST bash entry:
sed -n '/^permission:/,/^---$/p' agents/builder.md | rtk grep -A1 "^  bash:"
```

## Agent summary (non-bash perms untouched)

| agent | edit | bash catch-all |
| --- | --- | --- |
| orchestrator | deny | deny |
| adventurer | deny | ask |
| architect | deny | ask |
| builder | allow | ask |
| diagnose | allow | ask |
| planner | ask | ask |
| reviewer | deny | ask |
| writer | allow | ask |
