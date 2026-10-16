# Jira Subtask Rules

When planning or managing Jira subtasks:

- Read the parent ticket, comments, Story Points, creator, assignee, and existing subtasks before proposing changes. Deduplicate repeated ticket references.
- Treat parent Story Points as implementation effort only; QC effort is tracked separately and does not satisfy the implementation breakdown.
- A parent ticket above 3 Story Points must have at least one implementation subtask. Do not create subtasks for tickets at or below 1 Story Point unless the user explicitly asks.
- Show the proposed create/edit list and wait for explicit user approval before any Jira write.
- Only edit an existing subtask when its creator is the current user. Leave subtasks created by other users unchanged, including QC subtasks.
- New or edited implementation subtasks use a Vietnamese title beginning with `[App]`, a detailed Vietnamese description focused on the task content, the `App` label, and the current user as assignee. The description must be specific enough for another developer to implement independently: state the objective, affected flow/components/API or state, expected behavior, and relevant edge cases when applicable. Keep it task-specific; do not add generic boilerplate or QC scope.
- Do not assign Story Points to subtasks.
