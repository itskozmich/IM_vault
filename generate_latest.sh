#!/bin/bash

CONTENT_DIR="content"
INDEX_FILE="$CONTENT_DIR/index.md"
TEMP_FILE="$(mktemp)"
COUNT=5

# Vygeneruj nový obsah
{
  echo "<!--LATEST-->"
  echo "## 🧭 Poslední stopy ve vaultu"
  echo ""
  find "$CONTENT_DIR" -type f -name "*.md" \
    ! -name "index.md" \
    ! -name "latest.md" \
    -printf "%T@ %p\n" | sort -nr | head -n "$COUNT" | while read -r line; do
    FILE_PATH=$(echo "$line" | cut -d' ' -f2-)
    REL_PATH=${FILE_PATH#"$CONTENT_DIR"/}
    MOD_DATE=$(date -d @"$(stat -c %Y "$FILE_PATH")" +"%Y-%m-%d")
    echo "- [[${REL_PATH%.md}]] – \`$MOD_DATE\`"
  done
  echo "<!--ENDLATEST-->"
} > "$TEMP_FILE"

# Nahraď obsah mezi LATEST blokem
awk -v new="$(cat "$TEMP_FILE")" '
  BEGIN { in_block = 0 }
  /<!--LATEST-->/ {
    print new
    in_block = 1
    next
  }
  in_block && /<!--ENDLATEST-->/ {
    in_block = 0
    next
  }
  !in_block { print }
' "$INDEX_FILE" > "$INDEX_FILE.tmp" && mv "$INDEX_FILE.tmp" "$INDEX_FILE"

rm "$TEMP_FILE"
