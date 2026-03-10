---
description: Logs implementation progress to PROGRESS.md so work can be resumed in a new session.
argument-hint: "[summary of what was done, or 'auto']"
---

Append a progress entry to `PROGRESS.md` at the repository root.
Also update step statuses in `PLAN.md` if it exists.

## If PROGRESS.md does not exist yet
Create it with this structure:

```markdown
# Implementation Progress

## [Feature Name]

### [Date] — Session [n]

**Completed:**
- [what was implemented, with file names]

**Key decisions:**
- [any design decisions made and why]

**MCP findings used:**
- [which standard objects/events were leveraged]

**Current state:**
- Compiles: ✅ | ❌
- Last step completed: [step # from PLAN.md]
- Next step: [step # from PLAN.md]

**Open issues:**
- [anything that needs attention]

---
```

## If PROGRESS.md already exists
1. Read the existing file.
2. Append a new session entry at the top (newest first).
3. Summarize what was accomplished in this session.
4. Note the compilation status (`al_compile` if possible).
5. Reference which PLAN.md step was completed and which is next.

## Also update PLAN.md
If PLAN.md exists, update the step statuses to reflect current progress.

## If argument is 'auto'
Review the current session context and git diff to automatically determine what was done.

## Constraints
- Keep entries compact – this is a recovery document, not documentation.
- Always include: files changed, compile status, current step, next step.
- Newest entries at the top for quick scanning.
