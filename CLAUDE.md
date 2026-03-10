# Claude Code Instructions – Business Central AL Extension (AL-Go)

## Project context
This is a Microsoft Dynamics 365 Business Central extension built with AL, managed via AL-Go for GitHub.
The workspace follows the AL-Go multi-project structure with separate App and Test projects.

## Reference: AL Guidelines
This project follows the community and Microsoft-maintained AL coding guidelines at https://alguidelines.dev.
When in doubt about AL patterns, naming, style, or architecture, consult https://alguidelines.dev/docs/agentic-coding/vibe-coding-rules/ as the authoritative source.

## Available MCP tools
You have two MCP tool sets. **Use them actively** – do not guess about standard objects, symbols, or dependencies.

### AL MCP Server (read / research)
| Tool | Use for |
|---|---|
| `al_search_objects` | Find standard or custom AL objects by name or type |
| `al_get_object_summary` | Quick overview of an object's structure |
| `al_get_object_definition` | Full definition including fields, procedures, triggers |
| `al_search_object_members` | Find specific fields/procedures inside objects |
| `al_find_references` | Trace where an object or member is used |
| `al_packages` | List available symbol packages and their versions |

### AL Extension Tools (build / test / publish)
| Tool | Use for |
|---|---|
| `al_downloadsymbols` | Download symbols before analysis or build |
| `al_compile` | Compile AL code and check for errors |
| `al_build` | Full project build |
| `al_getdiagnostics` | Retrieve current compiler diagnostics |
| `al_publish` | Publish extension to development environment |
| `al_run_tests` | Execute test codeunits |
| `al_symbolsearch` | Search across all available symbols |
| `al_getpackagedependencies` | Check dependency graph |
| `al_auth_login` / `al_auth_logout` | Authenticate against BC environment |

---

## Core principles (per alguidelines.dev)
- Follow event-driven programming model; never modify standard application objects.
- Use clear, meaningful names and maintain consistent code structure.
- Prioritize performance optimization and proper error handling.
- Focus on main application implementation by default.
- Only generate test code when explicitly requested.
- Maintain proper AL-Go workspace structure separation.

## General working style
- **Research first**: Before proposing anything, use MCP tools to inspect standard objects, events, and extension points.
- Analyze → plan → implement. Never jump to code.
- Prefer small, reviewable increments over large rewrites.
- Before creating new objects, verify with `al_search_objects` and `al_find_references` whether an existing object, event, or subscriber pattern is more appropriate.
- Prioritize correctness of business logic over immediate compilation. If AI-suggested standard function names or event parameters may be incorrect, leave space for manual fixes rather than altering the intended behavior.

## Mandatory MCP research workflow
Before implementing any feature that touches standard BC behavior:
1. `al_search_objects` → find relevant standard tables, pages, codeunits
2. `al_get_object_definition` → inspect for integration events, business events, extensible enums
3. `al_search_object_members` → find specific fields or procedures you need to interact with
4. `al_find_references` → understand coupling and side effects
5. Only then design the implementation approach

Before considering any implementation complete:
1. `al_compile` → verify zero errors
2. `al_getdiagnostics` → check warnings and info messages
3. If tests exist: `al_run_tests` → verify test pass

---

## AL-Go workspace structure
This project uses AL-Go for GitHub. Respect the separation:
- **App project** (e.g. `ManageUsersAndPermissions/`): Contains all application logic – tables, pages, codeunits, reports, enums, permissions.
- **Test project** (separate folder when created): Contains all test code. References the App project as a dependency.
- **Never mix**: Application code stays in App, test code stays in Test project.
- `.AL-Go/` contains AL-Go configuration. Do not modify without explicit request.
- `.github/workflows/` contains AL-Go generated workflows. Do not modify directly.

## File naming (per alguidelines.dev)
Use the pattern: `<ObjectName>.<ObjectType>.al`

Examples:
```
CustomerCard.Page.al
SalesHeader.Table.al
PostSalesInvoice.Codeunit.al
ItemLedgerEntry.Report.al
InventorySetup.PageExt.al
SalesHeader.TableExt.al
INoSeries.Interface.al
NoSeriesImpl.Codeunit.al
SalesPostingTests.Codeunit.al
```

## Folder structure (per alguidelines.dev)
Organize by business feature, NOT by object type:

```
ManageUsersAndPermissions/
├── src/
│   ├── UserManagement/
│   │   ├── UserSetup.Table.al
│   │   ├── UserSetupCard.Page.al
│   │   └── UserPermissionMgt.Codeunit.al
│   ├── Permissions/
│   │   ├── PermissionSetAssignment.Table.al
│   │   └── PermissionSetAssignmentMgt.Codeunit.al
│   └── Common/
│       ├── Helpers/
│       └── Interfaces/
├── .vscode/
│   └── launch.json
└── app.json
```

Bad (avoid):
```
src/
├── Tables/
├── Pages/
└── Codeunits/
```

## Code style (per alguidelines.dev)
- **Indentation**: 2 spaces, consistent throughout.
- **Casing**: PascalCase for all variable names, function names, and object names.
- **Procedures**: Small, focused, one responsibility. < 30 lines guideline.
- **Modular**: Break complex operations into ValidateX, CalculateY, CreateZ steps.
- **XML documentation**: Global/public procedures in codeunits require `/// <summary>` comments.
- **Self-documenting code**: Avoid comments for obvious operations. Use clear naming instead.

## Naming conventions (per alguidelines.dev)
- **Object names**: PascalCase, max 26 characters for name (reserving 3+1 for prefix/affix). Descriptive and purpose-indicating.
- **Variables**: PascalCase, descriptive. `CustomerLedgerEntry` not `CustLE`. `TotalAmount` not `Amt`.
- **Procedures**: `CalculateCustomerBalance`, `ValidateSalesOrderLine` – verb + context.
- **Event subscribers**: Descriptive names indicating intent: `AddDefaultValuesOnBeforeInsertSalesHeader`.
- **Interfaces**: Prefix with `I` (e.g. `ICustomerService`). Implementations use `Impl` suffix.
- **Temporary variables**: Prefix with `Temp` (e.g. `TempSalesLine`).
- **Labels**: Use `Lbl` suffix. Telemetry labels use `Locked = true`.

## AL architecture rules
- Tables / TableExtensions → data structure only
- Pages / PageExtensions → UI only, no business logic
- Codeunits → business logic, always
- Enums / EnumExtensions → controlled value sets
- Interfaces → replaceable behavior contracts
- Reports / ReportExtensions → output and data processing
- Avoid business logic in pages. If you need more than field-level validation, extract to a codeunit.

## Event-driven development (per alguidelines.dev)
- Prefer integration events over direct modifications for extensibility.
- Use `SingleInstance = true` for subscriber codeunits (performance).
- Keep subscriber codeunits small – split by module/domain.
- Put business logic in separate "Method Codeunits", not in the subscriber itself.
- Use descriptive parameter names in event subscribers, not generic `Rec`.
- Avoid generic OnInsert/OnModify/OnDelete subscribers – only subscribe when necessary.
- Before creating custom workaround logic, search for existing events via MCP tools.

## Performance (per alguidelines.dev)
- Filter data as early as possible with `SetRange`/`SetFilter` before processing.
- Use `SetLoadFields` to minimize data retrieval – place before `Get`/`Find`.
- Use `CalcSums`/`CalcFields` instead of manual loops for aggregation.
- Use `Dictionary` and `List` for temporary in-memory data where appropriate.
- Minimize loops; favor set-based operations.
- Avoid nested loops – use queries or dictionaries.
- Always analyze performance impact when adding new features.

## Error handling (per alguidelines.dev)
- Use TryFunctions for error handling where rollback is required.
- Provide meaningful error messages using Label variables with `Comment` parameters.
- Use separate telemetry labels (`Locked = true`) for logging vs. user-facing labels for messages.
- Implement proper exception handling for external service calls.
- Prioritize correctness over immediate compilation – if logic is correct but names may need verification, preserve the logic and mark for manual review.

## Object design rules
- Every table field needs: `Caption`, `ToolTip`, `DataClassification`.
- Every new table needs: `DrillDownPageId`, `LookupPageId` where applicable.
- Permission sets: create dedicated objects, never rely on SUPER.
- Reuse setup tables for feature toggles. One central setup per module preferred.
- Use `internal` access modifier where appropriate.

## Modification strategy
When standard behavior is affected:
1. Use `al_search_objects` to find the standard object
2. Use `al_get_object_definition` to inspect events and extensibility
3. Use `al_find_references` to understand impact radius
4. Check for: Integration Events, Business Events, extensible enums, OnBefore/OnAfter triggers
5. Only create workaround logic if no reasonable extension point exists
6. If no event exists, document this as a limitation

## Testing rules (per alguidelines.dev)
- **Only generate tests when explicitly requested.**
- Test project is separate from App project (AL-Go structure).
- Test pattern: `[GIVEN]` → `[WHEN]` → `[THEN]`.
- Test categories: happy path, setup missing/disabled, invalid input/boundaries, permissions, posting side effects.
- Use Library* codeunits for test data.
- Descriptive test procedure names: `ApprovalAboveThresholdRequiresManagerSignoff`.
- Tests must be isolated and deterministic.

## Review checklist
Before considering work done:
- [ ] `al_compile` → zero errors
- [ ] `al_getdiagnostics` → no unexpected warnings
- [ ] File naming follows `<ObjectName>.<ObjectType>.al` pattern
- [ ] Folder structure is feature-based
- [ ] Naming consistent with repo and alguidelines.dev conventions
- [ ] No unused variables or dead code
- [ ] Permission sets cover new objects/fields
- [ ] DataClassification set on all table fields
- [ ] Captions and ToolTips present
- [ ] Upgrade-safe (no breaking schema changes without migration)
- [ ] Events used where available (verified with MCP)
- [ ] Subscriber codeunits use SingleInstance
- [ ] Business logic in codeunits, not pages
- [ ] Performance patterns applied (SetLoadFields, early filtering, CalcSums)
- [ ] Error handling uses TryFunctions + Labels where appropriate
- [ ] Test scenarios covered or documented (if tests requested)
- [ ] app.json dependencies reviewed if new packages referenced

## BC-specific caution zones
- **Posting / Ledger logic**: Extra caution. Document all assumptions. Test extensively.
- **Setup / Configuration**: Include initialization logic and default values.
- **Schema changes**: Flag explicitly. Consider upgrade codeunits.
- **app.json / Dependencies**: Flag any changes. Check with `al_getpackagedependencies`.
- **Page changes**: Note user experience impact.

## Command behavior
When I say "implement":
1. Inspect repo structure and nearby files first
2. Run MCP research on involved standard objects
3. Propose the smallest safe implementation path
4. Implement in coherent steps
5. Compile and verify

When I say "review":
1. Review from AL quality, BC patterns, tests, permissions, upgrade safety, maintainability
2. Use MCP tools to verify claims about standard objects
3. Be critical and concrete – reference exact files and patterns
4. Check against alguidelines.dev rules

## AI response behavior (per alguidelines.dev)
- Provide concise, actionable advice with specific AL method references.
- Always explain the reasoning behind recommendations.
- Reference Business Central architecture patterns and established best practices.
- Focus on practical implementation guidance that can be immediately applied.

## If information is missing
- State the assumption explicitly
- Make the most reasonable assumption based on BC standard patterns
- Use MCP tools to verify where possible
- Continue with best-effort implementation – don't block

## Definition of done
A change is complete when:
- Technical approach is documented
- MCP research on standard objects is done
- Code compiles (`al_compile`)
- File naming and folder structure follow alguidelines.dev conventions
- Impacted objects are identified
- Test scenarios are covered or listed (if tests were requested)
- Risks and assumptions are documented
- Permission implications are addressed
