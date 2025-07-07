"""test_setup_script.py: check that setup.sh creates the minimal app layout"""
import os
import subprocess
from pathlib import Path
import pytest


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
    bench_env = tmp_path / ".env"
    assert bench_env.exists()
    bench_text = bench_env.read_text()
    assert "API_KEY=dummyapikeydummyapikey" in bench_text
    assert "REPO_NAME" not in bench_text
    app_env = app_path / ".env"
    assert app_env.exists()
    app_text = app_env.read_text()
    assert "REPO_NAME=demoapp" in app_text


def test_setup_script_runs_update_vendors(tmp_path):
    repo_root = Path(__file__).resolve().parents[1]
    script_path = repo_root / "setup.sh"
    tmp_script = tmp_path / "setup.sh"
    tmp_script.write_text(script_path.read_text())
    tmp_script.chmod(0o755)

    bench_cmd = tmp_path / "bench"
    bench_cmd.write_text(
        """#!/bin/bash
if [ \"$1\" = \"new-app\" ]; then
    app_name=\"$2\"
    root=\"apps/$app_name\"
    mkdir -p \"$root/config\" \"$root/templates\" \"$root/$app_name\"
    touch \"$root/patches.txt\"
    base=$(dirname \"$root\")
    echo '[tool.poetry]' > \"$base/pyproject.toml\"
    echo '# App' > \"$base/README.md\"
    echo 'MIT' > \"$base/license.txt\"
    echo '*.pyc' > \"$base/.gitignore\"
else
    exit 1
fi
"""
    )
    bench_cmd.chmod(0o755)

    scripts_src = tmp_path / "scripts"
    scripts_src.mkdir()
    update_script = scripts_src / "update_vendors.sh"
    update_script.write_text("#!/bin/bash\n touch update_called\n")
    update_script.chmod(0o755)

    (tmp_path / "vendors.txt").write_text("")
    (tmp_path / "apps.json").write_text("{}")

    subprocess.run(["git", "init"], cwd=tmp_path, check=True)
    env = {
        **os.environ,
        "PATH": f"{tmp_path}:{os.environ['PATH']}",
        "API_KEY": "dummyapikeydummyapikey",
    }
    subprocess.run([str(tmp_script), "demoapp"], cwd=tmp_path, check=True, env=env)

    marker = tmp_path / "apps" / "demoapp" / "update_called"
    assert marker.exists()


def test_setup_script_uses_existing_env(tmp_path):
    repo_root = Path(__file__).resolve().parents[1]
    script_path = repo_root / "setup.sh"
    tmp_script = tmp_path / "setup.sh"
    tmp_script.write_text(script_path.read_text())
    tmp_script.chmod(0o755)

    bench_cmd = tmp_path / "bench"
    bench_cmd.write_text(
        """#!/bin/bash
if [ \"$1\" = \"new-app\" ]; then
    mkdir -p apps/$2/$2
else
    exit 1
fi
"""
    )
    bench_cmd.chmod(0o755)

    (tmp_path / ".env").write_text("API_KEY=stored\nGITHUB_USER=user\n")
    (tmp_path / "vendors.txt").write_text("")
    (tmp_path / "apps.json").write_text("{}")

    subprocess.run(["git", "init"], cwd=tmp_path, check=True)
    env = {**os.environ, "PATH": f"{tmp_path}:{os.environ['PATH']}"}
    subprocess.run([str(tmp_script), "demo2"], cwd=tmp_path, check=True, env=env)

    bench_text = (tmp_path / ".env").read_text()
    assert "API_KEY=stored" in bench_text
    assert "REPO_NAME" not in bench_text
    app_text = (tmp_path / "apps" / "demo2" / ".env").read_text()
    assert "REPO_NAME=demo2" in app_text


def test_setup_script_migrates_repo_env(tmp_path):
    repo_root = Path(__file__).resolve().parents[1]
    script_path = repo_root / "setup.sh"
    tmp_script = tmp_path / "setup.sh"
    tmp_script.write_text(script_path.read_text())
    tmp_script.chmod(0o755)

    bench_cmd = tmp_path / "bench"
    bench_cmd.write_text(
        """#!/bin/bash
if [ \"$1\" = \"new-app\" ]; then
    mkdir -p apps/$2/$2
else
    exit 1
fi
"""
    )
    bench_cmd.chmod(0o755)

    (tmp_path / ".env").write_text(
        "API_KEY=stored\nGITHUB_USER=user\nREPO_NAME=old\nREPO_PATH=old.git\nSSH_KEY_PATH=/tmp/key\nDEPLOY_KEY_ADDED=1\n"
    )
    (tmp_path / "vendors.txt").write_text("")
    (tmp_path / "apps.json").write_text("{}")

    subprocess.run(["git", "init"], cwd=tmp_path, check=True)
    env = {**os.environ, "PATH": f"{tmp_path}:{os.environ['PATH']}"}
    subprocess.run([str(tmp_script), "demo3"], cwd=tmp_path, check=True, env=env)

    bench_text = (tmp_path / ".env").read_text()
    assert "API_KEY=stored" in bench_text
    assert "REPO_NAME" not in bench_text

    app_text = (tmp_path / "apps" / "demo3" / ".env").read_text()
    assert "REPO_NAME=demo3" in app_text
    assert "SSH_KEY_PATH" in app_text
    assert "DEPLOY_KEY_ADDED=1" in app_text


def test_setup_script_fails_if_app_exists(tmp_path):
    repo_root = Path(__file__).resolve().parents[1]
    script_path = repo_root / "setup.sh"
    tmp_script = tmp_path / "setup.sh"
    tmp_script.write_text(script_path.read_text())
    tmp_script.chmod(0o755)

    bench_cmd = tmp_path / "bench"
    bench_cmd.write_text("#!/bin/bash\ntouch bench_called\nexit 1\n")
    bench_cmd.chmod(0o755)

    existing = tmp_path / "apps" / "demoapp"
    existing.mkdir(parents=True)

    (tmp_path / "vendors.txt").write_text("")
    (tmp_path / "apps.json").write_text("{}")

    subprocess.run(["git", "init"], cwd=tmp_path, check=True)
    env = {**os.environ, "PATH": f"{tmp_path}:{os.environ['PATH']}"}

    with pytest.raises(subprocess.CalledProcessError):
        subprocess.run([str(tmp_script), "demoapp"], cwd=tmp_path, check=True, env=env)

    assert not (tmp_path / "bench_called").exists()


def test_setup_script_copies_template_instructions(tmp_path):
    repo_root = Path(__file__).resolve().parents[1]
    script_path = repo_root / "setup.sh"
    tmp_script = tmp_path / "setup.sh"
    tmp_script.write_text(script_path.read_text())
    tmp_script.chmod(0o755)

    # replace submodule URL with local path to include template files
    data = tmp_script.read_text().replace(
        "https://github.com/Freddyslim/frappe_app_template",
        Path(repo_root).as_uri(),
    )
    tmp_script.write_text(data)

    bench_cmd = tmp_path / "bench"
    bench_cmd.write_text(
        """#!/bin/bash
if [ \"$1\" = \"new-app\" ]; then
    mkdir -p apps/$2
else
    exit 1
fi
"""
    )
    bench_cmd.chmod(0o755)
    (tmp_path / "vendors.txt").write_text((repo_root / "vendors.txt").read_text())
    (tmp_path / "apps.json").write_text((repo_root / "apps.json").read_text())


    subprocess.run(["git", "init"], cwd=tmp_path, check=True)
    env = {
        **os.environ,
        "PATH": f"{tmp_path}:{os.environ['PATH']}",
        "API_KEY": "dummy",
        "GIT_ALLOW_PROTOCOL": "file",
    }
    subprocess.run([str(tmp_script), "demo"], cwd=tmp_path, check=True, env=env)

    app_root = tmp_path / "apps" / "demo"
    assert (app_root / "AGENTS.md").read_text() == (repo_root / "AGENTS.md").read_text()
    assert (app_root / "instructions" / "bench" / "AGENTS.md").exists()
    assert (app_root / "instructions" / "frappe" / "AGENTS.md").exists()


def test_setup_script_preserves_agents_and_creates_projekt(tmp_path):
    repo_root = Path(__file__).resolve().parents[1]
    script_path = repo_root / "setup.sh"
    tmp_script = tmp_path / "setup.sh"
    tmp_script.write_text(script_path.read_text())
    tmp_script.chmod(0o755)

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
    echo 'keep' > "$root/AGENTS.md"
else
    exit 1
fi
"""
    )
    bench_cmd.chmod(0o755)

    (tmp_path / "vendors.txt").write_text((repo_root / "vendors.txt").read_text())
    (tmp_path / "apps.json").write_text((repo_root / "apps.json").read_text())

    subprocess.run(["git", "init"], cwd=tmp_path, check=True)
    env = {
        **os.environ,
        "PATH": f"{tmp_path}:{os.environ['PATH']}",
        "API_KEY": "dummy",
    }
    subprocess.run([str(tmp_script), "demo2"], cwd=tmp_path, check=True, env=env)

    app_root = tmp_path / "apps" / "demo2"
    assert (app_root / "AGENTS.md").read_text().strip() == "keep"
    assert (app_root / "PROJEKT.md").exists()

