---
name: cowork-with-onboarding
description: Guides setup of the Atlassian Rovo MCP server for Jira integration. Use when the user needs to set up Jira access or mentions Jira MCP setup.
disable-model-invocation: true
allowed-tools: Read, AskUserQuestion
---

# Onboarding

Walk the user through setting up their environment for the cowork-with plugin.

## Step 1: Authenticate with Jira

The Atlassian Rovo MCP server is automatically configured by the plugin. The user just needs to authenticate.

Tell the user to:

1. Type `/mcp` and press Enter
2. Select **`plugin:cowork-with:atlassian`** from the list
3. In the browser page that opens, under **"Use app on"**, select their Atlassian site
4. Click **"Accept"** to grant access

Authentication is complete when the user returns to Claude Code with a success message.

## Step 2: Claude Code Permissions (Optional)

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

After authentication succeeds, confirm readiness and display available commands:

**Setup Status:**
- Atlassian Rovo MCP: configured and authenticated
- Jira: accessible

**Available Commands:**

| Command | Description |
|---------|-------------|
| `/cowork-with:cowork-with-jira` | Jira workflow — issue creation, status transitions, sprint queries, epic management |
| `/cowork-with:cowork-with-onboarding` | Re-run this setup guide |
