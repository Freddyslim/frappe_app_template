import subprocess
from pathlib import Path


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

    subprocess.run([str(tmp_script)], cwd=tmp_path, check=True)

    tag = subprocess.check_output(["git", "tag"], cwd=tmp_path).decode().strip()
    assert tag.startswith("v")

    branch = subprocess.check_output([
        "git",
        "rev-parse",
        "--abbrev-ref",
        "HEAD",
    ], cwd=tmp_path).decode().strip()
    assert branch == f"publish-{tag}"
