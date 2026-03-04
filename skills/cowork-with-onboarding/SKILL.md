---
name: cowork-with-onboarding
description: Guides MCP setup for Atlassian and Figma integration
disable-model-invocation: true
allowed-tools: Read, AskUserQuestion
---

# Onboarding

Walk the user through setting up their environment for the cowork-with plugin.

## Step 1: Authenticate MCP Servers

Both MCP servers are automatically configured by the plugin. The user just needs to authenticate each one.

### Atlassian (Jira + Confluence)

Tell the user to:

1. Type `/mcp` and press Enter
2. Select **`plugin:cowork-with:atlassian`** from the list
3. In the browser page that opens, under **"Use app on"**, select their Atlassian site
4. Click **"Accept"** to grant access

### Figma

Tell the user to:

1. Type `/mcp` and press Enter
2. Select **`plugin:cowork-with:figma`** from the list
3. Grant access in the browser page that opens

Authentication is complete when the user returns to Claude Code with a success message for both servers.

## Step 2: Claude Code Permissions (Optional)

For a smoother workflow, suggest adding MCP tools to the project's allow list. Show the user what to add to `.claude/settings.json` or `.claude/settings.local.json`:

```json
{
  "permissions": {
    "allow": [
      "mcp__atlassian__*",
      "mcp__figma__*"
    ]
  }
}
```

This prevents repeated permission prompts for MCP tool calls.

## Completion

After authentication succeeds, confirm readiness and display available commands:

**Setup Status:**
- Atlassian Rovo MCP: configured and authenticated
- Figma MCP: configured and authenticated
- Jira: accessible
- Confluence: accessible
- Figma: accessible

**Available Commands:**

| Command | Description |
|---------|-------------|
| `/cowork-with:cowork-with-jira` | Jira workflow — issue creation, status transitions, sprint queries, epic management |
| `/cowork-with:cowork-with-wiki` | Wiki workflow — read product docs, search Confluence, manage personal pages |
| `/cowork-with:cowork-with-figma` | Figma workflow — design-to-code, design tokens, Code Connect, screenshots |
| `/cowork-with:cowork-with-onboarding` | Re-run this setup guide |
