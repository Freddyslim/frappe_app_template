import subprocess
from pathlib import Path


def test_setup_script_creates_app(tmp_path):
    repo_root = Path(__file__).resolve().parents[1]
    script_path = repo_root / "setup.sh"
    tmp_script = tmp_path / "setup.sh"
    tmp_script.write_text(script_path.read_text())
    tmp_script.chmod(0o755)

    tmp_scripts = tmp_path / "scripts"
    tmp_scripts.mkdir()
    src_script = repo_root / "scripts" / "new_frappe_app_folder.py"
    (tmp_scripts / "new_frappe_app_folder.py").write_text(src_script.read_text())
    (tmp_scripts / "generate_index.py").write_text((repo_root / "scripts" / "generate_index.py").read_text())

    # minimal required config files
    (tmp_path / "vendors.txt").write_text((repo_root / "vendors.txt").read_text())
    (tmp_path / "apps.json").write_text((repo_root / "apps.json").read_text())

    subprocess.run(["git", "init"], cwd=tmp_path, check=True)
    env = {"API_KEY": "dummyapikeydummyapikey"}
    subprocess.run([str(tmp_script), "demoapp"], cwd=tmp_path, check=True, env=env)

    app_path = tmp_path / "app" / "demoapp"

    assert (app_path / "config").is_dir()
    assert (app_path / "templates").is_dir()
    assert (app_path / "demoapp").is_dir()
    root = app_path.parent

    assert (root / "pyproject.toml").exists()
    assert (root / "README.md").exists()
    assert (root / "license.txt").exists()
    assert (root / ".gitignore").exists()
    assert (app_path / "patches.txt").exists()
    env_file = tmp_path / ".env"
    assert env_file.exists()
    assert "API_KEY=dummyapikeydummyapikey" in env_file.read_text()
