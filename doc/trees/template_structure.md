# Template Repository Layout

```bash
/home/frappe/frappe-bench/
└── frappe_app_tamplate/
        ├── instructions/                  # app instructions
        ├── vendor/                        # vendor repositories
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
        │   ├── clone_repo.sh              # pull vendor profiles
        │   ├── remove_repo.sh             # remove unwanted vendor directory
        │   ├── generate_diagrams.sh       # render Mermaid diagrams from doc/
        │   ├── update_vendors.sh          # sync vendor repositories
        │   └── publish_app.sh             # manual publish app without dev files --> create pull request with new tag <vx.x.x> auto upscaling with choice of dev-stable <vx.x.x+1>, test-stable <vx+1.0>, major <vx+1.0.0>
        │                                  # run with -h to see options

        ├── .github/
        │   └── workflows/
        │       ├── ci.yml
        │       ├── update-vendors.yml
        │       └── validate_commits.yml
        └── .pre-commit-config.yaml        # git hook definitions
```
