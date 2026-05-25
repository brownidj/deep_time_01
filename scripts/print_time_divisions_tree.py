#!/usr/bin/env python3
import argparse
import re
from pathlib import Path
import yaml

RANKS = ["eon", "era", "period", "epoch", "age"]
NEXT = {RANKS[i]: (RANKS[i + 1] if i + 1 < len(RANKS) else None) for i in range(len(RANKS))}

class Node:
    def __init__(self, name, rank):
        self.name = name
        self.rank = rank
        self.children = []
        self.parent = None
        self.height = None
        self.y_top = None
        self.y_bottom = None
        self.empty_subblock = None


def text_height(name, rank, line_height, padding, char_width, vertical):
    # Approximate single-line label size with padding.
    if vertical:
        # Vertical label height depends on text width.
        return (len(name) * char_width) + (padding * 2)
    return line_height + (padding * 2)


def build_tree(yaml_path):
    data = yaml.safe_load(Path(yaml_path).read_text())

    def build(node_dict):
        name = node_dict.get("name")
        rank = node_dict.get("rank")
        if rank == "stage":
            # Normalize to 'age' for algorithm rank ladder.
            rank = "age"
        n = Node(name, rank)
        for ch in node_dict.get("children", []) or []:
            cn = build(ch)
            cn.parent = n
            n.children.append(cn)
        return n

    return [build(e) for e in data.get("eons", [])]


def compute_height(node, min_age_height, line_height, padding, char_width, vertical_ranks):
    if node.rank == "age":
        node.height = min_age_height
        return node.height

    next_rank = NEXT.get(node.rank)
    children_next = [c for c in node.children if c.rank == next_rank]

    if not children_next:
        node.height = text_height(
            node.name,
            node.rank,
            line_height,
            padding,
            char_width,
            vertical=(node.rank in vertical_ranks),
        )
        node.empty_subblock = {"rank": next_rank, "height": node.height}
        return node.height

    total = 0.0
    for c in children_next:
        total += compute_height(c, min_age_height, line_height, padding, char_width, vertical_ranks)
    node.height = total
    return node.height


def assign_y(node, y_top):
    node.y_top = y_top
    node.y_bottom = y_top + node.height

    next_rank = NEXT.get(node.rank)
    children_next = [c for c in node.children if c.rank == next_rank]

    if not children_next:
        node.empty_subblock = {"rank": next_rank, "y_top": y_top, "height": node.height}
        return

    cur = y_top
    for c in children_next:
        assign_y(c, cur)
        cur += c.height


def parse_md_tree(md_path):
    lines = Path(md_path).read_text().splitlines()
    try:
        start = next(i for i, l in enumerate(lines) if l.strip().startswith("```"))
        end = next(i for i in range(start + 1, len(lines)) if lines[i].strip().startswith("```"))
    except StopIteration:
        raise SystemExit("time_divisions_tree.md missing code fence")

    content = lines[start + 1 : end]
    header_idx = next(i for i, l in enumerate(content) if l.strip().startswith("Name"))
    content = content[header_idx + 1 :]

    pattern = re.compile(r"^(?P<indent>(?:│   |    )*)(?:├── |└── )?(?P<name>[^\s].*?)\s{2,}.*$")
    paths = []
    stack = []

    for line in content:
        if not line.strip():
            continue
        m = pattern.match(line)
        if not m:
            parts = re.split(r"\s{2,}", line.strip())
            if not parts:
                continue
            name = parts[0]
            depth = 0
        else:
            indent = m.group("indent") or ""
            depth = len(indent) // 4
            name = m.group("name").strip()

        while stack and stack[-1][0] >= depth:
            stack.pop()
        path = [p[1] for p in stack] + [name]
        paths.append(tuple(path))
        stack.append((depth, name))
    return paths


def collect_paths(roots):
    paths = []

    def walk(n, path):
        cur = path + [n.name]
        paths.append(tuple(cur))
        for c in n.children:
            walk(c, cur)

    for r in roots:
        walk(r, [])
    return paths


def print_tree(roots, show_heights, show_empty):
    def recur(node, prefix, is_last):
        connector = "└── " if is_last else "├── "
        label = node.name
        extra = []
        if show_heights:
            extra.append(f"h={node.height:.1f}")
        if show_empty and node.empty_subblock:
            extra.append("empty")
        if extra:
            label = f"{label} ({', '.join(extra)})"
        print(prefix + connector + label)
        new_prefix = prefix + ("    " if is_last else "│   ")
        children = node.children
        for i, child in enumerate(children):
            recur(child, new_prefix, i == len(children) - 1)

    for i, root in enumerate(roots):
        # Root line
        label = root.name
        extra = []
        if show_heights:
            extra.append(f"h={root.height:.1f}")
        if show_empty and root.empty_subblock:
            extra.append("empty")
        if extra:
            label = f"{label} ({', '.join(extra)})"
        print(label)
        children = root.children
        for j, child in enumerate(children):
            recur(child, "", j == len(children) - 1)


def main():
    parser = argparse.ArgumentParser(description="Print time divisions tree with computed heights.")
    parser.add_argument("--yaml", default="data/time_divisions.yaml")
    parser.add_argument("--md", default="docs/time_divisions_tree.md")
    parser.add_argument("--min-age-height", type=float, default=16.0)
    parser.add_argument("--line-height", type=float, default=16.0)
    parser.add_argument("--padding", type=float, default=4.0)
    parser.add_argument("--char-width", type=float, default=7.2)
    parser.add_argument("--check-md", action="store_true")
    parser.add_argument("--show-heights", action="store_true")
    parser.add_argument("--show-empty", action="store_true")
    args = parser.parse_args()

    roots = build_tree(args.yaml)
    vertical_ranks = {"eon", "era", "period"}
    for r in roots:
        compute_height(
            r,
            args.min_age_height,
            args.line_height,
            args.padding,
            args.char_width,
            vertical_ranks,
        )
    cur = 0.0
    for r in roots:
        assign_y(r, cur)
        cur += r.height

    if args.check_md:
        md_paths = set(parse_md_tree(args.md))
        yaml_paths = set(collect_paths(roots))
        only_yaml = sorted(yaml_paths - md_paths)
        only_md = sorted(md_paths - yaml_paths)
        print("Structure check:")
        print(f"  yaml nodes: {len(yaml_paths)}")
        print(f"  md nodes:   {len(md_paths)}")
        print(f"  only in yaml: {len(only_yaml)}")
        print(f"  only in md:   {len(only_md)}")
        if only_yaml[:5]:
            print("  sample only in yaml:")
            for p in only_yaml[:5]:
                print("    -", " > ".join(p))
        if only_md[:5]:
            print("  sample only in md:")
            for p in only_md[:5]:
                print("    -", " > ".join(p))
        print("")

    print_tree(roots, show_heights=args.show_heights, show_empty=args.show_empty)

if __name__ == "__main__":
    main()
