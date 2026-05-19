#!/usr/bin/env bash
#
# ai-status.sh: Tmux status bar component showing AI agent status.
# Called by statusbar.tmux, outputs a short status string.
#
# Output examples:
#   " CC " (Claude Code session active)
#   " OC " (OpenClaw gateway running)
#   " CX " (Codex session active)
#   " CC OC CX " (multiple active)
#   "" (nothing running)

set -e

STATUS=""

# Check for active Claude Code processes
if pgrep -qf "claude" 2>/dev/null; then
  STATUS="${STATUS} CC"
fi

# Check for OpenClaw gateway (tmux session or process)
if tmux has-session -t openclaw 2>/dev/null || pgrep -qf "openclaw gateway" 2>/dev/null; then
  STATUS="${STATUS} OC"
fi

# Check for active Codex CLI processes
if pgrep -qf "codex" 2>/dev/null; then
  STATUS="${STATUS} CX"
fi

if [[ -n "$STATUS" ]]; then
  echo "#[fg=#000000,bg=#87af5f,bold]${STATUS} #[default]"
fi
