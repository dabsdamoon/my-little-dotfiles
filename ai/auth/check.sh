#!/bin/bash

# Run a command with a timeout (portable, no coreutils needed)
_timeout_run() {
  local secs="$1"; shift
  "$@" &
  local pid=$!
  ( sleep "$secs" && kill "$pid" 2>/dev/null ) &
  local watcher=$!
  wait "$pid" 2>/dev/null
  local ret=$?
  kill "$watcher" 2>/dev/null
  wait "$watcher" 2>/dev/null
  return $ret
}

echo "AI Agent Auth Status"
echo "===================="

# Claude Code
echo -n "Claude Code: "
if command -v claude &>/dev/null; then
  if _timeout_run 5 claude auth status --text 2>/dev/null | grep -qi "logged in"; then
    echo "authenticated"
  else
    echo "session expired (run: ai-auth)"
  fi
else
  echo "not installed"
fi

# OpenClaw
echo -n "OpenClaw:    "
if command -v openclaw &>/dev/null; then
  if _timeout_run 5 openclaw doctor 2>&1 | grep -qi "auth.*ok"; then
    echo "authenticated"
  else
    echo "needs re-auth (run: ai-auth)"
  fi
else
  echo "not installed"
fi

# 1Password CLI (fallback)
echo -n "1Password:   "
if command -v op &>/dev/null; then
  if _timeout_run 5 op account list &>/dev/null 2>&1; then
    echo "signed in"
  else
    echo "not signed in (run: op signin)"
  fi
else
  echo "not installed"
fi
