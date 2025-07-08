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
