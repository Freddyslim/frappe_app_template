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
