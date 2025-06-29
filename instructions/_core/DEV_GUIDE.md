# Development Instructions

This directory contains additional notes for Frappe and ERPNext. For the
automation guidelines used by Codex see `../DEV_INSTRUCTIONS.md`.

1. Default versions for Frappe and Bench reside in `../apps.json`.
2. List active vendor slugs in `../vendors.txt`. Passende Profil-Dateien liegen
   unter `../vendor_profiles/<kategorie>/<slug>.json`.
3. The *update-vendors* workflow clones all listed repositories and refreshes
   `apps.json`. Run
   `../setup.sh` locally if you want to perform the same steps manually.
4. The `CI` workflow only installs dependencies and runs tests. It no longer
   executes `../setup.sh` automatically.
5. Store JSON example files and API docs in `../sample_data` when needed.
   The folder is indexed in `codex.json` automatically.

When template repositories are included, consult their `DEV_INSTRUCTIONS.md` or
`instructions/` folders in addition to this documentation.

Refer to the following guides for framework-specific tips:

- [Frappe Notes](./frappe.md)
- [ERPNext Notes](./erpnext.md)
- [Using the Template as a Submodule](./submodule_usage.md)
- [Repository Management Notes](./repo_mgmt.md)
