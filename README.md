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
- clone the `frappe_app_template` into `apps/my_app/frappe_app_template`
- copy required template files into the root of your new app (e.g. `README.md`, `.gitignore`, `.github/`, `AGENTS.md`, `PROJEKT.md`, `instructions/` with vendor profiles, `scripts/` etc.)
- vendor profiles are mirrored under `instructions/<slug>/` so `frappe` and `bench` instructions are ready
- commit all copied files so `git status` is clean even when `bench` created the repo
- create new remote repo <path from .pre-commit-config.yaml>/my_app (is prompted interactively)
- prepare for GitHub push to your private repository (e.g. `github.com/mygithubacc/frappe-apps/`my_app (you will be prompted interactively)<-- from git hook definitions)
- the GitHub repository is automatically named after your app
- the GitHub API token is stored in `~/frappe-bench/.env` for reuse
- repo specific values like `REPO_NAME`, `REPO_PATH`, `SSH_KEY_PATH` and `DEPLOY_KEY_ADDED` are stored in `apps/my_app/.env`; keys from the bench `.env` are moved here if found
- run `./scripts/update_vendors.sh` to fetch vendor repositories before the initial push
  (use `--verbose` to see detailed logs)
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
Vendor profile templates live under `frappe_app_template/instructions/vendor_profiles/<category>/<slug>/`.
Each profile contains an `apps.json` file with repository information and an optional `AGENTS.md` for vendor-specific notes. When `update_vendors.sh` runs, the instructions for active vendors are copied to `instructions/<slug>` in your app.

Run `./scripts/update_vendors.sh` to sync vendors. The script reads `vendors.txt` and `custom_vendors.json`, looks up the matching profiles and clones each repository directly under `vendor/`. When a vendor repository is private, the script first tries your global GitHub token from the bench `.env` or `.config/github_api.json`. If cloning fails, it will ask you to enter a token interactively. The script relies on `jq` for JSON parsing. Vendor directories that no longer appear in the lists are removed and `apps.json` is rewritten with the current metadata. Use `--verbose` to print detailed progress.

For automation (e.g. CI or Codex) use `./scripts/update_vendors_ci.sh` which aborts if `GITHUB_TOKEN` is missing and disables git prompts.

The `update-vendors.yml` workflow launches this script automatically whenever `vendors.txt` or `custom_vendors.json` change.

### Codex Environment Setup

1. Add a secret named `GITHUB_TOKEN` in your Codex environment so vendor scripts can access private repositories.
2. Copy `scripts/setup_codex_env.sh` into the environment and run it once to initialize submodules and fetch vendor repositories. Set `SKIP_PIP_INSTALL=1` to skip installing Python requirements.

### Command Restrictions

Codex does not execute real shell commands or network operations while processing this repository. Only file creation and modification is performed. Commands like `bench`, `git`, `curl`, `wget`, `npm` and `ssh` must not run. You may place such commands in scripts or CI files, but they remain inactive during updates.

### License

MIT

---

For full Codex compatibility and developer productivity, follow the structural conventions and use the agent files provided.
