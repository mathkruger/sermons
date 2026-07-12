---
name: sermao-apresentacao
description: Use ONLY when the user asks to create a presentation/slides ("apresentação", "slides", "slide") from an existing sermon document ("sermão", "sermao"). This skill reads a sermao-texto.md file and generates a Marp presentation with images using the Marp MCP tools.
---

# Sermão Adventista - Geração da Apresentação

Você é um especialista em criar apresentações Marp para sermões adventistas. Dado um documento `sermao-texto.md` existente, você o transformará em uma apresentação visual com imagens.

## Pré-requisito

O arquivo `sermao-texto.md` deve existir em `src/<nome-do-sermao>/`. Se o usuário não especificar o caminho, pergunte qual sermão deseja transformar em apresentação.

## Workflow

### Passo 1: Ler o Documento
Leia o arquivo `sermao-texto.md` do sermão desejado. Identifique:
- Título do sermão
- Seções principais (introdução, pontos de desenvolvimento, conclusão)
- Versículos-chave de cada seção
- Tabela de versículos (se houver)

### Passo 2: Inicializar a Apresentação
1. Chame `set_frontmatter` com:
   - `theme: "gaia"`
   - `paginate: true`
   - `header: "<Título do Sermão>"`
2. Chame `create_presentation` com:
   - `filePath: "src/<nome-do-sermao>/index.md"`
   - `title: "<Título do Sermão>"`
   - `slideCount: 0`

### Passo 3: Gerar IDs
Chame `generate_slide_ids` para atribuir UUIDs estáveis aos slides.

### Passo 4: Buscar Imagens com Unsplash
Use o MCP `unsplash` (ferramenta `search_photos`) para encontrar imagens de fundo:
- Faça uma busca para cada slide principal, com query relacionada ao tema
- Use `orientation: "landscape"` para melhor encaixe nos slides
- Salve as imagens em `src/<nome-do-sermao>/images/` seguindo o padrão `image-01.jpg`, `image-02.jpg`, etc.

### Passo 5: Construir Slides
Adicione slides com `manage_slide`, `mode: "insert"`, `position: "end"`.

Estrutura típica de slides para sermões:

| Slide | Conteúdo | Observação |
|-------|----------|------------|
| 1 | **Título** | `layoutType: "title"` — título, versículo central, imagem de fundo |
| 2 | **Introdução** | Resumo do tema e conexão com a vida |
| 3-N | **Pontos principais** | Um slide por ponto/versículo-chave |
| N+1 | **Aplicação** | Desafio prático |
| N+2 | **Conclusão** | Apelo à decisão |

Para cada slide, inclua imagem de fundo com `![bg cover](images/image-NN.jpg)`.

### Passo 6: Apresentar ao Usuário
Após criar os slides, leia o conteúdo final com `read_slide` e apresente um resumo ao usuário.

## Regras Importantes

- **Sem export HTML**: Este projeto possui pipeline de build próprio. Não chame `export_slide`.
- **Slides sem estilos customizados**: Use apenas as classes nativas `lead` e `invert` do tema gaia (`_class: lead` ou `_class: invert`). Não adicione estilos CSS customizados, `style` tags, ou classes não padrão.
- **Imagens de fundo**: Use `![bg cover](images/image-NN.jpg)` sem filtros de brilho ou ajustes customizados.
- **Um slide = uma ideia**: Mantenha cada slide conciso.
- **Versículos**: Inclua o texto bíblico resumido com referência em cada slide.
- **Citações de Ellen G. White**: Não inclua nestes slides (elas ficam apenas no documento texto).
- **Layouts variados**: Use `title`, `section`, `list`, `content`, `quote`, `two-column` conforme o conteúdo.
