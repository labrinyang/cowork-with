# acli Command Reference

All commands follow: `acli jira <resource> <action> [--flags] --json`

## Anti-patterns

- **Do NOT use `--board-id`** — correct: `--id` for `board list-sprints`
- **Do NOT use `--sprint-id`** — correct: `--sprint` for `sprint list-workitems`
- **Do NOT omit `--board`** on `sprint list-workitems` — it is required
- **Do NOT iterate boards to find an issue** — Board is a view-layer concept, use JQL
- **`workitem create` has no `--sprint` flag** — create first, then assign via edit or Jira UI

## Reference Files

| File | When to read |
|------|-------------|
| [workitems.md](workitems.md) | Create, search, view, edit, transition, assign issues |
| [workitems-advanced.md](workitems-advanced.md) | Comments, links, attachments, clone, bulk create |
| [boards-sprints.md](boards-sprints.md) | Board search, sprint CRUD, sprint work items |
| [jql.md](jql.md) | JQL queries, projects, filters |

## Authentication

| Action | Command |
|--------|---------|
| Browser login | `acli jira auth login --web` |
| Check status | `acli jira auth status` |
| Logout | `acli jira auth logout` |
| Switch account | `acli jira auth switch` |
