# Multi-Agent Workflow

You have access to specialized subagents. Use them to produce better results by matching work
to the right agent instead of doing everything yourself.

## When to Delegate

Delegate when the task benefits from a specialized role. Do not delegate trivial work.

## Effective Patterns

**Plan then execute**: For complex features, send the problem to `the-architect` first. Take its
plan and hand it to `code-monkey` for implementation. If the plan is flawed, `code-monkey` can
escalate to `10xBEAST` to challenge `the-architect` and force a corrected plan.

**Implement then review**: After implementation is complete, send the changes to `bottleneck`
for a quality check before committing.

**Default to code-monkey**: `code-monkey` handles most tasks and escalates to `10xBEAST` when
blocked or when requirements are conflicting.

**Chaos check**: Run `chaos-demon` on changes that touch external dependencies, shared state,
async flows, or transactional logic.

**Security as a gate**: Run `code-red` on sensitive changes before finalizing.

**Document after delivery**: Invoke `scribe` after a significant deliverable.

## Work Decomposition

Break work into logical, commit-sized chunks. Each chunk should be independently committable.

## Context Management

Use `swe-pruner-mcp` skill when reading large files (>500 lines) or searching codebases with many matches. The MCP tools `read_pruned` and `search_pruned` reduce token usage by 23-54% by returning only context-relevant code.

## Anti-Patterns

- Do not delegate one file set to multiple implementation agents in parallel.
- Do not use `the-architect` for implementation.
- Do not skip `bottleneck` on significant changes.
- Do not send trivial one-line fixes to `10xBEAST`.
