#!/bin/bash
set -e

echo "=== AI Agent Authentication Setup ==="
echo ""

# Claude Code (OAuth via browser)
echo "[1/2] Claude Code"
if command -v claude &>/dev/null; then
  claude login
  echo "  Claude Code: authenticated"
else
  echo "  Claude Code: not installed (npm install -g @anthropic-ai/claude-code)"
fi

echo ""

# OpenClaw (OAuth via onboard wizard)
echo "[2/2] OpenClaw"
if command -v openclaw &>/dev/null; then
  openclaw onboard
  echo "  OpenClaw: configured"
else
  echo "  OpenClaw: not installed (npm install -g openclaw)"
fi

echo ""
echo "=== Done. Run 'ai-auth-status' to verify. ==="
