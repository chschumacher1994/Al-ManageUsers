Review the current changes as a senior Business Central AL reviewer.

## Process
1. Read all changed/new files in the repository.
2. `al_compile` → verify compilation status.
3. `al_getdiagnostics` → check warnings and info.
4. `al_find_references` → verify no unintended coupling.
5. `al_getpackagedependencies` → check dependency health.
6. Apply all review dimensions from CLAUDE.md and alguidelines.dev rules.

## Review dimensions
- alguidelines.dev compliance (file naming, folder structure, code style, naming, performance, events, error handling)
- Architecture fit (responsibilities, patterns)
- AL code quality (no dead code, small procedures, XML docs on public methods)
- BC extension compliance (DataClassification, Captions, Permissions)
- Upgrade safety (schema, enums, IDs)
- Test coverage (what's missing?)
- app.json / dependency impact
- AL-Go structure (App/Test separation)

## Output
1. **Compilation**: pass/fail + diagnostics
2. **Critical issues** (must fix)
3. **Important improvements** (should fix)
4. **Suggestions** (nice to have)
5. **Missing tests**
6. **Release assessment**: GO / NO-GO

## Constraints
- Be concrete: exact files, exact problems, exact suggestions.
- Verify claims about standard objects via MCP tools.
- Follow CLAUDE.md review checklist.
