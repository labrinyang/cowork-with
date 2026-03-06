---
name: cowork-with-onboarding
description: Guides MCP setup for Atlassian and Figma integration. Use when the user needs to set up, configure, or troubleshoot MCP server connections for Jira, Confluence, or Figma.
disable-model-invocation: true
allowed-tools: Read, Bash, AskUserQuestion
---

# Onboarding

Walk the user through setting up their environment for the cowork-with plugin.

This plugin requires two globally installed MCP servers: **Atlassian** (for Jira + Confluence) and **Figma**. The plugin itself does not bundle MCP servers — users install them once at the global level and all projects benefit.

## Step 0: Detect Existing Setup

Before guiding installation, check if MCP servers are already configured:

1. Run `cat ~/.claude/.mcp.json 2>/dev/null` to check for existing config
2. If `atlassian` and/or `figma` entries exist, skip to **Step 2** for the already-configured server(s)
3. If both exist, try calling `atlassianUserInfo` and `whoami` (Figma) to verify authentication — if both succeed, skip to **Completion**

## Step 1: Install MCP Servers

The user needs to add MCP servers to their global Claude Code configuration. Run these commands in their terminal (outside Claude Code):

### Atlassian (Jira + Confluence)

```bash
claude mcp add atlassian --transport sse --url https://mcp.atlassian.com/v1/sse -s user
```

### Figma

```bash
claude mcp add figma --transport http --url https://mcp.figma.com/mcp -s user
```

The `-s user` flag installs at the user level so the MCP servers are available across all projects.

After running these commands, ask the user to **restart Claude Code** (`Ctrl+C` and relaunch) so the new MCP servers are loaded.

## Step 2: Authenticate MCP Servers

After restart, the user needs to authenticate each server.

### Atlassian

Tell the user to:

1. Type `/mcp` and press Enter
2. Select **`atlassian`** from the list
3. In the browser page that opens, under **"Use app on"**, select their Atlassian site
4. Click **"Accept"** to grant access

### Figma

Tell the user to:

1. Type `/mcp` and press Enter
2. Select **`figma`** from the list
3. Grant access in the browser page that opens

Authentication is complete when the user returns to Claude Code with a success message for both servers.

## Step 3: Permissions (Optional)

For a smoother workflow, suggest allowing MCP tools without per-call prompts. The user can add this to their project's `.claude/settings.json` or global `~/.claude/settings.json`:

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

## Troubleshooting

If MCP servers aren't showing up:

1. Verify the config exists: `cat ~/.claude/.mcp.json`
2. Check that both `atlassian` and `figma` entries are present
3. Restart Claude Code after any config change

If authentication fails:

1. Re-run `/mcp` and select the server to re-authenticate
2. Check that the Atlassian site URL is correct and the user has access
3. For Figma, ensure the user has at least a Starter plan

## Completion

After authentication succeeds, confirm readiness and display available commands:

**Setup Status:**
- Atlassian MCP: installed globally and authenticated
- Figma MCP: installed globally and authenticated
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
