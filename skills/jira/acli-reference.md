# acli Command Reference

Common commands for the `acli-operator` subagent. Always append `--json` for structured output.

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

### Search (JQL)

```bash
acli jira workitem search \
  --jql "project = PROJ AND status = 'In Progress' AND assignee = currentUser()" \
  --json \
  --fields "key,summary,status,assignee,priority,issuetype" \
  --limit 20
```

### View

```bash
acli jira workitem view PROJ-123 --json
```

### Edit

```bash
acli jira workitem edit \
  --key "PROJ-123" \
  --summary "Updated title" \
  --yes \
  --json
```

### Transition Status

```bash
acli jira workitem transition \
  --key "PROJ-123" \
  --status "Done" \
  --yes \
  --json
```

### Comment

```bash
acli jira workitem comment create \
  --key "PROJ-123" \
  --body "Completed in commit abc1234. cc @username" \
  --json
```

### Assign

```bash
acli jira workitem assign \
  --key "PROJ-123" \
  --assignee "@me" \
  --json
```

## Projects

| Action | Command |
|--------|---------|
| List projects | `acli jira project list --json` |
| View project | `acli jira project view PROJ --json` |

## Boards & Sprints

| Action | Command |
|--------|---------|
| List boards | `acli jira board search --json` |
| List sprints | `acli jira board list-sprints --board-id 1 --state active --json` |
| Sprint items | `acli jira sprint list-workitems --sprint-id 1 --json` |

## Common JQL Queries

| Purpose | JQL |
|---------|-----|
| My open tasks | `assignee = currentUser() AND status != Done` |
| Current sprint | `sprint in openSprints() AND project = PROJ` |
| In Progress | `status = "In Progress" AND assignee = currentUser()` |
| Recently updated | `assignee = currentUser() AND updated >= -1d` |
| Unresolved bugs | `project = PROJ AND issuetype = Bug AND resolution = Unresolved` |
| Epic's stories | `"Epic Link" = PROJ-100` |
