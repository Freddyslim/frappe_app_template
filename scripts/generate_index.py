from __future__ import annotations

import re
from pathlib import Path
from typing import Dict, List, Optional


def generate_vendor_summaries(root: Path) -> List[str]:
    vendor_dir = root / "vendor"
    summaries = []
    if not vendor_dir.is_dir():
        return summaries
    dest_dir = root / "instructions" / "vendors"
    dest_dir.mkdir(parents=True, exist_ok=True)
    for entry in sorted(vendor_dir.iterdir()):
        if entry.is_dir():
            name = entry.name
            (dest_dir / f"{name}.md").write_text(f"# {name}\n")
            summaries.append(name)
    return summaries


def extract_tags(root: Path) -> List[str]:
    project_file = root / "PROJECT.md"
    if not project_file.is_file():
        return []
    lines = project_file.read_text().splitlines()
    try:
        idx = lines.index("## Tags")
    except ValueError:
        return []
    if idx + 1 >= len(lines):
        return []
    return [t.strip() for t in lines[idx + 1].split(',') if t.strip()]


def map_tags_to_vendors(tags: List[str], root: Path) -> Dict[str, List[str]]:
    vendor_dir = root / "vendor"
    mapping: Dict[str, List[str]] = {t: [] for t in tags}
    if not vendor_dir.is_dir():
        return mapping
    for entry in vendor_dir.iterdir():
        if not entry.is_dir():
            continue
        name = entry.name
        for tag in tags:
            if name.startswith(tag):
                mapping[tag].append(name)
    return mapping


def parse_prompts(root: Path) -> Dict[str, List[str]]:
    prompts_file = root / "projects.md"
    tasks: Dict[str, List[str]] = {}
    if not prompts_file.is_file():
        return tasks
    pattern = re.compile(r"\[(.*?)\]\s*(.*)")
    for line in prompts_file.read_text().splitlines():
        m = pattern.match(line.strip())
        if not m:
            continue
        tags = [t.strip() for t in m.group(1).split(',') if t.strip()]
        text = f"- {m.group(2).strip()}"
        for tag in tags:
            tasks.setdefault(tag, []).append(text)
    return tasks


def write_index(vendor_links: List[str], tags: List[str], tag_map: Dict[str, List[str]], root: Path, tasks: Optional[Dict[str, List[str]]] = None) -> None:
    instr_dir = root / "instructions"
    instr_dir.mkdir(parents=True, exist_ok=True)
    index_file = instr_dir / "_INDEX.md"
    lines = ["# Vendor Index"]
    if vendor_links:
        lines.append("## Vendors")
        for vendor in vendor_links:
            lines.append(f"- {vendor}")
    if tags:
        lines.append("## Tags")
        for tag in tags:
            lines.append(f"### {tag}")
            for vendor in tag_map.get(tag, []):
                lines.append(f"- {vendor}")
    if tasks:
        lines.append("## Tasks")
        for tag, entries in tasks.items():
            lines.append(f"### {tag}")
            lines.extend(entries)
    index_file.write_text("\n".join(lines) + "\n")


def main(argv: Optional[List[str]] = None) -> None:
    root = Path('.')
    vendor_links = generate_vendor_summaries(root)
    tags = extract_tags(root)
    tag_map = map_tags_to_vendors(tags, root)
    tasks = parse_prompts(root)
    write_index(vendor_links, tags, tag_map, root, tasks if tasks else None)


if __name__ == '__main__':
    main()

