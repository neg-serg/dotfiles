
#!/usr/bin/env python3
import re, sys
from pathlib import Path

ARRAY = "FAST_HIGHLIGHT_STYLES"

# Patterns
# : ${FAST_HIGHLIGHT_STYLES[key]:=value}
default_re = re.compile(r"""^\s*:\s*\$\{\s*%s\s*\[\s*([^\]]+?)\s*\]\s*:?=\s*(.*?)\s*\}\s*$""" % ARRAY)
# _setstyle key 'value'
setstyle_re = re.compile(r"""^\s*_setstyle\s+(.+?)\s+(.+?)\s*$""")
# FAST_HIGHLIGHT_STYLES[key]=value
assign_re = re.compile(r"""^\s*%s\s*\[\s*([^\]]+)\s*\]\s*=\s*(.+?)\s*$""" % ARRAY)
# typeset block
array_start_re = re.compile(r"""^\s*typeset\s+-gA\s+%s\s*=\s*\(\s*$""" % ARRAY)
literal_entry_re = re.compile(r"""\[\s*([^\]]+?)\s*\]\s*=\s*(.+)""")

theme_name_line_re = re.compile(r"""^\s*typeset\s+-g\s+FAST_THEME_NAME=.*$""")
zstyle_theme_re = re.compile(r"""^\s*zstyle\s+:plugin:fast-syntax-highlighting\s+theme\b""")

def strip_q(s: str) -> str:
    s = s.strip()
    if (s.startswith("'") and s.endswith("'")) or (s.startswith('"') and s.endswith('"')):
        return s[1:-1]
    return s

def cut_comment(s: str) -> str:
    out = []
    in_q = False
    q = ''
    i = 0
    while i < len(s):
        ch = s[i]
        if ch in ("'", '"'):
            if not in_q:
                in_q = True; q = ch
            elif q == ch:
                in_q = False; q = ''
            out.append(ch); i += 1; continue
        if ch == '#' and not in_q:
            break
        out.append(ch); i += 1
    return ''.join(out).strip()

def parse_literal_block(lines, start):
    d = {}
    i = start + 1
    while i < len(lines):
        line = lines[i]
        if line.strip() == ')':
            return i, d
        m = literal_entry_re.search(line)
        if m:
            key = strip_q(m.group(1))
            val = strip_q(cut_comment(m.group(2)))
            d[key] = val
        i += 1
    raise RuntimeError(f"Unterminated array starting at line {start+1}")

def format_literal(d: dict) -> str:
    def key_sort(k): return (0 if "file-extensions-" not in k else 1, k)
    out = [f"typeset -gA {ARRAY}=("]
    for k in sorted(d.keys(), key=key_sort):
        v = d[k]
        v_fmt = v if v == 'none' or (v.startswith("'") and v.endswith("'")) or (v.startswith('"') and v.endswith('"')) else "'" + v.replace("'", r"'\''") + "'"
        out.append(f"  [{k}]={v_fmt}")
    out.append(")")
    return "\n".join(out)

def transform_file(path: Path, write: bool):
    text = path.read_text(encoding="utf-8", errors="ignore")
    lines = text.splitlines()

    # Collect existing literal
    existing = {}
    i = 0
    literal_ranges = []
    while i < len(lines):
        if array_start_re.match(lines[i]):
            end, entries = parse_literal_block(lines, i)
            existing.update(entries)
            literal_ranges.append((i, end))
            i = end + 1
            continue
        i += 1

    collected = {}
    keep = []
    # Track where to insert: after theme/zstyle lines if present
    insert_after = -1

    for idx, line in enumerate(lines):
        if theme_name_line_re.match(line) or zstyle_theme_re.match(line):
            insert_after = idx
        # Skip lines from old literal(s)
        in_literal = False
        for s,e in literal_ranges:
            if s <= idx <= e:
                in_literal = True
                break
        if in_literal:
            continue

        m = default_re.match(line)
        if m:
            key = strip_q(cut_comment(m.group(1)))
            val = strip_q(cut_comment(m.group(2)))
            collected[key] = val
            continue
        m2 = setstyle_re.match(line)
        if m2:
            key = strip_q(cut_comment(m2.group(1)))
            val = strip_q(cut_comment(m2.group(2)))
            collected[key] = val
            continue
        m3 = assign_re.match(line)
        if m3:
            key = strip_q(cut_comment(m3.group(1)))
            val = strip_q(cut_comment(m3.group(2)))
            collected[key] = val
            continue
        keep.append(line)

    merged = {**existing, **collected}
    if not merged:
        print("Nothing to do: no styles found.", file=sys.stderr)
        return False

    block = format_literal(merged)

    # Decide insert index
    if insert_after >= 0:
        insert_idx = min(insert_after + 1, len(keep))
    else:
        # After initial comments/blank lines
        insert_idx = 0
        while insert_idx < len(keep) and (keep[insert_idx].strip().startswith("#") or keep[insert_idx].strip()=="" or keep[insert_idx].strip().startswith("#!")):
            insert_idx += 1

    out_lines = keep[:insert_idx] + [block] + keep[insert_idx:]

    output_text = "\n".join(out_lines) + ("\n" if out_lines and not out_lines[-1].endswith("\n") else "")
    if write:
        bak = path.with_suffix(path.suffix + ".bak")
        if not bak.exists():
            bak.write_text(text, encoding="utf-8")
        path.write_text(output_text, encoding="utf-8")
        print(f"Wrote updated file: {path}")
        print(f"Backup saved as:    {bak}")
    else:
        sys.stdout.write(output_text)
    return True

def main():
    if len(sys.argv) < 2:
        print("Usage: fsyh_theme_defaults_compactor.py /path/to/current_theme.zsh [--write]", file=sys.stderr)
        sys.exit(2)
    write = False
    paths = []
    for arg in sys.argv[1:]:
        if arg == "--write":
            write = True
        else:
            paths.append(Path(arg).expanduser())
    ok_any = False
    for p in paths:
        if not p.exists():
            print(f"Error: not found: {p}", file=sys.stderr)
            continue
        ok_any = transform_file(p, write) or ok_any
    if not ok_any:
        sys.exit(1)

if __name__ == "__main__":
    main()
