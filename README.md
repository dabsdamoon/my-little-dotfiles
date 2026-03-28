# my-little-dotfiles

Personal dotfiles for macOS and Linux, optimized for AI-agent-assisted development.

Based on [wookayin/dotfiles](https://github.com/wookayin/dotfiles) with added support for Claude Code, OpenClaw, and modern AI coding workflows.

## One-Liner Installation

```bash
curl -fsSL https://raw.githubusercontent.com/dabsdamoon/my-little-dotfiles/main/etc/install | bash
```

This will:
1. Install essential tools via Homebrew (macOS) or apt (Linux): **tmux**, **neovim**, **node**
2. Clone the repo to `~/.dotfiles`
3. Create symlinks for all configs
4. Set up zsh plugins (Antidote, Powerlevel10k)
5. Copy default AI agent configs (Claude Code, OpenClaw)

### Manual Installation

```bash
git clone --recursive -b main https://github.com/dabsdamoon/my-little-dotfiles.git ~/.dotfiles
cd ~/.dotfiles && python3 install.py
```

## What's Included

### Shell (zsh)
- **Prezto** framework + **Antidote** plugin manager + **Powerlevel10k** prompt
- Vi-mode, fzf integration, autosuggestions, syntax highlighting
- `ai-agents.zsh` -- aliases for Claude Code, OpenClaw, 1Password CLI, auth helpers

### Editor (Neovim)
- **Lazy.nvim** plugin manager, **mason.nvim** for LSP
- telescope, treesitter, nvim-cmp, conform.nvim
- **claudecode.nvim** -- Claude Code integration (`<leader>C*`)
- **avante.nvim** -- agentic editing with Claude as default (`<leader>a*`)

### Terminal Multiplexer (tmux)
- Prefix: `Ctrl-a`, vim-like pane navigation
- AI agent status indicator in status bar (shows CC/OC when active)
- `tmux-ai-workspace` -- pre-built AI dev layout:

```
┌──────────────────┬──────────────────┐
│                  │                  │
│  Claude Code     │  Shell (zsh)     │
│                  │                  │
│                  ├──────────────────┤
│                  │  cmonitor        │
│                  │  (token/cost)    │
│                  │                  │
└──────────────────┴──────────────────┘
```

### Monitoring
- **[cmonitor](https://github.com/Maciek-roboblog/Claude-Code-Usage-Monitor)** -- real-time Claude Code token usage, burn rate, cost estimates, plan limit predictions. Auto-installed and runs in tmux-ai-workspace bottom-right pane.

### Git
- **delta** pager, rebase-on-pull, rerere, diff3 conflict style
- AI token patterns in global gitignore

### AI Agent Integration

| Tool | Config Location | Auth |
|------|----------------|------|
| **Claude Code** | `~/.claude/CLAUDE.md`, `~/.claude/commands/` | OAuth (`claude login`) |
| **OpenClaw** | `~/.openclaw/openclaw.json` | OAuth (`openclaw onboard`) |
| **1Password CLI** | On-demand via `ai-key` function | `op signin` |

**Claude Code slash commands:** `/review`, `/test`, `/refactor`, `/debug-retro`

**Shell commands:**
- `ai-auth` -- authenticate all AI agents
- `ai-auth-status` -- check auth health
- `ai-status` -- show installed agents and gateway status
- `claude-init` -- scaffold a project-specific CLAUDE.md
- `tmux-ai-workspace [name] [dir]` -- launch AI dev layout

## Updating

```bash
dotfiles update                  # pull + reinstall
dotfiles update --fast           # skip plugin updates
```

## Structure

```
~/.dotfiles/
├── zsh/                    # Shell config (Prezto, Antidote, Powerlevel10k)
│   └── zsh.d/
│       └── ai-agents.zsh  # AI agent aliases & functions
├── nvim/                   # Neovim config (Lazy.nvim, LSP, AI plugins)
├── tmux/                   # Tmux config + AI status bar
├── git/                    # Git config (delta, gitignore with token patterns)
├── claude/                 # Claude Code global config
│   ├── CLAUDE.md           # Global instructions for all sessions
│   ├── settings.json       # Permissions and hooks
│   └── commands/           # Custom slash commands
├── openclaw/               # OpenClaw config (ChatGPT primary, Gemini fallback)
├── ai/                     # Shared AI agent configs
│   ├── AGENTS.md           # Universal agent instructions
│   ├── auth/               # OAuth setup and health check scripts
│   └── templates/          # Project-type CLAUDE.md templates
├── bin/                    # Custom utilities
├── install.py              # Symlink installer
└── tests/                  # Validation tests (symlinks, syntax, JSON)
```

## Tests

```bash
cd ~/.dotfiles && python3 -m pytest tests/ -v
```

Validates: symlink sources exist, shell syntax correct, JSON configs valid.

## Credits

- Based on [wookayin/dotfiles](https://github.com/wookayin/dotfiles) by Jongwook Choi
- AI agent integration by [@dabsdamoon](https://github.com/dabsdamoon)

## License

[The MIT License (MIT)](LICENSE)
