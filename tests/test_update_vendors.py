"""test_update_vendors.py: verify vendor update script behavior"""
import os
import subprocess
import json
from pathlib import Path


def test_update_vendors_prunes_obsolete_submodule(tmp_path):
    repo_root = Path(__file__).resolve().parents[1]
    scripts_dir = repo_root / "scripts"
    tmp_scripts = tmp_path / "scripts"
    tmp_scripts.mkdir()
    (tmp_scripts / "update_vendors.sh").write_text((scripts_dir / "update_vendors.sh").read_text())

    subprocess.run(["git", "init"], cwd=tmp_path, check=True)

    dummy_repo = tmp_path / "dummy_repo"
    dummy_repo.mkdir()
    subprocess.run(["git", "init"], cwd=dummy_repo, check=True)
    (dummy_repo / "README.md").write_text("dummy")
    subprocess.run(["git", "add", "README.md"], cwd=dummy_repo, check=True)
    subprocess.run(["git", "commit", "-m", "init"], cwd=dummy_repo, check=True)

    env = {**os.environ, "GIT_ALLOW_PROTOCOL": "file"}
    subprocess.run([
        "git",
        "submodule",
        "add",
        str(dummy_repo),
        "vendor/dummy",
    ], cwd=tmp_path, check=True, env=env)
    subprocess.run(["git", "commit", "-am", "add submodule"], cwd=tmp_path, check=True)

    assert (tmp_path / "vendor" / "dummy").exists()

    (tmp_path / "apps.json").write_text("{}")
    (tmp_path / "vendors.txt").write_text("")
    (tmp_path / "vendor_profiles").mkdir()

    subprocess.run(["bash", str(tmp_scripts / "update_vendors.sh")], cwd=tmp_path, check=True)

    assert not (tmp_path / "vendor" / "dummy").exists()
    gitmodules = tmp_path / ".gitmodules"
    if gitmodules.exists():
        assert "vendor/dummy" not in gitmodules.read_text()

    assert (tmp_path / "apps.json").read_text().strip() == "{}"


def test_update_vendors_rebuilds_configs(tmp_path):
    repo_root = Path(__file__).resolve().parents[1]
    scripts_dir = repo_root / "scripts"
    tmp_scripts = tmp_path / "scripts"
    tmp_scripts.mkdir()
    (tmp_scripts / "update_vendors.sh").write_text((scripts_dir / "update_vendors.sh").read_text())

    subprocess.run(["git", "init"], cwd=tmp_path, check=True)

    # create dummy repos for custom apps
    app1_repo = tmp_path / "app1_repo"
    app1_repo.mkdir()
    subprocess.run(["git", "init"], cwd=app1_repo, check=True)
    (app1_repo / "README.md").write_text("a1")
    subprocess.run(["git", "add", "README.md"], cwd=app1_repo, check=True)
    subprocess.run(["git", "commit", "-m", "init"], cwd=app1_repo, check=True)

    app2_repo = tmp_path / "app2_repo"
    app2_repo.mkdir()
    subprocess.run(["git", "init"], cwd=app2_repo, check=True)
    (app2_repo / "README.md").write_text("a2")
    subprocess.run(["git", "add", "README.md"], cwd=app2_repo, check=True)
    subprocess.run(["git", "commit", "-m", "init"], cwd=app2_repo, check=True)

    # root config has outdated apps.json which should be ignored
    (tmp_path / "apps.json").write_text("{\n  \"oldapp\": {\"repo\": \"file://old\", \"branch\": \"main\"}\n}")

    (tmp_path / "vendors.txt").write_text("app1\napp2\n")
    prof_dir = tmp_path / "vendor_profiles" / "test"
    (prof_dir / "app1").mkdir(parents=True)
    (prof_dir / "app2").mkdir(parents=True)
    (prof_dir / "app1" / "apps.json").write_text(json.dumps({"url": str(app1_repo), "branch": "v1"}))
    (prof_dir / "app2" / "apps.json").write_text(json.dumps({"url": str(app2_repo), "branch": "v2"}))

    env = {**os.environ, "GIT_ALLOW_PROTOCOL": "file"}
    subprocess.run(["bash", str(tmp_scripts / "update_vendors.sh")], cwd=tmp_path, check=True, env=env)

    data = json.loads((tmp_path / "apps.json").read_text())
    assert "oldapp" not in data
    assert (tmp_path / "vendor_profiles" / "test" / "app1" / "apps.json").exists()
    assert (tmp_path / "vendor_profiles" / "test" / "app2" / "apps.json").exists()



def test_update_vendors_accepts_manual_entry(tmp_path):
    repo_root = Path(__file__).resolve().parents[1]
    scripts_dir = repo_root / "scripts"
    tmp_scripts = tmp_path / "scripts"
    tmp_scripts.mkdir()
    (tmp_scripts / "update_vendors.sh").write_text((scripts_dir / "update_vendors.sh").read_text())

    subprocess.run(["git", "init"], cwd=tmp_path, check=True)

    manual_repo = tmp_path / "manual_repo"
    manual_repo.mkdir()
    subprocess.run(["git", "init"], cwd=manual_repo, check=True)
    (manual_repo / "README.md").write_text("manual")
    subprocess.run(["git", "add", "README.md"], cwd=manual_repo, check=True)
    subprocess.run(["git", "commit", "-m", "init"], cwd=manual_repo, check=True)

    (tmp_path / "apps.json").write_text("{}")
    (tmp_path / "vendors.txt").write_text(f"custom|{manual_repo}|main")
    (tmp_path / "vendor_profiles").mkdir()

    env = {**os.environ, "GIT_ALLOW_PROTOCOL": "file"}
    subprocess.run(["bash", str(tmp_scripts / "update_vendors.sh")], cwd=tmp_path, check=True, env=env)

    data = json.loads((tmp_path / "apps.json").read_text())
    assert "custom" in data
    assert data["custom"]["branch"] == "main"
    assert (tmp_path / "vendor" / "custom-main").exists()


def test_update_vendors_removes_unlisted_apps(tmp_path):
    repo_root = Path(__file__).resolve().parents[1]
    scripts_dir = repo_root / "scripts"
    tmp_scripts = tmp_path / "scripts"
    tmp_scripts.mkdir()
    (tmp_scripts / "update_vendors.sh").write_text((scripts_dir / "update_vendors.sh").read_text())

    subprocess.run(["git", "init"], cwd=tmp_path, check=True)

    manual_repo = tmp_path / "manual_repo2"
    manual_repo.mkdir()
    subprocess.run(["git", "init"], cwd=manual_repo, check=True)
    (manual_repo / "README.md").write_text("manual")
    subprocess.run(["git", "add", "README.md"], cwd=manual_repo, check=True)
    subprocess.run(["git", "commit", "-m", "init"], cwd=manual_repo, check=True)

    (tmp_path / "apps.json").write_text(json.dumps({"manual": {"repo": str(manual_repo), "branch": "main"}}))
    (tmp_path / "vendors.txt").write_text("")
    (tmp_path / "vendor_profiles").mkdir()

    env = {**os.environ, "GIT_ALLOW_PROTOCOL": "file"}
    subprocess.run(["bash", str(tmp_scripts / "update_vendors.sh")], cwd=tmp_path, check=True, env=env)

    data = json.loads((tmp_path / "apps.json").read_text())
    assert "manual" not in data
    assert not (tmp_path / "vendor" / "manual-main").exists()


def test_update_vendors_uses_custom_vendors_json(tmp_path):
    repo_root = Path(__file__).resolve().parents[1]
    scripts_dir = repo_root / "scripts"
    tmp_scripts = tmp_path / "scripts"
    tmp_scripts.mkdir()
    (tmp_scripts / "update_vendors.sh").write_text((scripts_dir / "update_vendors.sh").read_text())

    subprocess.run(["git", "init"], cwd=tmp_path, check=True)

    custom_repo = tmp_path / "custom_repo"
    custom_repo.mkdir()
    subprocess.run(["git", "init"], cwd=custom_repo, check=True)
    (custom_repo / "README.md").write_text("custom")
    subprocess.run(["git", "add", "README.md"], cwd=custom_repo, check=True)
    subprocess.run(["git", "commit", "-m", "init"], cwd=custom_repo, check=True)

    (tmp_path / "apps.json").write_text("{}")
    (tmp_path / "vendors.txt").write_text("")
    (tmp_path / "custom_vendors.json").write_text(json.dumps({"extra": {"repo": str(custom_repo), "branch": "main"}}))
    (tmp_path / "vendor_profiles").mkdir()

    env = {**os.environ, "GIT_ALLOW_PROTOCOL": "file"}
    subprocess.run(["bash", str(tmp_scripts / "update_vendors.sh")], cwd=tmp_path, check=True, env=env)

    data = json.loads((tmp_path / "apps.json").read_text())
    assert "extra" in data
    assert (tmp_path / "vendor" / "extra-main").exists()


def test_update_vendors_supports_tag(tmp_path):
    repo_root = Path(__file__).resolve().parents[1]
    scripts_dir = repo_root / "scripts"
    tmp_scripts = tmp_path / "scripts"
    tmp_scripts.mkdir()
    (tmp_scripts / "update_vendors.sh").write_text((scripts_dir / "update_vendors.sh").read_text())

    subprocess.run(["git", "init"], cwd=tmp_path, check=True)

    tag_repo = tmp_path / "tag_repo"
    tag_repo.mkdir()
    subprocess.run(["git", "init"], cwd=tag_repo, check=True)
    (tag_repo / "README.md").write_text("tag")
    subprocess.run(["git", "add", "README.md"], cwd=tag_repo, check=True)
    subprocess.run(["git", "commit", "-m", "init"], cwd=tag_repo, check=True)
    subprocess.run(["git", "tag", "v1.0"], cwd=tag_repo, check=True)

    (tmp_path / "apps.json").write_text("{}")
    (tmp_path / "vendors.txt").write_text("tagtest")
    prof_dir = tmp_path / "vendor_profiles"
    (prof_dir / "tagtest").mkdir(parents=True)
    (prof_dir / "tagtest" / "apps.json").write_text(json.dumps({"url": str(tag_repo), "tag": "v1.0"}))

    env = {**os.environ, "GIT_ALLOW_PROTOCOL": "file"}
    subprocess.run(["bash", str(tmp_scripts / "update_vendors.sh")], cwd=tmp_path, check=True, env=env)

    data = json.loads((tmp_path / "apps.json").read_text())
    assert "tagtest" in data
    assert data["tagtest"]["tag"] == "v1.0"
    assert (tmp_path / "vendor" / "tagtest-v1.0").exists()


def test_update_vendors_preserves_existing_apps_json(tmp_path):
    repo_root = Path(__file__).resolve().parents[1]
    scripts_dir = repo_root / "scripts"
    tmp_scripts = tmp_path / "scripts"
    tmp_scripts.mkdir()
    (tmp_scripts / "update_vendors.sh").write_text((scripts_dir / "update_vendors.sh").read_text())

    subprocess.run(["git", "init"], cwd=tmp_path, check=True)

    original_repo = tmp_path / "original_repo"
    original_repo.mkdir()
    subprocess.run(["git", "init"], cwd=original_repo, check=True)
    (original_repo / "README.md").write_text("orig")
    subprocess.run(["git", "add", "README.md"], cwd=original_repo, check=True)
    subprocess.run(["git", "commit", "-m", "init"], cwd=original_repo, check=True)

    alt_repo = tmp_path / "alt_repo"
    alt_repo.mkdir()
    subprocess.run(["git", "init"], cwd=alt_repo, check=True)
    (alt_repo / "README.md").write_text("alt")
    subprocess.run(["git", "add", "README.md"], cwd=alt_repo, check=True)
    subprocess.run(["git", "commit", "-m", "init"], cwd=alt_repo, check=True)

    (tmp_path / "apps.json").write_text(json.dumps({"demo": {"repo": str(original_repo), "branch": "main"}}))
    (tmp_path / "vendors.txt").write_text("demo\n")
    prof_dir = tmp_path / "vendor_profiles"
    (prof_dir / "demo").mkdir(parents=True)
    (prof_dir / "demo" / "apps.json").write_text(json.dumps({"url": str(alt_repo), "branch": "v1"}))

    env = {**os.environ, "GIT_ALLOW_PROTOCOL": "file"}
    subprocess.run(["bash", str(tmp_scripts / "update_vendors.sh")], cwd=tmp_path, check=True, env=env)

    data = json.loads((tmp_path / "apps.json").read_text())
    assert data["demo"]["repo"] == str(original_repo)
    assert data["demo"]["branch"] == "main"


