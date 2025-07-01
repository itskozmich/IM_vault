#!/bin/bash

CONTENT_DIR="content"
INDEX_FILE="$CONTENT_DIR/index.md"
COUNT=10

# Vytvoř blok s nadpisem a nejnovějšími poznámkami
latest_content=$( \
  echo "## 🧭 Poslední stopy ve vaultu" && echo "" && \
  find "$CONTENT_DIR" -type f -name "*.md" \
    ! -name "index.md" \
    ! -name "latest.md" \
    ! -name ".latest.md" \
    -printf "%T@ %p\n" | sort -nr | head -n "$COUNT" | while read -r line; do
      FILE_PATH=$(echo "$line" | cut -d' ' -f2-)
      REL_PATH=${FILE_PATH#"$CONTENT_DIR"/}
      MOD_DATE=$(date -d @"$(stat -c %Y "$FILE_PATH")" +"%Y-%m-%d")
      echo "- [[${REL_PATH%.md}]] – \`$MOD_DATE\`"
  done \
)

# Vlož nový obsah do index.md
awk -v new_block="$latest_content" '
  BEGIN { in_latest = 0 }
  /<!--LATEST-->/ {
    print
    print new_block
    in_latest = 1
    next
  }
  /<!--ENDLATEST-->/ {
    in_latest = 0
  }
  !in_latest
' "$INDEX_FILE" > "$INDEX_FILE.tmp" && mv "$INDEX_FILE.tmp" "$INDEX_FILE"
