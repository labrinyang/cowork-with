---
name: cowork-with-onboarding
description: Guides setup of the Atlassian Rovo MCP server for Jira integration. Use when the user needs to set up Jira access or mentions Jira MCP setup.
disable-model-invocation: true
allowed-tools: Bash, Read, AskUserQuestion
---

# Onboarding

Walk the user through setting up their environment for the cowork-with plugin. Check each step and skip any that are already complete.

## Step 1: Add the Atlassian Rovo MCP Server

Check if the MCP server is already configured:

```bash
claude mcp list
```

If `atlassian` is not listed, add it:

```bash
claude mcp add --transport sse atlassian https://mcp.atlassian.com/v1/sse
```

## Step 2: Restart Claude Code

The MCP server won't be available until Claude Code is restarted. Tell the user:

> Press **Ctrl+C** to exit Claude Code, then relaunch it.

## Step 3: Verify Connection

After restart, call any Atlassian MCP tool (e.g., `getVisibleJiraProjects`). This will trigger the OAuth browser flow automatically on first use:

1. A browser window opens
2. The user selects their Atlassian site and grants access
3. Authentication completes automatically

If the tool call succeeds, setup is complete.

## Step 4: Claude Code Permissions (Optional)

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
