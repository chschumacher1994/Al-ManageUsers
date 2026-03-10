Research standard Business Central objects, events, and extension points for the given topic.

## Process
1. `al_search_objects` with multiple keyword variations for the requested area.
2. For each relevant result: `al_get_object_summary` → quick relevance check.
3. For the most relevant objects: `al_get_object_definition` → full inspection.
4. `al_search_object_members` → find specific fields or procedures.
5. `al_find_references` → understand how standard objects connect.
6. `al_packages` → verify package availability.

## Output

### Standard objects found
| Type | ID | Name | Relevance to request |
|------|----|------|---------------------|

### Extension points available
| Object | Event/Hook | Parameters | Use case |
|--------|-----------|------------|----------|

### Key fields and procedures
Most important members for the requested feature area.

### Dependency notes
Package requirements and version constraints.

### Gaps
Where standard extensibility is missing.

### Recommendation
How to best leverage standard BC for this feature.

## Constraints
- Every finding must come from MCP tool results, not memory.
- If search returns nothing, try alternative keywords.
- Be explicit about what was NOT found.
