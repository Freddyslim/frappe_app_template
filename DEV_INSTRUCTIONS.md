# Developer Instructions for Codex

This repository uses Codex for automated code generation. These guidelines tell Codex how to work with the project.

## Setup

1. Versions for Frappe and Bench are defined in `apps.json`.
2. Maintain active vendor integrations in `vendors.txt`. Each slug must have a
   corresponding JSON file under `vendor_profiles/<category>/<slug>.json` which
   defines repository URL and branch or tag.
3. The *update-vendors* workflow clones all repositories listed in
   `vendors.txt` and regenerates `apps.json`. Run `./setup.sh` locally for the same
    effect (requires `jq`).
4. The CI workflow only installs dependencies and runs tests. It no longer
   runs `./setup.sh` automatically.
5. Example payloads or external API docs belong in `sample_data/`.
6. If you include template repositories (such as `template_frappe` or
   `template_erpnext`), also consult their respective `DEV_INSTRUCTIONS.md`
   files. Combine those guidelines with the instructions here.

## Repository Layout

- `app/` – custom app created in this project.
- `vendor/` – Frappe and other vendor apps managed as submodules.
- `instructions/` – framework notes for Frappe and ERPNext.
- `sample_data/` – reference payloads and docs.
- `vendors.txt` – active vendor slugs.
- `vendor_profiles/` – library of vendor profile JSON files.
- `apps.json` – default vendor apps and their versions.

## Additional Guidelines

The following tips keep all custom apps consistent:

- **App location**: place your app inside the `app/` folder.
- **Required content**: every app must include a README and a DocType named `<appname>_Globals`.
- **Documentation**: reference the notes in the `instructions/` directory for Frappe and ERPNext specifics.
- **Vendor submodules**: Add Frappe and any other framework apps under `vendor/`. Maintain slugs in `vendors.txt` and run `update_vendors.sh` to sync.

See `instructions/prompts.md` for an example prompt sequence that explains how to initialise and extend a project with Codex.
