Implement the requested feature or feature increment in this AL project.

## Process
1. **Inspect** the repository: structure, naming, nearby files.
2. **Research** with MCP tools if touching standard behavior:
   - `al_search_objects` → find standard objects
   - `al_get_object_definition` → check events and extensibility
3. **Restate** the implementation path in 3-5 bullet points.
4. **Implement** the smallest coherent increment.
5. **Verify**:
   - `al_compile` → zero errors
   - `al_getdiagnostics` → review warnings
6. **Summarize** changes, remaining work, and suggested tests.

## Constraints
- Follow CLAUDE.md and alguidelines.dev conventions.
- File naming: `<ObjectName>.<ObjectType>.al`.
- Feature-based folder structure under `src/`.
- Business logic in codeunits, not pages.
- Subscriber codeunits: SingleInstance, domain-split, no business logic.
- Every table field: Caption, ToolTip, DataClassification.
- Public procedures: XML documentation comments.
- 2-space indentation, PascalCase everywhere.
- If compile fails, fix before moving on.
- Be explicit about assumptions.
- Do not implement more than requested in one step.
- App code in App project only (AL-Go).
