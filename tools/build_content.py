#!/usr/bin/env python3
"""Converts the lessons of both courses into content/haeppchen.json for the Android app.

Courses: VHDL (this repository) and Rechnerarchitektur (MoritzErmer/Rechnerarchtektur_Lernen, cloned next to
it or passed with --ra PATH / RA_REPO). Block names and lesson order come from the tables in each README.md
(same convention as the website build in the Rechnerarchitektur repository).

The app renders this JSON natively (no HTML/WebView), so downloaded content can
never execute code. Supported markdown subset: paragraphs, fenced code blocks,
tables, bullet/numbered lists and inline **bold**, `code`, [links](...).

Usage (repo root):  python3 tools/build_content.py [--ra PATH] [--revision N]
                    python3 tools/build_content.py --check   -> exit 1 if the file is outdated
"""
import glob
import hashlib
import json
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(ROOT, "content", "haeppchen.json")
SCHEMA = 1
COURSES = [
    # id, name, exam, code language, default location relative to this repository
    ("vhdl", "VHDL", "Entwurf digitaler Systeme", "vhdl", "."),
    ("ra", "Rechnerarchitektur", "Rechnerarchitektur und Rechnerorganisation", "ikr",
     "../moritzermer/rechnerarchtektur_lernen"),
]
EMOJI = re.compile("[\U0001F000-\U0001FAFF\u2600-\u27BF\u2B00-\u2BFF\u23E9-\u23FA\uFE0F\u200D]")
ID_RE = re.compile(r"^[A-Z]\d\d$")


def clean(md: str) -> str:
    md = md.replace("\U0001F9E0", "Knobelfrage:")  # brain emoji in the Rechnerarchitektur lessons
    md = re.sub(r"\[([^\]]+)\]\(([A-Z]\d\d)_[^)]*\.md\)", r"[\1](#\2)", md)
    md = re.sub(r"\[([^\]]+)\]\(\.\./README\.md\)", r"\1", md)
    md = md.replace("Am Rechner:", "Am Rechner (Repo-Ordner):")
    md = EMOJI.sub("", md)
    return md.strip()


def table_row(line: str) -> list:
    return [c.strip() for c in line.strip().strip("|").split("|")]


def to_nodes(md: str) -> list:
    """Very small block-level markdown parser for the subset used in the lessons."""
    lines = clean(md).split("\n")
    nodes, para, lst = [], [], None
    i = 0

    def flush_para():
        nonlocal para
        if para:
            nodes.append({"t": "p", "s": " ".join(s.strip() for s in para)})
            para = []

    def flush_list():
        nonlocal lst
        if lst:
            nodes.append(lst)
            lst = None

    while i < len(lines):
        line = lines[i]
        stripped = line.strip()
        fence = re.match(r"^(\s*)```(\w*)\s*$", line)
        if fence:
            flush_para(); flush_list()
            indent, lang = len(fence.group(1)), fence.group(2)
            code = []
            i += 1
            while i < len(lines) and not lines[i].strip().startswith("```"):
                code.append(lines[i][indent:] if lines[i][:indent].strip() == "" else lines[i])
                i += 1
            nodes.append({"t": "code", "lang": lang or "", "s": "\n".join(code)})
            i += 1
            continue
        if stripped.startswith("|") and i + 1 < len(lines) and re.match(r"^\s*\|[\s:|-]+\|\s*$", lines[i + 1]):
            flush_para(); flush_list()
            rows = [table_row(line)]
            i += 2
            while i < len(lines) and lines[i].strip().startswith("|"):
                rows.append(table_row(lines[i]))
                i += 1
            nodes.append({"t": "table", "rows": rows})
            continue
        bullet = re.match(r"^- (.*)$", line)
        number = re.match(r"^(\d+)\. (.*)$", line)
        if bullet or number:
            flush_para()
            kind = "ul" if bullet else "ol"
            if not lst or lst["t"] != kind:
                flush_list()
                lst = {"t": kind, "items": []}
            lst["items"].append((bullet or number).group(bullet and 1 or 2))
            i += 1
            continue
        if lst and line.startswith("  ") and stripped:
            lst["items"][-1] += " " + stripped     # continuation of a list item
            i += 1
            continue
        if not stripped:
            flush_para(); flush_list()
            i += 1
            continue
        flush_list()
        para.append(line)
        i += 1
    flush_para(); flush_list()
    return nodes


def code_blocks(md: str, lang: str) -> list:
    return [b.strip("\n") for b in re.findall(r"```" + lang + r"\n(.*?)```", md, re.S)]


def readme_blocks(root: str) -> list:
    """[(block id, name, [lesson files in order])] from the README tables."""
    blocks, current = [], None
    for line in open(os.path.join(root, "README.md"), encoding="utf-8"):
        h = re.match(r"^## .*?Block ([A-Z]) [–-] (.+?)\s*$", line)
        if h:
            current = (h.group(1), EMOJI.sub("", h.group(2)).strip(), [])
            blocks.append(current)
            continue
        row = re.match(r"^\|\s*([A-Z]\d\d)\s*\|\s*\[[^\]]*\]\((haeppchen/[^)]+\.md)\)", line)
        if row and current and row.group(1)[0] == current[0]:
            current[2].append(os.path.join(root, row.group(2)))
    return [b for b in blocks if b[2]]


def parse(path: str, lang: str) -> dict:
    text = open(path, encoding="utf-8").read()
    lines = text.splitlines()
    m = re.match(r"# ([A-Z]\d\d) · (.+)", lines[0])
    hid, title = m.group(1), EMOJI.sub("", m.group(2)).strip()
    minutes = int(re.search(r"(\d+) min", lines[2]).group(1))
    sections, current = {}, None
    for line in lines[3:]:
        if line.startswith("## "):
            head = line[3:]
            current = next((k for k in ("Ziel", "Erklärung", "Aufgabe", "Klausur") if k in head), head)
            sections[current] = []
        elif current:
            sections[current].append(line)
    sec = {k: "\n".join(v).strip() for k, v in sections.items()}
    aufgabe = sec.get("Aufgabe", "")
    det = re.search(r"<details><summary>.*?</summary>(.*?)</details>", aufgabe, re.S)
    loesung = det.group(1).strip() if det else ""
    aufgabe_md = re.sub(r"<details>.*?</details>", "", aufgabe, flags=re.S).strip()
    sol_code = code_blocks(loesung, lang)
    starter = next((c for c in code_blocks(aufgabe_md, lang)
                    if "???" in c or c.lstrip().startswith((".reg", ".mem"))), "")
    if not ID_RE.match(hid) or not loesung:
        raise SystemExit(f"{path}: ID oder Lösung fehlt")
    return {
        "id": hid,
        "block": hid[0],
        "title": title,
        "min": minutes,
        "mode": "code" if sol_code else "text",
        "starter": starter,
        "solutionCode": "\n\n".join(sol_code),
        "ziel": to_nodes(sec.get("Ziel", "")),
        "erklaerung": to_nodes(sec.get("Erklärung", "")),
        "aufgabe": to_nodes(aufgabe_md),
        "aufgabeMd": clean(aufgabe_md),
        "loesung": to_nodes(loesung),
        "loesungMd": clean(loesung),
        "klausur": to_nodes(sec.get("Klausur", "")),
    }


def build(ra_path: str, revision: int) -> str:
    courses = []
    for cid, name, exam, lang, default in COURSES:
        root = ROOT if default == "." else (ra_path or os.path.normpath(os.path.join(ROOT, default)))
        if not os.path.exists(os.path.join(root, "README.md")):
            print(f"Hinweis: Fach '{name}' übersprungen, Repo nicht gefunden unter {root}", file=sys.stderr)
            continue
        blocks = readme_blocks(root)
        items = [parse(f, lang) for _, _, files in blocks for f in files]
        courses.append({
            "id": cid, "name": name, "exam": exam, "lang": lang,
            "blocks": [{"id": b, "name": n} for b, n, _ in blocks],
            "items": items,
        })
    digest = hashlib.sha256(json.dumps(courses, ensure_ascii=False, sort_keys=True).encode()).hexdigest()[:12]
    data = {"schema": SCHEMA, "version": digest, "revision": revision, "courses": courses}
    return json.dumps(data, ensure_ascii=False, indent=1) + "\n"


def arg(name: str, default=None):
    return sys.argv[sys.argv.index(name) + 1] if name in sys.argv else default


def main():
    text = build(arg("--ra", os.environ.get("RA_REPO")), int(arg("--revision", "0")))
    out = arg("--out", OUT)
    if "--check" in sys.argv:
        current = open(out, encoding="utf-8").read() if os.path.exists(out) else ""
        if current != text:
            print("content/haeppchen.json ist veraltet: python3 tools/build_content.py ausführen")
            sys.exit(1)
        print("content/haeppchen.json ist aktuell")
        return
    os.makedirs(os.path.dirname(out), exist_ok=True)
    with open(out, "w", encoding="utf-8") as fh:
        fh.write(text)
    data = json.loads(text)
    summary = ", ".join(f"{c['name']}: {len(c['items'])}" for c in data["courses"])
    print(f"{summary} Häppchen -> {os.path.relpath(out, ROOT)} ({len(text.encode()) // 1024} KB)")


if __name__ == "__main__":
    main()
