### Frappe App Dev Setup Template

This repository is a master template for Codex-enabled Frappe apps. It automates project structure, git setup and vendor management so new apps can be created quickly.

### Installation

Clone this repository and run the setup script to generate an app skeleton:

```bash
./setup.sh my_app
```

Store your GitHub API token in `.config/github_api.json` (ignored by git).

### Project Structure

```bash
/home/frappe/frappe-bench/
└── apps/
    └── my_app/
        ├── my_app/                        # Frappe app code
        ├── instructions/                  # app instructions
        │   └── AGENTS.md                  # project-specific guidance
        ├── frappe_app_template -> /opt/git/frappe_app_template
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

Install [pre-commit](https://pre-commit.com/) and enable it:

```bash
pre-commit install
```

Our hooks format code with ruff, eslint, prettier and pyupgrade.

### CI

GitHub Actions workflows run tests and manage vendor updates automatically.

### License

MIT
