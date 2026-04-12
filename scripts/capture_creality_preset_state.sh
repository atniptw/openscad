#!/usr/bin/env bash
set -euo pipefail
ROOT="/Users/tom/Library/Application Support/Creality/Creality Print/7.0"
OUT_DIR="/Users/tom/Projects/openscad/profiles/creality/state-captures"
mkdir -p "$OUT_DIR"
STAMP="$(date +%Y%m%d-%H%M%S)"
OUT="$OUT_DIR/$STAMP"
mkdir -p "$OUT"

cp "$ROOT/Creality.conf" "$OUT/Creality.conf"
find "$ROOT/user/default" -type f \( -name '*.json' -o -name '*.info' \) -print | sort > "$OUT/user-default-files.txt"

while IFS= read -r f; do
  rel="${f#"$ROOT/"}"
  dst="$OUT/$rel"
  mkdir -p "$(dirname "$dst")"
  cp "$f" "$dst"
done < "$OUT/user-default-files.txt"

echo "$OUT"
