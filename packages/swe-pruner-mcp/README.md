# SWE-Pruner MCP Server

Model Context Protocol (MCP) server for [SWE-Pruner](https://github.com/Ayanami1314/swe-pruner), enabling context-aware code pruning to reduce token usage by 23-54%.

## What It Does

SWE-Pruner is a 0.6B parameter model that selectively prunes code based on your current task or question. This MCP server wraps it as tools that can be used with opencode and other MCP-compatible AI agents.

## Installation

This package is installed as part of your nixfiles-v2 configuration:

```bash
# Enable the module
# In hosts/darwin/work/home.nix, add:
swe-pruner-mcp.enable = true;

# Apply changes
ns
```

The model is automatically downloaded and cached in the nix store, then copied to `$HOME/.cache/swe-pruner/models/` on first activation.

## Usage

### Tools Available

#### `read_pruned(file_path, context_focus_question?)`

Read a file with optional context-aware pruning.

**Parameters:**
- `file_path` (required): Path to the file to read
- `context_focus_question` (optional): Question to guide pruning. Only code relevant to this question will be returned.

**Examples:**
```bash
# Without pruning (returns full file)
read_pruned(file_path="src/main.py")

# With pruning (returns only relevant sections)
read_pruned(
  file_path="src/main.py",
  context_focus_question="How is authentication handled in this file?"
)
```

#### `search_pruned(pattern, context_focus_question?)`

Search codebase with optional context-aware pruning.

**Parameters:**
- `pattern` (required): Pattern to search for (regex supported)
- `context_focus_question` (optional): Question to guide pruning. Only matches relevant to this question will be returned.

**Examples:**
```bash
# Search without pruning
search_pruned(pattern="class User")

# Search with pruning
search_pruned(
  pattern="class User",
  context_focus_question="What fields does the User class have?"
)
```

## How Pruning Works

1. **First Run (slow)**: Model loads from cache (~30 seconds)
2. **Subsequent Runs (fast)**: Model already loaded, pruning takes 1-2 seconds
3. **Fallback Behavior**: If pruning fails, full content is returned automatically
4. **Statistics**: All operations logged to `$HOME/.cache/swe-pruner/stats.json`

## Performance

- **Token Savings**: 23-54% on average (based on SWE-Pruner paper)
- **First Call Latency**: ~30s (model loading)
- **Subsequent Calls**: ~1-2s (pruning only)
- **Model Size**: 2.3GB (cached in nix store)

## Statistics

View pruning statistics:

```bash
cat $HOME/.cache/swe-pruner/stats.json
```

Format:
```json
[
  {
    "timestamp": "2026-02-04T12:00:00",
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
]
```

## Troubleshooting

### Model Loading Fails

Check if model path is correct:
```bash
echo $MODEL_PATH
ls -la $MODEL_PATH
```

### Tools Not Found in Opencode

Ensure opencode is configured to use the MCP server. Check `modules/home/programs/opencode.nix` has the MCP server configured.

### Slow Performance

- First call is always slow due to model loading
- Consider keeping opencode open for longer sessions
- Check stats JSON to see actual compression ratios

## Updating Model

When a new model version is released:

```bash
# Update flake inputs (includes any model updates)
nu

# Rebuild
ns
```

The nix store automatically garbage collects old model versions after 7 days.

## License

MIT
