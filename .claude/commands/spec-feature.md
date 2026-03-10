Create a functional and technical specification for the requested Business Central feature.

## Process
1. Understand the business requirement.
2. **MCP research phase** (mandatory):
   - `al_search_objects` → find relevant standard objects
   - `al_get_object_definition` → inspect events, fields, extensibility
   - `al_find_references` → understand coupling
   - `al_packages` → verify available packages
3. Summarize MCP findings.
4. Identify impacted domains and modules.
5. Propose AL objects to create or change (with file names per alguidelines.dev convention).
6. Identify extension points to leverage.
7. Document risks, assumptions, and dependency implications.
8. Define test scenarios (list only, don't implement).
9. Recommend implementation sequence: Setup → Data → Logic → Subscribers → UI → Permissions → Tests.

## Constraints
- Follow CLAUDE.md and alguidelines.dev conventions strictly.
- Prefer extension-safe, modular solutions.
- Do NOT write implementation code unless explicitly asked.
- Every claim about standard objects must be verified via MCP tools.
