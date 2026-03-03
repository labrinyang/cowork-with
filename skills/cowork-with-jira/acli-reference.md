# acli Command Reference

Commands for the `acli-operator` subagent. Always append `--json` for structured output.

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

Supported `--type` values: `Story`, `Bug`, `Task`, `Epic`, `Sub-task`

Optional flags: `--parent "PROJ-100"` (for sub-tasks or linking to epics), `--description-file`, `--from-json`, `--editor`

> **Note:** `workitem create` has no `--sprint` flag. To add an issue to a sprint, create it first then use `workitem edit` or the Jira web UI.

### Search (JQL)

```bash
acli jira workitem search \
  --jql "project = PROJ AND status = 'In Progress' AND assignee = currentUser()" \
  --json \
  --fields "key,summary,status,assignee,priority,issuetype" \
  --limit 20
```

Additional flags: `--filter <ID>`, `--paginate`, `--count`, `--csv`, `--web`

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

Editable fields: `--summary`, `--description`, `--assignee`, `--labels`, `--type`, `--remove-assignee`, `--remove-labels`

Bulk edit: `--jql "..."` or `--filter <ID>` instead of `--key`

### Transition Status

```bash
acli jira workitem transition \
  --key "PROJ-123" \
  --status "Done" \
  --yes \
  --json
```

Bulk transition: `--jql "..."` or `--filter <ID>` instead of `--key`

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

Remove assignee: `--remove-assignee`

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
# From JSON file
acli jira workitem create-bulk --from-json issues.json

# From CSV file
acli jira workitem create-bulk --from-csv issues.csv

# Generate example JSON template
acli jira workitem create-bulk --generate-json
```

### Links

```bash
# Create link between issues
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
# List attachments
acli jira workitem attachment list --key "PROJ-123" --json

# Delete attachment
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

> **Anti-pattern:** Board is a Jira view-layer concept. You cannot reverse-lookup which board an issue belongs to. Do not iterate boards to locate an issue — use JQL search instead.

## Sprints

```bash
# List work items in a sprint (both --sprint and --board are REQUIRED)
acli jira sprint list-workitems --sprint 1 --board 6 --json

# Create sprint
acli jira sprint create --name "Sprint 1" --board 5 --json

# Create with dates and goal
acli jira sprint create --name "Sprint 2" --board 5 \
  --start "2025-01-01" --end "2025-01-14" --goal "Q1 release prep" --json

# View sprint details
acli jira sprint view --id 37 --json

# Update sprint
acli jira sprint update --id 37 --name "Sprint 1 - Final" --state closed --json

# Delete sprint
acli jira sprint delete --id 37 --yes
```

## Filters

```bash
# List my filters
acli jira filter list --my --json

# List favourites
acli jira filter list --favourite --json

# Search filters
acli jira filter search --json
acli jira filter search --name "report" --owner "user@atlassian.com" --json

# Get filter by ID
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
