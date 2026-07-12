#!/usr/bin/env node

import { chromium } from "playwright";
import { readFile, writeFile, mkdir } from "node:fs/promises";
import { dirname } from "node:path";

const URL = "https://markdowntoword.io/tools/markdown-to-pdf";

async function convertMdToPdf(inputPath, outputPath) {
  const markdown = await readFile(inputPath, "utf-8");

  const browser = await chromium.launch({ headless: true });
  const context = await browser.newContext({
    acceptDownloads: true,
    viewport: { width: 1280, height: 900 },
  });
  const page = await context.newPage();

  try {
    await page.goto(URL, { waitUntil: "networkidle", timeout: 30000 });

    const textarea = page.locator("textarea");
    await textarea.fill(markdown);

    const downloadButton = page.getByRole("button", { name: /download as pdf/i });
    await downloadButton.waitFor({ state: "visible", timeout: 10000 });
    await downloadButton.waitFor({ state: "attached", timeout: 10000 });

    await page.waitForFunction(
      () => {
        const btn = [...document.querySelectorAll("button")].find(
          (b) => /download as pdf/i.test(b.textContent)
        );
        return btn && !btn.disabled;
      },
      { timeout: 15000 }
    );

    const [download] = await Promise.all([
      page.waitForEvent("download", { timeout: 30000 }),
      downloadButton.click(),
    ]);

    await mkdir(dirname(outputPath), { recursive: true });
    await download.saveAs(outputPath);

    console.log(`PDF gerado: ${outputPath}`);
  } finally {
    await browser.close();
  }
}

const [, , inputArg, outputArg] = process.argv;

if (!inputArg || !outputArg) {
  console.error("Uso: node scripts/md-to-pdf.mjs <input.md> <output.pdf>");
  process.exit(1);
}

convertMdToPdf(inputArg, outputArg).catch((err) => {
  console.error("Erro na conversão:", err.message);
  process.exit(1);
});
