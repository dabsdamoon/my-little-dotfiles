"""Tests for bin/agent-sync against throwaway home directories (no mocks)."""

import importlib.util
import io
import json
import subprocess
import sys
import tarfile
from importlib.machinery import SourceFileLoader
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
_loader = SourceFileLoader("agent_sync", str(REPO_ROOT / "bin" / "agent-sync"))
_spec = importlib.util.spec_from_loader("agent_sync", _loader)
agent_sync = importlib.util.module_from_spec(_spec)
sys.modules["agent_sync"] = agent_sync  # dataclasses resolve annotations through sys.modules
_loader.exec_module(agent_sync)


def machine(home: Path):
    return agent_sync.Machine(home=home, backup_root=home / "backup")


def make_skill(path: Path) -> Path:
    path.mkdir(parents=True)
    (path / "SKILL.md").write_text(f"---\nname: {path.name}\n---\n")
    return path


def run_all(plan):
    for action in plan.actions:
        if action.run:
            action.run()


def test_codex_toggle_rewrites_only_the_named_plugin():
    text = '[plugins."a@m"]\nenabled = true\n\n[plugins."b@m"]\nenabled = true\n'
    out = agent_sync.set_codex_plugin_enabled(text, "b@m", False)
    assert out == '[plugins."a@m"]\nenabled = true\n\n[plugins."b@m"]\nenabled = false\n'


def test_codex_toggle_inserts_missing_key_and_appends_missing_section():
    out = agent_sync.set_codex_plugin_enabled('[plugins."a@m"]\nother = 1\n', "a@m", True)
    assert out == '[plugins."a@m"]\nenabled = true\nother = 1\n'
    out = agent_sync.set_codex_plugin_enabled('model = "x"\n', "c@m", True)
    assert out == 'model = "x"\n\n[plugins."c@m"]\nenabled = true\n'


def test_claude_settings_converge_and_second_plan_is_clean(tmp_path):
    claude = tmp_path / ".claude"
    (claude / "plugins").mkdir(parents=True)
    (claude / "plugins" / "installed_plugins.json").write_text(json.dumps(
        {"plugins": {"p@m": [{"installPath": str(tmp_path / "cache" / "p")}],
                     "q@m": [{"installPath": str(tmp_path / "cache" / "q")}]}}))
    (claude / "plugins" / "known_marketplaces.json").write_text(json.dumps({"m": {}}))
    (claude / "settings.json").write_text(json.dumps({"model": "opus", "enabledPlugins": {"p@m": True, "q@m": True}}))
    base = {"marketplaces": {"m": "o/r"}, "plugins": {"p@m": True, "q@m": False},
            "skillOverrides": {"$comment": "x", "review": "off"}}

    plan = agent_sync.Plan()
    agent_sync.plan_claude(machine(tmp_path), base, plan)
    assert [(a.kind, a.target) for a in plan.actions] == [
        ("claude-enable", "q@m"), ("claude-skill-override", "review")]
    run_all(plan)

    settings = json.loads((claude / "settings.json").read_text())
    assert settings == {"model": "opus", "enabledPlugins": {"p@m": True, "q@m": False},
                        "skillOverrides": {"review": "off"}}
    again = agent_sync.Plan()
    agent_sync.plan_claude(machine(tmp_path), base, again)
    assert again.actions == []


def test_legacy_codex_skills_move_to_backup_but_system_stays(tmp_path):
    legacy = tmp_path / ".codex" / "skills"
    make_skill(legacy / "tdd-workflow")
    (legacy / ".system").mkdir()
    plan = agent_sync.Plan()
    agent_sync.plan_codex(machine(tmp_path), {}, plan)
    run_all(plan)

    assert sorted(p.name for p in legacy.iterdir()) == [".system"]
    assert (tmp_path / "backup" / "codex-skills" / "tdd-workflow" / "SKILL.md").exists()


def test_loose_link_that_duplicates_an_enabled_plugin_skill_is_unlinked(tmp_path):
    cache = tmp_path / ".codex" / "plugins" / "cache" / "m" / "p" / "1.0.0" / "skills"
    make_skill(cache / "wikify-raw")
    source = make_skill(tmp_path / "repo" / "wikify-raw")
    loose = tmp_path / ".agents" / "skills"
    loose.mkdir(parents=True)
    (loose / "wikify-raw").symlink_to(source)
    make_skill(loose / "orca-cli")

    plan = agent_sync.Plan()
    agent_sync.plan_codex(machine(tmp_path), {"plugins": {"p@m": True}, "externalSkills": ["orca-cli"]}, plan)
    assert [(a.kind, a.target) for a in plan.actions if "duplicate" in a.kind] == [
        ("agents-skills-duplicate", "wikify-raw")]
    run_all(plan)

    assert not (loose / "wikify-raw").exists()
    assert (loose / "orca-cli").exists() and source.exists()


def test_extract_subdir_skips_pax_header_and_takes_only_the_path(tmp_path):
    archive = tmp_path / "src.tar.gz"
    with tarfile.open(archive, "w:gz", format=tarfile.PAX_FORMAT, pax_headers={"comment": "sha"}) as tar:
        for name, body in [("repo-abc/skills/a/SKILL.md", b"a"), ("repo-abc/skills/a/ref.md", b"r"),
                           ("repo-abc/skills/b/SKILL.md", b"b")]:
            info = tarfile.TarInfo(name)
            info.size = len(body)
            tar.addfile(info, io.BytesIO(body))
    agent_sync.extract_subdir(archive, "skills/a", tmp_path / "out")
    assert sorted(p.name for p in (tmp_path / "out").iterdir()) == ["SKILL.md", "ref.md"]


def test_project_rule_writes_ignored_local_settings_and_leaves_tracked_files_alone(tmp_path):
    root = tmp_path / "projects"
    fresh, tracked = root / "fresh", root / "tracked"
    for project in (fresh, tracked):
        project.mkdir(parents=True)
        (project / "vercel.json").write_text("{}")
        subprocess.run(["git", "init", "-q", str(project)], check=True)
    (tracked / ".claude").mkdir()
    (tracked / ".claude" / "settings.local.json").write_text("{}")
    subprocess.run(["git", "-C", str(tracked), "add", "-f", ".claude/settings.local.json"], check=True)

    base = {"roots": ["~/projects"],
            "rules": [{"name": "vercel", "ifAnyExists": ["vercel.json"], "claudeLocalPlugins": ["v@m"]}]}
    plan = agent_sync.Plan()
    agent_sync.plan_projects(machine(tmp_path), base, plan)
    by_target = {a.target: a for a in plan.actions}
    assert by_target["tracked"].run is None
    run_all(plan)

    assert json.loads((fresh / ".claude" / "settings.local.json").read_text()) == {"enabledPlugins": {"v@m": True}}
    assert subprocess.run(["git", "-C", str(fresh), "check-ignore", "-q", ".claude/settings.local.json"]).returncode == 0
    assert json.loads((tracked / ".claude" / "settings.local.json").read_text()) == {}
