
# 🚀 Frappe App Template (Agent-Optimiert)

Dieses Repository ist das **zentrale Master-Template** zur Entwicklung agent-unterstützter Frappe-Apps. Es beinhaltet alle Werkzeuge, Strukturen, Konventionen und Workflows, um neue Projekte effizient aufzusetzen, kontextoptimiert mit dem neuen Agent-Standard zu entwickeln und gezielt externe Inhalte (z. B. ERPNext) einzubinden.


## 🚀 Getting Started

1. Klone dieses Repository oder binde es als Submodul in dein App-Projekt ein.
2. Führe `./setup.sh` aus, um das Grundgerüst und die benötigten Ordner anzulegen.
   Dabei wird sofort ein App-Ordner inklusive `app/.gitignore` erstellt.
3. Trage aktive Vendoren in `vendors.txt` ein und starte `./scripts/update_vendors.sh`.
4. Installiere Entwickler-Abhängigkeiten mit `pip install -r requirements-dev.txt` und prüfe alles über `pytest`.
5. Installiere Bench (`pip install frappe-bench`) und stelle sicher, dass Node 18 aktiv ist (z. B. via `n 18`), bevor du `bench build` ausführst.
6. Lies den Abschnitt [Developer Guide](./PROJECT.md#developer-guide) in [PROJECT.md](./PROJECT.md) und die Hinweise im Ordner [instructions/_core](instructions/_core/README.md).
7. Das Projektprofil findest du in [PROJECT.md](./PROJECT.md). Dieses Dokument wird von `generate_index.py` beim Aufbau des Projektkontextes eingelesen.
8. Lege projektspezifische Hinweise in `agent.md` Dateien ab. Der Agent bezieht sie bei allen Aktionen mit ein.


Weitere Beispiele für Daten und Schnittstellen findest du im [sample_data/README.md](sample_data/README.md).

## 📂 Strukturtyp

Dies ist ein **`template_base`**-Repository.

* Es wird **nicht selbst gepublished** (`publish_enabled: false`)
* Dient als Submodul in App-Repos
* Enthält: Setup-Tools, Referenz-App, globale Instructions, Indexing-Mechanismen, Workflow-Templates
* Zudem liegt unter `doku/` eine Sammlung projektbegleitender Dokumente.

## 📁 Projektstruktur

```plaintext
frappe_app_template/
├── app/
│   └── frappe_template_core/           # Referenz-App: UI, Doctypes, Layouts etc.
│
├── instructions/
│   └── _core/                          # zentrale Agent-Anleitungen (niemals löschen)
│       ├── frappe.md
│       ├── erpnext.md
│       ├── prompts.md
│       └── ...
│
├── doku/
│   ├── overview.md
│   ├── user_story_template.md
│   └── guide_doctype_listing.md
│
├── scripts/                            # Setup- & Sync-Werkzeuge
│   ├── bootstrap_project.sh            # initialisiert neues App-Repo
│   ├── update_vendors.sh               # synchronisiert vendors.txt → apps.json → Submodule
│   └── ...
│
├── vendor_profiles/                    # zentrale Vendordefinitionen nach Kategorien
│   ├── cloud/nextcloud.json
│   └── ...                             # JSON-Dateien pro Vendor
│
├── sample_data/
│   └── example_payload.json
│
├── tests/
│   └── test_update_vendors.py
│
├── workflow_templates/
│   ├── init_new_app_repo.yml
│   ├── publish.yml
│   └── ...
│
├── .github/
│   ├── workflows/
│   │   ├── generate_agent_index.yml
│   │   ├── validate_commits.yml
│   │   └── ci.yml
│   └── workflows_readme/
│       └── template_maintenance/
│
├── .incoming/                          # Snapshots von Agent-Wissen aus App-Repos
│   └── codex_snapshots/
│       └── my_app.json
│
├── setup.sh
├── requirements.txt
├── requirements-dev.txt
├── apps.json                           # generiert: enth. aktive Submodule/Vendoren
├── instructions/_INDEX.md              # Übersicht aller Vendoren (autogeneriert)
├── .agent_gitlog.json                  # Commit-Historie mit #agent:-Tags
├── vendors.txt                         # aktive Vendor-Slugs (z. B. erpnext, website)
├── project_meta.yml                    # Steuerung des Repo-Typs etc.
├── pricing_settings.yml                # Parameter für Preiskalkulationen

└── README.md
```

Alle Workflows orientieren sich an der jeweiligen `project_meta.yml` eines App-Repositories. Templates selbst werden nicht veröffentlicht.

## 📈 `pricing_settings.yml`

In dieser optionalen Datei hinterlegst du Schätzwerte für typische Aufgaben wie Doctypes oder Webseiten. Externe Tools können die Werte nutzen, um Angebote zu kalkulieren. Hinterlege hier nur unsensible Daten und niemals vertrauliche Stundensätze.

## 💡 Agent-Prinzipien

* Nur **ein Git-Repo** als aktiver Kontext
* Externe Tools (ERPNext, Raven ...) werden als Submodule in `vendor/` eingebunden
* Zu jedem Submodul gibt es begleitende Anleitungen in `instructions/_<slug>/`
* Der Agent liest aus: `instructions/`, `vendor/`, `app/`, relevante `scripts/` & Workflows

## 🔄 Submodule & Versionierung

Unter `vendor_profiles/` liegen JSON-Dateien pro Vendor, z. B.:

```json
vendor_profiles/erp_business/erpnext.json
{
  "url": "https://github.com/frappe/erpnext",
  "tag": "v15.0.0"
}
```

Diese Profile werden beim Einrichten neuer Repositories genutzt, um die passenden Submodule zu klonen.
Beim ersten Ausführen von `setup.sh` wird zudem automatisch eine leere `.gitmodules`-Datei erzeugt (bzw. `git submodule init` ausgeführt), falls diese noch nicht existiert.

Frappe und Bench sind bereits in `apps.json` hinterlegt und werden bei jeder Ausführung von `update_vendors.sh` automatisch aktualisiert. Weitere Apps fügst du über `vendors.txt` hinzu. Dort kannst du entweder nur einen Slug eintragen – dann greift die passende Datei unter `vendor_profiles/` (oder im Template‑Unterordner `frappe_app_template/vendor_profiles/`, falls kein lokaler Ordner vorhanden) – oder ein eigenes Repository inklusive Branch oder Tag. Zusätzlich kannst du beliebige Repositories direkt in `apps.json` oder `custom_vendors.json` angeben; diese werden beim nächsten `update_vendors.sh` berücksichtigt:

```text
# slug aus vendor_profiles
erpnext
# manuelles Repository (optional mit Tag)
myaddon|https://github.com/me/myaddon|develop|v1.0
```

Passe bei Bedarf die JSON-Dateien unter `vendor_profiles/` an und starte danach `./scripts/update_vendors.sh` oder den Workflow **update-vendors**. Existiert kein solcher Ordner, nutzt das Skript automatisch die Profile aus dem Template‑Verzeichnis.

### Absoluter GitHub-Link

Wenn du in externer Doku oder CI auf Dateien eines Submodules verlinken möchtest,
verwende einen vollständigen GitHub-Link inklusive Branch oder Commit. Die
benötigten Informationen liest `generate_index.py` aus `apps.json`.

Beispiel:

- [frappe](https://github.com/your-org/frappe-version-15/tree/main/frappe)
- [frappe @ a1b2c3d](https://github.com/your-org/frappe-version-15/tree/a1b2c3d/frappe)
## 🔁 Wissen aus App-Repos zurückführen

App-Repos können neue Erkenntnisse lokal ablegen:

```json
agent_feedback.json
{
  "vendor": "erpnext",
  "context_improvement": [
    {
      "file": "instructions/_erpnext/project_logic.md",
      "comment": "Beispiel für ERP-Modulstruktur ergänzt"
    }
  ]
}
```

Ein Cronjob oder CI-Sync-Skript überträgt regelmäßig Inhalte aus `my_app/instructions/` und `instructions/_INDEX.md` zurück nach `.incoming/` in dieses Repo.

## 🧰 Commit-Konventionen (Agent-optimiert)


```bash
feat(ui): Add layout hooks #codex:index
refactor(sync): simplify vendor loader #codex:infra
```

Workflows wie `validate_commits.yml` prüfen auf Einhaltung.

## 📜 Beispiel: Neues App-Repo

```bash
# Projekt initialisieren
git init -b develop my_app && cd my_app

git submodule add https://github.com/your-org/frappe_app_template
./frappe_app_template/setup.sh
# erstellt auch sofort das App-Verzeichnis inklusive app/.gitignore
# (via `scripts/new_frappe_app_folder.py`)
# legt bei Bedarf auch eine leere .gitmodules an

nano vendors.txt
# z. B. erpnext, website
./scripts/update_vendors.sh

# Pushen
git add . && git commit -m "chore: setup"
git remote add origin ... && git push -u origin develop
```

Jedes App-Repository sollte folgenden Hinweis enthalten:

> Diese App basiert auf dem zentralen `frappe_app_template`.
> Eingebundene Vendoren stehen in vendors.txt.
> Anleitungen wurden automatisch übernommen.
> Die Datei `instructions/_INDEX.md` wird bei Änderungen automatisch aktualisiert.
> Erkenntnisse aus dieser App werden regelmäßig zurück in das zentrale Template synchronisiert.

## 📈 Mermaid-Diagramme

Legge `.mmd`-Dateien im Ordner `doku/` an und generiere die SVGs mit

```bash
./scripts/generate_diagrams.sh
```

Die Vorlage `workflow_templates/generate-mermaid.yml` automatisiert die Aktualisierung in GitHub Actions.


## ✨ Fazit

Dieses Repository ist das zentrale Fundament zur Entwicklung modularer, wartbarer und kontextoptimierter Frappe-Projekte. Alle Submodule, Anleitungssysteme und Automatisierungen zielen auf einen sauberen Agent-Kontext ab. Neue Erkenntnisse können strukturiert in `.incoming/` zur Verfügung gestellt werden – ganz ohne Submodule pushen zu müssen.

**Dieses Template ist das Gehirn – jede App ist ein Ausdruck davon.**

**Happy prompting!**
