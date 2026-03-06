---
name: cowork-with-jira
description: Use when the user works with or mentions Jira issues, tickets, stories, bugs, tasks, sprints, epics, or any agile workflow
argument-hint: "[PROJ-123 or description]"
allowed-tools: Read, Glob, Grep, Bash, Agent, AskUserQuestion
---

# Jira Workflow

Agile Jira workflow for Claude Code via the Atlassian Rovo MCP server.

## Prerequisites

Requires globally installed **Atlassian MCP** server (named `atlassian`). If not set up, run `/cowork-with:cowork-with-onboarding`.

## Issue Conventions

### Title Format

**No type prefix.** Jira tracks issue types natively — never prefix with `[Feature]`, `Bug:`, etc.

### Description Format

**Plain text only.** Jira does NOT render Markdown — no `##`, `**`, `- [ ]`, or backtick fences. Use Jira wiki markup or plain text with simple line breaks.

Every issue description MUST include these sections:

```
Background
Why this issue exists. What problem it solves. Any relevant context.

Acceptance Criteria
- Specific, testable criterion
- Another criterion
```

Do not skip Acceptance Criteria. Even for small tasks, at least one criterion is required.

### Issue Type Selection

Issue type names are **localized** — a project may use `"Bug"`, `"缺陷 Bug"`, `"バグ"`, etc. **Always** use the `explorer` agent to call `getJiraProjectIssueTypesMetadata` first and use the exact type name returned.

| Intent | Jira Type | Label | When to use |
|--------|-----------|-------|-------------|
| New functionality | Story | `story` | User-facing feature or capability |
| Bug fix | Bug | `bug` | Something is broken |
| Technical work | Task | `task` | Maintenance, config, dependencies, refactoring |
| Research | Task | `spike` | Investigation or spike |
| Documentation | Task | `documentation` | Docs changes |
| Large initiative | Epic | `epic` | Groups 3+ related stories |
| Subtask | Sub-task | `subtask` | Discrete piece of a parent story |

Additional labels for special categories: `tech-debt`. If the project has existing label conventions (check recent issues), follow those instead.

## Workflow Rules

### Default Assignment

Always assign to `@me` unless the user specifies a different assignee.

### User Lookup

When assigning to someone other than `@me`, use the `explorer` agent to call `lookupJiraAccountId` to resolve their name or email to an account ID before creating or editing the issue.

### Default Priority

Always set **Medium** unless specified.

| Priority | When to use |
|----------|-------------|
| Highest | Production down, data loss, security vulnerability |
| High | Blocks other work, major user-facing issue |
| **Medium** | **Default** — standard work |
| Low | Nice-to-have, minor polish |
| Lowest | Cosmetic, trivial |

### Status Lifecycle

```
To Do → In Progress → In Review → Done
```

| Status | When to transition |
|--------|-------------------|
| **To Do** | Issue created, ready to work on |
| **In Progress** | User starts working on it |
| **In Review** | Code submitted for review (if status exists) |
| **Done** | Work finished and verified |

**Proactive transitions:** When context makes it obvious (e.g., user says "I'm working on PROJ-42"), transition to In Progress without asking.

**Custom workflow handling:** If a transition fails, use the `explorer` agent to call `getTransitionsForJiraIssue` to inspect available transitions and pick the closest match. Report the actual status name to the user.

## Tool Strategy

<HARD-GATE>
ALL MCP read tool calls MUST go through the `explorer` agent. The main model MUST NOT call any MCP read tool directly — always spawn the `explorer` agent to do it. This is mandatory because the explorer agent enforces correct parameter types and names. Calling MCP read tools directly from the main model is forbidden.
</HARD-GATE>

Spawn via: `Agent tool → name: "explorer"` (the plugin ships `agents/explorer.md` — haiku model, read-only: MCP reads + codebase + git).

| Task | Who |
|------|-----|
| Read from Jira (search, view, metadata) | `explorer` agent |
| Read git/gh context, explore codebase | `explorer` agent |
| Draft issue content (title, description, criteria) | Main model |
| Preview to user and get confirmation | Main model |
| Write to Jira (create, edit, transition, comment) | Main model |

### MCP Tools

**Read** (`explorer` agent):
- `getJiraIssue` — read a single issue (param: `issueIdOrKey`)
- `searchJiraIssuesUsingJql` — search issues with JQL (param: `maxResults` must be **number**, not string)
- `getVisibleJiraProjects` — list projects
- `getJiraProjectIssueTypesMetadata` — issue types for a project (param: `projectIdOrKey`)
- `getJiraIssueTypeMetaWithFields` — field metadata for an issue type (param: `projectIdOrKey`, `issueTypeId`)
- `getTransitionsForJiraIssue` — available status transitions
- `getJiraIssueRemoteIssueLinks` — remote links on an issue
- `lookupJiraAccountId` — resolve user name/email to account ID
- `atlassianUserInfo` — current authenticated user info
- `jiraRead` — generic Jira REST API read (fallback for endpoints not covered above)
- `search` — cross-service Atlassian search (searches Jira + Confluence together)

**Write** (main model, after user confirmation):
- `createJiraIssue` — create a new issue (param: `issueTypeName` — NOT `issueType`; `labels` is array of strings)
- `editJiraIssue` — update an existing issue (param: `issueIdOrKey`; `fields` must be **object**, not JSON string)
- `transitionJiraIssue` — change issue status
- `addCommentToJiraIssue` — add a comment
- `addWorklogToJiraIssue` — log work time

### Issue Creation Flow

```
1. `explorer` agent        → Fetch project context (ALL in one batch, parallel where possible):
                           a. getJiraProjectIssueTypesMetadata (exact localized type names)
                           b. getJiraIssueTypeMetaWithFields (ALL required fields incl. custom)
                           c. searchJiraIssuesUsingJql "sprint in openSprints()" (active sprint name + goal)
2. Main model            → Compare required fields vs. known values
                           If ANY required field is missing → ask user via AskUserQuestion BEFORE drafting
3. Main model            → Present active sprint to user:
                           Show sprint name, goal, and date range
                           Ask: assign to this sprint, or leave unassigned?
4. `explorer` agent      → Read git context + search codebase if needed for context
5. Main model            → Draft title, description (plain text!), acceptance criteria
6. Main model            → Preview FULL draft to user via AskUserQuestion (HARD-GATE below)
                           Include sprint assignment in preview if selected
7. Main model            → Create issue after user approves (createJiraIssue)
8. Main model            → Offer to create a feature branch (git checkout -b feat/PROJ-123-slug)
```

Step 1c is critical — sprint context must ALWAYS be fetched before drafting. If the JQL returns no active sprint, inform the user that no sprint is active and proceed without sprint assignment.

### Required Fields & Custom Fields

Step 1b reads ALL required fields for the chosen issue type. Before drafting:

- **List every required field** and check which ones already have values (from user input or defaults like assignee, priority)
- **If any required field has no value** (especially custom fields like `customfield_10079`), use `AskUserQuestion` to ask the user for the missing values. Do NOT attempt to create the issue with missing required fields.
- Include discovered required fields in the final confirmation preview (Step 7)

**Fallback when creation still fails:** If `createJiraIssue` rejects due to a required field despite passing it via `additionalFields`, create as **Task** first (fewer required fields), then use `editJiraIssue` with `fields` (object, not string) to change issue type and set the custom field. Report the workaround to the user.

<HARD-GATE>
Before creating or updating issue content, you MUST use `AskUserQuestion` to present a structured confirmation. Show the full draft (title, type, sprint, description, labels, priority, and all required fields) in the `markdown` preview field. Options: "Submit" (Recommended), "Edit", "Cancel". Do NOT call any Jira write tool without explicit user approval via this confirmation. This is NOT optional — text-based confirmation ("确认创建？") does NOT satisfy this gate. You MUST call the `AskUserQuestion` tool. Status-only transitions skip this gate.
</HARD-GATE>

## Agile Workflow & Git Integration

For epics, sprints, sub-tasks, post-commit hook, and commit message format, see `reference.md` in this skill directory.

Key rules (always apply):
- **Sprints:** Never auto-add issues to a sprint — let the user decide
- **Branch names:** Include the issue key — `feat/PROJ-123-slug` or `fix/PROJ-123-slug`. Jira auto-tracks branches containing the issue key.
- **Commit messages:** `[PROJ-123] commit message` when related to a task
- **Post-commit:** Hook auto-triggers task closure check; use `explorer` agent to find related in-progress tasks

## Cross-Skill Integration

- After reading task context, offer `/superpowers:brainstorming` to explore implementation approaches.
- If implementation reveals undocumented product behavior, suggest `/cowork-with:cowork-with-wiki` to create or update documentation.
- If a Jira issue contains a Figma URL, use `/cowork-with:cowork-with-figma` to read design context before implementing.

## Limitations

See `reference.md` for full list. Key: no sprint management, no issue links, no attachments via MCP.
