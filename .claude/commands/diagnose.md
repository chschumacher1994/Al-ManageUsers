Diagnose and fix current compilation or runtime issues in this AL project.

## Process
1. `al_getdiagnostics` → get all current errors and warnings.
2. `al_compile` → attempt compilation to get fresh error state.
3. For each error:
   - Identify the root cause
   - Use `al_get_object_definition` or `al_search_object_members` if the error involves unknown members
   - Use `al_find_references` if the error involves broken references
   - Use `al_getpackagedependencies` if the error is dependency-related
4. Fix errors in order of dependency (fix causes before symptoms).
5. `al_compile` again → verify fixes.
6. Repeat until clean.

## Output
- Initial diagnostics summary
- Root cause analysis per error
- Fixes applied (with file references)
- Final compilation status
- Remaining warnings with assessment

## Constraints
- Fix the actual cause, not symptoms.
- If a fix requires design changes, flag this before implementing.
- Follow CLAUDE.md and alguidelines.dev conventions in all fixes.
- Preserve intended business logic even if names need correction.
