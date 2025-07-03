### Frappe App Dev Setup Template

This repository is a master template for Codex-enabled Frappe apps. It automates project structure, git setup and vendor management so new apps can be created quickly and consistently.

### Installation

Clone `frappe_app_template` to `/home/frappe/frappe-bench`:

```bash
cd /home/frappe/frappe-bench
git clone git@github.com:mygithubacc/frappe_app_template.git
```

Then run the setup script directly from within the `frappe-bench` directory:

```bash
./frappe_app_template/setup.sh my_app
```

The script will:

* use `bench new-app` to generate a new Frappe app under `apps/my_app/` (you will be prompted interactively)
* initialize a Git repository in `apps/my_app/`
* link the `frappe_app_template` as a submodule in `apps/my_app/frappe_app_template`
* copy required template files into the root of your new app (e.g. `README.md`, `.github/`, `AGENTS.md`, `instructions/`, etc.)
* prepare for GitHub push to your private repository (e.g. `github.com/mygithubacc/frappe-apps/`my\_app)

### Scripts

The `scripts/` directory contains helper tools:

* **`generate_index.py`** – builds the documentation index under `instructions/`.
  ```bash
  python scripts/generate_index.py
  ```
* **`create_index.py`** – creates a JSON mapping of files grouped by extension.
  ```bash
  python scripts/create_index.py --root . --output index.json
  ```
* **`new_frappe_app_folder.py`** – generates a minimal Frappe app skeleton.
  ```bash
  python scripts/new_frappe_app_folder.py my_app --root app
  ```


### GitHub Configuration

Important credentials, patterns and GitHub tokens should be stored in:

```bash
apps/my_app/.config/github_settings.json
```

> This file is ignored by git and allows central control of all secrets and GitHub-specific parameters.

### Project Structure

```bash
/home/frappe/frappe-bench/
└── apps/
    └── my_app/
        ├── my_app/                        # Frappe app code
        ├── instructions/                  # app instructions
        │   └── AGENTS.md              # project-specific guidance
        ├── frappe_app_template -> /opt/git/frappe_app_template  # submodule link
        ├── vendor/                        # vendor submodules
        │   ├── erpnext/
        │   └── nextcloud/
        ├── doc/                           # technical documentation
        ├── AGENTS.md                      # main Codex agent file
        ├── README.md                      # project documentation
        ├── apps.json                      # list of submodules
        ├── custom_vendors.json            # custom vendor definitions
        ├── vendors.txt                    # common vendors
        ├── .github/
        │   └── workflows/
        │       ├── ci.yml
        │       ├── update-vendors.yml
        │       └── validate_commits.yml
        └── .config/github_api.json        # local configuration (not tracked)
```

Each vendor used by your app has a dedicated folder under `instructions/vendor_profiles/<category>/<slug>/`.
The folder contains an `apps.json` with repository information and an `AGENTS.md` for vendor-specific notes.
Run `./scripts/update_vendors.sh` after editing these profiles.

### Contributing

Install [pre-commit](https://pre-commit.com/) and enable it in your app directory:

```bash
pre-commit install
```

Our pre-configured hooks format code automatically using:

* ruff (Python)
* eslint (JavaScript)
* prettier (Markdown, HTML, etc.)
* pyupgrade (Python modernizer)

### CI & Automation

This template comes with GitHub Actions workflows for:

* CI testing
* automated vendor submodule updates
* commit linting and validation

### License

MIT

---

For full Codex compatibility and developer productivity, follow the structural conventions and use the agent files provided.

### How to Code

Follow these active agent instructions:

- Remove helper files once they are no longer needed.
- Keep workflows, scripts and configuration consistent with this README and AGENTS.md.
- Update existing files if they drift from the documented structure.
- Keep README.md and AGENTS.md synchronized.
- Vendor-specific AGENTS.md files can override these rules.

Supported flags:

- `--no-agent` – use the prompt as the main instruction set.
- `--create-tasks` – output tasks without changing code.
- `--start` – (re)initialize the project according to the agent files.

