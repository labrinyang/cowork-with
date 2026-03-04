---
name: cowork-with-onboarding
description: Guides setup of the Atlassian Rovo MCP server for Jira integration. Use when the user needs to set up Jira access or mentions Jira MCP setup.
disable-model-invocation: true
allowed-tools: Bash, Read, AskUserQuestion
---

# Onboarding

Walk the user through setting up their environment for the cowork-with plugin. Check each step and skip any that are already complete.

## Step 1: Verify MCP Server

The Atlassian Rovo MCP server is automatically configured by the plugin. Verify it's loaded:

```bash
claude mcp list
```

If `atlassian` appears in the list, the server is ready. If not, the plugin may not have loaded correctly — ask the user to restart Claude Code and re-run this onboarding.

## Step 2: Authenticate with Jira

Call any Atlassian MCP tool (e.g., `getVisibleJiraProjects`) to trigger the OAuth browser flow:

1. A browser window opens automatically
2. The user selects their Atlassian site and grants access
3. Authentication completes — the tool call returns Jira data

If the tool call succeeds, authentication is complete.

## Step 3: Claude Code Permissions (Optional)

For a smoother workflow, suggest adding Atlassian MCP tools to the project's allow list. Show the user what to add to `.claude/settings.json` or `.claude/settings.local.json`:

```json
{
  "permissions": {
    "allow": [
      "mcp__atlassian__*"
    ]
  }
}
```

This prevents repeated permission prompts for Jira MCP tool calls.

## Completion

After all steps pass, confirm readiness and display available commands:

**Setup Status:**
- Atlassian Rovo MCP: configured and authenticated
- Jira: accessible

**Available Commands:**

| Command | Description |
|---------|-------------|
| `/cowork-with:cowork-with-jira` | Jira workflow — issue creation, status transitions, sprint queries, epic management |
| `/cowork-with:cowork-with-onboarding` | Re-run this setup guide |
