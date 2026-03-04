# cowork-with

Agile workflow plugin for Claude Code. Integrates Jira issue tracking, sprint management, and automated task lifecycle via the Atlassian Rovo MCP server.

## Install

All plugin commands are **slash commands inside Claude Code**, not terminal commands.

### From marketplace

```
/plugin marketplace add labrinyang/cowork-with-marketplace
/plugin install cowork-with@cowork-with-marketplace
```

### Local development

```bash
claude --plugin-dir /path/to/cowork-with
```

## Setup

After installing the plugin, press `Ctrl+C` to exit and restart Claude Code. Then run:

```
/cowork-with:cowork-with-onboarding
```

This walks you through:
1. Authenticating with Jira via `/mcp` → `plugin:cowork-with:atlassian` → OAuth
2. Configuring permissions (optional)

## Usage

```
/cowork-with:cowork-with-jira   <- activate Jira workflow
Create a story for...    <- issues follow conventions automatically
What's in my sprint?     <- sprint-aware queries
Fix the bug in...        <- commit triggers task closure check
```

## Skills

| Skill | Command | Purpose |
|-------|---------|---------|
| Jira | `/cowork-with:cowork-with-jira` | Issue CRUD, sprints, epics, status transitions |
| Onboarding | `/cowork-with:cowork-with-onboarding` | Setup: Atlassian Rovo MCP server |

## How It Works

1. **Pull task context** — reads Jira via MCP tools
2. **Brainstorm** — suggests `/superpowers:brainstorming` if installed
3. **Work** — you code as usual
4. **Commit** — post-commit hook checks if in-progress tasks should be closed
5. **Close task** — with your approval, transitions to Done and comments @creator

## Plugin Structure

```
cowork-with/
├── .claude-plugin/plugin.json    # Plugin manifest
├── .mcp.json                     # Atlassian Rovo MCP server (auto-configured)
├── skills/
│   ├── cowork-with-onboarding/SKILL.md  # Setup guide
│   └── cowork-with-jira/SKILL.md        # Main Jira workflow
├── hooks/hooks.json              # Post-commit hook config
└── scripts/post-commit-check.sh  # Git commit detection
```

## Features

- Issue conventions: Background + Acceptance Criteria template
- Auto-assigns to current user, default Medium priority
- Sprint-aware: query active sprint items via JQL
- Epic management: create epics, link stories
- Post-commit hook: automated task closure check
- Auto-configured MCP server: no manual setup required
- Preview before submit: always shows draft for confirmation

## Limitations

The following operations require the Jira web UI:

- Sprint management (create, start, close sprints)
- Board configuration
- Issue links, attachments, cloning
- Bulk operations and saved filters

## License

MIT
