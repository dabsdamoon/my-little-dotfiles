# My Little Dotfiles: AI-Agent-Optimized Plan

> Goal: Build a personal dotfiles repo starting from wookayin's dotfiles, optimized for **Claude Code** and **OpenClaw** workflows.
> Base: Forked from [wookayin/dotfiles](https://github.com/wookayin/dotfiles)
> Date: 2026-03-27

---

## Baseline: What We Keep from Wookayin

These components are solid and don't need changes:

- Zsh + Prezto + Antidote + Powerlevel10k (shell foundation)
- Tmux with vim-like navigation and TPM
- Git config (delta, rebase-on-pull, rerere)
- Neovim with Lazy.nvim, LSP, telescope, treesitter
- Python dev tool configs
- `install.py` symlink-based installation system
- `bin/` custom utilities
- Cross-platform macOS/Linux support

---

## Phase 1: Claude Code Integration

### 1.1 Global CLAUDE.md (`~/.claude/CLAUDE.md`)

Claude Code reads a global `CLAUDE.md` for cross-project instructions. Create a managed, version-controlled one:

```
dotfiles/
└── claude/
    ├── CLAUDE.md            # Global instructions (coding style, preferences, conventions)
    ├── settings.json        # Claude Code global settings (permissions, model prefs)
    └── commands/            # Custom slash commands
        ├── review.md        # /review -- code review prompt
        ├── test.md          # /test -- test generation prompt
        └── refactor.md      # /refactor -- refactoring prompt
```

**Symlinks to create:**
| Target | Source |
|--------|--------|
| `~/.claude/CLAUDE.md` | `claude/CLAUDE.md` |
| `~/.claude/settings.json` | `claude/settings.json` |
| `~/.claude/commands/` | `claude/commands/` |

**CLAUDE.md contents to define:**
- Preferred language/framework defaults
- Code style rules (formatting, naming, error handling)
- Project conventions (commit message format, PR structure)
- Behavior preferences (terse output, no trailing summaries, etc.)

### 1.2 Claude Code Shell Integration

Add to `zsh/zsh.d/ai-agents.zsh`:

```zsh
# Claude Code aliases
alias cc="claude"
alias ccc="claude --continue"
alias ccr="claude --resume"
alias ccp="claude --print"

# Quick prompts
alias cc-review="claude '/review'"
alias cc-test="claude '/test'"
alias cc-commit="claude '/commit'"

# Claude Code with specific model
alias cc-opus="claude --model opus"
alias cc-sonnet="claude --model sonnet"

# Pipe-friendly
alias cc-pipe="claude --print --output-format stream-json"

# Session management
alias cc-sessions="ls -lt ~/.claude/projects/"
```

### 1.3 Claude Code Hooks

Add managed hooks in `claude/settings.json`:

```jsonc
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Edit|Write",
        "command": "echo 'Editing: check for secrets before committing'"
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Bash",
        "command": "echo 'Command completed'"
      }
    ]
  },
  "permissions": {
    "allow": ["Read", "Glob", "Grep", "Bash(git *)"],
    "deny": ["Bash(rm -rf *)"]
  }
}
```

### 1.4 Project Template: CLAUDE.md Generator

Add to `bin/`:

```
bin/
└── claude-init    # Generate a project-specific CLAUDE.md from templates
```

`claude-init` would detect project type (Python, Node, Go, etc.) and scaffold an appropriate `CLAUDE.md` with relevant conventions.

---

## Phase 2: OpenClaw Integration

### 2.1 OpenClaw Configuration

OpenClaw uses `~/.openclaw/openclaw.json` (JSON5). Manage it in dotfiles:

```
dotfiles/
└── openclaw/
    ├── openclaw.json        # Main config (channels, model routing, security)
    ├── skills/              # Custom skill definitions
    │   ├── code-review/
    │   │   └── SKILL.md
    │   └── deploy-check/
    │       └── SKILL.md
    └── agents/              # Agent workspace configs
        └── defaults.json
```

**Symlinks:**
| Target | Source |
|--------|--------|
| `~/.openclaw/openclaw.json` | `openclaw/openclaw.json` |
| `~/.openclaw/skills/` | `openclaw/skills/` |

#### Model Routing (OAuth Constraint)

Anthropic blocks OAuth access for OpenClaw. Only two major providers support OAuth for third-party tools:

| Provider | OAuth Support | Notes |
|----------|:------------:|-------|
| OpenAI / ChatGPT | Yes | Established since GPT Plugins/GPTs era |
| Google / Gemini | Yes | Via Google Cloud OAuth 2.0 ecosystem |
| Anthropic / Claude | **No** | Blocked for OpenClaw; use Claude Code directly instead |
| Mistral, Cohere, xAI | No | API key only |

Default model routing in `openclaw.json`:

```json5
{
  "agents": {
    "defaults": {
      "model": {
        "primary": "openai:gpt-4.1",       // OAuth via OpenAI
        "fallbacks": ["google:gemini-2.5"]  // OAuth via Google
      }
    }
  }
}
```

> **Strategy:** Use Claude Code directly for Claude model access (Anthropic OAuth).
> Use OpenClaw with ChatGPT/Gemini OAuth for general-purpose agent tasks and Slack integration.

### 2.2 OpenClaw Shell Integration

Add to `zsh/zsh.d/ai-agents.zsh`:

```zsh
# OpenClaw aliases
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
```

### 2.4 OpenClaw Slack Channel (Primary)

Slack is the primary messaging channel. Configure in `openclaw.json`:

```json5
{
  "channels": {
    "slack": {
      "enabled": true,
      "workspace": "your-workspace",
      "allowFrom": ["your-user-id"]
      // OAuth tokens managed by openclaw onboard
    }
  }
}
```

> The channel config is designed to be swappable -- adding Discord, Telegram, etc.
> later only requires adding a new block to `channels` and running `openclaw onboard`
> for that platform's OAuth.

### 2.3 OpenClaw Daemon Management

Add tmux integration for running OpenClaw gateway as a background session:

```zsh
# Start OpenClaw gateway in a dedicated tmux session
alias oc-start="tmux new-session -d -s openclaw 'openclaw gateway --port 18789 --verbose'"
alias oc-stop="tmux kill-session -t openclaw 2>/dev/null; echo 'OpenClaw stopped'"
alias oc-attach="tmux attach-session -t openclaw"
```

---

## Phase 3: Cross-Agent Coordination

### 3.1 Shared Agent Config (`AGENTS.md`)

Since both Claude Code (via CLAUDE.md) and OpenClaw (via AGENTS.md) can read markdown instruction files, create a shared source of truth:

```
dotfiles/
└── ai/
    ├── AGENTS.md            # Universal agent instructions (Linux Foundation format)
    ├── style-guide.md       # Shared coding style (referenced by both tools)
    └── templates/
        ├── python-project.md
        ├── node-project.md
        └── go-project.md
```

### 3.2 Unified AI Aliases File

Consolidate all AI agent aliases into one file:

```
zsh/
└── zsh.d/
    └── ai-agents.zsh       # All AI agent aliases, functions, env vars
```

**Contents:**
- Claude Code aliases and functions
- OpenClaw aliases and functions
- Generic helpers:
  - `ai-init` -- scaffold AI config files for a new project
  - `ai-status` -- show status of all running agents
  - `ai-costs` -- quick API cost check (if available)

### 3.3 Authentication: OAuth-First Approach

Both Claude Code and OpenClaw use **OAuth** (browser-based login), not static API keys. This is an important distinction for dotfiles design:

| | API Key | OAuth |
|---|---|---|
| **Format** | Static string (`sk-ant-...`) | Token pair (access + refresh), expires |
| **How you get it** | Copy from dashboard | Interactive browser login flow |
| **Storage** | Env var or file | Tool-managed token store |
| **Rotation** | Manual | Automatic (refresh token) |
| **Portable across machines?** | Yes (copy string) | No (must re-authenticate per machine) |

**What dotfiles CAN manage:**
- OAuth provider configuration (which scopes, which accounts)
- Post-install hooks that trigger the login flows
- Auth status checking and re-auth helpers
- Gitignore rules to ensure tokens never leak

**What dotfiles CANNOT manage:**
- OAuth tokens themselves (ephemeral, machine-specific, tool-managed)
- The interactive browser redirect flow
- Token refresh (handled by the tools internally)

#### Auth Configuration Layer

```
dotfiles/
└── ai/
    └── auth/
        ├── setup.sh          # Interactive: runs all OAuth login flows
        ├── check.sh          # Validates all OAuth sessions are active
        └── .gitignore-tokens # Token path patterns to exclude
```

**`ai/auth/setup.sh`** -- run once per new machine:

```bash
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
```

**`ai/auth/check.sh`** -- verify auth health:

```bash
#!/bin/bash

echo "AI Agent Auth Status"
echo "===================="

# Claude Code
echo -n "Claude Code: "
if claude --version &>/dev/null 2>&1; then
  # Check if session is valid (non-zero exit = not authenticated)
  if claude --print "ping" &>/dev/null 2>&1; then
    echo "authenticated"
  else
    echo "session expired (run: claude login)"
  fi
else
  echo "not installed"
fi

# OpenClaw
echo -n "OpenClaw:    "
if command -v openclaw &>/dev/null; then
  openclaw doctor 2>&1 | grep -qi "auth.*ok" && echo "authenticated" || echo "needs re-auth (run: openclaw onboard)"
else
  echo "not installed"
fi
```

#### Token Gitignore Rules

Add to the global `.gitignore` (tracked in dotfiles):

```gitignore
# AI Agent OAuth tokens -- NEVER commit these
.claude/.credentials
.claude/oauth-*
.claude/session-*
.openclaw/tokens/
.openclaw/.session
*.oauth-token
*.refresh-token
```

#### Shell Integration for Auth

Add to `zsh/zsh.d/ai-agents.zsh`:

```zsh
# Auth status (quick check)
ai-auth-status() {
  source "$HOME/.dotfiles/ai/auth/check.sh"
}

# Re-authenticate all agents (interactive, opens browser)
ai-auth() {
  source "$HOME/.dotfiles/ai/auth/setup.sh"
}

# Run auth check on new shell if agents are installed (non-blocking)
if [[ -o interactive ]] && (( $+commands[claude] || $+commands[openclaw] )); then
  # Subtle reminder if auth is stale (check once per day via stamp file)
  local _auth_stamp="$HOME/.cache/ai-auth-check"
  if [[ ! -f "$_auth_stamp" ]] || [[ $(find "$_auth_stamp" -mmin +1440 2>/dev/null) ]]; then
    touch "$_auth_stamp"
    # Background check -- prints warning only if something is wrong
    (claude --print "ping" &>/dev/null 2>&1 || echo "[warn] Claude Code auth expired. Run: ai-auth") &!
  fi
fi
```

#### Environment Variables (Non-Secret, Tracked)

Add to `zsh/zshenv`:

```zsh
# AI Agent Configuration (non-secret settings only)
export CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1
export OPENCLAW_HOME="$HOME/.openclaw"
export OPENCLAW_DEFAULT_MODEL="anthropic:claude-sonnet-4-6"
```

> **Note:** No API keys in dotfiles. Both tools authenticate via OAuth browser flow.
> For fallback API key storage (scripts, CI, headless), use **1Password CLI (`op`)**
> for expandability (teams, vaults, service accounts, CI/CD integration).

#### Fallback API Key Storage: 1Password CLI

For scenarios where OAuth isn't available (CI, headless, scripts):

```zsh
# In zsh/zsh.d/ai-agents.zsh
# Fetch API keys from 1Password on demand (never stored in env permanently)
ai-key() {
  local provider="${1:?Usage: ai-key <anthropic|openai|google>}"
  case "$provider" in
    anthropic) op read "op://Dev/Anthropic API/credential" ;;
    openai)    op read "op://Dev/OpenAI API/credential" ;;
    google)    op read "op://Dev/Google AI API/credential" ;;
    *)         echo "Unknown provider: $provider" >&2; return 1 ;;
  esac
}

# Export temporarily for a single command
# Usage: with-ai-key anthropic some-script.py
with-ai-key() {
  local provider="${1:?}"; shift
  case "$provider" in
    anthropic) ANTHROPIC_API_KEY="$(ai-key anthropic)" "$@" ;;
    openai)    OPENAI_API_KEY="$(ai-key openai)" "$@" ;;
    google)    GOOGLE_API_KEY="$(ai-key google)" "$@" ;;
  esac
}
```

This approach:
- Never stores keys in env vars or files permanently
- Works across machines (1Password sync)
- Supports team sharing via vaults
- Integrates with CI via 1Password Service Accounts

#### Auth Check Strategy: Reactive with Daily Warning

Based on how existing tools handle auth:

| Tool | Strategy | Token Lifetime |
|------|----------|---------------|
| **Claude Code** | Checks at launch + on 401 failure | ~8-12hr access, ~24hr session |
| **OpenClaw** | `openclaw doctor` checks; gateway validates on startup | Provider-dependent |
| **`gh`** (reference) | Lazy -- tokens never expire | Never |
| **`gcloud`** (reference) | Silent auto-refresh on every call | ~1hr access, long-lived refresh |
| **`aws-cli`** (reference) | Reactive -- fails on 401 | ~8-12hr SSO |

The dominant industry pattern is **reactive/lazy** -- detect expiration on failure, not by polling.
Our approach: **daily background check** (once per 24hr via stamp file) that prints a
non-blocking warning if auth is stale. This matches Claude Code's ~24hr session lifetime
without adding noticeable shell startup latency.

---

## Phase 4: Neovim + AI Agent Integration

### 4.1 Neovim AI Plugin Landscape

Claude Code has **no official Neovim plugin** -- it's terminal-only. To get AI inside Neovim's UI, these are the options:

#### Inline Completions (ghost text as you type)

| Plugin | Auth | Models | Cost | Notes |
|--------|------|--------|------|-------|
| **copilot.lua** + copilot-cmp | GitHub OAuth | GitHub-managed | Paid subscription | Industry standard; integrates with nvim-cmp |
| **codeium.nvim** | Codeium token (browser) | Codeium proprietary | Free for individuals | Best free option; nvim-cmp support |
| **supermaven-nvim** | Token | Supermaven own | Free tier | Claims lowest latency |

#### Chat + Agentic Editing (describe changes, get diffs)

| Plugin | Auth | Models | What It Does |
|--------|------|--------|-------------|
| **avante.nvim** | API keys | Multi-provider (OpenAI, Anthropic, Gemini, Ollama, Copilot) | Cursor-like experience: sidebar chat, inline diff proposals, accept/reject. Most actively developed. |
| **codecompanion.nvim** | API keys | Multi-provider | Chat buffer, code actions, agent mode with tool use (file read, search, edit). Most feature-complete. |
| **CopilotChat.nvim** | GitHub OAuth | GitHub-managed | Chat sidebar for Copilot; explain, review, fix, test actions. Requires Copilot subscription. |
| **gp.nvim** | API keys | Multi-provider | Flexible chat-in-buffer, voice input, custom agents. |

#### Local / Private AI

| Plugin | Auth | Models | Notes |
|--------|------|--------|-------|
| **gen.nvim** | None | Ollama local | No API key, fully offline. Simple interface. |
| **ollama.nvim** | None | Ollama local | Similar, focused on Ollama integration. |

### 4.2 Recommended Plugin Selection

Given our OAuth-first approach and agent-centric workflow, we skip inline autocomplete
(Copilot/Codeium) -- it's redundant and distracting when the main agents (Claude Code,
avante.nvim) handle code generation at a higher level.

> **Future note:** If Claude Code or OpenClaw gain native inline-autocomplete support
> inside editors, that would be the ideal single-tool solution. Worth revisiting.

```lua
-- nvim/lua/plugins/ai.lua
return {
  -- Agentic editing: avante (multi-provider, Cursor-like experience)
  -- Uses API keys via 1Password for Anthropic/OpenAI access
  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    opts = {
      provider = "anthropic",  -- Claude as default
      -- API keys fetched from 1Password, not hardcoded
    },
  },

  -- No inline autocomplete (Copilot/Codeium) -- agents are the primary interface
  -- Claude Code: terminal-only, launched in splits (see 4.3)
}
```

**Rationale:**
- **avante.nvim** for agentic editing inside nvim -- describe changes in natural language, get diffs. Default provider: Claude (Anthropic) via 1Password API key.
- **Claude Code** stays in the terminal (tmux pane or nvim `:terminal` split) -- this is how it's designed
- **No inline autocomplete** -- redundant with agentic tools; revisit if agents gain autocomplete capability

### 4.3 Terminal Splits for Agents

Add keybindings to spawn Claude Code or OpenClaw in neovim terminal splits:

```lua
-- nvim/lua/config/ai-keymaps.lua
vim.keymap.set("n", "<leader>ac", function()
  vim.cmd("vsplit | terminal claude")
end, { desc = "Open Claude Code in vertical split" })

vim.keymap.set("n", "<leader>ao", function()
  vim.cmd("vsplit | terminal openclaw agent")
end, { desc = "Open OpenClaw agent in vertical split" })

vim.keymap.set("n", "<leader>aA", function()
  vim.cmd("vsplit | terminal ai-auth-status")
end, { desc = "Check AI auth status" })
```

---

## Phase 5: Tmux Workflow

### 5.1 AI Agent Tmux Layout

Create a tmux layout preset for AI-assisted development:

```
bin/
└── tmux-ai-workspace
```

Layout:
```
┌──────────────────┬──────────────────┐
│                  │                  │
│   Editor (nvim)  │  Claude Code     │
│                  │                  │
│                  ├──────────────────┤
│                  │  Shell / Tests   │
│                  │                  │
└──────────────────┴──────────────────┘
```

### 5.2 Tmux Status Bar: Agent Status

Extend tmux status bar to show:
- Whether OpenClaw gateway is running
- Active Claude Code sessions count

---

## Final Directory Structure

```
my-little-dotfiles/
├── install.py                  # Installer (extended from wookayin's)
├── README.md
│
├── zsh/                        # Shell config (from wookayin + additions)
│   ├── zshrc
│   ├── zshenv
│   ├── zprofile
│   ├── plugins.zsh
│   ├── p10k.zsh
│   ├── zpreztorc
│   └── zsh.d/
│       ├── alias.zsh
│       ├── envs.zsh
│       ├── key-bindings.zsh
│       └── ai-agents.zsh      # NEW: all AI agent aliases & functions
│
├── nvim/                       # Neovim config (from wookayin + additions)
│   └── lua/plugins/
│       └── ai.lua              # NEW: AI-related nvim plugins
│
├── tmux/                       # Tmux config (from wookayin)
│   └── tmux.conf
│
├── git/                        # Git config (from wookayin)
│   ├── gitconfig
│   └── gitignore
│
├── python/                     # Python dev tools (from wookayin)
│
├── config/                     # Terminal emulators (from wookayin)
│
├── claude/                     # NEW: Claude Code configuration
│   ├── CLAUDE.md               # Global agent instructions
│   ├── settings.json           # Permissions, hooks, model prefs
│   └── commands/               # Custom slash commands
│       ├── review.md
│       ├── test.md
│       └── refactor.md
│
├── openclaw/                   # NEW: OpenClaw configuration
│   ├── openclaw.json           # Main config (channels, models, security)
│   ├── skills/                 # Custom skills
│   └── agents/                 # Agent workspace defaults
│
├── ai/                         # NEW: Shared AI agent configs
│   ├── AGENTS.md               # Universal agent instructions
│   ├── style-guide.md          # Shared coding style
│   ├── auth/                   # NEW: OAuth auth management
│   │   ├── setup.sh            #   Interactive login flows (claude login, openclaw onboard)
│   │   ├── check.sh            #   Validate active OAuth sessions
│   │   └── .gitignore-tokens   #   Token path patterns to never commit
│   └── templates/              # Per-project-type CLAUDE.md templates
│       ├── python-project.md
│       ├── node-project.md
│       └── go-project.md
│
└── bin/                        # Utilities (from wookayin + additions)
    ├── dotfiles
    ├── claude-init             # NEW: scaffold project AI configs
    ├── ai-auth                 # NEW: wrapper for ai/auth/setup.sh
    ├── ai-auth-status          # NEW: wrapper for ai/auth/check.sh
    └── tmux-ai-workspace       # NEW: AI-optimized tmux layout
```

---

## Tooling: my-little-skills Integration

Skills from `dabsdamoon/my-little-skills` that accelerate building this dotfiles repo.
Instead of writing everything from scratch, use these skills to generate and validate configs.

### Skills to Use During Build

| Skill | Used In | How |
|-------|---------|-----|
| **system-prompt-creator** | Phase 1 (P0) | Generate `claude/CLAUDE.md` following best practices (OWASP security, prompt structure, readability). Far better than hand-writing global instructions. |
| **subagent-creator** | Phase 1 (P1) | Run on the dotfiles repo itself to generate `.claude/agents/` -- e.g., a `dotfiles-agent.md` that understands the repo structure and can help with config changes. |
| **claude-config-migrator** | Phase 1 (P1) | Pull useful Claude configs (rules, hooks, MCP settings) from your other projects into the dotfiles repo. Handles merge conflicts automatically. |
| **gcloud-direnv-setup** | Phase 3 (P1) | Reference its per-directory credential pattern for `ai/auth/`. Same concept: environment-specific secrets managed via direnv + dotfiles. |
| **pr-creator** | Ongoing | Use for all PRs to the dotfiles repo -- blast radius analysis, security scanning of diffs. |
| **prompt-optimizer** | Phase 3 (P2) | Optimize `claude/CLAUDE.md` and `ai/AGENTS.md` for token efficiency after initial drafts. |
| **debugging-retrospective** | Phase 1 (P1) | Add as a custom Claude Code slash command (`claude/commands/debug-retro.md`) for postmortem analysis of agent debugging sessions. |

### Build Workflow

```
Step 1: Generate              Step 2: Review & Customize       Step 3: Optimize
─────────────────            ──────────────────────────       ─────────────────
system-prompt-creator   →    Edit CLAUDE.md for personal     →  prompt-optimizer
  → claude/CLAUDE.md           preferences & style               (reduce tokens)

subagent-creator        →    Tune agent tools & paths
  → .claude/agents/

claude-config-migrator  →    Cherry-pick useful configs
  → settings, hooks             from other repos

gcloud-direnv-setup     →    Adapt pattern for ai/auth/
  (reference pattern)          setup.sh & check.sh
```

### Plugin Installation

To use these skills during the build, install the marketplace:

```bash
# In Claude Code, run:
/plugin marketplace add dabsdamoon/my-little-skills

# Then install the relevant plugins:
/plugin install developer-workflow-skills   # pr-creator, subagent-creator, debugging-retrospective
/plugin install config-skills               # claude-config-migrator
/plugin install writing-skills              # system-prompt-creator
/plugin install analysis-skills             # prompt-optimizer (via analytique)
```

---

## Implementation Priority

| Priority | Task | Skill Used | Effort |
|----------|------|-----------|--------|
| P0 | ~~Fork wookayin's dotfiles~~ (done), fix `~/.zshrc` symlink | -- | 10 min |
| P0 | Generate `claude/CLAUDE.md` + `settings.json` | **system-prompt-creator** | 30 min |
| P1 | Pull useful configs from existing projects | **claude-config-migrator** | 20 min |
| P1 | Generate `.claude/agents/` for the dotfiles repo | **subagent-creator** | 15 min |
| P1 | Create `zsh/zsh.d/ai-agents.zsh` with aliases | -- | 30 min |
| P1 | Update `install.py` with new symlinks (claude/, openclaw/) | -- | 30 min |
| P1 | Create `openclaw/openclaw.json` base config | -- | 30 min |
| P1 | Create `ai/auth/setup.sh` + `check.sh` (OAuth flows) | ref: **gcloud-direnv-setup** | 30 min |
| P1 | Add token gitignore rules to prevent credential leaks | -- | 10 min |
| P1 | Add `claude/commands/debug-retro.md` slash command | ref: **debugging-retrospective** | 15 min |
| P2 | Create `ai/AGENTS.md` shared instructions | **system-prompt-creator** | 1 hr |
| P2 | Optimize CLAUDE.md + AGENTS.md for token efficiency | **prompt-optimizer** | 30 min |
| P2 | Create `bin/claude-init` project scaffolder | -- | 1 hr |
| P2 | Create `bin/tmux-ai-workspace` layout script | -- | 30 min |
| P3 | Neovim AI plugin integration (`nvim/lua/plugins/ai.lua`) | -- | 1 hr |
| P3 | Tmux status bar agent indicators | -- | 1 hr |
| P3 | Create project templates (`ai/templates/`) | -- | 1 hr |

---

## Decisions (Resolved)

| # | Question | Decision | Rationale |
|---|----------|----------|-----------|
| 1 | Fork or reference? | **Fork** wookayin's repo | Upstream updates via `git merge`; already forked |
| 2 | OpenClaw model routing | **ChatGPT (primary)** + **Gemini (fallback)** | Anthropic blocks OAuth for OpenClaw; only OpenAI and Google support OAuth for third-party tools |
| 3 | Fallback API key storage | **1Password CLI (`op`)** | Expandable: teams, vaults, service accounts, CI/CD integration |
| 4 | Neovim AI plugin | **avante.nvim** (agentic, Claude default) + Claude Code in terminal | No inline autocomplete (redundant with agents); revisit if agents gain native autocomplete |
| 5 | OpenClaw channels | **Slack** (primary), swappable | Add other channels later by extending `openclaw.json` |
| 6 | Auth check aggressiveness | **Daily background check** (reactive) | Matches industry pattern (gcloud/aws/gh are all reactive); Claude Code sessions last ~24hr |

## Resolved: 1Password Vault Structure

Single `Dev` vault for all AI API keys. This is a personal dotfiles repo, not team-shared.

```
1Password
└── Dev (vault)
    ├── Anthropic API    -> op://Dev/Anthropic API/credential
    ├── OpenAI API       -> op://Dev/OpenAI API/credential
    └── Google AI API    -> op://Dev/Google AI API/credential
```
