# App Layout after setup.sh (develop branch)

```bash
/home/frappe/frappe-bench/
└── apps/
    └── test_application/
        ├── license.txt
        ├── pyproject.toml
        ├── README.md                        # Projektdokumentation
        ├── AGENTS.md                        # Codex-Agent Prompts (zentral)
        ├── apps.json                        # leere Datei für Vendor-Metadaten
        ├── custom_vendors.json              # leere Datei für eigene Vendoren
        ├── vendors.txt                      # Liste gebräuchlicher Vendoren (z.B. ERPNext, Nextcloud)
        ├── frappe_app_template              # geklontes Template-Repository
        ├── vendor/                          # von frappe_app_template kopiert
        │   ├── erpnext/
        │   └── nextcloud/
        ├── instructions/                    # projektspezifische Guidance für Codex
        ├── doc/                             # technische Dokumentation (Markdown, Mermaid)
        ├── sample_data/                     # leerer Ordner für optionale Testdaten
        ├── scripts/                         # Hilfsskripte
        │   ├── clone_repo.sh                # lädt Vendor-Repositories aus vendors.txt/custom_vendors.json
        │   ├── remove_repo.sh               # entfernt sauber ein Vendor-Verzeichnis und aktualisiert apps.json
        │   ├── generate_diagrams.sh         # rendert Mermaid-Diagramme aus /doc/
        │   ├── update_vendors.sh            # synchronisiert Vendor-Repositories (zentraler Einstieg)
        │   └── publish_app.sh               # erstellt Release, Tag, PR (manuell oder CI-unterstützt)
        ├── .pre-commit-config.yaml          # Hook-Setup für git (Black, isort, etc.)
        ├── .github/
        │   └── workflows/                   # GitHub Actions CI/CD
        │       ├── ci.yml                   # CI-Tests (z. B. Bench Build)
        │       ├── update-vendors.yml       # prüft und aktualisiert Vendor-Repositories automatisch
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
