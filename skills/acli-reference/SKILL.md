---
name: acli-reference
description: Atlassian acli CLI command reference for Jira operations. Contains exact parameter names, command templates, and common JQL queries. Pre-loaded into acli-operator subagent.
---

# acli Command Reference

Always append `--json` for structured output. Use `--yes` on write commands to skip prompts.

## Anti-patterns

- **Do NOT use `--board-id`** — the correct flag is `--id` for `board list-sprints`
- **Do NOT use `--sprint-id`** — the correct flag is `--sprint` for `sprint list-workitems`
- **Do NOT omit `--board`** on `sprint list-workitems` — it is required
- **Do NOT iterate boards to find an issue** — Board is a view-layer concept, use JQL search instead
- **`workitem create` has no `--sprint` flag** — create first, then assign to sprint via edit or Jira UI

## Authentication

| Action | Command |
|--------|---------|
| Browser login | `acli jira auth login --web` |
| Check status | `acli jira auth status` |
| Logout | `acli jira auth logout` |
| Switch account | `acli jira auth switch` |

## Work Items

### Create

```bash
acli jira workitem create \
  --summary "Short description" \
  --project "PROJ" \
  --type "Story" \
  --assignee "@me" \
  --label "story" \
  --description "## Background\n..." \
  --json
```

Supported `--type`: `Story`, `Bug`, `Task`, `Epic`, `Sub-task`

Optional: `--parent "PROJ-100"`, `--description-file`, `--from-json`, `--editor`

### Search (JQL)

```bash
acli jira workitem search \
  --jql "project = PROJ AND status = 'In Progress' AND assignee = currentUser()" \
  --json \
  --fields "key,summary,status,assignee,priority,issuetype" \
  --limit 20
```

Optional: `--filter <ID>`, `--paginate`, `--count`, `--csv`, `--web`

### View

```bash
acli jira workitem view PROJ-123 --json
```

Optional: `--fields "summary,comment"`, `--web`

### Edit

```bash
acli jira workitem edit \
  --key "PROJ-123" \
  --summary "Updated title" \
  --yes \
  --json
```

Editable: `--summary`, `--description`, `--assignee`, `--labels`, `--type`, `--remove-assignee`, `--remove-labels`

Bulk: `--jql "..."` or `--filter <ID>` instead of `--key`

### Transition Status

```bash
acli jira workitem transition \
  --key "PROJ-123" \
  --status "Done" \
  --yes \
  --json
```

Bulk: `--jql "..."` or `--filter <ID>` instead of `--key`

### Comment

```bash
# Create
acli jira workitem comment create \
  --key "PROJ-123" \
  --body "Completed in commit abc1234. cc @username" \
  --json

# List
acli jira workitem comment list --key "PROJ-123" --json

# Update
acli jira workitem comment update --key "PROJ-123" --id "10001" --body "Updated text"

# Delete
acli jira workitem comment delete --key "PROJ-123" --id "10001"
```

### Assign

```bash
acli jira workitem assign \
  --key "PROJ-123" \
  --assignee "@me" \
  --json
```

Remove: `--remove-assignee`

### Clone

```bash
acli jira workitem clone \
  --key "PROJ-123" \
  --to-project "TEAM" \
  --yes \
  --json
```

### Bulk Create

```bash
acli jira workitem create-bulk --from-json issues.json
acli jira workitem create-bulk --from-csv issues.csv
acli jira workitem create-bulk --generate-json
```

### Links

```bash
# Create link
acli jira workitem link create --out "PROJ-1" --in "PROJ-2" --type "Blocks" --yes

# List links
acli jira workitem link list --key "PROJ-123" --json

# Delete link
acli jira workitem link delete --id "10001" --yes

# List available link types
acli jira workitem link type --json
```

### Attachments

```bash
# List
acli jira workitem attachment list --key "PROJ-123" --json

# Delete
acli jira workitem attachment delete --id "12345"
```

## Projects

| Action | Command |
|--------|---------|
| List projects | `acli jira project list --json` |
| List all (paginated) | `acli jira project list --paginate --json` |
| View project | `acli jira project view --key "PROJ" --json` |

## Boards

| Action | Command |
|--------|---------|
| Search boards | `acli jira board search --json` |
| Search by project | `acli jira board search --project "PROJ" --json` |
| Search by type | `acli jira board search --type scrum --json` |
| Get board details | `acli jira board get --id 123 --json` |
| List sprints | `acli jira board list-sprints --id 123 --state active --json` |

## Sprints

```bash
# List work items (both --sprint and --board REQUIRED)
acli jira sprint list-workitems --sprint 1 --board 6 --json

# Create
acli jira sprint create --name "Sprint 1" --board 5 --json

# Create with dates
acli jira sprint create --name "Sprint 2" --board 5 \
  --start "2025-01-01" --end "2025-01-14" --goal "Q1 release prep" --json

# View
acli jira sprint view --id 37 --json

# Update
acli jira sprint update --id 37 --name "Sprint 1 - Final" --state closed --json

# Delete
acli jira sprint delete --id 37 --yes
```

## Filters

```bash
acli jira filter list --my --json
acli jira filter list --favourite --json
acli jira filter search --json
acli jira filter search --name "report" --owner "user@atlassian.com" --json
acli jira filter get --id 12345 --json
```

## Common JQL Queries

| Purpose | JQL |
|---------|-----|
| My open tasks | `assignee = currentUser() AND status != Done` |
| Current sprint | `sprint in openSprints() AND project = PROJ` |
| My sprint tasks | `sprint in openSprints() AND assignee = currentUser()` |
| In Progress | `status = "In Progress" AND assignee = currentUser()` |
| Recently updated | `assignee = currentUser() AND updated >= -1d` |
| Unresolved bugs | `project = PROJ AND issuetype = Bug AND resolution = Unresolved` |
| Epic's stories | `"Epic Link" = PROJ-100` |
