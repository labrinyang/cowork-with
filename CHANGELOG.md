# Changelog

## 2.4.0 (2026-03-04)

### Added
- **`settings.json`**: Default MCP permissions — auto-allow `mcp__atlassian__*` and `mcp__figma__*`
- **`reference.md`** for Jira skill: progressive disclosure — agile workflow, post-commit hook, and limitations extracted from SKILL.md (250→178 lines, −29%)
- `<HARD-GATE>` on Tool Strategy: all MCP read calls MUST go through `explorer` agent, main model forbidden from calling MCP reads directly

### Changed
- Explorer agent: add `disallowedTools: Write, Edit, NotebookEdit` and `permissionMode: plan` for system-enforced read-only
- All skills: add `argument-hint` for autocomplete (`[PROJ-123]`, `[figma-url]`, `[search term]`)
- All skills: add `allowed-tools` to restrict permission prompts during skill execution
- `plugin.json`: declare explicit component paths (`agents`, `skills`, `hooks`, `mcpServers`)

## 2.3.0 (2026-03-04)

### Added
- **`explorer` agent** (`agents/explorer.md`): Haiku-powered read-only subagent for all MCP reads — replaces ad-hoc "haiku subagent" pattern with a formal agent definition
  - Haiku model for cheap, fast reads
  - Tools: Read, Glob, Grep, Bash, Agent (no Write/Edit)
  - All Atlassian + Figma MCP read tools allowlisted, all write tools explicitly forbidden
  - MCP parameter rules baked in (exact names, types, nodeId format)

### Changed
- All skills now reference `explorer` agent instead of ad-hoc "haiku subagent"
- Jira skill: plain text descriptions only (no Markdown), read project metadata before drafting (localized type names, required fields, active sprint), ask user for missing required fields, confirm sprint assignment
- Jira skill: document exact MCP parameter names/types (`issueTypeName` not `issueType`, `maxResults` as number, `fields` as object, `labels` as array)
- Jira skill: add create-as-Task fallback for custom required field failures
- Figma skill: document nodeId colon format (`23102:138594`, not dash)
- All skills: strengthen HARD-GATE — text-based confirmation does NOT satisfy the gate, must call `AskUserQuestion` tool
- Tool Strategy tables simplified (removed Why column, added spawn instructions)

## 2.2.0 (2026-03-04)

### Added
- **cowork-with-figma skill**: Figma design workflow — design-to-code, design tokens, Code Connect, screenshots, code-to-design reverse
- Official Figma MCP server integration via `.mcp.json` (HTTP transport, OAuth auth)
- All 13 Figma MCP tools: `get_design_context`, `get_variable_defs`, `get_code_connect_map`, `get_code_connect_suggestions`, `get_screenshot`, `get_metadata`, `get_figjam`, `whoami`, `generate_figma_design`, `generate_diagram`, `add_code_connect_map`, `send_code_connect_mappings`, `create_design_system_rules`
- `<HARD-GATE>`: preview generated code before applying from Figma designs
- Cross-skill integration: Jira issues with Figma URLs auto-read design context; Wiki pages reference Figma specs

### Changed
- Onboarding skill: unified auth for both Atlassian and Figma MCP servers
- Jira skill: Cross-Skill Integration now references Figma for design context
- Wiki skill: renamed Jira Integration to Cross-Skill Integration, added Figma reference
- Plugin description and keywords updated to include Figma/design

## 2.1.2 (2026-03-04)

### Changed
- Simplify Jira and Wiki skill files — remove redundant Quick Reference tables, merge overlapping sections, consolidate flow diagrams (-33% lines, all functionality preserved)

## 2.1.1 (2026-03-04)

### Changed
- Shorten all skill descriptions following superpowers pattern — single sentence, trigger-focused, ~60% less context budget usage

## 2.1.0 (2026-03-04)

### Added
- **cowork-with-wiki skill**: Confluence wiki workflow — read product docs, search wiki, browse page hierarchies, create/update personal pages, add comments
- All 11 Confluence MCP tools: `getConfluencePage`, `getConfluencePageDescendants`, `getConfluencePageFooterComments`, `getConfluencePageInlineComments`, `getConfluenceSpaces`, `getPagesInConfluenceSpace`, `searchConfluenceUsingCql`, `createConfluencePage`, `updateConfluencePage`, `createConfluenceFooterComment`, `createConfluenceInlineComment`
- Write safety `<HARD-GATE>`: refuse writes to pages not created by the current user
- Product docs root configuration (space: ONEKEY, page ID: 489095189)
- CQL quick reference for Confluence search
- Cross-skill integration: Jira skill references wiki for product context; Wiki skill references Jira for doc gap issues

### Changed
- Jira skill: added Wiki Integration section for cross-referencing product docs
- Onboarding skill: added Confluence to setup status and wiki command to available commands
- Plugin description and keywords updated to include Confluence/wiki

## 2.0.0 (2026-03-04)

### Breaking Changes
- **Migrated from acli CLI to Atlassian Rovo MCP server** — acli is no longer required
- Removed `agents/` directory (acli-operator subagent no longer needed)
- Removed `reference/` directory (MCP tools are self-documenting)

### Added
- Atlassian Rovo MCP integration via plugin `.mcp.json` (auto-configured on plugin load)
- User lookup section (`lookupJiraAccountId` for non-self assignees)
- Limitations section documenting operations that require Jira web UI
- All 13 Jira MCP tools: `getJiraIssue`, `searchJiraIssuesUsingJql`, `createJiraIssue`, `editJiraIssue`, `transitionJiraIssue`, `addCommentToJiraIssue`, `addWorklogToJiraIssue`, `getVisibleJiraProjects`, `getJiraProjectIssueTypesMetadata`, `getJiraIssueTypeMetaWithFieldsData`, `getTransitionsForJiraIssue`, `getJiraIssueRemoteIssueLinks`, `lookupJiraAccountId`

### Changed
- Onboarding simplified from 5 steps to 3 (verify MCP, authenticate OAuth, optional permissions)
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
