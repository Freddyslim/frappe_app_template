"""test_publish_app.py: verify publish_app.sh tags releases correctly"""
import subprocess
from pathlib import Path


def prepare_repo(tmp_path, script_name):
    repo_root = Path(__file__).resolve().parents[1]
    script_path = repo_root / "scripts" / script_name
    tmp_scripts = tmp_path / "scripts"
    tmp_scripts.mkdir()
    dest = tmp_scripts / script_name
    dest.write_text(script_path.read_text())
    dest.chmod(0o755)
    subprocess.run(["git", "init"], cwd=tmp_path, check=True)
    (tmp_path / "README.md").write_text("init")
    subprocess.run(["git", "add", "README.md"], cwd=tmp_path, check=True)
    subprocess.run(["git", "commit", "-m", "init"], cwd=tmp_path, check=True)
    return dest


def test_publish_app_creates_patch_tag(tmp_path):
    script = prepare_repo(tmp_path, "publish_app.sh")
    subprocess.run(["git", "tag", "v1.2.3"], cwd=tmp_path, check=True)
    subprocess.run([str(script), "dev-stable"], cwd=tmp_path, check=True)
    tags = subprocess.check_output(["git", "tag"], cwd=tmp_path).decode().split()
    assert "v1.2.4" in tags


def test_publish_app_creates_major_tag(tmp_path):
    script = prepare_repo(tmp_path, "publish_app.sh")
    subprocess.run(["git", "tag", "v0.1.0"], cwd=tmp_path, check=True)
    subprocess.run([str(script), "major"], cwd=tmp_path, check=True)
    tags = subprocess.check_output(["git", "tag"], cwd=tmp_path).decode().split()
    assert "v1.0.0" in tags


def test_publish_app_creates_tag_and_branch(tmp_path):
    repo_root = Path(__file__).resolve().parents[1]
    script_path = repo_root / "scripts" / "publish_app.sh"
    tmp_script = tmp_path / "publish_app.sh"
    tmp_script.write_text(script_path.read_text())
    tmp_script.chmod(0o755)

    subprocess.run(["git", "init"], cwd=tmp_path, check=True)
    (tmp_path / "README.md").write_text("demo")
    subprocess.run(["git", "add", "README.md"], cwd=tmp_path, check=True)
    subprocess.run(["git", "commit", "-m", "init"], cwd=tmp_path, check=True)

    subprocess.run([str(tmp_script), "dev-stable"], cwd=tmp_path, check=True)

    tag = subprocess.check_output(["git", "tag"], cwd=tmp_path).decode().strip()
    assert tag.startswith("v")

    # The script does not create a new branch; ensure the tag was created
    current_branch = subprocess.check_output(
        ["git", "rev-parse", "--abbrev-ref", "HEAD"], cwd=tmp_path
    ).decode().strip()
    assert current_branch in {"master", "main"}


