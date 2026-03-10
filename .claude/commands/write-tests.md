Design and implement tests for the requested Business Central feature.

## Process
1. Inspect the feature implementation to understand what needs testing.
2. Use `al_search_objects` to find available test library codeunits.
3. Check existing test patterns in the repo.
4. Design test scenarios covering ALL mandatory categories:
   - Happy path
   - Setup missing / disabled
   - Invalid input / boundaries
   - Permission-relevant behavior
   - Posting side effects (if applicable)
5. Implement test codeunit(s) in the Test project (AL-Go separation).
6. `al_compile` → verify compilation.
7. `al_run_tests` → execute if environment is available.

## Output
- Test scenario matrix
- Test setup requirements
- Test codeunit code (file named `<Feature>Tests.Codeunit.al`)
- Execution results (if available)
- Coverage gaps with justification

## Constraints
- Test code goes into the Test project, not the App project.
- GIVEN/WHEN/THEN pattern.
- Isolated and deterministic.
- Use Library* codeunits for data creation.
- Descriptive procedure names.
- Follow CLAUDE.md and alguidelines.dev conventions.
