---
name: update-claude-md
description: Review what was learned during this session and surgically update CLAUDE.md and AGENTS.md to keep both current with new conventions, patterns, file paths, and workflow discoveries.
---

# Update AI Documentation

## Purpose

Keep `CLAUDE.md` and `AGENTS.md` accurate and current by reflecting real discoveries made during each session. This skill is invoked automatically at session end via the `Stop` hook.

`CLAUDE.md` is for Claude Code and may include Claude-specific extension points (hooks, skills, agents, MCP). `AGENTS.md` is tool-agnostic and targets Gemini CLI, Cursor, Codex, and other AI assistants — it should contain only information that applies across tools.

## Instructions

### 1. Identify What Changed This Session

Scan the session history for any of the following signals:

- **New files or directories** created that are not yet mentioned in either doc.
- **New commands or Makefile targets** used that are not documented.
- **Corrected information**: a command failed and a different one worked, or a documented path was wrong.
- **New conventions discovered**: naming patterns, required fields, structural rules, or tooling behavior.
- **New components added**: skills, agents, hooks, commands, MCP/LSP servers.
- **Workflow discoveries**: sequences of steps that proved necessary or beneficial.
- **Prerequisite changes**: new tools required, version constraints, or environment setup.

If nothing meaningful was discovered — skip all edits and do not touch either file.

### 2. Read Both Files Before Editing

Always read the full current `CLAUDE.md` and `AGENTS.md` before making any edits. Never modify content you have not read.

### 3. Decide Which File(s) to Update

| Discovery                                                            | Update CLAUDE.md | Update AGENTS.md |
| -------------------------------------------------------------------- | ---------------- | ---------------- |
| Claude-specific extension points (hooks schema, skills, agents, MCP) | Yes              | No               |
| General repo structure, file paths, directory layout                 | Yes              | Yes              |
| General commands (`make lint`, `make format`, `make test`)           | Yes              | Yes              |
| New plugin component conventions (manifest fields, kebab-case)       | Yes              | Yes              |
| New Makefile targets                                                 | Yes              | Yes              |
| New linter in Trunk config                                           | Yes              | Yes              |
| New CI workflow                                                      | Yes              | Yes              |
| New prerequisite tool                                                | Yes              | Yes              |
| New key convention (applies to all tools)                            | Yes              | Yes              |
| New key convention (Claude-specific only)                            | Yes              | No               |

### 4. Apply Surgical Edits Only

- **Do not rewrite sections** that are already accurate.
- **Add** new entries to the appropriate existing section.
- **Correct** only the specific lines that are wrong.
- **Create a new section** only if the discovery genuinely does not fit any existing section.
- Keep wording consistent with the existing style in each file: imperative, concise, no filler phrases.

### 5. Section Routing

| Discovery type              | Target section                                                           |
| --------------------------- | ------------------------------------------------------------------------ |
| New directory or file       | Repository Structure (tree)                                              |
| New plugin component        | Plugin Component Conventions (CLAUDE.md) / Plugin Components (AGENTS.md) |
| New Makefile target         | Linting and Formatting → Makefile Targets                                |
| New linter                  | Enabled Linters table                                                    |
| New GitHub Actions workflow | CI/CD table                                                              |
| New convention or rule      | Key Conventions (numbered list)                                          |
| New prerequisite tool       | Prerequisites table                                                      |
| New agent or skill          | Agent Orchestration (CLAUDE.md only)                                     |
| Corrected workflow step     | Development Workflows                                                    |

### 6. Do Not

- Do not add speculative or hypothetical content.
- Do not document things that were tried but did not work.
- Do not remove correct existing content.
- Do not reformat or restructure sections that were not touched.
- Do not add the current date or session metadata to either file.
- Do not copy Claude-specific content (hooks schema, skill frontmatter, agent orchestration) into `AGENTS.md`.

## Example

**Session discovery**: A new `make check` target was added that runs `make format` then `make lint`.

**Edits**:

- In `CLAUDE.md`: add one row to the Makefile Targets table.
- In `AGENTS.md`: add one row to the equivalent commands section.

No other changes needed.
