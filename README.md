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

- use `bench new-app` to generate a new Frappe app under `apps/my_app/` (you will be prompted interactively) <-- instead orphaned create_repo_folder
- initialize a Git repository in `apps/my_app/`
- link the `frappe_app_template` as a submodule in `apps/my_app/frappe_app_template`
- copy required template files into the root of your new app (e.g. `README.md`, `.github/`, `AGENTS.md`, `instructions/`, `scripts/` etc.)
- create new remote repo <path from .config>/my_app
- prepare for GitHub push to your private repository (e.g. `github.com/mygithubacc/frappe-apps/`my_app)
- pushes new generated app repo to remote develop branch
- triggers publish wf if is not selftriggered

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
        ├── scripts/
        │   ├── clone_submodules.sh        # pull vendor profiles
        │   ├── remove_submodule.sh        # remove unwanted vendor
        │   └── update_vendors.sh          # sync vendor submodules
        │   └── publish_app.sh             # manual publish app without dev files --> create pull request with new tag <vx.x.x> auto upscaling with choice of dev-stable <vx.x.x+1>, test-stable <vx.x+1.0>, major <vx+1.0.0>
        ├── .pre-commit-config.yaml        # git hook definitions
        ├── .github/
        │   └── workflows/
        │       ├── ci.yml
        │       ├── update-vendors.yml
        │       └── validate_commits.yml
        └── .config/github_api.json        # local configuration (not tracked)
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

- Create any missing essential files described in the documentation.
- Remove one-off helper files after they are used.
- Build workflows, scripts and configs logically and keep them consistent when paths or structures change.
- Keep tests up to date as the project evolves.
- Update existing files if they do not match the documentation in `README.md` or the instructions in `AGENTS.md`.
- Keep `README.md` and `AGENTS.md` synchronized.
- Ensure scripts under `scripts/` reflect what the README describes.
- Maintain this "How to Code" section so it lists available flags, how Codex is influenced and which instructions are active or disabled.
- Use `--create-tasks` when prompts risk exceeding context limits.
- Check vendor-specific instructions under `instructions/vendor_profiles/<vendorname>/AGENTS.md`; those override the main `AGENTS.md` when present.

Codex can be guided with these flags:

- `--no-agent` &ndash; Treat the prompt as the main instruction, rewrite `README.md` and `AGENTS.md`, then adjust the code to match.
- `--create-tasks` &ndash; Instead of changing code directly, produce a list of discrete, non-conflicting tasks for manual implementation.
- `--start` &ndash; Initialize the project using the current documentation without running code. Missing files are created and structures put in place.
- `--go` &ndash; Execute tasks found in `PROJECT.md` before the separator line.
- `--update-agent` &ndash; Rewrite `AGENTS.md` according to the prompt and update the project afterwards.
- `--update-readme` &ndash; Rewrite `README.md` according to the prompt and adjust the repository.
- `--update-docs` &ndash; Work exclusively on documentation under `doc/`.

Inactive instructions, if any, appear here as "not active" when they are commented out in `AGENTS.md`.
