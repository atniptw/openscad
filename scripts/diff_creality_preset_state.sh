#!/usr/bin/env bash
set -euo pipefail
BASE_DIR="/Users/tom/Projects/openscad/profiles/creality/state-captures"
if [[ $# -eq 2 ]]; then
  A="$1"
  B="$2"
else
  A="$(ls -1 "$BASE_DIR" | sort | tail -n 2 | head -n 1)"
  B="$(ls -1 "$BASE_DIR" | sort | tail -n 1)"
fi

if [[ -z "${A:-}" || -z "${B:-}" ]]; then
  echo "Need two captures."
  exit 1
fi

PA="$BASE_DIR/$A"
PB="$BASE_DIR/$B"

echo "Comparing: $A -> $B"

echo "\n== Changed file list =="
diff -u "$PA/user-default-files.txt" "$PB/user-default-files.txt" || true

echo "\n== Creality.conf presets section =="
for p in ".app.sync_user_preset" ".app.preset_folder" ".presets" ".orca_presets"; do
  echo "\n--- $p (A) ---"
  jq "$p" "$PA/Creality.conf"
  echo "--- $p (B) ---"
  jq "$p" "$PB/Creality.conf"
done

echo "\n== Per-file diffs (user/default) =="
comm -12 <(sed 's#^.*/user/default/##' "$PA/user-default-files.txt" | sort) <(sed 's#^.*/user/default/##' "$PB/user-default-files.txt" | sort) | while read -r rel; do
  fa="$PA/user/default/$rel"
  fb="$PB/user/default/$rel"
  if ! cmp -s "$fa" "$fb"; then
    echo "\n--- $rel ---"
    diff -u "$fa" "$fb" || true
  fi
done
