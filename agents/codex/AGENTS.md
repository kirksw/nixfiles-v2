# Multi-Agent Workflow

You can spawn specialized agents for focused tasks. Use role-specific agents when specialization
adds clear value, and keep trivial work in the main thread.

## Role Selection

- Use `the-architect` for design and planning.
- Use `code-monkey` for implementation.
- Use `bottleneck` for read-only code review before finalizing.
- Use `chaos-demon` to enumerate failure modes without proposing fixes.
- Use `code-red` for security-focused review.
- Use `scribe` after a deliverable to update docs and session logs.
- Use `10xBEAST` to break blockers, force decisions, and simplify bad plans.

## Context Management

Use `swe-pruner-mcp` skill when reading large files (>500 lines) or searching codebases with many matches. The MCP tools `read_pruned` and `search_pruned` reduce token usage by 23-54% by returning only context-relevant code.

## Working Rules

- Do not run multiple implementation agents on the same file set in parallel.
- Keep changes in commit-sized chunks.
- Prefer safe, incremental changes over broad rewrites.
- Escalate to the most specialized role when blocked.
