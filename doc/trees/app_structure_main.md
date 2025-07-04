# Example layout after release (main branch)

```bash
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
