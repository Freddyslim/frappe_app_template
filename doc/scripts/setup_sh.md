# 🛠 Übersicht: Was `setup.sh` kann (Stand: aktuell)

## 📌 Aufrufoptionen
- `--verbose` oder `-v`: gibt zusätzliche Informationen aus (`vlog`)
- `--autogencreds`: liest und speichert GitHub-Zugangsdaten automatisch in `.env`
- `<APP_NAME>` als letztes Argument oder automatisch aus Ordnername abgeleitet

---

## 🔍 Vorbereitungs-Checks
- Prüft, ob `jq` installiert ist (benötigt für JSON-Verarbeitung)
- Verhindert Ausführung im Ordner `frappe_app_template`
- Setzt `SCRIPT_DIR`, `BENCH_DIR`, `WORKFLOW_TEMPLATE_DIR`
- Erkennt `APP_NAME` und generiert `APP_TITLE`

---

## 🧱 App-Verzeichnis & Basisstruktur
- Wenn `apps/<APP_NAME>` existiert → Script bricht mit Fehler ab, um bestehende Dateien nicht zu überschreiben
- Wenn **nicht vorhanden**:
  - `bench new-app` wird mit vorgegebenen Werten ausgeführt
  - App-Struktur wird angelegt
  - Erstellt `.env` im Bench-Hauptordner (falls nicht vorhanden) für globale Git-Einstellungen
- Legt eine `.env` im App-Ordner an und speichert dort `REPO_NAME`, `REPO_PATH` und `SSH_KEY_PATH`
  - Gibt bei neu angelegter Datei im `--verbose`-Modus den Pfad mit `vlog` aus
  - Liest bzw. schreibt `API_KEY` und `GITHUB_USER` ausschließlich im Bench-`.env`

---

## 🔐 SSH-Zugang
- Generiert SSH-Key `~/.ssh/id_deploy_<repo>` (falls nicht vorhanden)
- Fügt Eintrag zu `~/.ssh/config` hinzu mit Host-Alias `github.com-<repo>`
 - Schreibt `SSH_KEY_PATH` in die `.env` der App

---

## 🧠 GitHub-Repo-Logik
- Erstellt GitHub-Repo per API (entweder user- oder org-basiert)
- Erkennt, ob Repo schon existiert und fragt ggf. nach Push
- Optional: Hängt Deploy-Key ans GitHub-Repo (wenn nicht bereits vorhanden)
 - Speichert `DEPLOY_KEY_ADDED` in der app-spezifischen `.env`

---

## 🗂 Projektstruktur
- Erstellt folgende Ordner:
  - `.github/workflows/`
  - `scripts/`
  - `sample_data/`
  - `vendor/`
  - `instructions/`
  - `doc/`
  - `.config/`
- Erstellt/leert zentrale Dateien:
- `apps.json`, `vendors.txt`, `custom_vendors.json`, `README.md`, `AGENTS.md`, `.pre-commit-config.yaml`, etc.
- Kopiert Workflows aus Template-Verzeichnis `workflow_templates/*.yml`
- Kopiert Skripte aus `scripts/`-Ordner im Template
- Kopiert `AGENTS.md` und vorhandene `instructions/vendor_profiles/` aus dem Template (Profile landen zusätzlich unter `instructions/<slug>/`)
- Symlink auf `/opt/git/frappe_app_template`

---

## 🧬 Git-Initialisierung
- Initialisiert Git-Repo im App-Ordner nur wenn `.git` nicht vorhanden
- Erstellt neuen Branch `develop`
- Commit: `"Initial commit for <APP_NAME>"`

---

## 🔁 Git Remote Setup & Push
- Fügt Remote `origin` → `github.com-<repo>:<user>/<repo>.git`
- Optionaler Push nach Nachfrage:
  - Führt `fetch` + `pull --rebase` aus
  - Falls das Repository bereits existiert, wird `pull --rebase` ausgelassen
    und nach Bestätigung ein `git push --force` ausgeführt
  - Bei Fehlern fragt das Script ebenfalls nach `--force`
  - Vor jedem Push wird ein möglicher abgebrochener Rebase mit
    `git rebase --abort` zurückgesetzt
  - Erfolgreicher Push → Bestätigung

---

## ✅ Abschluss
- Gibt "Setup complete for <APP_NAME>" aus

---

## 🔒 Sicherheit & Robustheit
- `set -euo pipefail`: Bricht bei Fehlern oder nicht gesetzten Variablen ab
- Zugriff auf `.env` sicher via `chmod 600`

Weitere Hinweise zur Verwaltung von Vendoren findest du in [vendor_management.md](vendor_management.md).
