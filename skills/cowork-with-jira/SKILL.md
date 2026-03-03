---
name: cowork-with-jira
description: Use when working with Jira issues, sprints, epics, or any Jira workflow. Activate for issue creation, status transitions, sprint management, commit workflows, and agile project organization. Also activate when the user mentions Jira tickets, stories, bugs, tasks, or board management.
---

# Jira Workflow

Agile Jira workflow for Claude Code via the Atlassian `acli` CLI.

## Prerequisites

Ensure `acli` is installed and authenticated. Quick check:

```bash
acli jira auth status
```

If not set up, run `/cowork-with:cowork-with-onboarding`.

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

**Custom workflow handling:** If a transition fails (project uses custom workflow), use `acli-operator` to inspect the issue's available transitions and pick the closest match. Report the actual status name to the user.

## Subagent Strategy

| Task | Model | Why |
|------|-------|-----|
| Read from Jira (search, view, list) | `acli-operator` (haiku) | Cheap, fast, repetitive |
| Write to Jira (create, edit, transition, comment) | `acli-operator` (haiku) | Simple CLI calls |
| Explore codebase for issue context | Explore subagent | Efficient file search |
| Draft issue content (title, description, criteria) | **Main model** | Requires quality writing |

### Issue Creation Flow

```
1. acli-operator (haiku)  → Read Jira (existing issues, project context, sprint)
2. Explore subagent       → Search codebase if needed for context
3. Main model             → Draft title, description, acceptance criteria
4. Preview to user        → Show full draft for confirmation
5. acli-operator (haiku)  → Submit to Jira after user approves
```

### Issue Update Flow

```
1. acli-operator (haiku)  → Read current issue state
2. Main model             → Determine changes, draft new content if needed
3. Preview to user        → Show changes for confirmation (content changes only)
4. acli-operator (haiku)  → Apply updates
```

### Key Rules

- **Always preview issue content before submission.** Show title, type, description, labels, priority before creating or making content changes.
- **Status-only transitions skip preview** — apply directly.
- **All acli commands use `--json` flag** for structured output.
- **Transitions use `--yes` flag** to avoid interactive prompts.
- For complete acli command syntax, see [acli-reference.md](acli-reference.md).

## Agile Workflow

### Epics

Epics group related stories under a theme or feature area.

- Create epic: `acli jira workitem create --type "Epic" --summary "..." --project "PROJ" --assignee "@me" --json`
- Link story to epic: use `--parent "PROJ-100"` when creating, or edit after creation
- Epic titles are plain descriptive text (e.g., "OAuth Integration", "Payment System Overhaul")
- If work spans 3+ related stories, create an epic first
- Before creating, check existing epics:
  ```
  acli jira workitem search --jql "project = PROJ AND issuetype = Epic AND status != Done" --json
  ```

### Sprints

The skill is sprint-aware but does NOT manage sprints (that's the Scrum Master's job).

- **Check active sprint:** query via JQL `sprint in openSprints()`
- **View sprint items:** `acli jira sprint list-workitems --sprint-id ID --json`
- **Never auto-add issues to a sprint** — let the user or Scrum Master decide
- When user asks "what am I working on?", search:
  ```
  acli jira workitem search --jql "sprint in openSprints() AND assignee = currentUser()" --json
  ```

### Sub-tasks

Break down stories into discrete pieces:

```bash
acli jira workitem create --type "Sub-task" --summary "..." --parent "PROJ-456" --project "PROJ" --assignee "@me" --json
```

Sub-tasks inherit the parent's sprint and epic.

## Brainstorming Integration

After reading task context from Jira, ask the user:

> "Would you like to brainstorm implementation approaches?"

If the user agrees and the superpowers plugin is installed, suggest:

> "You can use `/superpowers:brainstorming` to start a structured brainstorming session."

If not installed, proceed with normal conversation-based discussion.

## Post-Commit Behavior

After a git commit, the plugin's hook injects context about checking task status. When this happens:

1. Use `acli-operator` to search in-progress tasks assigned to the user:
   ```
   acli jira workitem search --jql "status = 'In Progress' AND assignee = currentUser()" --json
   ```

2. If any task appears related to the commit (match by branch name, commit message, or conversation context), ask the user:
   > "Should I close PROJ-123 (task summary)?"

3. If user approves:
   - Transition to **Done**: `acli jira workitem transition --key "PROJ-123" --status "Done" --yes --json`
   - Add a comment summarizing the work
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

## Quick Reference

| Action | Rule |
|--------|------|
| Issue title | Plain text, no type prefix |
| Issue description | Background + Acceptance Criteria |
| Issue type | Story / Bug / Task / Epic / Sub-task |
| Assign issue | Default to `@me` |
| Label | Lowercase matching issue type |
| Priority | Default Medium |
| New issue status | To Do (project default) |
| Start working | Transition to In Progress |
| Code in review | Transition to In Review |
| Commit closes issue | Transition to Done (user approval required) |
| Close comment | @mention creator if not self-created |
| Read/write Jira | `acli-operator` subagent (haiku) |
| Draft content | Main model, preview before submit |
| All acli commands | `--json` flag |
| Transitions | `--yes` flag |
| Related stories | Group under an Epic |
| Sprint queries | JQL: `sprint in openSprints()` |
| Brainstorming | Suggest `/superpowers:brainstorming` if available |
