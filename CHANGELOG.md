# Changelog

## 2.0.0 (2026-03-04)

### Breaking Changes
- **Migrated from acli CLI to Atlassian Rovo MCP server** — acli is no longer required
- Removed `agents/` directory (acli-operator subagent no longer needed)
- Removed `reference/` directory (MCP tools are self-documenting)

### Added
- Atlassian Rovo MCP integration (`https://mcp.atlassian.com/v1/sse`)
- User lookup section (`lookupJiraAccountId` for non-self assignees)
- Limitations section documenting operations that require Jira web UI
- All 13 Jira MCP tools: `getJiraIssue`, `searchJiraIssuesUsingJql`, `createJiraIssue`, `editJiraIssue`, `transitionJiraIssue`, `addCommentToJiraIssue`, `addWorklogToJiraIssue`, `getVisibleJiraProjects`, `getJiraProjectIssueTypesMetadata`, `getJiraIssueTypeMetaWithFieldsData`, `getTransitionsForJiraIssue`, `getJiraIssueRemoteIssueLinks`, `lookupJiraAccountId`

### Changed
- Onboarding simplified from 5 steps to 3 (add MCP server, restart, verify)
- Tool strategy: main model calls MCP directly instead of haiku subagent
- Post-commit hook references MCP tools instead of acli commands
- Setup no longer requires Homebrew or acli installation

### Removed
- `agents/acli-operator.md` — subagent replaced by direct MCP calls
- `reference/` directory (index.md, workitems.md, workitems-advanced.md, boards-sprints.md, jql.md)
- All `acli jira ...` command examples
- Sprint assignment via `workitem edit` (use Jira web UI)
- `--json` / `--yes` flag rules (not applicable to MCP)

## 1.2.0 (2026-03-03)

### Changed
- Refactor acli-operator: add Read tool, remove skills injection, abstract command framework
- Replace acli-reference skill with progressive disclosure reference files
- Add `<HARD-GATE>` for preview-before-submit and read-before-execute rules
- Add `<example>` tags in agent description (superpowers pattern)
- Fix acli parameter names (`--id`, `--sprint`, `--board`)
- Add sprint awareness to issue creation flow
- Add anti-pattern warning for board iteration

### Added
- `reference/` directory with split command reference (index, workitems, workitems-advanced, boards-sprints, jql)
- Missing acli commands: link, attachment, clone, create-bulk, filter, sprint CRUD

## 1.1.0 (2026-03-03)

### Changed
- Rename skills to `cowork-with-jira` and `cowork-with-onboarding` namespace convention

## 1.0.0 (2026-03-03)

Initial release.

### Skills
- **cowork-with-jira**: Main Jira workflow — issue CRUD, status transitions, sprint awareness, epic management
- **cowork-with-onboarding**: Setup guide for Homebrew, acli CLI, and Jira authentication

### Agents
- **acli-operator**: Haiku subagent for executing acli CLI commands

### Hooks
- **post-commit-check**: Detects git commits and prompts for in-progress task closure
