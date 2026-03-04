---
name: cowork-with-jira
description: Use when working with Jira issues, sprints, epics, or any Jira workflow. Activate for issue creation, status transitions, sprint management, commit workflows, and agile project organization. Also activate when the user mentions Jira tickets, stories, bugs, tasks, or board management.
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

When assigning to someone other than `@me`, use `lookupJiraAccountId` to resolve their name or email to an account ID before creating or editing the issue.

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

**Custom workflow handling:** If a transition fails (project uses custom workflow), use `getTransitionsForJiraIssue` to inspect the issue's available transitions and pick the closest match. Report the actual status name to the user.

## Tool Strategy

All Jira operations use MCP tools directly from the main model — no subagent needed.

| Task | Approach |
|------|----------|
| Read from Jira (search, view) | MCP tools: `getJiraIssue`, `searchJiraIssuesUsingJql` |
| Write to Jira (create, edit, transition) | MCP tools: `createJiraIssue`, `editJiraIssue`, `transitionJiraIssue` |
| Comments | MCP tool: `addCommentToJiraIssue` |
| Project metadata | MCP tools: `getVisibleJiraProjects`, `getJiraProjectIssueTypesMetadata`, `getJiraIssueTypeMetaWithFieldsData` |
| Explore codebase for issue context | Explore subagent |
| Draft issue content (title, description, criteria) | Main model |

### Issue Creation Flow

```
1. MCP: searchJiraIssuesUsingJql → Identify active sprint / existing issues
2. MCP: getVisibleJiraProjects   → Confirm project key
3. Explore subagent              → Search codebase if needed for context
4. Main model                    → Draft title, description, acceptance criteria
5. Preview to user               → Show full draft for confirmation
6. MCP: createJiraIssue          → Create issue after user approves
```

### Issue Update Flow

```
1. MCP: getJiraIssue        → Read current issue state
2. Main model               → Determine changes, draft new content if needed
3. Preview to user          → Show changes for confirmation (content changes only)
4. MCP: editJiraIssue       → Apply updates
```

### Status Transitions

```
1. MCP: getTransitionsForJiraIssue → Get available transitions
2. MCP: transitionJiraIssue        → Apply transition
```

### Key Rules

<HARD-GATE>
Always preview issue content before submission. Show title, type, description, labels, priority before creating or making content changes. Do NOT submit to Jira without user confirmation.
</HARD-GATE>

- **Status-only transitions skip preview** — apply directly.

## Agile Workflow

### Epics

Epics group related stories under a theme or feature area.

- Create epic: `createJiraIssue` with type "Epic"
- Link story to epic: set the parent field when creating, or use `editJiraIssue` after creation
- Epic titles are plain descriptive text (e.g., "OAuth Integration", "Payment System Overhaul")
- If work spans 3+ related stories, create an epic first
- Before creating, check existing epics:
  ```
  searchJiraIssuesUsingJql with JQL: "project = PROJ AND issuetype = Epic AND status != Done"
  ```

### Sprints

The skill is sprint-aware but does NOT manage sprints (that's the Scrum Master's job).

- **Check active sprint:** query via JQL `sprint in openSprints()`
- **When user asks "what am I working on?"**, search:
  ```
  searchJiraIssuesUsingJql with JQL: "sprint in openSprints() AND assignee = currentUser()"
  ```
- **Never auto-add issues to a sprint** — let the user or Scrum Master decide
- Sprint management (creating, starting, closing sprints) requires the Jira web UI

> **Anti-pattern:** Board is a Jira view-layer concept. You cannot reverse-lookup which board an issue belongs to. Do not iterate boards to locate an issue — use JQL search instead.

### Sub-tasks

Break down stories into discrete pieces using `createJiraIssue` with type "Sub-task" and the parent field set to the parent issue key.

Sub-tasks inherit the parent's sprint and epic.

## Brainstorming Integration

After reading task context from Jira, ask the user:

> "Would you like to brainstorm implementation approaches?"

If the user agrees and the superpowers plugin is installed, suggest:

> "You can use `/superpowers:brainstorming` to start a structured brainstorming session."

If not installed, proceed with normal conversation-based discussion.

## Post-Commit Behavior

After a git commit, the plugin's hook injects context about checking task status. When this happens:

1. Search in-progress tasks assigned to the user:
   ```
   searchJiraIssuesUsingJql with JQL: "status = 'In Progress' AND assignee = currentUser()"
   ```

2. If any task appears related to the commit (match by branch name, commit message, or conversation context), ask the user:
   > "Should I close PROJ-123 (task summary)?"

3. If user approves:
   - Transition to **Done** using `transitionJiraIssue`
   - Add a comment summarizing the work using `addCommentToJiraIssue`
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
| User lookup | `lookupJiraAccountId` for non-self assignees |
| Label | Lowercase matching issue type |
| Priority | Default Medium |
| New issue status | To Do (project default) |
| Start working | Transition to In Progress |
| Code in review | Transition to In Review |
| Commit closes issue | Transition to Done (user approval required) |
| Close comment | @mention creator if not self-created |
| All Jira operations | MCP tools called directly (no subagent) |
| Draft content | Main model, preview before submit |
| Related stories | Group under an Epic |
| Sprint queries | JQL: `sprint in openSprints()` |
| Brainstorming | Suggest `/superpowers:brainstorming` if available |
