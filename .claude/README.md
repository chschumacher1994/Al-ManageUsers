# Claude Code Setup für Business Central AL-Go Projekte

## Was ist das?
Ein vorkonfiguriertes Setup für Claude Code CLI, optimiert für agentic Business Central Extension Entwicklung mit:
- **MCP-Tool-Integration** (AL Symbol Research + Build/Test/Publish)
- **alguidelines.dev Vibe Coding Rules** (Microsoft/Community AL Best Practices)
- **AL-Go for GitHub** Workspace-Struktur

## Setup

### 1. Dateien kopieren
Kopiere folgende Dateien ins Root deines AL-Go Repos:
```
CLAUDE.md                          → Repo-Root
.claude/agents/*.md                → .claude/agents/
.claude/commands/*.md              → .claude/commands/
```

### 2. Anpassen
- In `CLAUDE.md`: Projektname `ManageUsersAndPermissions` ggf. durch deinen ersetzen
- Objekt-Prefix (z.B. `SMP`) in Naming-Beispielen anpassen falls nötig

### 3. Bestehende Struktur
Das Setup ist designed für deine bestehende AL-Go Struktur:
```
Al-ManageUsers/
├── .AL-Go/                        # AL-Go Konfiguration (nicht anfassen)
├── .claude/                       # ← NEU: Agents + Commands
│   ├── agents/
│   │   ├── bc-supervisor.md         # Orchestriert den gesamten Workflow
│   │   ├── solution-architect.md
│   │   ├── bc-symbol-researcher.md
│   │   ├── al-implementer.md
│   │   ├── al-tester.md
│   │   └── reviewer-compliance.md
│   └── commands/
│       ├── spec-feature.md
│       ├── plan-implementation.md
│       ├── implement-feature.md
│       ├── write-tests.md
│       ├── review-al.md
│       ├── research-standard.md
│       ├── diagnose.md
│       ├── save-plan.md             # /save-plan – Plan in Datei schreiben
│       ├── save-progress.md         # /save-progress – Fortschritt loggen
│       └── resume.md                # /resume – Arbeit fortsetzen
├── .github/                       # AL-Go Workflows (nicht anfassen)
├── ManageUsersAndPermissions/     # App-Projekt
│   ├── src/                       # ← Feature-basierte Struktur anlegen
│   ├── app.json
│   └── .vscode/
├── CLAUDE.md                      # ← NEU: Hauptinstruktionen
├── .mcp.json                      # MCP-Konfiguration (bereits vorhanden)
└── al.code-workspace
```

## Empfohlener Workflow

### Command-Referenz
| Command | Zweck |
|---------|-------|
| `/spec-feature [Beschreibung]` | MCP-Recherche + technische Spezifikation erstellen |
| `/plan-implementation [Feature]` | Schrittweisen Implementierungsplan erstellen |
| `/implement-feature [konkreter Teil]` | Einen Implementierungsschritt umsetzen + compile |
| `/write-tests [Feature/Bereich]` | Tests designen und implementieren (nur auf Anfrage) |
| `/review-al` | Code-Review gegen alguidelines.dev und BC-Patterns |
| `/research-standard [BC-Bereich]` | Standard-Objekte und Events via MCP recherchieren |
| `/diagnose` | Compile-Fehler analysieren und beheben |
| `/save-plan [Feature]` | Implementierungsplan in `PLAN.md` schreiben/aktualisieren |
| `/save-progress [auto]` | Fortschritt in `PROGRESS.md` loggen + `PLAN.md` updaten |
| `/resume` | `PLAN.md` + `PROGRESS.md` lesen und dort weitermachen |

### Option A: Supervisor (automatisch orchestriert)
Der `bc-supervisor` Agent übernimmt die gesamte Orchestrierung:
```
Nutze den bc-supervisor: Wir brauchen ein Modul für automatische Permission-Set-Zuweisung basierend auf Abteilungs-Setup.
```
Der Supervisor delegiert automatisch an die spezialisierten Sub-Agents in der richtigen Reihenfolge:
Research → Spec → Plan → Implement (schrittweise) → Test (nur auf Anfrage) → Review

### Option B: Manuell (volle Kontrolle)
```
/spec-feature Wir brauchen User-Management mit automatischer Permission-Set-Zuweisung.
/plan-implementation [Claude kennt die Spec noch aus dem Kontext]
/implement-feature Nur Setup + Datenmodell
/implement-feature Kernlogik-Codeunit
/implement-feature Subscriber + UI
/write-tests Permission-Zuweisung
/review-al
```
Hinweis: Innerhalb einer Session merkt sich Claude Code den Kontext.
Du musst nichts kopieren – ein kurzer Verweis reicht.

### Standard-BC-Recherche:
```
/research-standard User Setup und Permission Set Assignment
```

### Bei Compile-Fehlern:
```
/diagnose
```

### Session-Persistenz (Plan & Fortschritt speichern):
```
/save-plan Automatische Permission-Set-Zuweisung basierend auf Abteilungs-Setup
/implement-feature Setup + Datenmodell
/save-progress auto
# ... Session endet ...
# Neue Session:
/resume
```

`PLAN.md` und `PROGRESS.md` werden im Repo-Root angelegt und können committet werden.
So geht kein Kontext verloren wenn eine Session abbricht.

## Wie die Sub-Agents funktionieren

Alle Agent-Dateien haben YAML Frontmatter, das Claude Code braucht um sie als echte Sub-Agents zu erkennen:

```yaml
---
name: agent-name           # Eindeutiger Name
description: |             # Wann soll der Agent genutzt werden
  Use this agent when...
tools: Read, Grep, Glob    # Optional: Tool-Einschränkung (ohne = erbt alles)
model: sonnet              # Optional: sonnet/opus/haiku/inherit
---
```

Jeder Sub-Agent bekommt:
- **Eigenes Kontextfenster** – verschmutzt nicht den Haupt-Thread
- **Eigenen System-Prompt** – der Markdown-Body nach dem Frontmatter
- **Eigene Tool-Permissions** – z.B. Researcher nur Read, Implementer alles
- **Eigenes Modell** – Researcher auf Sonnet (günstig), Supervisor auf Opus (smart)

Der `bc-supervisor` läuft auf Opus und delegiert an die anderen Agents auf Sonnet.
So bekommst du Opus-Qualität für Orchestrierung bei Sonnet-Kosten für Umsetzung.

**Einschränkung**: Sub-Agents können keine weiteren Sub-Agents spawnen.
Der Supervisor ist der einzige der delegieren kann.

## Was dieses Setup besser macht

### vs. ChatGPT-Entwurf
| Aspekt | ChatGPT-Entwurf | Dieses Setup |
|--------|----------------|--------------|
| MCP-Integration | Nicht bekannt | Vollständig in allen Agents/Commands |
| alguidelines.dev | Nicht referenziert | Als autoritative Quelle integriert |
| AL-Go Awareness | Nicht berücksichtigt | App/Test-Trennung, Workflow-Schutz |
| Compile-Verification | Nicht vorhanden | Nach jedem Implementierungsschritt |
| File Naming | Eigene Konvention | alguidelines.dev Standard |
| Folder Structure | Object-type-basiert vorgeschlagen | Feature-basiert (alguidelines.dev) |
| Extra Commands | 5 Commands | 10 Commands (+research, diagnose, save-plan, save-progress, resume) |
| Session-Persistenz | Nicht vorhanden | PLAN.md + PROGRESS.md + /resume |
| Supervisor Agent | Nicht vorhanden | bc-supervisor orchestriert automatisch |
| YAML Frontmatter | Nicht vorhanden | Alle Agents mit model/tools/description |
| Test-Generierung | Immer | Nur auf Anfrage (alguidelines.dev Regel) |
| Subscriber-Pattern | Generisch | SingleInstance, domain-split, logic-separated |
| Error Handling | Grundregeln | TryFunction + Label + Telemetry Pattern |
| Performance Rules | Grundregeln | SetLoadFields, CalcSums, Dictionary/List |

### Quellen
- AL Vibe Coding Rules: https://alguidelines.dev/docs/agentic-coding/vibe-coding-rules/
- AL Best Practices: https://alguidelines.dev/docs/bestpractices/
- AL Design Patterns: https://alguidelines.dev/docs/patterns/
- AL-Go for GitHub: https://github.com/microsoft/AL-Go
