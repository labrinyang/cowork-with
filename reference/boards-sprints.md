# Boards & Sprints

## Boards

| Action | Command |
|--------|---------|
| Search boards | `acli jira board search --json` |
| Search by project | `acli jira board search --project "PROJ" --json` |
| Search by type | `acli jira board search --type scrum --json` |
| Get board details | `acli jira board get --id 123 --json` |
| List sprints | `acli jira board list-sprints --id 123 --state active --json` |

> Board is a view-layer concept. Do not iterate boards to locate an issue — use JQL.

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
