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
./frappe_app_template/setup.sh --autogencreds --verbose my_app
```

The script will:

- use `bench new-app` to generate a new Frappe app under `apps/my_app/` (interactive)
- abort if `apps/my_app/` already exists to avoid overwriting
- initialize a Git repository in `apps/my_app/`
- add `frappe_app_template` as a submodule in `apps/my_app/frappe_app_template`
- copy template files such as `README.md`, `.github/`, `AGENTS.md`, `instructions/` and `scripts/`
- create the GitHub repository for your app or prompt to push to an existing repo
- configure the deploy key and set `origin` for GitHub push
- the GitHub repository is automatically named after your app
- the GitHub API token is stored in `~/frappe-bench/.env` for reuse
- repo specific values like `REPO_NAME`, `REPO_PATH`, `SSH_KEY_PATH` and `DEPLOY_KEY_ADDED` are stored in `apps/my_app/.env`; keys from the bench `.env` are moved here if found
- run `./scripts/update_vendors.sh` to fetch vendor submodules before the initial push
- push the new repository to the remote `develop` branch

### GitHub Configuration

General GitHub credentials such as the API token and default repo path belong in:

```bash
frappe-bench/.env
```

Each created app has its own `.env` for repo specific values such as `REPO_NAME`, `REPO_PATH`, `SSH_KEY_PATH` and `DEPLOY_KEY_ADDED`.
Both files are ignored by git so secrets remain local.

### Project Structure

The full directory layout is documented in [doc/trees/template_structure.md](doc/trees/template_structure.md).


See [doc/trees/app_structure_develop.md](doc/trees/app_structure_develop.md) for the directory created by setup.sh.
See [doc/trees/app_structure_main.md](doc/trees/app_structure_main.md) for an example layout after release.
Each vendor used by your app has a dedicated folder under `instructions/vendor_profiles/<category>/<slug>/`.
The folder contains an `apps.json` file with repository information and an optional `AGENTS.md` for vendor‑specific notes.

Run `./scripts/update_vendors.sh` to sync vendors. The script reads `vendors.txt` and `custom_vendors.json`, looks up the matching profiles and adds each repository as a submodule under `vendor/`. If a vendor repository is private, provide a `GITHUB_TOKEN` or `API_KEY` via the bench `.env`, the repo `.env` or `.config/github_api.json` so the script can clone it. Submodules that no longer appear in the lists are removed and `apps.json` is rewritten with the current metadata.

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
[vendor_management.md](doc/scripts/vendor_management.md).
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
