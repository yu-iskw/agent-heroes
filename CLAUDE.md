# CLAUDE.md — Agent Heroes

This file provides guidance for AI assistants working in this repository.

## Repository Purpose

**agent-heroes** is a Claude Code plugin monorepo template for bootstrapping high-quality Claude Code plugins with shared CI/CD and testing infrastructure. It follows the standard Claude Code plugin layout and demonstrates every available extension point through a comprehensive sample plugin (`plugins/core`).

## Repository Structure

```text
.
├── plugins/                         # All plugins live here
│   └── core/                        # Reference plugin (demonstrates all extension points)
│       ├── .claude-plugin/
│       │   └── plugin.json          # Required plugin manifest
│       ├── skills/                  # Agent Skills (model-invoked)
│       │   └── <skill-name>/
│       │       ├── SKILL.md         # Skill definition (required; YAML frontmatter + instructions)
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
│   ├── test-plugin-install.sh       # Tests `claude plugin install` via Claude CLI
│   ├── test-plugin-loading.sh       # Tests plugin loading
│   ├── test-component-discovery.sh  # Validates component directory structure
│   ├── Dockerfile                   # Docker image for CI integration tests
│   └── docker-entrypoint.sh        # Container entry point
├── .claude-plugin/
│   └── marketplace.json             # Marketplace metadata for this repo
├── .claude/
│   ├── agents/
│   │   └── claude-plugin-manager.md # Orchestrator agent for plugin development
│   └── ANTHROPIC_BEST_PRACTICES.md  # Best practices reference
├── .github/
│   ├── workflows/
│   │   ├── integration_tests.yml    # Runs integration tests on every push/PR
│   │   ├── trunk_check.yml          # Runs Trunk linters on PRs
│   │   └── trunk_upgrade.yml        # Keeps Trunk tooling up to date
│   └── CODEOWNERS                   # Code ownership
├── .trunk/
│   ├── trunk.yaml                   # Trunk linter configuration
│   └── configs/                     # Per-linter config files
├── Makefile                         # Task runner
├── README.md
├── CONTRIBUTING.md
├── AGENTS.md                        # AI assistant context for Gemini CLI, Cursor, Codex, etc.
└── CLAUDE.md                        # This file (Claude Code-specific)
```

## Plugin Component Conventions

### Plugin Manifest (`plugin.json`)

Every plugin directory **must** contain `.claude-plugin/plugin.json`. Required fields:

```json
{
  "name": "plugin-name",      // kebab-case, matches ^[a-z0-9-]+$
  "version": "1.0.0",
  "description": "...",
  "author": { "name": "..." },
  "license": "Apache-2.0",
  "repository": "...",
  "mcpServers": "./.mcp.json",  // optional
  "lspServers": "./.lsp.json"   // optional
}
```

- `name` must be kebab-case (`^[a-z0-9-]+$`)
- `name`, `version`, and `description` are required non-empty strings

### Skills (`skills/<name>/SKILL.md`)

Skills are model-invoked. The `SKILL.md` requires YAML frontmatter:

```markdown
---
name: skill-name
description: One-sentence description used for skill selection.
---

# Skill Title

## Purpose
...

## Instructions
...
```

- Keep instructions specific, testable, and deterministic
- Place supporting templates/data under `skills/<name>/assets/`
- Component discovery expects at least one `SKILL.md` per `skills/` directory

### Agents (`agents/*.md`)

Sub-agent markdown files require YAML frontmatter:

```markdown
---
name: agent-name
description: What this agent does.
---

# Agent Title

## Role
...
```

### Hooks (`hooks/hooks.json`)

```json
{
  "version": "1",
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [{ "type": "command", "command": "..." }]
      }
    ],
    "TeammateIdle": [
      {
        "hooks": [{ "type": "prompt", "prompt": "..." }]
      }
    ]
  }
}
```

- Must be valid JSON; validated by `test-component-discovery.sh`
- Supported event types: `PostToolUse`, `TeammateIdle` (and others per Claude Code spec)
- Hook types: `command` (shell) or `prompt` (model invocation)

### Commands (`commands/*.md`)

Slash command definitions as Markdown files. Place in `commands/` directory.

### MCP Servers (`.mcp.json`)

```json
{
  "mcpServers": {
    "server-name": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-sqlite", "--db", "${CLAUDE_PLUGIN_ROOT}/data/sample.db"],
      "env": { "DEBUG": "true" }
    }
  }
}
```

Use `${CLAUDE_PLUGIN_ROOT}` for paths relative to the plugin root.

### LSP Servers (`.lsp.json`)

```json
{
  "typescript": {
    "command": "typescript-language-server",
    "args": ["--stdio"],
    "extensionToLanguage": { ".ts": "typescript" }
  }
}
```

## Development Workflows

### Adding a New Plugin

1. Create `plugins/<name>/` with the standard layout.
2. Add `.claude-plugin/plugin.json` (required manifest).
3. Add at least one component: `skills/`, `agents/`, `hooks/`, or `commands/`.
4. Run validation locally (see Testing below).
5. The integration test runner auto-discovers any directory in `plugins/` containing `.claude-plugin/plugin.json`.

### Adding or Updating Components

- **Skills**: Add `skills/<skill-name>/SKILL.md` under the plugin directory.
- **Agents**: Add `agents/<name>.md` under the plugin directory.
- **Hooks**: Edit `hooks/hooks.json`; keep JSON valid and minimal.
- **Commands**: Add `commands/<name>.md` under the plugin directory.

## Testing

### Integration Test Runner

```bash
# Run all integration tests (requires docker)
make test

# Run directly (requires Claude CLI)
./integration_tests/run.sh

# Options
./integration_tests/run.sh --verbose          # Verbose output
./integration_tests/run.sh --skip-loading     # Skip plugin install/load tests (no Claude CLI needed)
./integration_tests/run.sh --manifest-only    # Only validate manifests
./integration_tests/run.sh --fail-fast        # Stop on first failure
```

The runner auto-discovers plugins by scanning `plugins/*/` for directories containing `.claude-plugin/`.

### Test Stages (per plugin)

1. **Manifest validation** — Checks `plugin.json` is valid JSON with required fields and kebab-case name.
2. **Plugin install** — Runs `claude plugin install --scope project <path>` and verifies `claude plugin list` (requires Claude CLI; skipped if not available).
3. **Plugin loading** — Verifies the plugin loads correctly.
4. **Component discovery** — Validates directory structure and JSON validity of `hooks/hooks.json`.

### Validate Manifest Only

```bash
./integration_tests/validate-manifest.sh plugins/core
```

Requires `jq` or `node` to be available.

## Linting and Formatting

This project uses [Trunk](https://trunk.io) for unified linting and formatting.

### Makefile Targets

```bash
make lint      # Run trunk check --all (all linters)
make format    # Run trunk fmt --all (auto-format)
make test      # Build Docker image and run integration tests
```

### Enabled Linters (`.trunk/trunk.yaml`)

| Linter | Purpose |
|--------|---------|
| `shfmt` | Shell script formatting |
| `shellcheck` | Shell script static analysis |
| `actionlint` | GitHub Actions workflow linting |
| `markdownlint` | Markdown style checks |
| `prettier` | General formatting (JSON, YAML, etc.) |
| `trivy` | Security vulnerability scanning |
| `yamllint` | YAML validation |
| `git-diff-check` | Trailing whitespace / mixed line endings |

### Pre-commit / Pre-push Hooks (Trunk Actions)

Trunk is configured to auto-run:
- `trunk-fmt-pre-commit` — Format on commit
- `trunk-check-pre-push` — Lint on push

Always run `make format && make lint` before opening a PR.

## CI/CD

### GitHub Actions Workflows

| Workflow | Trigger | What it does |
|---------|---------|-------------|
| `integration_tests.yml` | Push to any branch, PRs, manual | Installs Claude CLI, runs `./integration_tests/run.sh --verbose` |
| `trunk_check.yml` | PRs, manual | Runs Trunk linters via `trunk-io/trunk-action@v1` |
| `trunk_upgrade.yml` | Scheduled | Keeps Trunk tooling versions up to date |

CI runs all linters and integration tests. Both must pass before merging.

## Agent Orchestration

### `claude-plugin-manager` Agent

The `.claude/agents/claude-plugin-manager.md` agent orchestrates the full plugin development lifecycle:

- Routes to specialized skills based on task complexity (scored 0–10)
- Enforces quality gates: design → implement → lint → package → verify
- Automatically invokes `lint-fix` after implementation steps
- Runs `plugin-verification` before reporting completion

**Complexity scoring guide** (from Anthropic best practices):
- **Score 0–3**: Simple skill (deterministic, single task)
- **Score 4–6**: Workflow skill (multi-step, some branching)
- **Score 7–8**: Sub-agent (autonomous, model-driven decisions)
- **Score 9–10**: Agent team (multi-agent coordination)

**Always start with the simplest approach**. Only increase complexity when clearly justified.

### Available Skills (invoked by the agent)

| Skill | Purpose |
|-------|---------|
| `implement-claude-extensions` | Decision gateway; routes to appropriate component skill |
| `implement-agent-skills` | Create/validate SKILL.md files |
| `implement-sub-agents` | Create/validate sub-agent definitions |
| `implement-hooks` | Implement hook configurations and scripts |
| `implement-agent-teams` | Set up agent team configurations |
| `implement-plugin` | Package plugin for distribution |
| `plugin-verification` | Layered verification (component, manifest, runtime) |
| `lint-fix` | Auto-fix linting violations via Trunk |

## Key Conventions for AI Assistants

1. **Read files before modifying them.** Never propose changes without reading the current state.
2. **Follow kebab-case for plugin names.** The manifest validator enforces `^[a-z0-9-]+$`.
3. **SKILL.md frontmatter is required.** The `name` and `description` fields must be present.
4. **Keep hooks.json valid JSON.** Both `jq` and `node` validators check it during tests.
5. **Run `make format && make lint` before committing.** Trunk pre-push hooks enforce this in CI.
6. **Use `make test` (Docker) to validate integration tests locally.**
7. **Keep plugin components focused and minimal.** Follow the "start simple" Anthropic principle.
8. **Don't add docstrings, comments, or extra structure** beyond what the task requires.
9. **Preserve existing file structure.** Don't reorganize directories without explicit instruction.
10. **Commit messages should be imperative, clear, and scoped** (e.g., "Add problem-solving skill to core plugin").

## Prerequisites

| Tool | Required for |
|------|-------------|
| `git` | Version control |
| `docker` | Running integration tests via `make test` |
| `trunk` | Linting and formatting (`make lint`, `make format`) |
| `jq` or `node` | Manifest and hook JSON validation |
| `claude` CLI (optional) | Full plugin install/load tests |

Install Trunk:
```bash
curl https://get.trunk.io -fsSL | bash
```

Install Claude Code CLI (optional):
```bash
npm install -g @anthropic-ai/claude-code
```

## Local Development Checklist (before opening a PR)

```bash
make format                          # Auto-format all files
make lint                            # Run all linters
./integration_tests/run.sh --verbose # Run integration tests (or make test for Docker)
```
