# Work Items — Core Operations

## Create

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

## Search (JQL)

```bash
acli jira workitem search \
  --jql "project = PROJ AND status = 'In Progress' AND assignee = currentUser()" \
  --json \
  --fields "key,summary,status,assignee,priority,issuetype" \
  --limit 20
```

Optional: `--filter <ID>`, `--paginate`, `--count`, `--csv`, `--web`

## View

```bash
acli jira workitem view PROJ-123 --json
```

Optional: `--fields "summary,comment"`, `--web`

## Edit

```bash
acli jira workitem edit \
  --key "PROJ-123" \
  --summary "Updated title" \
  --yes \
  --json
```

Editable: `--summary`, `--description`, `--assignee`, `--labels`, `--type`, `--remove-assignee`, `--remove-labels`

Bulk: `--jql "..."` or `--filter <ID>` instead of `--key`

## Transition Status

```bash
acli jira workitem transition \
  --key "PROJ-123" \
  --status "Done" \
  --yes \
  --json
```

Bulk: `--jql "..."` or `--filter <ID>` instead of `--key`

## Assign

```bash
acli jira workitem assign \
  --key "PROJ-123" \
  --assignee "@me" \
  --json
```

Remove: `--remove-assignee`
