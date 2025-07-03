# 📁 Frappe App Dev Setup – Codex-fähiges Metakonzept

Dieses Repository ist das zentrale Master-Template zur Entwicklung Codex-unterstützter Frappe-Apps. Es automatisiert die Erstellung, Strukturierung und Verwaltung neuer Frappe-Apps inkl. Git- und Vendor-Einbindung. Ziel ist es, alle Informationen und Workflows so zu strukturieren, dass sie direkt mit der OpenAI Codex UI unter [openai.com/codex](https://openai.com/codex) nutzbar sind.

---

## 🔧 Verzeichnisstruktur

```bash
/home/frappe/frappe-bench/
└── apps/
    └── my_app/
        ├── my_app/                        # Frappe App-Code
        ├── instructions/                  # App-spezifische Anweisungen
        │   └── AGENTS.md                  # projektspezifische Erweiterung für Codex
        ├── frappe_app_template/ → symlink auf /opt/git/frappe_app_template
        ├── vendor/                        # Vendor-Submodule
        │   ├── erpnext/                   
        │   └── nextcloud/
        ├── doc/                           # ausführliche technische Dokumentation (Details, Hintergründe)
        │   ├── logic.md                   # Detailbeschreibung Logik, Zustände, Use-Cases
        │   ├── modules.md                 # Struktur und Modulverhalten
        │   ├── MERMAID.mmd                # wird automatisch gepflegt aus doc/*
        │   └── ...
        ├── AGENTS.md                      # Hauptagent-Datei für Codex – kontextführend & lernend
        ├── README.md                      # Projektdokumentation (Zweck, Nutzung, Weiterentwicklung)
        ├── apps.json                      # Übersicht aller Submodule
        ├── custom_vendors.json            # projektspezifische Vendoren (Repo + Tag/Branch)
        ├── vendors.txt                    # Namen gängiger Vendoren (aus Template)
        ├── .github/
        │   └── workflows/
        │       └── sync.yml               # CI/CD oder Sync-Logik für Codex/Updates
        └── .config/github_api.json        # Lokale Konfig mit sicherem API-Token (nicht tracken!)
```

### 🔀 Aufgabentrennung `AGENTS.md` vs `README.md`

| Datei       | Zweck                                                                                                                                                                                                                                                                                                                                       |
| ----------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `AGENTS.md` | Einstiegspunkt für Codex CLI und Codex UI. Enthält **Agentenbefehle**, **Verweise auf alle relevanten Anleitungen**, Regeln zur Struktur, Indexierungen, bekannte Kontexte und interaktive Codex-Kommandos. Diese Datei **lernt und wächst mit**. Sie enthält keine Projektbeschreibung, sondern dient der strukturierten Kontextsteuerung. |
| `README.md` | **Projektbeschreibung für Menschen**. Erläutert:                                                                                                                                                                                                                                                                                            |

1. Was macht das Projekt?
2. Wie installiere und nutze ich es?
3. Was muss ich bei der Weiterentwicklung beachten?
   Auch geeignet für Nicht-Techies oder externe Stakeholder.                                                                                                              |
   \| `doc/`      | Detaillierte technische Dokumentation. Alle Inhalte hier dienen als tiefergehende Projektbasis. Daraus wird regelmäßig ein aktuelles **Mermaid-Diagramm (****`MERMAID.mmd`****)** generiert. Dieser Ordner dient auch als langfristiges Wissensarchiv.                                                                                                    |

---

## 🧪 Setup-Ablauf (Automatisiert via `setup.sh`)

**Kurzübersicht der Schritte:**

1. Neue App mit `bench new-app` erzeugen
2. GitHub-Repo via API anlegen (Token in `.config/github_api.json`)
3. Git initialisieren, `main` und `develop` Branch anlegen
4. Remote auf GitHub setzen, SSH-Zugriff sicherstellen
5. Template-Symlink auf `/opt/git/frappe_app_template` erstellen
6. Struktur einrichten:

   * `README.md`, `AGENTS.md` kopieren
   * `instructions/AGENTS.md` anlegen
   * `.gitignore`, `vendors.txt`, `custom_vendors.json` vorbereiten
7. Optional: Vendoren mit `update_vendors.sh` einbinden
8. App installieren, anpassen und in Codex UI nutzbar machen

---

## 🔗 ToDo (optional)

* Validierung der Struktur via `structure.json`
* GitHub CLI optional nutzbar machen
* Mermaid-Generierung aus `doc/*.md` regelmäßig automatisieren (z. B. via `generate_mermaid_from_docs.py` + CI)
* Codex-Dialoge direkt aus `AGENTS.md` trainieren
