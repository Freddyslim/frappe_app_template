# Workflow Templates

This repository provides minimal GitHub Actions workflows that you can reuse in your own app projects. They live in the `workflow_templates/` folder.

- **`ci.yml`** – installs Python dependencies and acts as a starting point for custom CI steps. Extend it with linting or packaging commands as needed.
- **`generate-mermaid.yml`** – rebuilds diagrams from `.mmd` files in `doc/` and pushes the resulting `.svg` files back to the repository.
- **`test.yml`** – runs unit tests using `pytest` and performs a simple ShellCheck on scripts.
- **`update-vendors.yml`** – keeps `vendor/` submodules in sync with `vendors.txt` and `custom_vendors.json` by running `scripts/update_vendors.sh` whenever those files change.

Copy any of these files to `.github/workflows/` in your app repository. The `setup.sh` script does this automatically when you bootstrap a new app, but you can also copy them manually and adjust branches or Python versions to your needs.
