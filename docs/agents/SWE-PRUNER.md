# SWE-Pruner Integration for Opencode

## Overview

SWE-Pruner is a self-adaptive context pruning framework that reduces token usage by 23-54% while preserving critical implementation details. It uses a 0.6B parameter model to selectively prune code based on your current task or question.

This integration provides SWE-Pruner as a Model Context Protocol (MCP) server that runs on-demand when you start opencode.

## Architecture

```
opencode starts → MCP server launches → SWE-Pruner model loads from cache
                        ↓
                  [First call: ~30s]
                  [Subsequent: ~1-2s]
                        ↓
               Tools available: read_pruned, search_pruned
                        ↓
               Prune code based on context focus question
                        ↓
               Return pruned content (or full content if pruning fails)
                        ↓
               Stats logged to: $HOME/.cache/swe-pruner/stats.json
```

## Setup Guide

### Prerequisites

- `python3.12` or later installed
- 2GB+ free disk space for model cache
- Openable enabled in your nixfiles-v2 config

### Installation

The SWE-Pruner MCP server is already integrated into your nixfiles-v2 configuration. To enable it:

1. **Enable the module** (if not already enabled)
   ```nix
   # In hosts/darwin/work/home.nix, ensure:
   homeModules.swePrunerMcp.enable = true;
   ```

2. **Apply configuration**
   ```bash
   apps/aarch64-darwin/switch
   ```

The server attempts model-backed pruning when a model is available at `MODEL_PATH`.
If no model is available, it falls back to heuristic pruning.

## Usage

### Tool: `read_pruned`

Read file contents with optional context-aware pruning.

**Parameters:**
- `file_path` (required, string): Path to the file to read
- `context_focus_question` (optional, string): Question to guide pruning

**When to use:**
- Reading large files (10k+ tokens)
- Need specific sections (e.g., "How is error handling implemented?")
- Want to reduce token usage while maintaining context

**When NOT to use:**
- Small files (< 1k tokens) - overhead isn't worth it
- Reading configuration files - need full context
- First time reading a file - overhead of understanding query

**Examples:**

```bash
# Read full file (no pruning)
read_pruned(file_path="src/main.py")

# Read only authentication-related code
read_pruned(
  file_path="src/main.py",
  context_focus_question="How is authentication handled in this file?"
)

# Read only database schema
read_pruned(
  file_path="src/models.py",
  context_focus_question="What are the database table structures?"
)
```

### Tool: `search_pruned`

Search codebase with optional context-aware pruning.

**Parameters:**
- `pattern` (required, string): Pattern to search for (regex supported)
- `context_focus_question` (optional, string): Question to guide pruning

**When to use:**
- Searching for function/class definitions
- Looking for specific patterns in large codebase
- Need context-aware filtering of search results

**When NOT to use:**
- Simple grep operations - use standard search tools
- Pattern-based refactoring - use standard search
- Small codebases - full results are manageable

**Examples:**

```bash
# Search without pruning
search_pruned(pattern="class User")

# Search for User class methods only
search_pruned(
  pattern="class User",
  context_focus_question="What methods does the User class have?"
)

# Search for API endpoints
search_pruned(
  pattern="@router\.(get|post|put|delete)",
  context_focus_question="What are the API endpoint handlers?"
)
```

## Performance Characteristics

### First Run (Cold Start)

- **Model Loading**: ~30 seconds
- **Status**: Logged to stderr
- **What happens**: Model downloaded from nix store and loaded into memory
- **Subsequent calls**: Fast (~1-2s) for pruning

### Typical Performance

| File Size | Without Pruning | With Pruning | Savings | First Call | Subsequent |
|-----------|----------------|---------------|---------|------------|-------------|
| 1k tokens | ~10ms | ~50ms | 0% | +30s | +1s |
| 10k tokens | ~100ms | ~2s | 23-54% | +30s | +1s |
| 50k tokens | ~500ms | ~5s | 40-50% | +30s | +2s |

**Note**: Actual savings depend on query specificity and code structure.

## Statistics

View pruning statistics and performance metrics:

```bash
# View all operations
cat $HOME/.cache/swe-pruner/stats.json

# View only successful pruning operations
jq '.[] | select(.pruned == true)' $HOME/.cache/swe-pruner/stats.json

# View average compression ratio
jq 'map(.compression_ratio) | add / length' $HOME/.cache/swe-pruner/stats.json

# View operations from today
jq '.[] | select(.timestamp | startswith("2026-02-04"))' $HOME/.cache/swe-pruner/stats.json
```

### Stats Format

```json
{
  "timestamp": "2026-02-04T12:34:56.789",
  "operation": "prune",
  "input_size": 15234,
  "output_size": 7890,
  "compression_ratio": 0.482,
  "status": "success",
  "error": null,
  "metadata": {
    "query": "How is authentication handled in this file?"
  }
}
```

## Troubleshooting

### Model Loading Fails

**Symptom**: Server starts but pruning always returns full content

**Check**:
```bash
# Verify model path is set
echo $MODEL_PATH

# Verify model files exist
ls -la $MODEL_PATH

# Check server logs
# Logs are written to stderr (visible in opencode)
```

**Solution**:
- Ensure model downloaded successfully during build
- Check nix store contains model files
- Rebuild: `apps/aarch64-darwin/build`

### Tools Not Found in Opencode

**Symptom**: `read_pruned` and `search_pruned` not available in opencode

**Check**:
```bash
# Verify MCP server is registered in opencode config
grep "swe-pruner" ~/Library/Application\ Support/opencode/config.json

# Check module is enabled
grep "homeModules.swePrunerMcp.enable" hosts/darwin/work/home.nix
```

**Solution**:
- Ensure `homeModules.swePrunerMcp.enable = true` in home config
- Rebuild: `apps/aarch64-darwin/switch`
- Restart opencode

### Poor Compression Ratios

**Symptom**: Savings < 10% or 0%

**Possible Causes**:
1. Query is too general ("What does this file do?")
2. Code is already minimal
3. File structure doesn't lend itself to pruning

**Solutions**:
- Use more specific queries ("How is authentication implemented?")
- Accept some files don't benefit from pruning
- Check stats to understand which queries work best

### First Call Always Slow

**Symptom**: Every opencode session has slow first call

**Explanation**: Model must load from disk into memory (~30s, 2.3GB)

**Mitigation**:
- Keep opencode open for longer sessions
- Consider using smaller models for quick tasks
- Pre-load model with test call if needed

## Updating Model Version

When SWE-Pruner releases a new model version:

```bash
# Update flake inputs (this includes any model updates)
nu

# Rebuild to get new model
apps/aarch64-darwin/build

# Apply changes
apps/aarch64-darwin/switch
```

**Notes**:
- Old model versions are automatically garbage collected from nix store after 7 days
- No manual cleanup needed
- `nu` handles all model updates

## Disabling Integration

If you want to disable SWE-Pruner:

```nix
# In hosts/darwin/work/home.nix
homeModules.swePrunerMcp.enable = false;
```

Then apply:
```bash
ns
```

## Advanced Usage

### Understanding Token Savings

Track your savings over time:

```bash
# Total tokens saved
jq '[.[] | select(.pruned == true) | map(.original_tokens - .tokens) | add]' \
  $HOME/.cache/swe-pruner/stats.json

# Total tokens processed
jq '[.[] | map(.original_tokens) | add]' \
  $HOME/.cache/swe-pruner/stats.json

# Overall savings percentage
jq '([.[] | map(.original_tokens - .tokens) | add] / [.[] | map(.original_tokens) | add] * 100)' \
  $HOME/.cache/swe-pruner/stats.json
```

### Optimizing Queries for Better Pruning

**Good queries:**
- "How is authentication implemented?"
- "What error handling exists for database operations?"
- "Show me the API endpoint definitions"

**Less effective queries:**
- "What does this file do?"
- "Explain this code to me"
- "How do I use this?"

**Why**: Specific queries help the model understand what context is relevant, leading to better compression.

## Model Information

- **Name**: code-pruner
- **Repository**: https://huggingface.co/ayanami-kitasan/code-pruner
- **Paper**: https://arxiv.org/abs/2601.16746
- **Parameters**: 0.6B
- **Architecture**: Lightweight neural skimmer with CRF layer
- **Training**: SWE-Bench Verified, LongCodeQA benchmarks
- **License**: MIT

## References

- [SWE-Pruner GitHub](https://github.com/Ayanami1314/swe-pruner)
- [SWE-Pruner Paper](https://arxiv.org/abs/2601.16746)
- [MCP Specification](https://modelcontextprotocol.io)
- [OpenCode Documentation](https://opencode.ai/docs)
