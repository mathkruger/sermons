#!/bin/bash
set -e

rm -rf dist

for sermon_dir in src/*/; do
  sermon_name=$(basename "$sermon_dir")

  if [ -f "$sermon_dir/index.md" ]; then
    mkdir -p "dist/$sermon_name"
    npx @marp-team/marp-cli "$sermon_dir/index.md" -o "dist/$sermon_name/index.html" --html true
  fi

  if [ -f "$sermon_dir/sermao-texto.md" ]; then
    mkdir -p "dist/$sermon_name"
    cat "$sermon_dir/sermao-texto.md" | npx md-to-pdf > "dist/$sermon_name/sermao-texto.pdf"
  fi
done

find src -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o -iname "*.svg" \) | while read img; do
  relpath="${img#src/}"
  mkdir -p "dist/$(dirname "$relpath")"
  cp "$img" "dist/$relpath"
done

echo "Build concluído! HTML e PDF em dist/"
