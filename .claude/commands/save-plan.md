---
description: Writes or updates the implementation plan to PLAN.md for session persistence.
argument-hint: "[Feature-Beschreibung oder 'update']"
---

Write or update the implementation plan in `PLAN.md` at the repository root.

## If PLAN.md does not exist yet
1. Run MCP research on the requested feature (if not already done in this session).
2. Create a structured plan following this template:

```markdown
# Implementation Plan: [Feature Name]

## Status: IN PROGRESS | COMPLETED | BLOCKED
Last updated: [date]

## Feature Summary
[One paragraph: what does this solve?]

## MCP Research Summary
[Key findings: relevant standard objects, events, extension points]

## Implementation Steps

### Step 1: [Title] — ⬜ TODO | 🔄 IN PROGRESS | ✅ DONE | ❌ BLOCKED
**Files**: [list of files to create/change]
**Description**: [what this step does]
**Dependencies**: [what needs to be done first]
**Notes**: [decisions, assumptions, gotchas]

### Step 2: [Title] — ⬜ TODO
...

## Open Questions
- [anything that needs clarification]

## Decisions Log
| # | Decision | Reason | Date |
|---|----------|--------|------|
```

Order steps as: Setup → Data model → Core logic → Subscribers → UI → Permissions → Tests

## If PLAN.md already exists
1. Read the current plan.
2. Update step statuses based on what was accomplished in this session.
3. Add any new decisions to the Decisions Log.
4. Update "Last updated" timestamp.
5. Add new open questions if any emerged.

## Constraints
- Follow alguidelines.dev file naming in the Files lists.
- Keep it concise – this is a working document, not a spec.
- Status emojis must be consistent: ⬜ TODO, 🔄 IN PROGRESS, ✅ DONE, ❌ BLOCKED.
