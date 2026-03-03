# cowork-with

Agile workflow plugin for Claude Code. Integrates Jira issue tracking, sprint management, and automated task lifecycle via the Atlassian `acli` CLI.

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
1. Installing Homebrew (if missing)
2. Installing the Atlassian CLI (`acli`)
3. Authenticating with your Jira Cloud instance
4. Configuring Claude Code permissions (optional)

Once ready, it displays all available commands.

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
| Onboarding | `/cowork-with:cowork-with-onboarding` | Setup: Homebrew, acli, authentication |

## How It Works

1. **Pull task context** — reads Jira via lightweight haiku subagent
2. **Brainstorm** — suggests `/superpowers:brainstorming` if installed
3. **Work** — you code as usual
4. **Commit** — post-commit hook checks if in-progress tasks should be closed
5. **Close task** — with your approval, transitions to Done and comments @creator

## Plugin Structure

```
cowork-with/
├── .claude-plugin/plugin.json    # Plugin manifest
├── skills/
│   ├── cowork-with-onboarding/SKILL.md  # Setup guide
│   └── cowork-with-jira/SKILL.md        # Main Jira workflow
├── reference/                           # acli CLI command reference (progressive disclosure)
│   ├── index.md                         # Overview, anti-patterns, file index
│   ├── workitems.md                     # Create, search, view, edit, transition, assign
│   ├── workitems-advanced.md            # Comments, links, attachments, clone, bulk
│   ├── boards-sprints.md                # Boards, sprint CRUD
│   └── jql.md                           # JQL queries, projects, filters
├── agents/acli-operator.md       # Haiku subagent for acli
├── hooks/hooks.json              # Post-commit hook config
└── scripts/post-commit-check.sh  # Git commit detection
```

## Features

- Issue conventions: Background + Acceptance Criteria template
- Auto-assigns to current user, default Medium priority
- Sprint-aware: query active sprint items via JQL
- Epic management: create epics, link stories
- Post-commit hook: automated task closure check
- Subagent strategy: haiku for Jira I/O, main model for content drafting
- Preview before submit: always shows draft for confirmation

## License

MIT
