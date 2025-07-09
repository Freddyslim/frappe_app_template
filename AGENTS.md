# AGENTS.md

## Purpose

This document serves as an AI-readable knowledge base for Codex and other LLMs to assist in the structured and sustainable development of Frappe apps. It assumes that each project is based on the `frappe_app_template` structure and contains a `vendor/` folder with all relevant vendor copies (e.g., `frappe`, `bench`, `erpnext`, etc.).

## Overview

Every Frappe app built with this template should follow a strict and modular layout that supports:

- Codex code generation
- Maintainability
- Compatibility with the official Frappe ecosystem
- Explicit vendor tracking and version control

## Key Instructions

### 1. Project Structure

Make sure the following folders exist at the root of your app repository:

- `/app/<app_name>`: Your Frappe app (generated with `bench new-app`)
- `/vendor/<vendor_name>`: A full copy of each upstream dependency (e.g. `frappe`, `erpnext`, `bench`)
- `/instructions/`: AI-readable guidance files for Codex (like this one)
- `/scripts/`: Shell/Python scripts for automation
- `/doc/`: Developer documentation
- `/sample_data/`: Example records for import

### 2. Vendor Usage

Codex is expected to reference vendor copies under `vendor/`. Always keep vendor code up to date and accessible. Avoid remote calls when referencing internal Frappe functions — Codex should resolve them locally using the vendor files.

```text
vendor/
├── frappe/
├── bench/
└── erpnext/
```

### 3. Coding Guidelines

- Use consistent syntax and proper indentation throughout the codebase.  
- Keep comments concise but meaningful — especially for Codex-relevant logic.  
- Name functions, classes, and variables clearly and descriptively.  
- Prefer official Frappe APIs and patterns to maximize compatibility.  
- Avoid global side effects where possible; favor pure functions.  
- **All backend elements — including Doctype names, fieldnames, method names, script comments, and other technical identifiers — must always be written in English.**  
  Likewise, all **frontend labels and content** that appear in ERPNext/Frappe must also use English as the default language.  
  → **Translations should later be handled exclusively via ERPNext’s built-in translation mechanisms.**  
- **At the end of every code generation or modification step, all created files must be automatically checked for correct syntax according to their respective language.**  
  This ensures that Codex and other LLMs always work with valid, parseable input without syntax errors or formatting issues.
