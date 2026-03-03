#!/usr/bin/env bash
set -euo pipefail

# PostToolUse hook script: detect git commits and inject Jira task check context.
# Runs on every Bash PostToolUse event. Exits silently for non-commit commands.

INPUT=$(cat)

TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Only process Bash tool calls
if [[ "$TOOL_NAME" != "Bash" ]]; then
  exit 0
fi

# Only process git commit commands
if ! echo "$COMMAND" | grep -qE '^\s*git\s+commit\b'; then
  exit 0
fi

# Extract branch name for context
BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")

# Extract commit output
COMMIT_OUTPUT=$(echo "$INPUT" | jq -r '.tool_response // empty' | head -5)

# Inject context telling Claude to check in-progress Jira tasks
jq -n \
  --arg branch "$BRANCH" \
  --arg commit_info "$COMMIT_OUTPUT" \
  '{
    "hookSpecificOutput": {
      "hookEventName": "PostToolUse",
      "additionalContext": ("A git commit was made on branch \u0027" + $branch + "\u0027. Check if there are in-progress Jira tasks assigned to the user that should be closed. Use acli-operator to search: acli jira workitem search --jql \"status = \u0027In Progress\u0027 AND assignee = currentUser()\" --json. If any tasks appear related to this commit, ask the user if they want to close the task. On approval: (1) transition to Done, (2) add a closing comment, (3) @mention the creator in the comment if the issue was NOT created by the current user.")
    }
  }'

exit 0
