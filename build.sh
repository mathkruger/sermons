#!/bin/bash
set -euo pipefail

SRC_DIR="src"
DIST_DIR="dist"
STATE_FILE="$DIST_DIR/.build-state.json"

FORCE=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --force)
      FORCE=1
      shift
      ;;
    *)
      echo "Uso: ./build.sh [--force]"
      echo "  --force   reconstroi todos os sermões (ignora o estado incremental)"
      exit 1
      ;;
  esac
done

hash_dir() {
  local dir="$1"
  if [ ! -d "$dir" ] || [ "$(find "$dir" -type f | wc -l)" -eq 0 ]; then
    echo ""
    return
  fi
  find "$dir" -type f -print0 | sort -z | xargs -0 sha256sum | sha256sum | awk '{print $1}'
}

build_sermon() {
  local dir="$1"
  local name="$2"

  rm -rf "$DIST_DIR/$name"
  mkdir -p "$DIST_DIR/$name"

  local presentation_md=""
  if [ -f "$dir/index.md" ]; then
    presentation_md="$dir/index.md"
  else
    presentation_md=$(find "$dir" -maxdepth 1 -name "*.md" ! -name "sermao-texto.md" | head -n 1)
  fi

  if [ -n "$presentation_md" ]; then
    npx @marp-team/marp-cli "$presentation_md" -o "$DIST_DIR/$name/index.html" --html true
  fi

  if [ -f "$dir/sermao-texto.md" ]; then
    node scripts/md-to-pdf.mjs "$dir/sermao-texto.md" "$DIST_DIR/$name/sermao-texto.pdf"
  fi
}

mkdir -p "$DIST_DIR"

TOOLS_HASH=$({ hash_dir "scripts"; sha256sum "build.sh"; sha256sum "package.json"; } | sha256sum | awk '{print $1}')

declare -A PREV_STATE
if [ -f "$STATE_FILE" ]; then
  while read -r key value; do
    [ -n "$key" ] || continue
    PREV_STATE["$key"]="$value"
  done < "$STATE_FILE"
fi

if [ "$FORCE" = 1 ] || [ "${PREV_STATE[TOOLS_HASH]:-}" != "$TOOLS_HASH" ]; then
  BUILD_ALL=1
else
  BUILD_ALL=0
fi

mapfile -t sermon_dirs < <(find "$SRC_DIR" -mindepth 1 -maxdepth 1 -type d | sort)

declare -A NEW_HASHES
REBUILT=0
KEPT=0

for dir in "${sermon_dirs[@]}"; do
  name=$(basename "$dir")
  cur_hash=$(hash_dir "$dir")
  NEW_HASHES["$name"]="$cur_hash"

  if [ "$BUILD_ALL" = 1 ] || [ "${PREV_STATE[$name]:-}" != "$cur_hash" ] || [ ! -d "$DIST_DIR/$name" ]; then
    echo ">>> Construindo: $name"
    build_sermon "$dir" "$name"
    REBUILT=$((REBUILT + 1))
  else
    echo ">>> Mantendo (sem alterações): $name"
    KEPT=$((KEPT + 1))
  fi
done

for entry in "$DIST_DIR"/*/; do
  [ -d "$entry" ] || continue
  name=$(basename "$entry")
  if [ ! -d "$SRC_DIR/$name" ]; then
    echo ">>> Removendo (não existe mais em src): $name"
    rm -rf "$entry"
  fi
done

find "$SRC_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o -iname "*.svg" \) -print0 | while IFS= read -r -d '' img; do
  relpath="${img#$SRC_DIR/}"
  dest="$DIST_DIR/$relpath"
  if [ ! -f "$dest" ] || ! cmp -s "$img" "$dest"; then
    mkdir -p "$(dirname "$dest")"
    cp "$img" "$dest"
  fi
done

cp "$SRC_DIR/index.html" "$DIST_DIR/index.html"
node scripts/generate-sermons-json.mjs

{
  echo "TOOLS_HASH $TOOLS_HASH"
  for name in "${!NEW_HASHES[@]}"; do
    echo "$name ${NEW_HASHES[$name]}"
  done
} | sort > "$STATE_FILE"

echo ""
echo "Build concluído: $REBUILT reconstruído(s), $KEPT mantido(s)."
