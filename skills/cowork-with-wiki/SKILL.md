---
name: cowork-with-wiki
description: Use when the user works with or mentions Confluence wiki, product docs, documentation pages, or knowledge base content
---

# Wiki Workflow

Confluence wiki workflow for Claude Code via the Atlassian Rovo MCP server.

## Prerequisites

The Atlassian Rovo MCP server is automatically configured by the plugin. If authentication hasn't been completed yet, run `/cowork-with:cowork-with-onboarding`.

## Product Documentation Root

The primary product documentation lives in Confluence:

- **Space key:** ONEKEY
- **Root page ID:** 489095189
- **Root URL:** https://onekeyhq.atlassian.net/wiki/spaces/ONEKEY/pages/489095189/App

When the user asks about product docs, features, or specifications, start by navigating from this root page using `getConfluencePageDescendants` to find relevant child pages.

## Write Safety

<HARD-GATE>
Before ANY write operation to an existing page (`updateConfluencePage`, `createConfluenceFooterComment`, `createConfluenceInlineComment`), the haiku subagent MUST first read the target page using `getConfluencePage` and verify the page creator. If the page was NOT created by the current user, REFUSE the write and explain why. Only pages created by "me" (the current authenticated user) may be modified. This applies to ALL write operations on existing pages without exception.
</HARD-GATE>

For new page creation (`createConfluencePage`), the creator check is not needed since the current user will be the creator. However, always confirm with the user before creating a new page.

## Tool Strategy

Split Confluence operations between a **haiku subagent** (reads) and the **main model** (writes):

| Task | Who | Why |
|------|-----|-----|
| Read pages, search, list spaces | Haiku subagent | Cheap, fast, keeps main context clean |
| Browse page tree (descendants) | Haiku subagent | May require multiple calls |
| Read comments (footer, inline) | Haiku subagent | Informational reads |
| Verify page creator before writes | Haiku subagent | Safety check via getConfluencePage |
| Draft page content | Main model | Requires quality writing |
| Preview to user and get confirmation | Main model | User interaction |
| Write to Confluence (create, update, comment) | Main model | Requires user confirmation + creator check |

### Haiku Subagent — Wiki Reader

Use the Agent tool with `model: "haiku"` for all Confluence read operations. The subagent has access to Atlassian MCP tools and returns structured data to the main model.

**Read MCP tools** (haiku subagent):
- `getConfluencePage` — get a page by ID, body returned as Markdown
- `getConfluencePageDescendants` — list child pages under a parent
- `getConfluencePageFooterComments` — list footer comments on a page
- `getConfluencePageInlineComments` — list inline comments on a page
- `getConfluenceSpaces` — list available spaces
- `getPagesInConfluenceSpace` — list pages in a space
- `searchConfluenceUsingCql` — search using CQL (Confluence Query Language)

**Write MCP tools** (main model, after creator check + user confirmation):
- `createConfluencePage` — create a new page (Markdown body)
- `updateConfluencePage` — update existing page (title, body, location)
- `createConfluenceFooterComment` — add a footer comment
- `createConfluenceInlineComment` — add an inline comment

### Read Product Docs Flow

```
1. Haiku subagent   → Get descendants of root page (getConfluencePageDescendants, page ID 489095189)
2. Haiku subagent   → Read specific page content (getConfluencePage)
3. Main model       → Summarize or present relevant content to user
```

### Search Wiki Flow

```
1. Haiku subagent   → Search using CQL (searchConfluenceUsingCql)
2. Haiku subagent   → Read matching pages for detail (getConfluencePage)
3. Main model       → Present results to user
```

### Update Page Flow

```
1. Haiku subagent   → Read page to get current content AND verify creator (getConfluencePage)
2. HARD-GATE        → If creator != current user, REFUSE and stop
3. Main model       → Draft updated content
4. Main model       → Preview changes to user for confirmation
5. Main model       → Apply update after user approves (updateConfluencePage)
```

### Create Page Flow

```
1. Haiku subagent   → Read parent page to verify location (getConfluencePage)
2. Main model       → Draft page title and content
3. Main model       → Preview to user for confirmation
4. Main model       → Create page after user approves (createConfluencePage)
```

### Add Comment Flow

```
1. Haiku subagent   → Read page to verify creator (getConfluencePage)
2. HARD-GATE        → If creator != current user, REFUSE and stop
3. Main model       → Draft comment content
4. Main model       → Preview to user for confirmation
5. Main model       → Add comment after user approves
```

### Key Rules

<HARD-GATE>
Always preview page content before submission. Show title, parent page, and body content before creating or updating. Do NOT submit to Confluence without user confirmation.
</HARD-GATE>

- **All Confluence reads go through haiku subagent** — never read from Confluence directly in the main model.
- **All Confluence writes stay in the main model** — ensures user confirmation and creator check before any mutation.
- **Creator check is mandatory for all writes to existing pages** — no exceptions.
- **New page creation skips creator check** but still requires user confirmation.

## CQL Quick Reference

Common CQL queries for searching Confluence:

| Goal | CQL |
|------|-----|
| Pages in a space | `space = "ONEKEY" AND type = page` |
| Search by title | `space = "ONEKEY" AND title ~ "search term"` |
| Pages containing text | `space = "ONEKEY" AND text ~ "search term"` |
| Recently modified | `space = "ONEKEY" AND lastModified > now("-7d")` |
| Pages I created | `space = "ONEKEY" AND creator = currentUser()` |
| Pages I modified | `space = "ONEKEY" AND contributor = currentUser()` |

## Jira Integration

When working with wiki pages, consider these Jira connections:

- **Doc gaps found?** If product documentation is missing or outdated, suggest creating a Jira issue using `/cowork-with:cowork-with-jira` with type Task and label `documentation`.
- **Related Jira issues?** When reading a wiki page, use the haiku subagent to search Jira for related issues: `searchJiraIssuesUsingJql` with JQL containing keywords from the page title.
- **Issue needs context?** When a Jira issue references product behavior, look up the relevant wiki page for specifications.

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

## Quick Reference

| Action | Rule |
|--------|------|
| Read product docs | Haiku subagent → start from root page ID 489095189 |
| Search wiki | Haiku subagent → `searchConfluenceUsingCql` |
| Browse page tree | Haiku subagent → `getConfluencePageDescendants` |
| Read page content | Haiku subagent → `getConfluencePage` |
| Read comments | Haiku subagent → footer or inline comments |
| Write to page | Main model, creator check FIRST, then user confirmation |
| Create new page | Main model, user confirmation (no creator check needed) |
| Add comment | Main model, creator check FIRST, then user confirmation |
| Draft content | Main model, preview before submit |
| Doc gap found | Suggest Jira issue via `/cowork-with:cowork-with-jira` |
| CQL search | `space = "ONEKEY" AND text ~ "term"` |
