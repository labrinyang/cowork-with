# cowork-with

Connect PM, Dev, and QA context in AI-native development. Brings Jira issues, Confluence docs, Figma designs, and code into one workflow loop inside Claude Code — so the AI agent understands what to build, why, and when to close the loop.

Works for **teams** and **solo developers**. A single developer running multiple Claude Code terminals gets shared context across sessions — every terminal can pull the same Jira tasks, wiki specs, and Figma designs without copy-pasting URLs or issue numbers between windows.

## Why

When developers work with AI agents, the agent only sees code. It doesn't know what the PM specified, what tasks are in the sprint, what the product docs say, or what the design looks like. This plugin bridges that gap:

- **PM → Dev**: Read Jira tasks and Confluence specs before writing code
- **Design → Dev**: Read Figma designs, extract tokens, generate code from specs
- **Dev → PM**: Auto-close tasks on commit, comment @creator
- **Dev → QA**: Link commits to issues with structured descriptions
- **QA → Dev**: Surface related issues and doc gaps during development
- **Terminal → Terminal**: Shared context across multiple Claude Code sessions — one creates the issue, another implements it, both see the same task state

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
1. Authenticating with Atlassian (Jira + Confluence) via `/mcp` → `plugin:cowork-with:atlassian` → OAuth
2. Authenticating with Figma via `/mcp` → `plugin:cowork-with:figma` → OAuth
3. Configuring permissions (optional)

## Usage

```
/cowork-with:cowork-with-jira   <- activate Jira workflow
Create a story for...    <- issues follow conventions automatically
What's in my sprint?     <- sprint-aware queries
Fix the bug in...        <- commit triggers task closure check

/cowork-with:cowork-with-wiki   <- activate Wiki workflow
What does the product spec say about...  <- reads product docs
Search the wiki for...           <- CQL-powered search

/cowork-with:cowork-with-figma  <- activate Figma workflow
Implement this design: <figma-url>  <- reads design context, generates code
Extract the design tokens from...    <- colors, spacing, typography
```

## Skills

| Skill | Command | Purpose |
|-------|---------|---------|
| Jira | `/cowork-with:cowork-with-jira` | Issue CRUD, sprints, epics, status transitions |
| Wiki | `/cowork-with:cowork-with-wiki` | Read product docs, search Confluence, manage personal pages |
| Figma | `/cowork-with:cowork-with-figma` | Design-to-code, design tokens, Code Connect, screenshots |
| Onboarding | `/cowork-with:cowork-with-onboarding` | Setup: Atlassian + Figma MCP servers |

## How It Works

```
  Design (Figma)    PM (Jira + Confluence)    Dev (Claude Code)        Loop Back
┌───────────────┐  ┌─────────────────────┐  ┌─────────────────────┐  ┌──────────────────┐
│ UI specs      │─>│ Sprint tasks        │─>│ Pull task context    │  │ Transition: Done │
│ Design tokens │─>│ Product specs       │─>│ Read design + specs  │  │ Comment @creator │
│ Prototypes    │  │ Acceptance criteria │─>│ Brainstorm approach  │─>│ Update wiki      │
│               │  │                     │  │ Code + commit        │─>│ Close task       │
└───────────────┘  └─────────────────────┘  └─────────────────────┘  └──────────────────┘
```

1. **Pull task context** — `explorer` agent (haiku) reads Jira tasks, wiki specs, and Figma designs
2. **Brainstorm** — suggests `/superpowers:brainstorming` if installed
3. **Work** — you code as usual, with full PM + design context available
4. **Commit** — post-commit hook checks if in-progress tasks should be closed
5. **Close the loop** — with your approval, transitions to Done, comments @creator, flags doc gaps

## Plugin Structure

```
cowork-with/
├── .claude-plugin/plugin.json    # Plugin manifest
├── .mcp.json                     # Atlassian + Figma MCP servers (auto-configured)
├── agents/
│   └── explorer.md               # Haiku read-only subagent for all MCP reads
├── skills/
│   ├── cowork-with-onboarding/SKILL.md  # Setup guide
│   ├── cowork-with-jira/SKILL.md        # Jira workflow
│   ├── cowork-with-wiki/SKILL.md        # Wiki workflow
│   └── cowork-with-figma/SKILL.md       # Figma workflow
├── hooks/hooks.json              # Post-commit hook config
└── scripts/post-commit-check.sh  # Git commit detection
```

## Features

- Issue conventions: Background + Acceptance Criteria template
- Auto-assigns to current user, default Medium priority
- Sprint-aware: query active sprint items via JQL
- Epic management: create epics, link stories
- Confluence wiki integration: read product docs, search, manage personal pages
- Write safety: only modify self-created wiki pages
- Figma design integration: design-to-code, design tokens, Code Connect, screenshots
- Code-to-design: capture running UI as editable Figma design
- Cross-skill linking: Jira issues with Figma URLs auto-read design context
- Post-commit hook: automated task closure with @creator notification
- Auto-configured MCP servers: no manual setup required
- Explorer agent: haiku-powered read-only subagent for all MCP reads (Jira/wiki/Figma/codebase)
- Preview before submit: always shows draft for confirmation

## Limitations

The following operations require the web UI:

**Jira:** Sprint management, board configuration, issue links, attachments, cloning, bulk operations, saved filters

**Confluence:** Page permissions, labels, attachments, templates, page history, space admin, macros

**Figma:** Direct component editing, comment management, version history, team/project management. Starter plan: 6 read calls/month

## License

MIT
