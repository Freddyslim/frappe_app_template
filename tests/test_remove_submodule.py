"""test_remove_submodule.py: ensure submodule cleanup works"""
import subprocess
from pathlib import Path


def test_remove_submodule_script(tmp_path):
    scripts_dir = Path(__file__).resolve().parents[1] / "scripts"
    tmp_scripts = tmp_path / "scripts"
    tmp_scripts.mkdir()
    (tmp_scripts / "remove_submodule.sh").write_text((scripts_dir / "remove_submodule.sh").read_text())

    vendor = tmp_path / "vendor" / "demo-template"
    instr = tmp_path / "instructions" / "_demo-template"
    vendor.mkdir(parents=True)
    instr.mkdir(parents=True)

    # create minimal .gitmodules so removal logic triggers
    gitmodules = tmp_path / ".gitmodules"
    gitmodules.write_text("""[submodule \"vendor/demo-template\"]\n  path = vendor/demo-template\n  url = https://example.com/demo-template\n""")



    subprocess.run(["bash", str(tmp_scripts / "remove_submodule.sh"), "demo-template"], cwd=tmp_path, check=True)

    assert not vendor.exists()
    assert not instr.exists()

