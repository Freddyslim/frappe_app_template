# Repository Cleanup Summary

This document lists major files and directories that were removed or replaced while streamlining the template repository.

## Removed

- **erpnext_app_template/** – outdated ERPNext example including documentation and tests
- **apps/my_custom_app/** – placeholder app with demo DocType
- **vendor-repos.txt** and **template-repos.txt** – replaced by **vendors.txt** and **vendor_profiles/**
- **tests/** – initial test suite removed to simplify the template
- **patch** – unused patch file deleted
- **testapp/** – earlier scaffold for example app

## Replaced

- **codex_prompt.md** → consolidated into `instructions/prompts.md`
- **.github/workflows/create-app-repo.yml** → renamed to `create-app-folder.yml`

These changes keep the repository minimal and focus on configuration files that Codex can apply to new projects.
