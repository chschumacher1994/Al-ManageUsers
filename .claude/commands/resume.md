---
description: Reads PLAN.md and PROGRESS.md to resume work from where the last session left off.
argument-hint: ""
---

Resume implementation from the last saved state.

## Process
1. Read `PLAN.md` – understand the overall plan and which steps are done.
2. Read `PROGRESS.md` – understand what happened in the last session, key decisions, and open issues.
3. Identify the next step (first step with ⬜ TODO or 🔄 IN PROGRESS status).
4. Summarize for the user:
   - What was already completed
   - What the next step is
   - Any open issues or questions from last time
5. Ask the user to confirm before proceeding.
6. If confirmed, start implementing the next step via the al-implementer workflow.

## If files don't exist
Tell the user:
- No PLAN.md found → suggest running `/save-plan [feature description]` first
- No PROGRESS.md found → that's fine, just work from PLAN.md

## Constraints
- Do NOT skip the summary step. The user needs to see where things stand.
- Do NOT start implementing without confirmation.
- Re-run MCP research if the progress notes mention unresolved standard object questions.
- Follow CLAUDE.md and alguidelines.dev conventions.
