#
# ai-agents.zsh
#
# Shell aliases and functions for AI coding agents.
# Claude Code, OpenClaw, auth helpers, 1Password integration.
#

# ============================================================
# Claude Code
# ============================================================

if (( $+commands[claude] )); then
  alias cc="claude"
  alias ccc="claude --continue"
  alias ccr="claude --resume"
  alias ccp="claude --print"

  # Model selection
  alias cc-opus="claude --model opus"
  alias cc-sonnet="claude --model sonnet"

  # Pipe-friendly
  alias cc-pipe="claude --print --output-format stream-json"

  # Session management
  alias cc-sessions="ls -lt ~/.claude/projects/ 2>/dev/null"
fi

# ============================================================
# OpenClaw
# ============================================================

if (( $+commands[openclaw] )); then
  alias oc="openclaw"
  alias oc-agent="openclaw agent"
  alias oc-dash="openclaw dashboard"
  alias oc-doc="openclaw doctor"

  # Quick agent invocations
  alias oc-code="openclaw agent --skill coding-agent"
  alias oc-browse="openclaw agent --skill browser"
  alias oc-github="openclaw agent --skill github"

  # Status
  alias oc-status="openclaw gateway status"
  alias oc-logs="openclaw logs --follow"

  # Daemon management via tmux
  alias oc-start="tmux new-session -d -s openclaw 'openclaw gateway --port 18789 --verbose'"
  alias oc-stop="tmux kill-session -t openclaw 2>/dev/null; echo 'OpenClaw stopped'"
  alias oc-attach="tmux attach-session -t openclaw"
fi

# ============================================================
# Auth Management (OAuth-first)
# ============================================================

# Check auth status for all agents
ai-auth-status() {
  source "$HOME/.dotfiles/ai/auth/check.sh"
}

# Re-authenticate all agents (interactive, opens browser)
ai-auth() {
  source "$HOME/.dotfiles/ai/auth/setup.sh"
}

# Daily background auth check (non-blocking)
if [[ -o interactive ]] && (( $+commands[claude] || $+commands[openclaw] )); then
  local _auth_stamp="$HOME/.cache/ai-auth-check"
  if [[ ! -f "$_auth_stamp" ]] || [[ -n $(find "$_auth_stamp" -mmin +1440 2>/dev/null) ]]; then
    mkdir -p "$HOME/.cache"
    touch "$_auth_stamp"
    (claude --print "ping" &>/dev/null 2>&1 || echo "[warn] Claude Code auth expired. Run: ai-auth") &!
  fi
fi

# ============================================================
# 1Password CLI (fallback API key access)
# ============================================================

if (( $+commands[op] )); then
  # Fetch API key from 1Password on demand
  ai-key() {
    local provider="${1:?Usage: ai-key <anthropic|openai|google>}"
    case "$provider" in
      anthropic) op read "op://Dev/Anthropic API/credential" ;;
      openai)    op read "op://Dev/OpenAI API/credential" ;;
      google)    op read "op://Dev/Google AI API/credential" ;;
      *)         echo "Unknown provider: $provider" >&2; return 1 ;;
    esac
  }

  # Export key temporarily for a single command
  # Usage: with-ai-key anthropic some-script.py
  with-ai-key() {
    local provider="${1:?}"; shift
    case "$provider" in
      anthropic) ANTHROPIC_API_KEY="$(ai-key anthropic)" "$@" ;;
      openai)    OPENAI_API_KEY="$(ai-key openai)" "$@" ;;
      google)    GOOGLE_API_KEY="$(ai-key google)" "$@" ;;
      *)         echo "Unknown provider: $provider" >&2; return 1 ;;
    esac
  }
fi

# ============================================================
# Helpers
# ============================================================

# Show status of all running AI agents
ai-status() {
  echo "AI Agent Status"
  echo "==============="

  # Claude Code
  echo -n "Claude Code: "
  if (( $+commands[claude] )); then
    echo "installed ($(claude --version 2>/dev/null || echo 'unknown version'))"
  else
    echo "not installed"
  fi

  # OpenClaw
  echo -n "OpenClaw:    "
  if (( $+commands[openclaw] )); then
    echo "installed"
    if tmux has-session -t openclaw 2>/dev/null; then
      echo "  gateway:   running (tmux session)"
    else
      echo "  gateway:   stopped"
    fi
  else
    echo "not installed"
  fi

  # 1Password CLI
  echo -n "1Password:   "
  if (( $+commands[op] )); then
    echo "installed"
  else
    echo "not installed (fallback API keys unavailable)"
  fi
}
