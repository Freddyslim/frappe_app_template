# Codex Agent Instructions

## Start

Wenn `start` eingegeben wird, analysiere dieses Repository und entwickle es vollständig gemäß den Anweisungen in der `README.md`.

**Führe keine Shell-Befehle oder Scripts aus.** Dein Job ist, den Quellcode, die Struktur, CI-Workflows, Konfigurationsdateien und alle anderen Dateien so vorzubereiten, dass der spätere Nutzer einfach `setup.sh my_app` aufrufen kann und alles funktioniert wie beschrieben.

## Ziel

Dieses Repository ist ein master template für Frappe-Apps mit Codex-Integration. Die `README.md` beschreibt:

- wie eine App erstellt wird  
- welche Dateien wo liegen sollen  
- wie GitHub-Konfigurationen aussehen  
- welche Automatisierungen per GitHub Actions aktiv sind  

Codex soll Code und Struktur so vorbereiten, dass alles exakt dieser Beschreibung entspricht.

## Umsetzung

- Ergänze fehlende Dateien (z. B. `.github/workflows/*.yml`, `.config/github_api.json.example`, `instructions/AGENTS.md`)
- Passe vorhandene Dateien an, falls sie von der `README.md` abweichen
- Achte auf vollständige, Shell-kompatible `setup.sh`
- Strukturiere alles so, dass `bench new-app` in `setup.sh` funktioniert
- Verlinke das Template korrekt als Submodul
- Organisiere vendor-spezifische Daten unter `instructions/vendor_profiles/<kategorie>/<slug>/` mit `apps.json` und `AGENTS.md`
- CI/Workflow-Dateien sollten valide YAML enthalten
- **Prüfe alle Skripte, Shell-Kommandos und Workflows logisch auf Funktionsfähigkeit und Seiteneffekte** – insbesondere bei Umstrukturierungen (z. B. Dateiverschiebungen), ob alle Referenzen konsistent angepasst wurden. Fehler wie veraltete Pfade, nicht aktualisierte Imports oder fehlerhafte CI-Triggers müssen erkannt und vermieden werden.

## Flags

### `--no-agent`

Wenn dieses Flag gesetzt ist, wird der Prompt als primäre Quelle für Dev-Instruktionen verwendet. Die Dateien `AGENTS.md` und `README.md` dienen in diesem Fall nur als sekundäre Referenz.

- **Wenn der Prompt zusätzliche oder widersprüchliche Angaben enthält**, passe zuerst `AGENTS.md` und `README.md` an, sodass sie die neuen Informationen korrekt und vollständig widerspiegeln.
- Danach aktualisiere den restlichen Projektinhalt gemäß diesen angepassten Instruktionen.
- Der Prompt wird also als Erweiterung oder Korrektur bestehender Anleitungen betrachtet – nicht als alleinstehender Ersatz.

## Beispiele

### `start`

> Entwickle das Projekt gemäß `README.md`.

### prompt + `--no-agent`

> Verwende die Informationen im Prompt als primäre Quelle. Aktualisiere `README.md` und `AGENTS.md` entsprechend, bevor du die restliche Struktur anpasst.

## Hinweis

Diese `AGENTS.md` ist für Codex. Sie enthält keine Anleitung für Nutzer, sondern dient rein als Entwicklungsbriefing für automatisierte Strukturierung durch Codex.
