#!/bin/bash
set -e

rm -rf dist

for sermon_dir in src/*/; do
  sermon_name=$(basename "$sermon_dir")

  presentation_md=""
  if [ -f "$sermon_dir/index.md" ]; then
    presentation_md="$sermon_dir/index.md"
  else
    presentation_md=$(find "$sermon_dir" -maxdepth 1 -name "*.md" ! -name "sermao-texto.md" | head -n 1)
  fi

  if [ -n "$presentation_md" ]; then
    mkdir -p "dist/$sermon_name"
    npx @marp-team/marp-cli "$presentation_md" -o "dist/$sermon_name/index.html" --html true
  fi

  if [ -f "$sermon_dir/sermao-texto.md" ]; then
    mkdir -p "dist/$sermon_name"
    node scripts/md-to-pdf.mjs "$sermon_dir/sermao-texto.md" "dist/$sermon_name/sermao-texto.pdf"
  fi
done

find src -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o -iname "*.svg" \) | while read img; do
  relpath="${img#src/}"
  mkdir -p "dist/$(dirname "$relpath")"
  cp "$img" "dist/$relpath"
done

cp src/index.html dist/index.html
node scripts/generate-sermons-json.mjs

echo "Build concluído! HTML e PDF em dist/"
