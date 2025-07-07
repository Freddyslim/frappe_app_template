"""test_remove_repo.py: ensure repository cleanup works"""
import subprocess
from pathlib import Path


def test_remove_repo_script(tmp_path):
    scripts_dir = Path(__file__).resolve().parents[1] / "scripts"
    tmp_scripts = tmp_path / "scripts"
    tmp_scripts.mkdir()
    (tmp_scripts / "remove_repo.sh").write_text((scripts_dir / "remove_repo.sh").read_text())

    vendor = tmp_path / "vendor" / "demo-template"
    instr = tmp_path / "instructions" / "_demo-template"
    vendor.mkdir(parents=True)
    instr.mkdir(parents=True)

    subprocess.run(["bash", str(tmp_scripts / "remove_repo.sh"), "demo-template"], cwd=tmp_path, check=True)

    assert not vendor.exists()
    assert not instr.exists()

