# Codex Agent Instructions

## Start

Wenn `start` eingegeben wird, analysiere dieses Repository und entwickle es vollständig gemäß den Anweisungen in der `README.md`.

**Führe keine Shell-Befehle oder Scripts aus.** Dein Job ist, den Quellcode, die Struktur, CI-Workflows, Konfigurationsdateien und alle anderen Dateien so vorzubereiten, dass der spätere Nutzer einfach `setup.sh my_app` aufrufen kann und alles funktioniert wie beschrieben.

## Ziel

Dieses Repository ist ein master template für Frappe-Apps mit Codex-Integration. Die README.md beschreibt klar:

- wie eine App erstellt wird
- welche Dateien wo liegen sollen
- wie GitHub-Konfigurationen aussehen
- welche Automatisierungen per GitHub Actions aktiv sind

Du sollst den Code und die Struktur so vorbereiten, dass alles exakt dieser Beschreibung entspricht.

## Umsetzung

- Ergänze fehlende Dateien (z. B. `.github/workflows/*.yml`, `.config/github_api.json.example`, `instructions/AGENTS.md`)
- Passe vorhandene Dateien an, falls sie von der README abweichen
- Achte auf vollständige, valides Shell-kompatibles `setup.sh`
- Strukturiere alles so, dass eine spätere `bench new-app`-Ausführung innerhalb von `setup.sh` funktioniert
- Verlinke das Template korrekt als Submodul
- CI/Workflow-Dateien sollten valide YAML enthalten und auf typische CI-Tools abgestimmt sein

## Hinweis

Diese `AGENTS.md` ist für Codex. Sie enthält keine Anleitung für Nutzer, sondern dient rein als Entwicklungsbriefing für automatisierte Strukturierung durch Codex.
