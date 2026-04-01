# Spec-Driven Development

This project uses **spec-driven development** — a framework for importing reusable [Copilot agent](https://docs.github.com/en/copilot/concepts/agents/coding-agent/about-custom-agents) patterns from a shared spec repository.

## How It Works

Patterns like grounding rules, agent flows, and documentation conventions are maintained as parameterized **spec files** in a dedicated spec repo. This project imports the specs it needs, filling in project-specific values (URLs, folder names, agent names) via `{{VARIABLE}}` placeholders.

## Quick Reference

| Task | Command |
|---|---|
| **Import or re-import specs** | `@spec-importer Import specs from <path-to-specs>` |
| **Check for drift** | `@spec-drift Compare this project against its imported specs` |
| **Export a new pattern** | `@spec-exporter Extract <pattern> from this project` |

## Key Files

| File | Purpose |
|---|---|
| `.spec-config.yaml` | Records which specs are imported, their version, and variable values |
| `.github/copilot-instructions.md` | Generated grounding rules and architecture (from specs) |
| `.github/agents/*.agent.md` | Generated agent definitions (from specs) |

## Variable Syntax

Specs use mustache-style placeholders: `{{VARIABLE_NAME}}`. Values are stored in `.spec-config.yaml` under `variables:` and substituted during import.

## Full Documentation

For the complete spec format reference, FAQ, and available specs, see the spec repository:

👉 **[paulwu/arbitrated-grounding-specs — Full Documentation](https://github.com/paulwu/arbitrated-grounding-specs/tree/main/docs/spec-driven-development)**
