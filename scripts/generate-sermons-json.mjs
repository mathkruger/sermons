#!/usr/bin/env node

import { readdir, readFile, writeFile } from "node:fs/promises";
import { join } from "node:path";

const SRC_DIR = new URL("../src/", import.meta.url).pathname;
const DIST_DIR = new URL("../dist/", import.meta.url).pathname;

const STOP_WORDS = new Set(["a", "o", "e", "da", "de", "do", "em", "que", "se", "para"]);

function slugToTitle(slug) {
  return slug
    .split("-")
    .map((word) => {
      if (STOP_WORDS.has(word)) return word;
      return word.charAt(0).toUpperCase() + word.slice(1);
    })
    .join(" ");
}

function stripFrontmatter(content) {
  if (!content.startsWith("---")) return content;
  const end = content.indexOf("\n---", 3);
  if (end === -1) return content;
  return content.slice(end + 4);
}

async function extractTitle(entry) {
  const files = await readdir(join(SRC_DIR, entry));
  const md =
    files.find((f) => f === "index.md") ||
    files.find((f) => f.endsWith(".md") && f !== "sermao-texto.md");

  if (md) {
    const content = await readFile(join(SRC_DIR, entry, md), "utf-8");
    const body = stripFrontmatter(content);
    const match = body.match(/^#\s+(.+)$/m);
    if (match) return match[1].trim();
  }
  return slugToTitle(entry);
}

const entries = await readdir(SRC_DIR, { withFileTypes: true });
const sermons = [];

for (const entry of entries) {
  if (!entry.isDirectory()) continue;
  const dir = join(SRC_DIR, entry.name);
  const files = await readdir(dir);

  const hasPresentation = files.some(
    (f) => f === "index.md" || (f.endsWith(".md") && f !== "sermao-texto.md")
  );
  const hasPdf = files.includes("sermao-texto.md");

  if (!hasPresentation && !hasPdf) continue;

  sermons.push({
    id: entry.name,
    title: await extractTitle(entry.name),
    presentation: hasPresentation,
    pdf: hasPdf,
  });
}

sermons.sort((a, b) => a.title.localeCompare(b.title));

await writeFile(
  join(DIST_DIR, "sermons.json"),
  JSON.stringify(sermons, null, 2) + "\n",
  "utf-8"
);

console.log(`sermons.json gerado com ${sermons.length} sermões`);
