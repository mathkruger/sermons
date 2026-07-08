# Sermões

Apresentações de sermões em slides criadas com [Marp](https://marp.app/).

## Estrutura

```
src/               — Sermões em Markdown (formato Marp)
dist/              — HTML gerado após build
build.sh           — Script de build (Marp CLI + assets)
.opencode/         — Configuração e skills do opencode
```

## Sermões

| Título | Descrição |
|--------|-----------|
| Comunidade | |
| Gaby — Mulheres que Marcaram o Céu e a Terra | |
| O Amor Divino | |
| O Maior Presente | |
| Os 8 Remédios Naturais | |
| Quando Tudo Ainda é Pouco | |

## Uso

```bash
npm install
npm run build
```

O HTML gerado estará em `dist/`.

## Deploy

O envio para `main` aciona o GitHub Actions que faz build e publica via GitHub Pages.

## Gerar novos sermões com opencode

Este repositório conta com uma skill do [opencode](https://opencode.ai/) chamada **sermao-adventista**, que pesquisa o tema na web, estrutura o conteúdo segundo a teologia adventista e gera uma apresentação completa em Marp.

Atalho: `Ctrl/Cmd + Shift + P` → "opencode: Add Skill Files to Workspace"

### MCPs utilizados

| Servidor | Finalidade |
|----------|------------|
| [`duckduckgo-mcp-server`](https://www.npmjs.com/package/duckduckgo-mcp-server) | Pesquisa web para embasamento bíblico e teológico |
| [`@jeff_kit/unsplash-mcp-server`](https://www.npmjs.com/package/@jeff_kit/unsplash-mcp-server) | Busca de imagens no Unsplash para os slides |
| [`@masaki39/marp-mcp`](https://www.npmjs.com/package/@masaki39/marp-mcp) | Criação e manipulação de slides Marp via MCP |
