# Wookayin's Dotfiles Analysis

> Repository: [github.com/wookayin/dotfiles](https://github.com/wookayin/dotfiles)
> Analyzed: 2026-03-27

---

## What Is It?

A comprehensive, cross-platform dotfiles framework for full-stack development. It manages shell, editor, terminal multiplexer, git, and development tool configurations through a single Python-based installer that creates symlinks from a central `~/.dotfiles/` repo to the expected locations in `$HOME`.

---

## Overall Structure

```
~/.dotfiles/
├── bin/              # Custom CLI utilities
├── config/           # Terminal emulator & app configs (kitty, wezterm, alacritty, karabiner, pudb, etc.)
├── etc/              # Installation & setup scripts (bootstrap, OS-specific setup)
├── git/              # Git configuration (gitconfig, gitignore)
├── nvim/             # Neovim configuration (Lua-based, Lazy.nvim)
├── python/           # Python dev tool configs (pylintrc, ptpython, condarc, pythonrc)
├── tmux/             # Tmux configuration & plugins (TPM)
├── vim/              # Legacy Vim configuration (vim-plug)
├── zsh/              # Zsh shell configuration (Prezto, Antidote, Powerlevel10k)
├── install.py        # Main installer (symlinks + post-install hooks)
├── bashrc            # Fallback bash config
└── README.md
```

---

## Feature Breakdown

### 1. Zsh Shell

| Component | Choice |
|-----------|--------|
| Framework | **Prezto** (legacy module system for completions, history, etc.) |
| Plugin Manager | **Antidote** (static loading/caching for fast startup) |
| Theme/Prompt | **Powerlevel10k** (instant prompt for zero-lag startup) |
| Syntax Highlighting | **F-Sy-H** (fast-syntax-highlighting with custom theme) |
| Editor Mode | Vi-mode |

**Plugins loaded:**
- `zsh-autosuggestions` -- fish-like command suggestions
- `fzf-fasd` (custom fork) -- fuzzy + frecency directory jumping
- `fzf-git.sh` -- git-aware fzf bindings
- `zsh-autoswitch-virtualenv` -- auto conda/venv switching on `cd`
- `conda-zsh-completion` -- conda tab completions
- `anybar-zsh` -- macOS AnyBar integration

**Modular config (`zsh/zsh.d/`):**
- `alias.zsh` (16KB) -- extensive aliases for ls/eza, vim/nvim, tmux, git, ssh
- `envs.zsh` -- FZF, history, path settings
- `fasd.zsh` -- frecency-based directory navigation
- `fzf-widgets.zsh` -- FZF key binding widgets
- `key-bindings.zsh` -- bash-compatible + vi-mode bindings
- `utils.zsh` -- utility functions

**Startup chain:** `~/.zshenv` -> `~/.zprofile` -> `~/.zshrc` -> `~/.zlogin`
- `GLOBAL_RCS` disabled to prevent macOS `/etc/zprofile` from corrupting `$PATH`
- Careful `$PATH` ordering with `prepend_path()` function

### 2. Neovim / Vim

| Component | Choice |
|-----------|--------|
| Plugin Manager | **Lazy.nvim** (neovim), vim-plug (legacy vim) |
| LSP Server Manager | **mason.nvim** + mason-lspconfig |
| Completion Engine | **nvim-cmp** (buffer, LSP, path, snippets, git sources) |
| Fuzzy Finder | **telescope.nvim** + **fzf-lua** |
| Snippets | **UltiSnips** (Python-based) |
| Formatting | **conform.nvim** |
| Debugging | **nvim-dap** + nvim-dap-ui |
| Testing | **neotest** (pytest) |
| Color Scheme | xoria256-wook (custom variant) |

**Plugin organization (`nvim/lua/plugins/`):**
- `basic.lua` -- core (nvim-tree, surround, repeat)
- `appearance.lua` -- UI themes, colors
- `ui.lua` -- telescope, fzf-lua, aerial
- `keymap.lua` -- key binding enhancements
- `git.lua` -- fugitive, gitsigns, diffview
- `ide.lua` -- LSP, completion, DAP, testing, formatting
- `treesitter.lua` -- syntax highlighting, text objects
- `utilities.lua` -- misc tools

**Language support:** Python (with conda auto-switching), Go, Rust, Ruby, Node, LaTeX, Markdown

### 3. Tmux

| Component | Choice |
|-----------|--------|
| Plugin Manager | **TPM** (Tmux Plugin Manager) |
| Session Persistence | **tmux-resurrect** |
| Prefix Key | `Ctrl-a` (not default `Ctrl-b`) |

**Key features:**
- Vim-like pane navigation (h/j/k/l) with smart vim-tmux integration
- True-color (24-bit) support, undercurl, OSC52 clipboard
- 100,000 line scrollback
- Custom dark status bar theme
- Mouse support enabled
- Synchronized panes toggle (prefix + e)

**Plugins:** tpm, tmux-resurrect, tmux-scroll-copy-mode, extrakto, tmux-menus

### 4. Git

| Feature | Setting |
|---------|---------|
| Pager | **delta** (syntax-highlighted diffs) |
| Conflict Style | diff3 |
| Pull Strategy | rebase (no merge commits) |
| Rerere | enabled (reuse merge resolutions) |
| Default Branch | main |

**Notable aliases:** `history` (pretty graph log), `partial-clone`, `wdiff`/`sdiff` (word/side-by-side diffs), `amend`, `assume-unchanged`

**Security:** SSH forced for GitHub pushes, credential cache with 60s timeout, `.gitconfig.secret` for user info (not tracked)

### 5. Python / Dev Tools

- `pythonrc.py` -- enhanced REPL with auto-imports, history, tab completion
- `ptpython.config.py` -- advanced REPL with vi-mode, syntax highlighting
- `pylintrc` -- linter rules
- `pycodestyle` -- PEP8 style checking
- `condarc` -- conda configuration

### 6. Terminal Emulators

| Terminal | Config Format | Font |
|----------|--------------|------|
| Kitty | `.conf` | JetBrainsMono Nerd Font Mono, 16pt |
| Wezterm | Lua | JetBrainsMono Nerd Font + Apple emoji fallback |
| Alacritty | YAML | (configured) |
| Ghostty | (new addition) | (configured) |

### 7. Custom Utilities (`bin/`)

- `dotfiles` -- main CLI (update, install packages)
- `imgcat` / `imgls` -- terminal image display (iTerm2)
- `cpu-usage` / `mem-usage` -- system monitoring
- `git-fixup` -- create fixup commits
- `print-256-colors` -- color palette display
- `pbcopy` -- clipboard wrapper

---

## Installation System

**`install.py`** (Python 3) handles everything:

1. Creates symlinks from `~/.dotfiles/` to `$HOME` locations
2. Post-install hooks:
   - Installs fzf from GitHub
   - Updates zsh plugins via antidote
   - Installs tmux plugins via TPM
   - Changes default shell to zsh
   - Installs/updates neovim
   - Updates vim plugins via Lazy.nvim
   - Creates `~/.gitconfig.secret`
3. Supports `--force` and `--skip-*` flags

**CLI shortcut:** `dotfiles update` (pull + reinstall)

**Symlinks created (key ones):**

| Target | Source |
|--------|--------|
| `~/.zshrc` | `zsh/zshrc` |
| `~/.zshenv` | `zsh/zshenv` |
| `~/.zprofile` | `zsh/zprofile` |
| `~/.vimrc` | `vim/vimrc` |
| `~/.config/nvim` | `nvim/` |
| `~/.tmux.conf` | `tmux/tmux.conf` |
| `~/.gitconfig` | `git/gitconfig` |
| `~/.config/kitty` | `config/kitty` |
| `~/.config/wezterm` | `config/wezterm` |

---

## Design Philosophy

1. **Performance-first** -- static plugin caching (antidote), lazy loading (conda, nvm), instant prompt (p10k), profiling tools built in
2. **Cross-platform** -- macOS (Intel + Apple Silicon) and Linux, with SSH-awareness
3. **Modular** -- each tool in its own directory, compartmentalized configs
4. **Extensible** -- `.local` override files not tracked by git, `.gitconfig.secret` for credentials
5. **Self-contained** -- single `python install.py` to set up everything from scratch
