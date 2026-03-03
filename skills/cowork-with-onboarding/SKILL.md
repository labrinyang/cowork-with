---
name: cowork-with-onboarding
description: Guides installation of Homebrew, the Atlassian acli CLI, authentication with Jira, and optional superpowers plugin setup. Use when the user needs to set up acli or mentions Jira CLI setup.
disable-model-invocation: true
allowed-tools: Bash, Read, AskUserQuestion
---

# Onboarding

Walk the user through setting up their environment for the cowork-with plugin. Check each step and skip any that are already complete.

## Step 1: Homebrew

Check if Homebrew is installed:

```bash
which brew
```

If missing, guide the user to install it:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Verify after install:

```bash
brew --version
```

## Step 2: Atlassian CLI (acli)

Check if acli is installed:

```bash
which acli
```

If missing, install:

```bash
brew tap atlassian/homebrew-acli
brew install acli
```

Verify:

```bash
acli --version
```

## Step 3: Authenticate with Jira

Check authentication status:

```bash
acli jira auth status
```

If not authenticated, run browser-based OAuth:

```bash
acli jira auth login --web
```

This opens a browser window. The user should:
1. Select their Atlassian site
2. Grant access to the CLI
3. Return to the terminal

Verify authentication:

```bash
acli jira auth status
```

## Step 4: Claude Code Permissions (Optional)

For a smoother workflow, suggest adding acli commands to the project's allow list. Show the user what to add to `.claude/settings.json` or `.claude/settings.local.json`:

```json
{
  "permissions": {
    "allow": [
      "Bash(acli *)"
    ]
  }
}
```

This prevents repeated permission prompts for acli commands.

## Step 5: Superpowers Plugin (Optional)

Ask the user if they want structured brainstorming and development workflows.

If yes, the superpowers plugin provides `/superpowers:brainstorming`, `/superpowers:test-driven-development`, and more.

Install instructions depend on how the user manages plugins. Point them to the superpowers plugin documentation for their setup.

## Completion

After all steps pass, confirm readiness and display available commands:

**Setup Status:**
- Homebrew: installed
- acli: installed and authenticated
- Jira: accessible

**Available Commands:**

| Command | Description |
|---------|-------------|
| `/cowork-with:cowork-with-jira` | Jira workflow — issue creation, status transitions, sprint queries, epic management |
| `/cowork-with:acli-reference` | acli CLI command reference and JQL templates |
| `/cowork-with:cowork-with-onboarding` | Re-run this setup guide |
