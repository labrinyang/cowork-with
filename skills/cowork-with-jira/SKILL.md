---
name: cowork-with-jira
description: Use when the user works with or mentions Jira issues, tickets, stories, bugs, tasks, sprints, epics, or any agile workflow
---

# Jira Workflow

Agile Jira workflow for Claude Code via the Atlassian Rovo MCP server.

## Prerequisites

The Atlassian Rovo MCP server is automatically configured by the plugin. If authentication hasn't been completed yet, run `/cowork-with:cowork-with-onboarding`.

## Issue Conventions

### Title Format

**No type prefix.** Jira has native issue types (Story, Bug, Task, Epic, Sub-task) — do not duplicate them in the title.

**Good:**
- `Add OAuth login flow` (type: Story)
- `Fix crash on empty cart submission` (type: Bug)
- `Upgrade React to v19` (type: Task)

**Bad:**
- `[Feature] Add OAuth login flow` — redundant, Jira already tracks type
- `add login` — too vague

### Description Template

Every issue description MUST include these sections:

```markdown
## Background
[Why this issue exists. What problem it solves. Any relevant context.]

## Acceptance Criteria
- [ ] [Specific, testable criterion]
- [ ] [Another criterion]
```

Do not skip Acceptance Criteria. Even for small tasks, at least one criterion is required.

### Issue Type Selection

When creating an issue, choose the Jira type based on intent:

| Intent | Jira Type | When to use |
|--------|-----------|-------------|
| New functionality | Story | User-facing feature or capability |
| Bug fix | Bug | Something is broken |
| Technical work | Task | Maintenance, config, dependencies, refactoring |
| Research | Task | Investigation or spike (add `spike` label) |
| Documentation | Task | Docs changes (add `documentation` label) |
| Large initiative | Epic | Groups 3+ related stories |
| Subtask | Sub-task | Discrete piece of a parent story |

## Workflow Rules

### Default Assignment

Always assign to `@me` unless the user specifies a different assignee.

### User Lookup

When assigning to someone other than `@me`, use a haiku subagent to call `lookupJiraAccountId` to resolve their name or email to an account ID before creating or editing the issue.

### Default Priority

Always set **Medium** unless specified. Jira priorities:

| Priority | When to use |
|----------|-------------|
| Highest | Production down, data loss, security vulnerability |
| High | Blocks other work, major user-facing issue |
| **Medium** | **Default** — standard work |
| Low | Nice-to-have, minor polish |
| Lowest | Cosmetic, trivial |

### Labels

Apply lowercase labels matching the issue type:

| Jira Type | Label |
|-----------|-------|
| Story | `story` |
| Bug | `bug` |
| Task | `task` |
| Epic | `epic` |
| Sub-task | `subtask` |

For special categories, add additional labels: `spike`, `documentation`, `tech-debt`.

If the project has existing label conventions (check recent issues), follow those instead.

### Status Lifecycle

Standard Jira workflow:

```
To Do → In Progress → In Review → Done
```

| Status | When to transition |
|--------|-------------------|
| **To Do** | Issue created, ready to work on |
| **In Progress** | User starts working on it |
| **In Review** | Code submitted for review (if status exists) |
| **Done** | Work finished and verified |

**Proactive transitions:** When context makes it obvious (e.g., user says "I'm working on PROJ-42" or "let's start PROJ-42"), transition to In Progress without asking.

**Custom workflow handling:** If a transition fails (project uses custom workflow), use a haiku subagent to call `getTransitionsForJiraIssue` to inspect the issue's available transitions and pick the closest match. Report the actual status name to the user.

## Tool Strategy

Split Jira operations between a **haiku subagent** (reads) and the **main model** (writes):

| Task | Who | Why |
|------|-----|-----|
| Read from Jira (search, view, metadata) | Haiku subagent | Cheap, fast, keeps main context clean |
| Explore codebase for issue context | Explore subagent | Efficient file search |
| Draft issue content (title, description, criteria) | Main model | Requires quality writing |
| Preview to user and get confirmation | Main model | User interaction |
| Write to Jira (create, edit, transition, comment) | Main model | Requires user confirmation first |

### Haiku Subagent — Jira Reader

Use the Agent tool with `model: "haiku"` for all Jira read operations. The subagent has access to Atlassian MCP tools and returns structured data to the main model.

**Read MCP tools** (haiku subagent):
- `getJiraIssue` — read a single issue
- `searchJiraIssuesUsingJql` — search issues with JQL
- `getVisibleJiraProjects` — list projects
- `getJiraProjectIssueTypesMetadata` — issue types for a project
- `getJiraIssueTypeMetaWithFieldsData` — field metadata for an issue type
- `getTransitionsForJiraIssue` — available status transitions
- `getJiraIssueRemoteIssueLinks` — remote links on an issue
- `lookupJiraAccountId` — resolve user name/email to account ID

**Write MCP tools** (main model, after user confirmation):
- `createJiraIssue` — create a new issue
- `editJiraIssue` — update an existing issue
- `transitionJiraIssue` — change issue status
- `addCommentToJiraIssue` — add a comment
- `addWorklogToJiraIssue` — log work time

### Issue Creation Flow

```
1. Haiku subagent        → Read Jira context (search existing issues, confirm project, check sprint)
2. Explore subagent      → Search codebase if needed for context
3. Main model            → Draft title, description, acceptance criteria
4. Main model            → Preview to user for confirmation
5. Main model            → Create issue after user approves (createJiraIssue)
```

### Issue Update Flow

```
1. Haiku subagent        → Read current issue state (getJiraIssue)
2. Main model            → Determine changes, draft new content if needed
3. Main model            → Preview changes to user for confirmation
4. Main model            → Apply updates after user approves (editJiraIssue)
```

### Status Transitions

```
1. Haiku subagent        → Get available transitions (getTransitionsForJiraIssue)
2. Main model            → Apply transition (transitionJiraIssue)
```

### Key Rules

<HARD-GATE>
Always preview issue content before submission. Show title, type, description, labels, priority before creating or making content changes. Do NOT submit to Jira without user confirmation.
</HARD-GATE>

- **Status-only transitions skip preview** — apply directly.
- **All Jira reads go through haiku subagent** — never read from Jira directly in the main model.
- **All Jira writes stay in the main model** — ensures user confirmation before any mutation.

## Agile Workflow

### Epics

Epics group related stories under a theme or feature area.

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
- Sprint management (creating, starting, closing sprints) requires the Jira web UI

> **Anti-pattern:** Board is a Jira view-layer concept. You cannot reverse-lookup which board an issue belongs to. Do not iterate boards to locate an issue — use JQL search instead.

### Sub-tasks

Break down stories into discrete pieces using `createJiraIssue` with type "Sub-task" and the parent field set to the parent issue key (main model, after user confirms).

Sub-tasks inherit the parent's sprint and epic.

## Brainstorming Integration

After reading task context from Jira (via haiku subagent), ask the user:

> "Would you like to brainstorm implementation approaches?"

If the user agrees and the superpowers plugin is installed, suggest:

> "You can use `/superpowers:brainstorming` to start a structured brainstorming session."

If not installed, proceed with normal conversation-based discussion.

## Post-Commit Behavior

After a git commit, the plugin's hook injects context about checking task status. When this happens:

1. Use haiku subagent to search in-progress tasks assigned to the user:
   ```
   searchJiraIssuesUsingJql with JQL: "status = 'In Progress' AND assignee = currentUser()"
   ```

2. If any task appears related to the commit (match by branch name, commit message, or conversation context), ask the user:
   > "Should I close PROJ-123 (task summary)?"

3. If user approves:
   - Transition to **Done** using `transitionJiraIssue` (main model)
   - Add a comment summarizing the work using `addCommentToJiraIssue` (main model)
   - If the issue was **NOT created by the current user**, @mention the creator in the comment
   - If the issue **was** created by the current user, skip the @mention

4. If user declines, leave the task as-is.

### Commit Message Format

```
[PROJ-123] commit message

# Examples:
[PROJ-42] Add OAuth login flow
[PROJ-15] Fix crash on empty cart submission
```

Include the Jira issue key in the commit message when the commit is related to a task.

## Wiki Integration

When working with Jira issues, consider these wiki connections:

- **Need product context?** Use `/cowork-with:cowork-with-wiki` to look up product documentation and specifications from the Confluence knowledge base.
- **Link wiki pages:** When an issue relates to documented product behavior, reference the relevant wiki page URL in the issue description.
- **Doc gaps:** If implementation reveals undocumented product behavior, suggest creating or updating a wiki page via `/cowork-with:cowork-with-wiki`.

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

## Quick Reference

| Action | Rule |
|--------|------|
| Issue title | Plain text, no type prefix |
| Issue description | Background + Acceptance Criteria |
| Issue type | Story / Bug / Task / Epic / Sub-task |
| Assign issue | Default to `@me` |
| User lookup | Haiku subagent → `lookupJiraAccountId` |
| Label | Lowercase matching issue type |
| Priority | Default Medium |
| New issue status | To Do (project default) |
| Start working | Transition to In Progress |
| Code in review | Transition to In Review |
| Commit closes issue | Transition to Done (user approval required) |
| Close comment | @mention creator if not self-created |
| Read from Jira | Haiku subagent (cheap, fast) |
| Write to Jira | Main model (user confirmation first) |
| Draft content | Main model, preview before submit |
| Related stories | Group under an Epic |
| Sprint queries | Haiku subagent → JQL: `sprint in openSprints()` |
| Brainstorming | Suggest `/superpowers:brainstorming` if available |
