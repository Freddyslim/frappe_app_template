# Codex Agent Instructions

## Ziel

Dieses Repository ist ein Master-Template für Frappe-Apps mit Codex-Integration.

Die `README.md` beschreibt:

- wie eine App erstellt wird  
- welche Dateien wo liegen sollen  
- wie GitHub-Konfigurationen aussehen  
- welche Automatisierungen per GitHub Actions aktiv sind  

Codex soll die Struktur, Dateien und Logik dieses Repos so entwickeln, dass alles exakt diesen Vorgaben entspricht – **ohne Shell-Befehle auszuführen.**

---

## Anweisungen

Diese Anweisungen gelten dauerhaft und müssen durch Codex bei jedem Lauf beachtet werden, **sofern sie nicht deaktiviert wurden**.

Einzelne Anweisungen können deaktiviert werden, indem sie **innerhalb eines HTML-Kommentars `<!-- ... -->`** auskommentiert werden.  
Codex ignoriert solche Anweisungen vollständig.  
Die `How to Code`-Sektion in der `README.md` wird automatisch angepasst und listet deaktivierte Anweisungen korrekt als "nicht aktiv".

### Aktive Standardanweisungen

- Einmalige Initialdateien oder Helfer nach Verwendung entfernen

- Workflows, Skripte und Konfigs logisch und konsistent aufbauen – insbesondere bei Strukturänderungen (z. B. Pfade, Imports, CI-Trigger)

- Bestehende Dateien aktualisieren, wenn sie nicht zur `README.md` oder `AGENTS.md` passen

- `README.md` ↔ `AGENTS.md` synchron halten: Änderungen in einer Datei müssen sich in der anderen widerspiegeln

- Die Sektion `How to Code` am Ende der `README.md` immer prüfen und anpassen, sodass sie verständlich wiedergibt:
  - Welche Flags verfügbar sind
  - Wie Codex beeinflusst wird
  - Welche Anweisungen aktiv oder deaktiviert sind

- **Vendorspezifische AGENTS.md beachten:**  
  Wenn im Verzeichnis `/vendors` Submodule eingebunden sind, prüfe, ob unter  
  `instructions/vendor_profiles/<vendorname>/AGENTS.md`  
  eine vendorspezifische Agent-Anweisung vorhanden ist.  
  **Im Fall von Widersprüchen zu dieser Haupt-AGENTS.md ist die vendorspezifische Datei vorrangig zu behandeln.**

---

## Flags

Die folgenden Flags können über den Prompt gesetzt werden.  
**Wenn nicht gesetzt, werden sie ignoriert.**  
Sie müssen nicht deaktiviert oder auskommentiert werden.

### `--no-agent`

Wenn gesetzt:

- Der Prompt gilt als primäre Anweisung
- `README.md` und `AGENTS.md` werden basierend auf dem Prompt aktualisiert
- Danach wird der restliche Code dem neuen Zustand angepasst
- Die Sektion `How to Code` muss entsprechend überarbeitet werden

### `--create-tasks`

Wenn gesetzt:

- Es erfolgt keine direkte Codeänderung
- Stattdessen werden konkrete, konfliktfreie Aufgaben erzeugt
- Diese sind logisch getrennt und ermöglichen paralleles Arbeiten
- Auch hier gilt: Die `How to Code`-Sektion wird entsprechend angepasst

### `--start`

Wenn gesetzt:

- Initialisiert die Analyse und Umsetzung des Projekts basierend auf der aktuellen `README.md` und `AGENTS.md`
- Es werden alle aktiven Anweisungen aus dieser Datei verarbeitet
- Fehlende Dateien werden ergänzt, vorhandene angepasst
- Struktur, CI-Workflows und Konfigurationen werden vollständig aufgebaut, ohne dass Code oder Shell ausgeführt wird
- Dieses Flag eignet sich besonders für neue Repositories oder nach einem Reset
- Die Sektion `How to Code` wird ebenfalls aktualisiert, um die aktiven Anweisungen und unterstützten Flags klar aufzulisten

---

## Hinweis

Diese Datei ist für Codex – nicht für Nutzer.  
Sie enthält zentrale Anweisungen für automatisierte Entwicklung.  
**Anweisungen** können bei Bedarf durch Auskommentieren deaktiviert werden.  
Die `How to Code`-Sektion in der `README.md` zeigt immer den aktuellen Zustand an.  
Vendorspezifische Agent-Profile aus `instructions/vendor_profiles/...` können bei Bedarf einzelne Regeln hier überschreiben.
