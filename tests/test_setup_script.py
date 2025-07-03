import os
import subprocess
from pathlib import Path


def test_setup_script_uses_bench_new_app(tmp_path):
    repo_root = Path(__file__).resolve().parents[1]
    script_path = repo_root / "setup.sh"
    tmp_script = tmp_path / "setup.sh"
    tmp_script.write_text(script_path.read_text())
    tmp_script.chmod(0o755)

    # create dummy bench executable that mimics `bench new-app`
    bench_cmd = tmp_path / "bench"
    bench_cmd.write_text(
        """#!/bin/bash
if [ "$1" = "new-app" ]; then
    app_name="$2"
    root="apps/$app_name"
    mkdir -p "$root/config" "$root/templates" "$root/$app_name"
    touch "$root/patches.txt"
    base=$(dirname "$root")
    echo '[tool.poetry]' > "$base/pyproject.toml"
    echo '# App' > "$base/README.md"
    echo 'MIT' > "$base/license.txt"
    echo '*.pyc' > "$base/.gitignore"
else
    exit 1
fi
"""
    )
    bench_cmd.chmod(0o755)

    # minimal required config files
    (tmp_path / "vendors.txt").write_text((repo_root / "vendors.txt").read_text())
    (tmp_path / "apps.json").write_text((repo_root / "apps.json").read_text())

    subprocess.run(["git", "init"], cwd=tmp_path, check=True)
    env = {
        **os.environ,
        "PATH": f"{tmp_path}:{os.environ['PATH']}",
        "API_KEY": "dummyapikeydummyapikey",
    }
    subprocess.run([str(tmp_script), "demoapp"], cwd=tmp_path, check=True, env=env)

    app_path = tmp_path / "apps" / "demoapp"
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


def test_setup_script_copies_clean_vendor_files(tmp_path):
    repo_root = Path(__file__).resolve().parents[1]
    script_path = repo_root / "setup.sh"
    tmp_script = tmp_path / "setup.sh"
    tmp_script.write_text(script_path.read_text())
    tmp_script.chmod(0o755)

    bench_cmd = tmp_path / "bench"
    bench_cmd.write_text(
        """#!/bin/bash
if [ "$1" = "new-app" ]; then
    mkdir -p "apps/$2/$2"
else
    exit 1
fi
"""
    )
    bench_cmd.chmod(0o755)

    (tmp_path / "vendors.txt").write_text((repo_root / "vendors.txt").read_text())
    (tmp_path / "apps.json").write_text((repo_root / "apps.json").read_text())
    (tmp_path / "custom_vendors.json").write_text((repo_root / "custom_vendors.json").read_text())

    subprocess.run(["git", "init"], cwd=tmp_path, check=True)
    env = {**os.environ, "PATH": f"{tmp_path}:{os.environ['PATH']}"}
    subprocess.run([str(tmp_script), "demoapp"], cwd=tmp_path, check=True, env=env)

    app_root = tmp_path / "apps" / "demoapp"
    vendors_content = (app_root / "vendors.txt").read_text().splitlines()
    assert all(not line.strip() or line.lstrip().startswith("#") for line in vendors_content)
    assert (app_root / "apps.json").read_text().strip() == "{}"
    assert (app_root / "custom_vendors.json").read_text().strip() == "{}"

