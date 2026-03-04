---
name: cowork-with-figma
description: Use when the user works with or mentions Figma designs, prototypes, mockups, UI specs, design tokens, or design-to-code workflows
---

# Figma Workflow

Design-to-code workflow for Claude Code via the official Figma MCP server.

## Prerequisites

MCP is auto-configured. If not authenticated, run `/cowork-with:cowork-with-onboarding`.

## Design Context from URLs

When a Figma URL appears — in conversation, a Jira issue description, or a wiki page — use the haiku subagent to extract design context automatically. Pass the full Figma URL directly to `get_design_context`; the tool extracts the relevant node.

## Tool Strategy

Split Figma operations between a **haiku subagent** (reads) and the **main model** (writes):

| Task | Who |
|------|-----|
| Read design context, tokens, metadata | Haiku subagent |
| Take screenshots for visual reference | Haiku subagent |
| Inspect Code Connect mappings | Haiku subagent |
| Generate code from design context | Main model |
| Preview to user and get confirmation | Main model |
| Write to Figma (generate design, diagrams, Code Connect) | Main model |

### MCP Tools

**Read** (haiku subagent):
- `get_design_context` — structured code from frames/components (React + Tailwind default)
- `get_variable_defs` — design tokens: colors, spacing, typography
- `get_code_connect_map` — existing component-to-code mappings
- `get_code_connect_suggestions` — detect unmapped components
- `get_screenshot` — visual reference of a selection
- `get_metadata` — XML layer structure (lightweight; use for large files before calling `get_design_context` on specific nodes)
- `get_figjam` — FigJam diagram metadata and screenshots
- `whoami` — current user info and plan details

**Write** (main model, after user confirmation):
- `generate_figma_design` — capture running web UI as editable Figma design (code → Figma); confirm target file with user first
- `generate_diagram` — create FigJam diagram from Mermaid syntax or natural language
- `add_code_connect_map` — create Code Connect mappings between components and code
- `send_code_connect_mappings` — finalize suggested Code Connect mappings
- `create_design_system_rules` — generate rule file for consistent code output

<HARD-GATE>
Always preview generated code before applying. Show the design context source (Figma URL, frame name) and the generated code before writing to any file. Do NOT write code from Figma designs without user confirmation.
</HARD-GATE>

## Cross-Skill Integration

- After reading design context, offer `/superpowers:brainstorming` to explore implementation approaches before coding.
- If a **Jira issue** contains a Figma URL, auto-read the design context when working on that issue.
- If a **wiki page** references Figma designs, extract design context for implementation specifications.
- After implementing a design, suggest updating the related **Jira issue** via `/cowork-with:cowork-with-jira` to track progress.

## Limitations

The following are **not available** via MCP or have restrictions:

- **Rate limits**: Starter plan — 6 read calls/month; Professional+ with Dev/Full seats — per-minute limits. Write tools are exempt.
- **`generate_figma_design`**: Rolling out, limited availability.
- **No direct Figma editing**: Cannot create/modify individual components, layers, or styles.
- **No comment management**: Cannot read or write Figma comments.
- **No version history**: Cannot access file version history.
- **No team/project management**: Cannot manage teams, projects, or permissions.
