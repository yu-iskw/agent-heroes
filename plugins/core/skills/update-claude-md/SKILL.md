---
name: update-claude-md
description: Review what was learned during this session and surgically update CLAUDE.md to keep it current with new conventions, patterns, file paths, and workflow discoveries.
---

# Update CLAUDE.md

## Purpose

Keep `CLAUDE.md` accurate and current by reflecting real discoveries made during each Claude Code session. This skill is invoked automatically at session end via the `Stop` hook.

## Instructions

### 1. Identify What Changed This Session

Scan the session history for any of the following signals:

- **New files or directories** created that are not yet mentioned in `CLAUDE.md`.
- **New commands or Makefile targets** used that are not documented.
- **Corrected information**: a command failed and a different one worked, or a documented path was wrong.
- **New conventions discovered**: naming patterns, required fields, structural rules, or tooling behavior.
- **New components added**: skills, agents, hooks, commands, or MCP/LSP servers.
- **Workflow discoveries**: sequences of steps that were found to be necessary or beneficial.
- **Prerequisite changes**: new tools required, version constraints, or environment setup.

If nothing meaningful was discovered—skip all edits and do not touch `CLAUDE.md`.

### 2. Read the Current CLAUDE.md

Always read the full current `CLAUDE.md` before making any edits. Never modify content you have not read.

### 3. Apply Surgical Edits Only

- **Do not rewrite sections** that are already accurate.
- **Add** new entries to the appropriate existing section (e.g., a new linter under the Linters table, a new Makefile target, a new convention to the Key Conventions list).
- **Correct** only the specific lines that are wrong.
- **Create a new section** only if the discovery genuinely does not fit any existing section.
- Keep wording consistent with the existing style: imperative, concise, no filler phrases.

### 4. Sections and Where Things Go

| Discovery type | Target section |
|---|---|
| New directory or file | Repository Structure (tree) |
| New plugin component | Plugin Component Conventions |
| New Makefile target | Linting and Formatting → Makefile Targets |
| New linter | Enabled Linters table |
| New GitHub Actions workflow | CI/CD table |
| New convention or rule | Key Conventions (numbered list) |
| New prerequisite tool | Prerequisites table |
| New agent or skill | Agent Orchestration |
| Corrected workflow step | Development Workflows |

### 5. Do Not

- Do not add speculative or hypothetical content.
- Do not document things that were tried but did not work.
- Do not remove correct existing content.
- Do not reformat or restructure sections that were not touched.
- Do not add the current date or session metadata to the file.

## Example

**Session discovery**: A new `make check` target was used that runs both `make format` and `make lint` together.

**Edit**: Add one row to the Makefile Targets table:

```
| `make check` | Run `make format` then `make lint` in sequence |
```

No other changes needed.
