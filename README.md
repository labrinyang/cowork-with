# cowork-with

Connect PM, Dev, and QA context in AI-native development. Brings Jira issues, Confluence docs, Figma designs, and code into one workflow loop inside Claude Code — so the AI agent understands what to build, why, and when to close the loop.

Works for **teams** and **solo developers**. A single developer running multiple Claude Code terminals gets shared context across sessions — every terminal can pull the same Jira tasks, wiki specs, and Figma designs without copy-pasting URLs or issue numbers between windows.

## Why

When developers work with AI agents, the agent only sees code. It doesn't know what the PM specified, what tasks are in the sprint, what the product docs say, or what the design looks like. This plugin bridges that gap:

- **PM -> Dev**: Read Jira tasks and Confluence specs before writing code
- **Design -> Dev**: Read Figma designs, extract tokens, generate code from specs
- **Dev -> PM**: Auto-close tasks on commit, comment @creator
- **Dev -> QA**: Link commits to issues with structured descriptions
- **QA -> Dev**: Surface related issues and doc gaps during development
- **Terminal -> Terminal**: Shared context across multiple Claude Code sessions — one creates the issue, another implements it, both see the same task state

## Install

### Step 1: Install the plugin

From marketplace:

```
/plugin marketplace add labrinyang/cowork-with-marketplace
/plugin install cowork-with@cowork-with-marketplace
```

Local development:

```bash
claude --plugin-dir /path/to/cowork-with
```

### Step 2: Install MCP servers globally

This plugin requires two MCP servers installed at the user level. Run these in your terminal (outside Claude Code):

```bash
claude mcp add atlassian --transport sse --url https://mcp.atlassian.com/v1/sse -s user
claude mcp add figma --transport http --url https://mcp.figma.com/mcp -s user
```

### Step 3: Authenticate and configure

Restart Claude Code after installing, then run:

```
/cowork-with:cowork-with-onboarding
```

This walks you through:
1. Authenticating with Atlassian (Jira + Confluence) via `/mcp` -> `atlassian` -> OAuth
2. Authenticating with Figma via `/mcp` -> `figma` -> OAuth
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
| Onboarding | `/cowork-with:cowork-with-onboarding` | Setup: global MCP servers + authentication |

## How It Works

Everyone uses Claude Code. Everyone stays in their lane. The plugin connects the context.

```
        PM                          Dev                         QA
   Claude Code                 Claude Code                 Claude Code
+------------------+      +------------------+      +------------------+
| Figma designs    |      | Jira tasks       |      | Wiki specs       |
| Wiki specs       |      | Wiki specs       |      | Figma designs    |
| Jira issues      |      | Figma designs    |      | Code + git       |
|                  |      | Code + git       |      | Jira issues      |
|                  |      |                  |      |                  |
| Focus:           |      | Focus:           |      | Focus:           |
| Product design,  |      | Engineering,     |      | Full-context     |
| docs, logic      |      | implementation   |      | quality review   |
+--------+---------+      +--------+---------+      +--------+---------+
         |                         |                          |
         +-------------------------+--------------------------+
                    Shared: Jira + Confluence + Figma
```

### PM workflow

PM focuses on product — designs in Figma, specs in Confluence. When reviewing implementation, PM uses Claude Code to brainstorm, analyze the code, and inspect the running result. Then creates rich, context-aware Jira issues with background, acceptance criteria, and Figma links — all without writing code.

### Dev workflow

Dev pulls a task and Claude Code already has the full picture: Jira description, Confluence specs, Figma design context. No context-switching between browser tabs. Code, commit, and the post-commit hook offers to close the task and @mention the PM.

### QA workflow

QA gets the deepest context — wiki specs for expected behavior, Figma designs for visual correctness, source code for implementation details, and Jira issues for acceptance criteria. All in one Claude Code session. Files precise, well-documented bugs with full traceability.

## Plugin Structure

```
cowork-with/
├── .claude-plugin/plugin.json    # Plugin manifest
├── agents/
│   └── explorer.md               # Haiku read-only subagent for all MCP reads
├── skills/
│   ├── cowork-with-onboarding/SKILL.md  # Setup guide (global MCP install)
│   ├── cowork-with-jira/SKILL.md        # Jira workflow
│   ├── cowork-with-wiki/SKILL.md        # Wiki workflow
│   └── cowork-with-figma/SKILL.md       # Figma workflow
├── hooks/hooks.json              # Post-commit hook config
└── scripts/post-commit-check.sh  # Git commit detection
```

MCP servers (Atlassian + Figma) are installed globally at the user level, not bundled with the plugin. This means one-time setup that works across all projects.

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
- Explorer agent: haiku-powered read-only subagent for all MCP reads (Jira/wiki/Figma/codebase)
- Preview before submit: always shows draft for confirmation

## Limitations

The following operations require the web UI:

**Jira:** Sprint management, board configuration, issue links, attachments, cloning, bulk operations, saved filters

**Confluence:** Page permissions, labels, attachments, templates, page history, space admin, macros

**Figma:** Direct component editing, comment management, version history, team/project management. Starter plan: 6 read calls/month

## License

MIT
