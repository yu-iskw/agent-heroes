# AGENTS.md — Agent Heroes

Context file for AI coding assistants (Gemini CLI, Cursor, Codex, and others).
For Claude Code-specific guidance see `CLAUDE.md`.

## Repository Purpose

**agent-heroes** is a Claude Code plugin monorepo template for bootstrapping high-quality Claude Code plugins with shared CI/CD and testing infrastructure. It demonstrates every available extension point through a comprehensive sample plugin (`plugins/core`).

## Repository Structure

```text
.
├── plugins/                         # All plugins live here
│   └── core/                        # Reference plugin (all extension points)
│       ├── .claude-plugin/
│       │   └── plugin.json          # Required plugin manifest
│       ├── skills/                  # Agent Skills (model-invoked)
│       │   └── <skill-name>/
│       │       ├── SKILL.md         # Skill definition (YAML frontmatter + instructions)
│       │       └── assets/          # Supporting assets (templates, data)
│       ├── agents/                  # Sub-agent definitions (.md files with frontmatter)
│       ├── hooks/
│       │   └── hooks.json           # Event hook configuration
│       ├── commands/                # Slash command definitions (.md files)
│       ├── .mcp.json                # MCP server configuration
│       └── .lsp.json                # LSP server configuration
├── integration_tests/               # Shared test harness
│   ├── run.sh                       # Orchestrator: discovers + runs all plugin tests
│   ├── validate-manifest.sh         # Validates plugin.json schema and required fields
│   ├── test-plugin-install.sh       # Tests plugin install via Claude CLI
│   ├── test-plugin-loading.sh       # Tests plugin loading
│   ├── test-component-discovery.sh  # Validates component directory structure
│   └── Dockerfile                   # Docker image for CI integration tests
├── .claude-plugin/
│   └── marketplace.json             # Marketplace metadata for this repo
├── .claude/
│   └── agents/
│       └── claude-plugin-manager.md # Orchestrator agent for plugin development
├── .github/
│   └── workflows/                   # GitHub Actions CI/CD
├── .trunk/
│   └── trunk.yaml                   # Trunk linter configuration
├── Makefile                         # Task runner (lint, format, test)
├── AGENTS.md                        # This file
├── CLAUDE.md                        # Claude Code-specific guidance
└── README.md
```

## Plugin Manifest (`plugin.json`)

Every plugin **must** have `.claude-plugin/plugin.json`:

```json
{
  "name": "plugin-name",
  "version": "1.0.0",
  "description": "...",
  "author": { "name": "..." },
  "license": "Apache-2.0",
  "repository": "..."
}
```

- `name` must be kebab-case matching `^[a-z0-9-]+$`
- `name`, `version`, and `description` are required non-empty strings

## Plugin Components

| Component | Location | File |
|-----------|----------|------|
| Skills | `skills/<name>/` | `SKILL.md` (required YAML frontmatter: `name`, `description`) |
| Agents | `agents/` | `<name>.md` (required frontmatter: `name`, `description`) |
| Hooks | `hooks/` | `hooks.json` (must be valid JSON) |
| Commands | `commands/` | `<name>.md` |
| MCP servers | plugin root | `.mcp.json` |
| LSP servers | plugin root | `.lsp.json` |

### SKILL.md frontmatter (required)

```markdown
---
name: skill-name
description: One-sentence description.
---
```

### hooks.json structure

```json
{
  "version": "1",
  "hooks": {
    "PostToolUse": [{ "matcher": "Write|Edit", "hooks": [{ "type": "command", "command": "..." }] }],
    "Stop": [{ "hooks": [{ "type": "prompt", "prompt": "..." }] }]
  }
}
```

## Development Workflows

### Adding a New Plugin

1. Create `plugins/<name>/` with the standard layout.
2. Add `.claude-plugin/plugin.json`.
3. Add at least one component (`skills/`, `agents/`, `hooks/`, or `commands/`).
4. Run `./integration_tests/run.sh --manifest-only` to validate.

### Adding or Updating Components

- **Skills**: Add `skills/<skill-name>/SKILL.md` — include YAML frontmatter.
- **Agents**: Add `agents/<name>.md` — include YAML frontmatter.
- **Hooks**: Edit `hooks/hooks.json` — keep JSON valid.
- **Commands**: Add `commands/<name>.md`.

## Testing

```bash
# Full integration tests (Docker)
make test

# Without Docker (requires Claude CLI)
./integration_tests/run.sh --verbose

# Manifest validation only (requires jq or node)
./integration_tests/validate-manifest.sh plugins/core

# Skip plugin loading tests (no Claude CLI needed)
./integration_tests/run.sh --skip-loading
```

Test stages per plugin:
1. Manifest validation — checks `plugin.json` schema and kebab-case name.
2. Plugin install — `claude plugin install --scope project <path>` (requires Claude CLI).
3. Plugin loading — verifies runtime load.
4. Component discovery — validates directory structure and `hooks.json` JSON validity.

## Linting and Formatting

```bash
make format    # Auto-format via Trunk
make lint      # Run all linters via Trunk
```

Enabled linters: `shfmt`, `shellcheck`, `actionlint`, `markdownlint`, `prettier`, `trivy`, `yamllint`, `git-diff-check`.

Always run `make format && make lint` before committing.

## CI/CD

| Workflow | Trigger |
|---------|---------|
| `integration_tests.yml` | Push to any branch, PRs, manual |
| `trunk_check.yml` | PRs, manual |
| `trunk_upgrade.yml` | Scheduled |

## Key Conventions

1. Read files before modifying them — never propose changes without reading current state.
2. Plugin names must be kebab-case (`^[a-z0-9-]+$`).
3. `SKILL.md` frontmatter (`name`, `description`) is required — tests will fail without it.
4. `hooks.json` must always be valid JSON.
5. Run `make format && make lint` before committing.
6. Keep plugin components focused and minimal — start with the simplest approach.
7. Do not add comments, docstrings, or extra structure beyond what the task requires.
8. Preserve existing file structure — do not reorganize directories without explicit instruction.
9. Commit messages must be imperative, clear, and scoped.
10. Do not create files unless strictly necessary — prefer editing existing ones.

## Prerequisites

| Tool | Required for |
|------|-------------|
| `git` | Version control |
| `docker` | Integration tests via `make test` |
| `trunk` | Linting and formatting |
| `jq` or `node` | JSON validation in tests |
| `claude` CLI | Plugin install/load tests (optional) |

```bash
# Install Trunk
curl https://get.trunk.io -fsSL | bash

# Install Claude CLI (optional)
npm install -g @anthropic-ai/claude-code
```
