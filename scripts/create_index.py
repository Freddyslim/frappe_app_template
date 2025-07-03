import argparse
import json
from pathlib import Path


def build_index(root: Path, extensions):
    index = {}
    for ext in extensions:
        index[ext] = sorted(p.name for p in root.rglob(f"*.{ext}") if p.is_file())
    return index


def main(argv=None):
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", type=Path, default=Path("."))
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--ext", action="append", dest="exts")
    args = parser.parse_args(argv)

    exts = args.exts or ["py", "js"]
    index = build_index(args.root, exts)
    args.output.write_text(json.dumps(index, indent=2))


if __name__ == "__main__":
    main()
