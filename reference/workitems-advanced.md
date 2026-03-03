# Work Items — Advanced Operations

## Comment

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

## Links

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

## Attachments

```bash
# List
acli jira workitem attachment list --key "PROJ-123" --json

# Delete
acli jira workitem attachment delete --id "12345"
```

## Clone

```bash
acli jira workitem clone \
  --key "PROJ-123" \
  --to-project "TEAM" \
  --yes \
  --json
```

## Bulk Create

```bash
acli jira workitem create-bulk --from-json issues.json
acli jira workitem create-bulk --from-csv issues.csv
acli jira workitem create-bulk --generate-json
```
