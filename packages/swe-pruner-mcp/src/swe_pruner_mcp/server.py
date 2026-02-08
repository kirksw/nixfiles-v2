"""SWE-Pruner MCP Server"""
import os
import sys
import logging
from pathlib import Path
from typing import Any

import torch
from transformers import AutoTokenizer, AutoModelForSequenceClassification

from mcp.server.lowlevel import Server
from mcp.types import TextContent

from .logger import PrunerLogger

# Configure logging to stderr only
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
    stream=sys.stderr,
)
logger = logging.getLogger(__name__)


class SWEPrunerService:
    """Service to load and use SWE-Pruner model"""

    def __init__(self, model_path: str | None = None):
        """Initialize pruner service and load model"""
        self.model_path = model_path or os.getenv("MODEL_PATH")
        self.stats_file = os.getenv("STATS_FILE")
        self.logger = PrunerLogger(self.stats_file)

        self.tokenizer = None
        self.model = None
        self._load_model()

    def _load_model(self):
        """Load SWE-Pruner model from HuggingFace or local path"""
        try:
            if self.model_path and Path(self.model_path).exists():
                logger.info(f"Loading model from local path: {self.model_path}")
                model_name = self.model_path
            else:
                logger.info("Loading model from HuggingFace: ayanami-kitasan/code-pruner")
                model_name = "ayanami-kitasan/code-pruner"

            logger.info("Loading tokenizer...")
            self.tokenizer = AutoTokenizer.from_pretrained(model_name)

            logger.info("Loading model (this may take 30+ seconds)...")
            self.model = AutoModelForSequenceClassification.from_pretrained(model_name)

            self.model.eval()
            logger.info("Model loaded successfully!")
        except Exception as e:
            logger.error(f"Failed to load model: {e}")
            logger.warning("Will operate in fallback mode (no pruning)")

    async def prune(self, code: str, query: str | None = None) -> tuple[str, dict[str, Any]]:
        """
        Prune code based on query if provided, otherwise return full code.

        Args:
            code: The code content to potentially prune
            query: The context focus question to guide pruning

        Returns:
            Tuple of (result_code, metadata)
        """
        input_size = len(code)

        if not query or self.model is None:
            return code, {
                "pruned": False,
                "reason": "No query provided" if not query else "Model not loaded",
                "tokens": input_size,
            }

        try:
            # Tokenize and encode
            inputs = self.tokenizer(
                code,
                return_tensors="pt",
                truncation=True,
                max_length=4096,
                padding=True,
            )

            # Get model predictions
            with torch.no_grad():
                outputs = self.model(**inputs)
                scores = outputs.logits
                probabilities = torch.softmax(scores, dim=-1)

                # Simple pruning: keep lines with high relevance
                # This is a simplified approach - real implementation would be more sophisticated
                keep_ratio = 0.5  # Keep top 50% most relevant
                k_value = int(probabilities.shape[-1] * (1 - keep_ratio))
                threshold = torch.kthvalue(probabilities, k_value, dim=-1).values[0]

                # For now, return a simple pruned version
                # Real implementation would use more sophisticated token-level selection
                pruned_code = self._simple_prune(code, query, threshold)

            output_size = len(pruned_code)
            compression_ratio = 1 - (output_size / input_size) if input_size > 0 else 0

            # Log operation
            self.logger.log_operation(
                operation="prune",
                input_size=input_size,
                output_size=output_size,
                compression_ratio=round(compression_ratio, 4),
                metadata={"query": query[:100] if query else None},
            )

            logger.info(
                f"Pruned: {input_size} -> {output_size} tokens "
                f"({compression_ratio:.1%} reduction)"
            )

            return pruned_code, {
                "pruned": True,
                "tokens": output_size,
                "original_tokens": input_size,
                "compression_ratio": compression_ratio,
            }

        except Exception as e:
            logger.error(f"Pruning failed: {e}, returning full code")
            self.logger.log_operation(
                operation="prune",
                input_size=input_size,
                output_size=input_size,
                compression_ratio=0.0,
                status="error",
                error=str(e),
            )
            return code, {
                "pruned": False,
                "reason": f"Pruning error: {str(e)}",
                "tokens": input_size,
            }

    def _simple_prune(self, code: str, query: str, threshold) -> str:
        """
        Simple pruning implementation based on query relevance.

        For now, this is a placeholder. Real SWE-Pruner uses
        more sophisticated token-level selection with a 0.6B model.
        """
        # This is a simplified fallback for demonstration
        # In production, you'd integrate with actual swe-pruner inference code
        lines = code.split("\n")
        kept_lines = []

        # Simple keyword matching for demonstration
        query_lower = query.lower() if query else ""
        keywords = query_lower.split()

        for line in lines:
            if not keywords:
                kept_lines.append(line)
            elif any(keyword in line.lower() for keyword in keywords):
                kept_lines.append(line)
            else:
                # Keep some context lines (imports, structure)
                stripped = line.strip()
                if stripped.startswith(("import ", "from ", "class ", "def ", "# ")):
                    kept_lines.append(line)

        return "\n".join(kept_lines)


def create_server():
    """Create and return MCP server"""
    app = Server("swe-pruner")

    # Initialize pruner service
    model_path = os.getenv("MODEL_PATH")
    pruner = SWEPrunerService(model_path)

    @app.call_tool()
    async def read_pruned(name: str, arguments: dict[str, Any]) -> list[TextContent]:
        """Read file contents with optional context-aware pruning"""
        if name != "read_pruned":
            raise ValueError(f"Unknown tool: {name}")

        file_path = arguments.get("file_path")
        if not file_path:
            raise ValueError("Missing required argument: file_path")

        context_focus_question = arguments.get("context_focus_question")

        try:
            path = Path(file_path)
            if not path.is_file():
                return [
                    TextContent(
                        type="text",
                        text=f"Error: File not found: {file_path}",
                    )
                ]

            content = path.read_text(encoding="utf-8", errors="ignore")
            result, metadata = await pruner.prune(content, context_focus_question)

            result_text = f"/* Tokens: {metadata['tokens']}"
            if metadata.get("pruned"):
                result_text += f" (reduced from {metadata['original_tokens']}, saved {metadata['compression_ratio']:.1%})"
            result_text += f" */\n\n{result}"

            return [TextContent(type="text", text=result_text)]

        except Exception as e:
            logger.error(f"Error in read_pruned: {e}")
            return [TextContent(type="text", text=f"Error: {str(e)}")]

    @app.call_tool()
    async def search_pruned(name: str, arguments: dict[str, Any]) -> list[TextContent]:
        """Search codebase with optional context-aware pruning"""
        if name != "search_pruned":
            raise ValueError(f"Unknown tool: {name}")

        pattern = arguments.get("pattern")
        context_focus_question = arguments.get("context_focus_question")

        if not pattern:
            raise ValueError("Missing required argument: pattern")

        try:
            # Use subprocess to search (this is a simple implementation)
            import subprocess
            result = subprocess.run(
                ["grep", "-r", pattern, "."],
                capture_output=True,
                text=True,
                timeout=10,
            )

            output = result.stdout
            if not output:
                output = f"No matches found for pattern: {pattern}"

            result, metadata = await pruner.prune(output, context_focus_question)

            result_text = f"/* Tokens: {metadata['tokens']}"
            if metadata.get("pruned"):
                result_text += f" (reduced from {metadata['original_tokens']}, saved {metadata['compression_ratio']:.1%})"
            result_text += f" */\n\n{result}"

            return [TextContent(type="text", text=result_text)]

        except subprocess.TimeoutExpired:
            return [TextContent(type="text", text="Error: Search timed out after 10 seconds")]
        except Exception as e:
            logger.error(f"Error in search_pruned: {e}")
            return [TextContent(type="text", text=f"Error: {str(e)}")]

    @app.list_tools()
    async def list_tools() -> list[dict[str, Any]]:
        """List available tools"""
        return [
            {
                "name": "read_pruned",
                "description": "Read file contents with optional context-aware pruning based on a focus question. "
                "If no context_focus_question is provided, returns full content. "
                "If provided, returns only content relevant to the question, saving tokens.",
                "inputSchema": {
                    "type": "object",
                    "required": ["file_path"],
                    "properties": {
                        "file_path": {
                            "type": "string",
                            "description": "Path to the file to read",
                        },
                        "context_focus_question": {
                            "type": "string",
                            "description": "Optional question to guide pruning. "
                            "Only code relevant to this question will be returned. "
                            "If not provided, full file content is returned.",
                        },
                    },
                },
            },
            {
                "name": "search_pruned",
                "description": "Search codebase for a pattern with optional context-aware pruning. "
                "If no context_focus_question is provided, returns all matches. "
                "If provided, returns only matches relevant to the question.",
                "inputSchema": {
                    "type": "object",
                    "required": ["pattern"],
                    "properties": {
                        "pattern": {
                            "type": "string",
                            "description": "Pattern to search for (regex supported)",
                        },
                        "context_focus_question": {
                            "type": "string",
                            "description": "Optional question to guide pruning. "
                            "Only matches relevant to this question will be returned.",
                        },
                    },
                },
            },
        ]

    return app


async def main():
    """Main entry point for MCP server"""
    from mcp.server.stdio import stdio_server

    app = create_server()

    logger.info("Starting SWE-Pruner MCP server...")
    logger.info(f"Model path: {os.getenv('MODEL_PATH', 'not set, will use HuggingFace')}")
    logger.info(f"Stats file: {os.getenv('STATS_FILE', 'not set')}")

    async with stdio_server() as streams:
        await app.run(streams[0], streams[1], app.create_initialization_options())


if __name__ == "__main__":
    import asyncio
    asyncio.run(main())
