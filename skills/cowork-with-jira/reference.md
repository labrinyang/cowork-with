# Jira Reference

Detailed patterns for agile workflow, post-commit automation, and git integration. Load this when working with epics, sprints, sub-tasks, or post-commit task closure.

## Agile Workflow

### Epics

- Create epic: `createJiraIssue` with type "Epic" (main model, after user confirms)
- Link story to epic: set the parent field when creating, or use `editJiraIssue` after creation
- Epic titles are plain descriptive text (e.g., "OAuth Integration", "Payment System Overhaul")
- If work spans 3+ related stories, create an epic first
- Before creating, use `explorer` agent to check existing epics:
  ```
  searchJiraIssuesUsingJql with JQL: "project = PROJ AND issuetype = Epic AND status != Done"
  ```

### Sprints

The skill is sprint-aware but does NOT manage sprints (that's the Scrum Master's job).

- **Check active sprint:** use `explorer` agent to query via JQL `sprint in openSprints()`
- **When user asks "what am I working on?"**, use `explorer` agent to search:
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

1. Use `explorer` agent to search in-progress tasks assigned to the user:
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

### Branch Creation Hook

When a new branch is created without a Jira issue key (via `git checkout -b` or `git switch -c`), the plugin's hook automatically:

1. Detects the missing issue key in the branch name
2. Searches in-progress Jira tasks assigned to the user
3. Suggests renaming the branch to include the related issue key:
   ```
   git branch -m old-name feat/PROJ-123-slug
   ```

If the branch already contains an issue key (e.g., `feat/PROJ-123-my-feature`), the hook stays silent.

### Branch Naming

```
feat/PROJ-123-short-description
fix/PROJ-123-short-description
```

Include the issue key in the branch name. Jira auto-tracks branches, commits, and PRs that contain the issue key — no manual linking required.

### Commit Message Format

```
[PROJ-123] commit message
```

Include the Jira issue key in the commit message when the commit is related to a task.

## JQL Quick Reference

Common JQL patterns for `searchJiraIssuesUsingJql`. Combine with `AND` / `OR`.

### By Assignment

| Goal | JQL |
|------|-----|
| My open tasks | `assignee = currentUser() AND status != Done` |
| Unassigned in project | `project = PROJ AND assignee is EMPTY` |
| Created by me | `reporter = currentUser()` |
| Assigned to someone | `assignee = "user@example.com"` |

### By Sprint

| Goal | JQL |
|------|-----|
| Active sprint items | `sprint in openSprints()` |
| My sprint work | `sprint in openSprints() AND assignee = currentUser()` |
| Future sprint items | `sprint in futureSprints()` |
| Sprint backlog (unfinished) | `sprint in openSprints() AND status != Done` |

### By Epic & Hierarchy

| Goal | JQL |
|------|-----|
| Stories in an epic | `"Epic Link" = PROJ-100` |
| All epics in project | `project = PROJ AND issuetype = Epic` |
| Open epics | `project = PROJ AND issuetype = Epic AND status != Done` |
| Sub-tasks of an issue | `parent = PROJ-123` |

### By Label & Type

| Goal | JQL |
|------|-----|
| By label | `project = PROJ AND labels = "tech-debt"` |
| Multiple labels | `labels in ("tech-debt", "security")` |
| Bugs only | `project = PROJ AND issuetype = Bug` |
| Stories + bugs | `project = PROJ AND issuetype in (Story, Bug)` |

### By Date & Recency

| Goal | JQL |
|------|-----|
| Created this week | `project = PROJ AND created >= startOfWeek()` |
| Updated in last 7 days | `project = PROJ AND updated >= -7d` |
| Created this month | `project = PROJ AND created >= startOfMonth()` |
| Resolved recently | `project = PROJ AND resolved >= -7d` |
| Overdue | `project = PROJ AND duedate < now() AND status != Done` |

### By Priority & Status

| Goal | JQL |
|------|-----|
| High priority open | `project = PROJ AND priority in (Highest, High) AND status != Done` |
| In Progress tasks | `project = PROJ AND status = "In Progress"` |
| Blocked / on hold | `project = PROJ AND status = "On Hold"` |
| Recently resolved | `project = PROJ AND status = Done AND resolved >= -7d` |

### Combined Patterns

| Goal | JQL |
|------|-----|
| My bugs this sprint | `sprint in openSprints() AND assignee = currentUser() AND issuetype = Bug` |
| Unfinished high-priority | `project = PROJ AND priority in (Highest, High) AND status not in (Done, Closed)` |
| Tech debt backlog | `project = PROJ AND labels = "tech-debt" AND status = "To Do"` |
| Sprint review (done items) | `sprint in openSprints() AND status = Done` |

### Tips

- Use `currentUser()` instead of hardcoding usernames — works across all accounts
- Date functions: `startOfDay()`, `startOfWeek()`, `startOfMonth()`, `now()`, `-7d` (relative)
- `text ~ "keyword"` searches summary + description
- `summary ~ "keyword"` searches summary only
- `ORDER BY priority DESC, created ASC` for sorting

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
