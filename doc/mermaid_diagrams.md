# Mermaid Diagram Guide

This project uses [Mermaid](https://mermaid.js.org/) for simple architecture diagrams.

## 1. Install the CLI

```bash
npm install -g @mermaid-js/mermaid-cli
```

The CLI provides the `mmdc` command used by the helper script below.

## 2. Generate diagrams

Create `.mmd` files inside `doc/` and run:

```bash
./scripts/generate_diagrams.sh
```

Generated diagrams are written next to their source files with a `.svg` extension.

## 3. Continuous updates

A workflow template under `workflow_templates/generate-mermaid.yml` shows how to
rebuild diagrams automatically when Markdown sources change. Copy it to
`.github/workflows/` in your app repository if you want CI updates.
