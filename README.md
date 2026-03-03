# cowork-with

Agile workflow plugin for Claude Code. Integrates Jira issue tracking, sprint management, and automated task lifecycle via the Atlassian `acli` CLI.

## Prerequisites

- [Jira Cloud](https://www.atlassian.com/software/jira) account
- [Claude Code](https://claude.ai/code)

## Install

Load the plugin from the local directory:

```bash
claude --plugin-dir /path/to/cowork-with
```

Or install from GitHub:

```bash
claude plugin add github:labrinyang/cowork-with
```

## Setup

Run the onboarding skill to install dependencies and authenticate:

```
/cowork-with:onboarding
```

This guides you through installing Homebrew, the Atlassian CLI (`acli`), and authenticating with Jira.

## Usage

```
/cowork-with:jira        <- activate Jira workflow
Create a story for...    <- issues follow conventions automatically
What's in my sprint?     <- sprint-aware queries
Fix the bug in...        <- commit triggers task closure check
```

## Skills

| Skill | Command | Purpose |
|-------|---------|---------|
| Jira | `/cowork-with:jira` | Main workflow: issue CRUD, sprints, epics, status transitions |
| Onboarding | `/cowork-with:onboarding` | Setup guide: Homebrew, acli, authentication |

## How It Works

1. **Pull task context** — reads Jira issues via `acli` CLI using a lightweight haiku subagent
2. **Brainstorm** — suggests `/superpowers:brainstorming` if installed
3. **Work** — you code as usual
4. **Commit** — post-commit hook checks if in-progress tasks should be closed
5. **Close task** — with your approval, transitions to Done and comments @creator

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
