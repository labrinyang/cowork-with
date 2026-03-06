#!/usr/bin/env bash
set -euo pipefail

# PostToolUse hook script: detect new branch creation without a Jira issue key.
# Runs on every Bash PostToolUse event. Exits silently for non-branch commands.

INPUT=$(cat)

TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Only process Bash tool calls
if [[ "$TOOL_NAME" != "Bash" ]]; then
  exit 0
fi

# Detect branch creation: git checkout -b, git switch -c
if ! echo "$COMMAND" | grep -qE 'git\s+(checkout\s+-b|switch\s+-c)\s'; then
  exit 0
fi

# Extract the new branch name (first arg after -b/-c)
BRANCH_NAME=$(echo "$COMMAND" | sed -nE 's/.*git[[:space:]]+(checkout[[:space:]]+-b|switch[[:space:]]+-c)[[:space:]]+([^ ]+).*/\2/p')

if [[ -z "$BRANCH_NAME" ]]; then
  exit 0
fi

# If branch name already contains a Jira issue key (e.g., PROJ-123), skip
if echo "$BRANCH_NAME" | grep -qE '[A-Z]+-[0-9]+'; then
  exit 0
fi

# Inject context telling Claude to search for related issues and suggest renaming
jq -n \
  --arg branch "$BRANCH_NAME" \
  '{
    "hookSpecificOutput": {
      "hookEventName": "PostToolUse",
      "additionalContext": ("A new branch \u0027" + $branch + "\u0027 was created without a Jira issue key. Search for in-progress Jira issues assigned to the user using searchJiraIssuesUsingJql with JQL: \"status = \u0027In Progress\u0027 AND assignee = currentUser()\". If a related issue is found, suggest renaming the branch to include the issue key using: git branch -m " + $branch + " <prefix>/PROJ-123-<slug>. Follow the branch naming convention: feat/PROJ-123-slug or fix/PROJ-123-slug.")
    }
  }'

exit 0
