---
name: cowork-with-jira
description: Use when the user works with or mentions Jira issues, tickets, stories, bugs, tasks, sprints, epics, or any agile workflow
---

# Jira Workflow

Agile Jira workflow for Claude Code via the Atlassian Rovo MCP server.

## Prerequisites

MCP is auto-configured. If not authenticated, run `/cowork-with:cowork-with-onboarding`.

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

Issue type names are **localized** — a project may use `"Bug"`, `"缺陷 Bug"`, `"バグ"`, etc. **Always** use a haiku subagent to call `getJiraProjectIssueTypesMetadata` first and use the exact type name returned.

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

When assigning to someone other than `@me`, use a haiku subagent to call `lookupJiraAccountId` to resolve their name or email to an account ID before creating or editing the issue.

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

**Custom workflow handling:** If a transition fails, use a haiku subagent to call `getTransitionsForJiraIssue` to inspect available transitions and pick the closest match. Report the actual status name to the user.

## Tool Strategy

Split Jira operations between a **haiku subagent** (reads) and the **main model** (writes):

| Task | Who | Why |
|------|-----|-----|
| Read from Jira (search, view, metadata) | Haiku subagent | Cheap, fast, keeps main context clean |
| Read git/gh context (branch, log, diff, PRs) | Main model | Local CLI, fast, informs drafting |
| Explore codebase for issue context | Explore subagent | Efficient file search |
| Draft issue content (title, description, criteria) | Main model | Requires quality writing |
| Preview to user and get confirmation | Main model | User interaction |
| Write to Jira (create, edit, transition, comment) | Main model | Requires user confirmation first |

### MCP Tools

**Read** (haiku subagent):
- `getJiraIssue` — read a single issue (param: `issueIdOrKey`)
- `searchJiraIssuesUsingJql` — search issues with JQL (param: `maxResults` must be **number**, not string)
- `getVisibleJiraProjects` — list projects
- `getJiraProjectIssueTypesMetadata` — issue types for a project (param: `projectIdOrKey`)
- `getJiraIssueTypeMetaWithFieldsData` — field metadata for an issue type (param: `projectIdOrKey`, `issueTypeId`)
- `getTransitionsForJiraIssue` — available status transitions
- `getJiraIssueRemoteIssueLinks` — remote links on an issue
- `lookupJiraAccountId` — resolve user name/email to account ID

**Write** (main model, after user confirmation):
- `createJiraIssue` — create a new issue (param: `issueTypeName` — NOT `issueType`; `labels` is array of strings)
- `editJiraIssue` — update an existing issue (param: `issueIdOrKey`; `fields` must be **object**, not JSON string)
- `transitionJiraIssue` — change issue status
- `addCommentToJiraIssue` — add a comment
- `addWorklogToJiraIssue` — log work time

### Issue Creation Flow

```
1. Haiku subagent        → Read project metadata:
                           a. getJiraProjectIssueTypesMetadata (exact localized type names)
                           b. getJiraIssueTypeMetaWithFieldsData (ALL required fields incl. custom)
                           c. searchJiraIssuesUsingJql "sprint in openSprints()" (active sprint)
2. Main model            → Compare required fields vs. known values
                           If ANY required field is missing → ask user via AskUserQuestion BEFORE drafting
3. Main model            → Ask user which sprint to assign (show active sprint name), or skip
4. Main model            → Read git context if relevant (branch, recent commits, diff)
5. Explore subagent      → Search codebase if needed for context
6. Main model            → Draft title, description (plain text!), acceptance criteria
7. Main model            → Preview FULL draft to user via AskUserQuestion (HARD-GATE below)
8. Main model            → Create issue after user approves (createJiraIssue)
9. Main model            → Offer to create a feature branch (git checkout -b feat/PROJ-123-slug)
```

### Required Fields & Custom Fields

Step 1b reads ALL required fields for the chosen issue type. Before drafting:

- **List every required field** and check which ones already have values (from user input or defaults like assignee, priority)
- **If any required field has no value** (especially custom fields like `customfield_10079`), use `AskUserQuestion` to ask the user for the missing values. Do NOT attempt to create the issue with missing required fields.
- Include discovered required fields in the final confirmation preview (Step 7)

**Fallback when creation still fails:** If `createJiraIssue` rejects due to a required field despite passing it via `additionalFields`, create as **Task** first (fewer required fields), then use `editJiraIssue` with `fields` (object, not string) to change issue type and set the custom field. Report the workaround to the user.

<HARD-GATE>
Before creating or updating issue content, you MUST use `AskUserQuestion` to present a structured confirmation. Show the full draft (title, type, sprint, description, labels, priority, and all required fields) in the `markdown` preview field. Options: "Submit" (Recommended), "Edit", "Cancel". Do NOT call any Jira write tool without explicit user approval via this confirmation. This is NOT optional — text-based confirmation ("确认创建？") does NOT satisfy this gate. You MUST call the `AskUserQuestion` tool. Status-only transitions skip this gate.
</HARD-GATE>

## Agile Workflow

### Epics

- Create epic: `createJiraIssue` with type "Epic" (main model, after user confirms)
- Link story to epic: set the parent field when creating, or use `editJiraIssue` after creation
- Epic titles are plain descriptive text (e.g., "OAuth Integration", "Payment System Overhaul")
- If work spans 3+ related stories, create an epic first
- Before creating, use haiku subagent to check existing epics:
  ```
  searchJiraIssuesUsingJql with JQL: "project = PROJ AND issuetype = Epic AND status != Done"
  ```

### Sprints

The skill is sprint-aware but does NOT manage sprints (that's the Scrum Master's job).

- **Check active sprint:** use haiku subagent to query via JQL `sprint in openSprints()`
- **When user asks "what am I working on?"**, use haiku subagent to search:
  ```
  searchJiraIssuesUsingJql with JQL: "sprint in openSprints() AND assignee = currentUser()"
  ```
- **Never auto-add issues to a sprint** — let the user or Scrum Master decide

> **Anti-pattern:** Board is a Jira view-layer concept. You cannot reverse-lookup which board an issue belongs to. Do not iterate boards to locate an issue — use JQL search instead.

### Sub-tasks

Break down stories into discrete pieces using `createJiraIssue` with type "Sub-task" and the parent field set to the parent issue key (main model, after user confirms). Sub-tasks inherit the parent's sprint and epic.

## Post-Commit & Git Context

The current repo's git and GitHub state is available as context. Use it naturally when it helps — not as mandatory steps.

**Available context** (via `git` and `gh` CLI):
- `git branch` / `git log --oneline` — current branch and recent commits
- `git diff` / `git diff --stat` — what changed
- `gh pr list` / `gh pr view` — open pull requests

**When to use it:**
- **Creating an issue** — glance at branch name and recent commits to enrich the issue description
- **Closing an issue** — summarize code changes and link the PR in the closing comment
- **Linking PRs** — if a PR title or branch contains a Jira key, mention it when discussing the issue

### Post-Commit Hook

After a git commit, the plugin's hook injects context about checking task status. When this happens:

1. Use haiku subagent to search in-progress tasks assigned to the user:
   ```
   searchJiraIssuesUsingJql with JQL: "status = 'In Progress' AND assignee = currentUser()"
   ```

2. If any task appears related to the commit (match by branch name, commit message, or conversation context), ask the user:
   > "Should I close PROJ-123 (task summary)?"

3. If user approves:
   - Read `git log` and `git diff` to understand what changed
   - Check `gh pr list` for any open PR related to this branch
   - Transition to **Done** using `transitionJiraIssue`
   - Add a closing comment using `addCommentToJiraIssue` — include a summary of changes, link the PR if one exists
   - If the issue was **NOT created by the current user**, @mention the creator in the comment
   - If the issue **was** created by the current user, skip the @mention

4. If user declines, leave the task as-is.

### Commit Message Format

```
[PROJ-123] commit message
```

Include the Jira issue key in the commit message when the commit is related to a task.

## Cross-Skill Integration

- After reading task context, offer `/superpowers:brainstorming` to explore implementation approaches.
- If implementation reveals undocumented product behavior, suggest `/cowork-with:cowork-with-wiki` to create or update documentation.
- If a Jira issue contains a Figma URL, use `/cowork-with:cowork-with-figma` to read design context before implementing.

## Limitations

The following operations are **not available** via MCP and require the Jira web UI:

- Sprint management (create, start, close sprints)
- Board configuration
- Issue links (linking two issues together)
- Attachments (uploading files to issues)
- Cloning issues
- Bulk operations
- Saved filters
- Moving issues between projects
