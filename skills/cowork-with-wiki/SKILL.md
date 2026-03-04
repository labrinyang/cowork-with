---
name: cowork-with-wiki
description: Use when the user works with or mentions Confluence wiki, product docs, documentation pages, or knowledge base content
argument-hint: "[search term or page title]"
allowed-tools: Read, Glob, Grep, Bash, Agent, AskUserQuestion
---

# Wiki Workflow

Confluence wiki workflow for Claude Code via the Atlassian Rovo MCP server.

## Prerequisites

MCP is auto-configured. If not authenticated, run `/cowork-with:cowork-with-onboarding`.

## Product Documentation Root

- **Space:** ONEKEY
- **Root page ID:** 489095189

For product doc queries, navigate from root via `getConfluencePageDescendants`.

## Write Safety

<HARD-GATE>
Before ANY write operation to an existing page (`updateConfluencePage`, `createConfluenceFooterComment`, `createConfluenceInlineComment`), the `explorer` agent MUST first read the target page using `getConfluencePage` and verify the page creator. If the page was NOT created by the current user, REFUSE the write and explain why. Only pages created by "me" (the current authenticated user) may be modified. This applies to ALL write operations on existing pages without exception.
</HARD-GATE>

New page creation skips the creator check (current user is the creator), but always confirm with the user before creating.

## Tool Strategy

<HARD-GATE>
ALL MCP read tool calls MUST go through the `explorer` agent. The main model MUST NOT call any MCP read tool directly — always spawn the `explorer` agent to do it. This is mandatory because the explorer agent enforces correct parameter types and names.
</HARD-GATE>

Spawn via: `Agent tool → name: "explorer"` (the plugin ships `agents/explorer.md` — haiku model, read-only tools, all MCP read access).

| Task | Who |
|------|-----|
| Read pages, search, list spaces | `explorer` agent |
| Browse page tree (descendants) | `explorer` agent |
| Read comments (footer, inline) | `explorer` agent |
| Verify page creator before writes | `explorer` agent |
| Draft page content | Main model |
| Preview to user and get confirmation | Main model |
| Write to Confluence (create, update, comment) | Main model |

### MCP Tools

**Read** (`explorer` agent):
- `getConfluencePage` — get a page by ID, body returned as Markdown
- `getConfluencePageDescendants` — list child pages under a parent
- `getConfluencePageFooterComments` — list footer comments on a page
- `getConfluencePageInlineComments` — list inline comments on a page
- `getConfluenceSpaces` — list available spaces
- `getPagesInConfluenceSpace` — list pages in a space
- `searchConfluenceUsingCql` — search using CQL (Confluence Query Language)

**Write** (main model, after creator check + user confirmation):
- `createConfluencePage` — create a new page (Markdown body)
- `updateConfluencePage` — update existing page (title, body, location)
- `createConfluenceFooterComment` — add a footer comment
- `createConfluenceInlineComment` — add an inline comment

### Update Page Flow

```
1. `explorer` agent   → Read page to get current content AND verify creator (getConfluencePage)
2. HARD-GATE        → If creator != current user, REFUSE and stop
3. Main model       → Draft updated content
4. Main model       → Preview changes to user for confirmation
5. Main model       → Apply update after user approves (updateConfluencePage)
```

### Create Page Flow

```
1. `explorer` agent   → Read parent page to verify location (getConfluencePage)
2. Main model       → Draft page title and content
3. Main model       → Preview to user for confirmation
4. Main model       → Create page after user approves (createConfluencePage)
```

Comments on existing pages follow the same gate as page updates: verify creator first, then confirm with user.

<HARD-GATE>
Before creating or updating page content, you MUST use `AskUserQuestion` to present a structured confirmation. Show title, parent page, and body content in the `markdown` preview field. Options: "Submit" (Recommended), "Edit", "Cancel". Do NOT call any Confluence write tool without explicit user approval via this confirmation. This is NOT optional — text-based confirmation does NOT satisfy this gate. You MUST call the `AskUserQuestion` tool.
</HARD-GATE>

## CQL Quick Reference

| Goal | CQL |
|------|-----|
| Pages in a space | `space = "ONEKEY" AND type = page` |
| Search by title | `space = "ONEKEY" AND title ~ "search term"` |
| Pages containing text | `space = "ONEKEY" AND text ~ "search term"` |
| Recently modified | `space = "ONEKEY" AND lastModified > now("-7d")` |
| Pages I created | `space = "ONEKEY" AND creator = currentUser()` |
| Pages I modified | `space = "ONEKEY" AND contributor = currentUser()` |

## Cross-Skill Integration

- If product documentation is missing or outdated, suggest creating a Jira issue via `/cowork-with:cowork-with-jira` with type Task and label `documentation`.
- When reading a wiki page, use the `explorer` agent to search Jira for related issues via `searchJiraIssuesUsingJql`.
- If a wiki page references Figma designs, use `/cowork-with:cowork-with-figma` to extract design specs for implementation.

## Limitations

The following operations are **not available** via MCP and require the Confluence web UI:

- Page permissions management
- Page labels / tags
- Attachments (uploading files to pages)
- Page templates
- Page history / version comparison
- Space administration
- Macros and dynamic content
- Page restrictions
