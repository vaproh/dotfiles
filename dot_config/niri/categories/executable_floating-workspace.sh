#!/bin/bash
# Toggle workspace auto-float: float existing windows on focused workspace,
# then keep floating every new window that opens there until toggled off.
set -euo pipefail

WS=$(niri msg -j workspaces | python3 -c 'import json,sys; ws=json.load(sys.stdin); print(next(x["id"] for x in ws if x.get("is_focused")))')
PIDFILE="${XDG_RUNTIME_DIR:-/tmp}/niri-autofloat-$WS.pid"

if [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
  kill "$(cat "$PIDFILE")" 2>/dev/null || true
  rm -f "$PIDFILE"
  # Back to normal scrolling: move all floating windows here to tiling
  niri msg -j windows | python3 -c '
import json,sys,subprocess
ws_id = int(sys.argv[1])
for w in json.load(sys.stdin):
  if w.get("workspace_id") == ws_id and w.get("is_floating"):
    subprocess.run(["niri","msg","action","move-window-to-tiling","--id",str(w["id"])])
' "$WS"
  exit 0
fi

# Float all current tiling windows on this workspace
niri msg -j windows | python3 -c '
import json,sys,subprocess
ws_id = int(sys.argv[1])
for w in json.load(sys.stdin):
  if w.get("workspace_id") == ws_id and not w.get("is_floating"):
    subprocess.run(["niri","msg","action","move-window-to-floating","--id",str(w["id"])])
' "$WS"

# Background watcher: float every new window on this workspace
SCRIPT_DIR="$(dirname "$0")"
nohup python3 "$SCRIPT_DIR/floating-watcher.py" "$WS" >/tmp/niri-autofloat-$WS.log 2>&1 & echo $! > "$PIDFILE"
exit 0
