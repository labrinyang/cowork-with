# Changelog

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
