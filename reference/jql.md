# JQL Queries, Projects & Filters

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

## Projects

| Action | Command |
|--------|---------|
| List projects | `acli jira project list --json` |
| List all (paginated) | `acli jira project list --paginate --json` |
| View project | `acli jira project view --key "PROJ" --json` |

## Filters

```bash
acli jira filter list --my --json
acli jira filter list --favourite --json
acli jira filter search --json
acli jira filter search --name "report" --owner "user@atlassian.com" --json
acli jira filter get --id 12345 --json
```
