#!/usr/bin/env bash
# Memoirs of Technoir — serve HTML5 build (optional Godot export).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$ROOT/build/web"
PORT="${PORT:-8060}"
GODOT_BIN="${GODOT:-godot}"

if [[ "${1:-}" == "--export" ]]; then
  mkdir -p "$OUT"
  "$GODOT_BIN" --headless --path "$ROOT" --export-release "Web" "$OUT/index.html"
fi

if [[ ! -f "$OUT/index.html" ]]; then
  echo "Missing $OUT/index.html — export Web preset from Godot first (or pass --export)."
  exit 1
fi

echo "Serving $OUT on http://127.0.0.1:$PORT/"
cd "$OUT"
if command -v python3 >/dev/null; then
  python3 -m http.server "$PORT"
elif command -v python >/dev/null; then
  python -m http.server "$PORT"
else
  npx --yes serve -l "$PORT" .
fi
