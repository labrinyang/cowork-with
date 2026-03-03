# Changelog

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
