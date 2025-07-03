# Codex Agent Instructions

## Ziel

Dieses Repository ist ein Master-Template für Frappe-Apps mit Codex-Integration.

Die `README.md` beschreibt:

- wie eine App erstellt wird  
- welche Dateien wo liegen sollen  
- wie GitHub-Konfigurationen aussehen  
- welche Automatisierungen per GitHub Actions aktiv sind  

Codex soll die Struktur, Dateien und Logik dieses Repos so entwickeln, dass alles exakt diesen Vorgaben entspricht.

---

## Anweisungen

Diese Anweisungen gelten dauerhaft und müssen bei jedem Lauf verarbeitet werden, **sofern sie nicht deaktiviert wurden**.

Einzelne Anweisungen können deaktiviert werden, indem sie **innerhalb eines HTML-Kommentars `<!-- ... -->`** auskommentiert werden.  
Codex ignoriert solche Anweisungen vollständig.  
Die `How to Code`-Sektion in der `README.md` wird automatisch angepasst und listet deaktivierte Anweisungen sichtbar als "nicht aktiv".

### Aktive Standardanweisungen

- Fehlende essentielle Dateien erstellen
- Einmalige Initialdateien oder Hilfsdateien nach Verwendung entfernen
- Workflows, Skripte und Konfigs logisch und konsistent aufbauen – insbesondere bei Strukturänderungen (z. B. Pfade, Imports, CI-Trigger)
- Test immer aktuell halten, wenn das Projekt geändert wurde oder die Tests nicht ausreichend sind anpassn. Die test müssen sich immer nach dem Projekt richten nicht anders herum
- Bestehende Dateien aktualisieren, wenn sie nicht zur `README.md` oder `AGENTS.md` passen
- `README.md` ↔ `AGENTS.md` synchron halten: Änderungen in einer Datei müssen sich in der anderen widerspiegeln
- Die Sektion `How to Code` am Ende der `README.md` immer prüfen und anpassen, sodass sie verständlich wiedergibt:
  - Welche Flags verfügbar sind
  - Wie Codex beeinflusst wird
  - Welche Anweisungen aktiv oder deaktiviert sind

### Vendor-spezifische Agentenprofile

Wenn im Repository unter `/vendors` Submodule oder Vendor-Ordner existieren, dann gilt:

- Suche in `instructions/vendor_profiles/<vendorname>/AGENTS.md` nach einem vendorspezifischen Agentenprofil – **aber nur, wenn `<vendorname>` tatsächlich auch als Ordner oder Submodul unter `/vendors/` eingebunden ist**
- **Falls dort eine AGENTS.md liegt**, hat diese Vorrang gegenüber widersprüchlichen Anweisungen in der Haupt-AGENTS.md

---

## Einschränkungen für Befehle & Ausführungen

Codex darf **keine realen Shell-Kommandos oder Prozesse ausführen**. Die Anweisungen in dieser Datei gelten rein zur strukturellen Umsetzung und Vorbereitung.

Erlaubt ist:

- Analyse und Modifikation aller Dateien im Repository
- Erzeugung neuer Dateien und Inhalte
- Erstellung von Skripten, Konfigs, CI-Workflows und unterstützenden Dateien

Nicht erlaubt ist:

- Ausführen von `bench`, `git`, `curl`, `wget`, `npm`, `ssh`, etc.
- Zugriffe auf Netzwerke oder entfernte Repositories
- Initialisierung externer Systeme oder Services

**Ausnahme:**  
Codex darf lokale Kommandos in CI-Dateien oder `setup.sh` **als Code erzeugen**, **aber nicht ausführen**.  
Diese müssen vollständig im Repository-Kontext bleiben (z. B. `chmod`, `yarn install`, `git status`, `rm`, `mkdir`, usw.).

Ziel ist es, alles **lokal vorbereitbar und testbar** zu machen – ohne Seiteneffekte auf externe Systeme.

---

## Flags

Die folgenden Flags können über den Prompt gesetzt werden.  
**Wenn nicht gesetzt, werden sie ignoriert.**

### `--start`

- Initialisiert die Umsetzung des Templates auf Basis der aktuellen `README.md` und `AGENTS.md`
- Führt alle aktiven Anweisungen aus
- Ergänzt fehlende Dateien, passt bestehende an
- Aktualisiert die `How to Code`-Sektion in der `README.md`

### `--no-agent`

- Prompt wird als primäre Quelle interpretiert
- `README.md` und `AGENTS.md` werden entsprechend dem Prompt angepasst
- Danach wird das gesamte Projekt aktualisiert
- `How to Code` muss ebenfalls angepasst werden

### `--create-tasks`

- Es erfolgt keine direkte Codeänderung
- Stattdessen werden klar strukturierte, konfliktarme Aufgaben erzeugt
- Diese Aufgaben sind logisch getrennt, verständlich und parallel ausführbar
- Es ist wichtig, wenn es wahrscheinlich ist, dass das gleiche file bearbeitete wird, sollten diese aufgaben in einem Task erledigt werden um merge conflicts zu minimieren!

---

## Hinweis

Diese Datei ist für Codex – nicht für Nutzer.  
Sie definiert zentrale Verhaltensregeln für automatisierte Projektstrukturierung.  
**Anweisungen** können durch Auskommentieren deaktiviert werden.  
Die Flags sind dynamisch und müssen aktiv gesetzt werden.  
Die `How to Code`-Sektion der `README.md` dokumentiert stets den aktuellen Zustand.
