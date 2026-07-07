#!/bin/bash
set -e

rm -rf dist

npx @marp-team/marp-cli --input-dir src -o dist --html true

find src -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o -iname "*.svg" \) | while read img; do
  relpath="${img#src/}"
  mkdir -p "dist/$(dirname "$relpath")"
  cp "$img" "dist/$relpath"
done

echo "Build concluído! HTML em dist/"
