Create a step-by-step implementation plan for the requested Business Central feature.

## Process
1. If no spec exists yet, run a quick MCP research phase first.
2. Inspect the current repository structure and conventions.
3. Break the feature into the smallest safe increments.
4. Order increments: Setup → Data model → Core logic → Subscribers/Events → UI → Permissions → Tests.
5. For each step: identify files to create/change (with alguidelines.dev file naming), complexity, and dependencies.

## Output

### Prerequisites
What needs to be in place before starting?

### Implementation steps
| # | Step | Files (using ObjectName.ObjectType.al) | Depends on | Complexity |
|---|------|---------------------------------------|------------|------------|

### Assumptions
What are we assuming? List explicitly.

### Test scope
Which test scenarios belong to which implementation step?

### Risks & rollback
What could go wrong? How to recover?

## Constraints
- Keep each step independently compilable (`al_compile` should pass).
- Each step should be a reviewable unit.
- Respect AL-Go project separation.
- Follow CLAUDE.md and alguidelines.dev conventions.
