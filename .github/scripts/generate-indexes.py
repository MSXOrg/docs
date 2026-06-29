#!/usr/bin/env python3
"""Generate the index tables in each section's ``index.md`` from page front matter.

Every documentation page declares ``title`` and ``description`` in YAML front
matter. Each ``index.md`` that contains the ``INDEX`` markers gets an
auto-generated table of the documents at its level — subsections for the root,
pages for a section — ordered to match the navigation in ``zensical.toml``.

Run with no arguments to update the index files in place. Run with ``--check`` to
verify they are up to date, changing nothing and exiting non-zero on drift.
"""

from __future__ import annotations

import sys
import tomllib
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
DOCS = ROOT / "src" / "docs"
CONFIG = ROOT / "src" / "zensical.toml"
START = "<!-- INDEX:START -->"
END = "<!-- INDEX:END -->"


def read_front_matter(path: Path) -> dict[str, str]:
    """Return the simple ``key: value`` pairs from a file's YAML front matter."""
    text = path.read_text(encoding="utf-8")
    if not text.startswith("---"):
        return {}
    closing = text.find("\n---", 3)
    if closing == -1:
        return {}
    meta: dict[str, str] = {}
    for line in text[3:closing].splitlines():
        stripped = line.strip()
        if not stripped or stripped.startswith("#") or ":" not in line:
            continue
        key, _, value = line.partition(":")
        value = value.strip().strip('"').strip("'")
        if key.strip() and value:
            meta[key.strip()] = value
    return meta


def nav_order() -> dict[str, int]:
    """Map each doc path (posix, relative to DOCS) to its position in the nav."""
    data = tomllib.loads(CONFIG.read_text(encoding="utf-8"))
    paths: list[str] = []

    def walk(items: list) -> None:
        for item in items:
            if isinstance(item, str):
                paths.append(item)
            elif isinstance(item, dict):
                for value in item.values():
                    if isinstance(value, str):
                        paths.append(value)
                    elif isinstance(value, list):
                        walk(value)

    walk(data["project"]["nav"])
    return {path: position for position, path in enumerate(paths)}


def build_table(index_path: Path, order: dict[str, int]) -> str:
    """Build the markdown table of children for the given index file."""
    directory = index_path.parent
    subdirs = sorted(
        d for d in directory.iterdir() if d.is_dir() and (d / "index.md").exists()
    )
    files = sorted(
        f
        for f in directory.iterdir()
        if f.is_file() and f.suffix == ".md" and f.name != "index.md"
    )

    rows: list[tuple[int, str, str, str]] = []
    for child in subdirs:
        target = child / "index.md"
        meta = read_front_matter(target)
        key = target.relative_to(DOCS).as_posix()
        rows.append(
            (
                order.get(key, 10_000),
                meta.get("title", child.name),
                f"{child.name}/index.md",
                meta.get("description", ""),
            )
        )
    for child in files:
        meta = read_front_matter(child)
        key = child.relative_to(DOCS).as_posix()
        rows.append(
            (
                order.get(key, 10_000),
                meta.get("title", child.stem),
                child.name,
                meta.get("description", ""),
            )
        )

    rows.sort(key=lambda row: (row[0], row[1].lower()))

    header = "Section" if subdirs and not files else "Page"
    lines = [f"| {header} | Description |", "| --- | --- |"]
    lines += [
        f"| [{title}]({link}) | {description} |" for _, title, link, description in rows
    ]
    return "\n".join(lines)


def render(index_path: Path, order: dict[str, int]) -> str | None:
    """Return the index file's content with the table refreshed, or None to skip."""
    text = index_path.read_text(encoding="utf-8")
    if START not in text or END not in text:
        return None
    head = text[: text.index(START) + len(START)]
    tail = text[text.index(END) :]
    return f"{head}\n\n{build_table(index_path, order)}\n\n{tail}"


def main() -> int:
    check = "--check" in sys.argv
    order = nav_order()
    stale: list[Path] = []
    for index_path in sorted(DOCS.rglob("index.md")):
        rendered = render(index_path, order)
        if rendered is None or rendered == index_path.read_text(encoding="utf-8"):
            continue
        stale.append(index_path.relative_to(ROOT))
        if not check:
            index_path.write_text(rendered, encoding="utf-8")

    if not stale:
        return 0
    if check:
        print("Documentation index tables are out of date:")
        print("\n".join(f"  - {path}" for path in stale))
        print("Run: python .github/scripts/generate-indexes.py")
        return 1
    print("Updated index tables:")
    print("\n".join(f"  - {path}" for path in stale))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
