"""
Lean dotfiles validation tests.

1. All symlink sources in install.py exist in the repo
2. All .zsh/.sh scripts pass syntax check
3. All .json configs are valid JSON
"""

import json
import os
import subprocess
from pathlib import Path

import pytest

REPO_ROOT = Path(__file__).resolve().parent.parent


# ============================================================
# 1. Symlink source validation
# ============================================================

def _parse_symlink_tasks():
    """Extract symlink source paths from install.py tasks dict."""
    tasks = {}
    exec_globals = {"__file__": str(REPO_ROOT / "install.py")}

    # Read just the tasks dict from install.py
    in_tasks = False
    lines = []
    for line in (REPO_ROOT / "install.py").read_text().splitlines():
        if line.strip().startswith("tasks = {"):
            in_tasks = True
        if in_tasks:
            lines.append(line)
            if line.strip() == "}":
                break

    # Parse tasks safely
    source = "\n".join(lines)
    # Replace dict() calls with simple dicts for eval
    source = source.replace("dict(", "dict(")
    local_vars = {"IS_SSH": False}
    exec(source, local_vars)
    return local_vars.get("tasks", {})


def _resolve_source(src, repo_root):
    """Resolve a symlink source to an absolute path."""
    if isinstance(src, dict):
        if src.get("action") == "remove":
            return None
        actual_src = src.get("src", "")
        if actual_src.startswith("~"):
            # External sources (e.g., ~/.fzf/bin/fzf) -- skip validation
            return None
        return repo_root / actual_src
    if src.startswith("~"):
        return None
    return repo_root / src


def get_symlink_sources():
    """Return list of (target, resolved_source_path) for testable entries."""
    tasks = _parse_symlink_tasks()
    results = []
    for target, src in tasks.items():
        resolved = _resolve_source(src, REPO_ROOT)
        if resolved is not None:
            results.append((target, resolved))
    return results


@pytest.mark.parametrize("target,source_path", get_symlink_sources(),
                         ids=[t for t, _ in get_symlink_sources()])
def test_symlink_source_exists(target, source_path):
    assert source_path.exists(), (
        f"Symlink target {target} points to {source_path} which does not exist"
    )


# ============================================================
# 2. Shell script syntax validation
# ============================================================

def _detect_shell_from_shebang(path):
    """Detect shell type from shebang line. Returns 'bash', 'zsh', or None."""
    try:
        first_line = path.read_text().split("\n", 1)[0]
        if "zsh" in first_line:
            return "zsh"
        if "bash" in first_line or "sh" in first_line:
            return "bash"
    except (UnicodeDecodeError, IndexError):
        pass
    return None


def find_shell_scripts():
    """Find all .sh, .zsh files and extensionless scripts with shebangs."""
    scripts = []
    skip_patterns = ["node_modules", ".git", "antidote", "prezto", "fasd/fasd"]

    # Files with extensions
    for pattern, shell in [("**/*.sh", "bash"), ("**/*.zsh", "zsh")]:
        for path in REPO_ROOT.glob(pattern):
            rel = path.relative_to(REPO_ROOT)
            if any(part in str(rel) for part in skip_patterns):
                continue
            scripts.append((str(rel), path, shell))

    # Extensionless scripts in bin/ and etc/ (detect shell from shebang)
    for dir_name in ["bin", "etc"]:
        dir_path = REPO_ROOT / dir_name
        if not dir_path.is_dir():
            continue
        for path in dir_path.iterdir():
            if not path.is_file() or path.suffix:
                continue
            rel = path.relative_to(REPO_ROOT)
            if any(part in str(rel) for part in skip_patterns):
                continue
            shell = _detect_shell_from_shebang(path)
            if shell:
                scripts.append((str(rel), path, shell))

    return scripts


@pytest.mark.parametrize("name,path,shell", find_shell_scripts(),
                         ids=[s[0] for s in find_shell_scripts()])
def test_shell_syntax(name, path, shell):
    result = subprocess.run(
        [shell, "-n", str(path)],
        capture_output=True, text=True, timeout=10,
    )
    assert result.returncode == 0, (
        f"{shell} syntax error in {name}:\n{result.stderr}"
    )


# ============================================================
# 3. JSON config validation
# ============================================================

def find_json_configs():
    """Find all .json files in the repo (excluding vendored dirs)."""
    configs = []
    for path in REPO_ROOT.glob("**/*.json"):
        rel = path.relative_to(REPO_ROOT)
        if any(part in str(rel) for part in ["node_modules", ".git", "antidote", "prezto"]):
            continue
        configs.append((str(rel), path))
    return configs


def _strip_json_comments(text):
    """Strip // line comments for JSON5 files (e.g., openclaw.json)."""
    import re
    return re.sub(r'(?m)^\s*//.*$', '', text)


@pytest.mark.parametrize("name,path", find_json_configs(),
                         ids=[c[0] for c in find_json_configs()])
def test_json_valid(name, path):
    text = _strip_json_comments(path.read_text())
    try:
        json.loads(text)
    except json.JSONDecodeError as e:
        pytest.fail(f"Invalid JSON in {name}: {e}")


# ============================================================
# 4. Install script references validation
# ============================================================

def test_install_script_includes_cmonitor():
    """Verify the install script installs claude-monitor (cmonitor)."""
    text = (REPO_ROOT / "etc" / "install").read_text()
    assert "claude-monitor" in text, "etc/install should install claude-monitor"


def test_tmux_workspace_includes_cmonitor():
    """Verify tmux-ai-workspace launches cmonitor in pane 3."""
    text = (REPO_ROOT / "bin" / "tmux-ai-workspace").read_text()
    assert "cmonitor" in text, "bin/tmux-ai-workspace should reference cmonitor"
