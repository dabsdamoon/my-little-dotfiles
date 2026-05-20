#!/usr/bin/env bash
# Claude Code statusLine command
# Mirrors p10k lean prompt: context dir vcs | model ctx%

input=$(cat)

cwd=$(echo "$input" | jq -r '.cwd // .workspace.current_dir // ""')
model=$(echo "$input" | jq -r '.model.display_name // ""')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

CYAN="\033[0;36m"
BLUE="\033[0;34m"
YELLOW="\033[0;33m"
GREEN="\033[0;32m"
RED="\033[0;31m"
GRAY="\033[0;37m"
RESET="\033[0m"

# user@host segment (p10k context)
user_host=$(printf "${CYAN}%s${RESET}@${CYAN}%s${RESET}" "$(whoami)" "$(hostname -s)")

# dir segment: replace $HOME with ~
dir_str="${cwd/#$HOME/~}"
dir_part=$(printf "${BLUE}%s${RESET}" "$dir_str")

# vcs segment: git branch with dirty indicator (skip optional locks)
git_part=""
branch=$(git --no-optional-locks -C "$cwd" rev-parse --abbrev-ref HEAD 2>/dev/null)
if [ -n "$branch" ]; then
  git_stat=$(git --no-optional-locks -C "$cwd" status --porcelain 2>/dev/null)
  if [ -z "$git_stat" ]; then
    git_part=$(printf "${GREEN}%s${RESET}" "$branch")
  else
    git_part=$(printf "${YELLOW}%s *${RESET}" "$branch")
  fi
fi

# model + context usage (right-side info)
right_parts=""
if [ -n "$model" ]; then
  right_parts=$(printf "${GRAY}%s${RESET}" "$model")
fi
if [ -n "$used_pct" ]; then
  used_int=$(printf "%.0f" "$used_pct")
  ctx_part=$(printf "${GRAY}ctx %s%%${RESET}" "$used_int")
  if [ -n "$right_parts" ]; then
    right_parts="${right_parts} $(printf "${GRAY}|${RESET}") ${ctx_part}"
  else
    right_parts="$ctx_part"
  fi
fi

# Assemble: user@host dir [branch] | model ctx%
line="${user_host} ${dir_part}"
if [ -n "$git_part" ]; then
  line="${line} $(printf "${GRAY}git:(${RESET}")${git_part}$(printf "${GRAY})${RESET}")"
fi
if [ -n "$right_parts" ]; then
  line="${line} $(printf "${GRAY}|${RESET}") ${right_parts}"
fi

printf "%b" "$line"
