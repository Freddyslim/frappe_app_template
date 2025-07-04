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
# for detailed output use --verbose
./frappe_app_template/setup.sh --verbose my_app
```

The script will:

- use `bench new-app` to generate a new Frappe app under `apps/my_app/` (you will be prompted interactively) <-- instead orphaned create_repo_folder
- initialize a Git repository in `apps/my_app/`
- link the `frappe_app_template` as a submodule in `apps/my_app/frappe_app_template`
- copy required template files into the root of your new app (e.g. `README.md`, `.github/`, `AGENTS.md`, `instructions/`, `scripts/` etc.)
- create new remote repo <path from .pre-commit-config.yaml>/my_app (is prompted interactively)
- prepare for GitHub push to your private repository (e.g. `github.com/mygithubacc/frappe-apps/`my_app (you will be prompted interactively)<-- from git hook definitions)
- pushes new generated app repo to remote develop branch

### GitHub Configuration

Important credentials, patterns and GitHub tokens should be stored in:

```bash
frappe-bench/.env
```

> This file is ignored by git and allows central control of all secrets and GitHub-specific parameters.

### Project Structure

```bash
/home/frappe/frappe-bench/
└── frappe_app_tamplate/
        ├── instructions/                  # app instructions
        │   └── AGENTS.md                  # project-specific guidance
        ├── vendor/                        # vendor submodules
        │   ├── erpnext/
        │   └── nextcloud/
        ├── doc/                           # technical documentation
        ├── AGENTS.md                      # main Codex agent file
        ├── README.md                      # project documentation
        ├── apps.json                      # contains frappe_app template vendors (frappe,bench) automatically from vendors.txt
        ├── custom_vendors.json            # empty JSON for custom vendor definitions
        ├── vendors.txt                    # common vendors
        ├── sample_data/                   # empty folder reserved for sample datasets
        ├── scripts/
        │   ├── clone_submodules.sh        # pull vendor profiles
        │   ├── remove_submodule.sh        # remove unwanted vendor
        │   ├── generate_diagrams.sh       # render Mermaid diagrams from doc/
        │   ├── update_vendors.sh          # sync vendor submodules
        │   └── publish_app.sh             # manual publish app without dev files --> create pull request with new tag <vx.x.x> auto upscaling with choice of dev-stable <vx.x.x+1>, test-stable <vx.x+1.0>, major <vx+1.0.0>
        │                                  # run with -h to see options

        ├── .github/
        │   └── workflows/
        │       ├── ci.yml
        │       ├── update-vendors.yml
        │       └── validate_commits.yml
        └── .pre-commit-config.yaml        # git hook definitions
```


```bash
branch:develop
/home/frappe/frappe-bench/
└── apps/
    └── test_application/
        ├── license.txt
        ├── pyproject.toml
        ├── README.md                        # Projektdokumentation
        ├── AGENTS.md                        # Codex-Agent Prompts (zentral)
        ├── apps.json                        # leere Datei für Vendor-Metadaten
        ├── custom_vendors.json              # leere Datei für eigene Vendoren
        ├── vendors.txt                      # Liste gebräuchlicher Vendoren (z.​​B. ERPNext, Nextcloud)
        ├── frappe_app_template              # eingebunden als submodule
        ├── vendor/                          # von frappe_app_template kopiert
        │   ├── erpnext/
        │   └── nextcloud/
        ├── instructions/                    # projektspezifische Guidance für Codex
        │   └── AGENTS.md                    # Ergänzende Anweisungen, z. B. Feature-Konventionen
        ├── doc/                             # technische Dokumentation (Markdown, Mermaid)
        ├── sample_data/                     # leerer Ordner für optionale Testdaten
        ├── scripts/                         # Hilfsskripte
        │   ├── clone_submodules.sh          # lädt vendor-Submodule aus vendors.txt/custom_vendors.json
        │   ├── remove_submodule.sh          # entfernt sauber ein Vendor-Submodul und aktualisiert apps.json
        │   ├── generate_diagrams.sh         # rendert Mermaid-Diagramme aus /doc/
        │   ├── update_vendors.sh            # synchronisiert Vendor-Submodule (zentraler Einstieg)
        │   └── publish_app.sh               # erstellt Release, Tag, PR (manuell oder CI-unterstützt)
        ├── .pre-commit-config.yaml          # Hook-Setup für git (Black, isort, etc.)
        ├── .github/
        │   └── workflows/                   # GitHub Actions CI/CD
        │       ├── ci.yml                   # CI-Tests (z. B. Bench Build)
        │       ├── update-vendors.yml       # prüft und aktualisiert Vendor-Submodule automatisch
        │       └── validate_commits.yml     # prüft Conventional Commit Messages
        ├── .config/
        │   └── github_api.json              # Lokale API Keys / Tokens (nicht versioniert)
        └── test_application/                # eigentlicher App-Code
            ├── config/
            │   └── __init__.py
            ├── hooks.py
            ├── __init__.py
            ├── modules.txt
            ├── patches.txt
            ├── public/
            │   ├── css/
            │   └── js/
            ├── __pycache__/
            │   └── __init__.cpython-311.pyc
            ├── templates/
            │   ├── includes/
            │   ├── __init__.py
            │   └── pages/
            ├── test_application/          # App-eigene Module/Doctypes etc.
            │   └── __init__.py
            └── www/                        # Web-Routen
```
```
EXAMPLE after coding and publish
branch:main
/home/frappe/frappe-bench/
└── apps/
    └── test_application/
        ├── license.txt
        ├── pyproject.toml
        ├── README.md
        └── test_application/
            ├── __init__.py
            ├── config/
            │   └── __init__.py
            ├── hooks.py
            ├── modules.txt
            ├── patches.txt
            ├── public/
            │   ├── css/
            │   │   └── custom_style.css               # eigene Styles
            │   └── js/
            │       └── custom_script.js               # global eingebundenes JS
            ├── __pycache__/
            ├── templates/
            │   ├── includes/
            │   │   └── my_include.html               # z. B. Sidebar/Buttons etc.
            │   ├── __init__.py
            │   └── pages/
            │       └── landing_page.html             # frei zugängliche Web-Seite
            ├── test_application/
            │   ├── __init__.py
            │   ├── doctype/
            │   │   ├── __init__.py
            │   │   └── projekt_auftrag/              # Beispiel-Doctype
            │   │       ├── __init__.py
            │   │       ├── projekt_auftrag.py        # Python-Controller
            │   │       ├── projekt_auftrag.json      # Meta-Definition (Feldstruktur)
            │   │       └── projekt_auftrag.js        # Client Script (optional)
            │   ├── client_script/
            │   │   └── kunde_form.js                 # dynamisches JS für Kunde-Formular
            │   ├── report/
            │   │   └── projekt_auswertung/           # Custom Report
            │   │       ├── __init__.py
            │   │       ├── projekt_auswertung.py     # Python Backend (Query Report)
            │   │       └── projekt_auswertung.json   # Report Config
            │   └── custom/
            │       └── field_fetcher.py              # Hilfsfunktionen o.ä.
            └── www/
                └── mein-tool/
                    └── index.html                    # Web-Ressource unter /mein-tool

```
Each vendor used by your app has a dedicated folder under `instructions/vendor_profiles/<category>/<slug>/`.
The folder contains an `apps.json` file with repository information and an optional `AGENTS.md` for vendor‑specific notes.

Run `./scripts/update_vendors.sh` to sync vendors. The script reads `vendors.txt` and `custom_vendors.json`, looks up the matching profiles and adds each repository as a submodule under `vendor/`. If a vendor repository is private, provide a `GITHUB_TOKEN` or `API_KEY` in `.env` or `.config/github_api.json` so the script can clone it. Submodules that no longer appear in the lists are removed and `apps.json` is rewritten with the current metadata.

The `update-vendors.yml` workflow launches this script automatically whenever `vendors.txt` or `custom_vendors.json` change.

### Contributing

Install [pre-commit](https://pre-commit.com/) and enable it in your app directory:

```bash
pre-commit install
```

Our pre-configured hooks format code automatically using:

- ruff (Python)
- eslint (JavaScript)
- prettier (Markdown, HTML, etc.)
- pyupgrade (Python modernizer)

All hook definitions live in `.pre-commit-config.yaml` at the repository root.

### CI & Automation

This template comes with GitHub Actions workflows for:

- CI testing
- automated vendor submodule updates via `update-vendors.yml`
- commit linting and validation

Workflow examples are stored in `workflow_templates/`. Copy them into
`.github/workflows/` in your app repository and adjust them as needed.
The [workflow_templates.md](doc/workflow_templates.md) document explains what
each template does. Details about vendor handling are described in
[vendor_management.md](doc/vendor_management.md).
### Command Restrictions
Codex does not execute real shell commands or network operations while processing this repository. Only file creation and modification is performed. Commands like `bench`, `git`, `curl`, `wget`, `npm` and `ssh` must not run. You may place such commands in scripts or CI files, but they remain inactive during updates.
### License
MIT

---

For full Codex compatibility and developer productivity, follow the structural conventions and use the agent files provided.

### How to Code

Update PROJECT.md with new development prompts
Connect repo as environment in codex ui environments
code with prompts and/or flags and/or --go (starts with reading PROJECT.md).

--- autocreated ---

Codex processes this repository based on the rules in `AGENTS.md`. The following instructions are currently active:
- Flags have highest priority!
- Always update `README.md` when `AGENTS.md` includes new instructions relevant to later usage.

- Create any missing essential files described in the documentation.
- Remove one-off helper files after they are used.
- Build workflows, scripts and configs logically and keep them consistent when paths or structures change.
- Keep tests up to date as the project evolves.
- Update existing files if they do not match the documentation in `README.md` or the instructions in `AGENTS.md`.
- Keep `README.md` and `AGENTS.md` synchronized.
- Ensure scripts under `scripts/` reflect what the README describes.
- Store Mermaid diagrams as `.mmd` files in `doc/` and use `flowchart TD` with files as rectangles and scripts as rounded nodes.
- Maintain this "How to Code" section so it lists available flags, how Codex is influenced and which instructions are active or disabled.
- Use `--create-tasks` when prompts risk exceeding context limits.
- Check vendor-specific instructions under `instructions/vendor_profiles/<vendorname>/AGENTS.md`; those override the main `AGENTS.md` when present.

Codex can be guided with these flags:

- `--no-agent` &ndash; Treat the prompt as the main instruction, rewrite `README.md` and `AGENTS.md`, then adjust the code to match.
- `--create-tasks` &ndash; Instead of changing code directly, produce a list of discrete, non-conflicting tasks for manual implementation.
- `--start` &ndash; Initialize the project using the current documentation without running code. Missing files are created and structures put in place.
- `--go` &ndash; Execute tasks found in `PROJECT.md` before the separator line.
- `--focus-on-<file/folder>` &ndash; Prioritize a specific file or folder recursively.
- `--update-scripts` &ndash; Review scripts under `scripts/` and `setup.sh`.
- `--update-workflows` &ndash; Review GitHub Actions in `.github/workflows/`.
- `--update-comments` &ndash; Add useful code comments only, no other changes.
- `--update-agent` &ndash; Rewrite `AGENTS.md` according to the prompt and update the project afterwards.
- `--update-readme` &ndash; Rewrite `README.md` according to the prompt and adjust the repository.
- `--update-docs` &ndash; Work exclusively on documentation under `doc/`.
- `--update-scripts` &ndash; Review and adapt files in `scripts/` and `setup.sh`.
- `--update-workflows` &ndash; Update files in `.github/workflows/` to match the docs.
- `--update-comments` &ndash; Add concise comments that clarify why code exists.

Inactive instructions, if any, appear here as "not active" when they are commented out in `AGENTS.md`.
