#!/usr/bin/env python3
"""Builds the lesson diagrams from diagrams/src/ into diagrams/<name>.json and diagrams/<name>.svg.

Sources:
  *.dot   Graphviz (state and block diagrams). Colours are roles, written as sentinel values:
          #000001 ink (text, outlines), #000002 line (edges), #000003 accent, #000004 accent area,
          white = surface. The layout comes from `dot -Tjson`.
  *.wave  Timing diagrams: one signal per line, "name: wave", wave characters
          0 / 1 = level, x = unknown, . = repeat previous, | = gap is not used. Lines starting
          with "#" are comments, "@title" sets nothing (kept for readability).

Output:
  <name>.json  primitives for the app (drawn natively with the theme palette, so light/dark work)
  <name>.svg   the same drawing for GitHub (follows the viewer's light/dark preference)

Usage (repo root): python3 tools/build_diagrams.py   (needs Graphviz `dot`)
"""
import glob
import json
import os
import subprocess
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import schematic  # noqa: E402  (gate-level schematics, DIN EN 60617)

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SRC = os.path.join(ROOT, "diagrams", "src")
OUT = os.path.join(ROOT, "diagrams")
PAD = 6

ROLE = {"#000001": "ink", "#000002": "line", "#000003": "accent", "#000004": "soft",
        "#ffffff": "surface", "white": "surface", "#fffffe": "surface"}


def role(color, fill=False):
    """Maps a Graphviz colour to a palette role. Unknown or transparent fills draw nothing."""
    if not color or color in ("transparent", "none") or (len(color) == 9 and color.endswith("00")):
        return None
    return ROLE.get(color.lower()[:7], None if fill else "ink")


# ---------------------------------------------------------------- Graphviz

def from_dot(path):
    data = json.loads(subprocess.run(["dot", "-Tjson", path], check=True, capture_output=True, text=True).stdout)
    x0, y0, x1, y1 = (float(v) for v in data["bb"].split(","))
    w, h = x1 - x0, y1 - y0
    prims = []

    def X(x): return round(x - x0 + PAD, 1)
    def Y(y): return round(h - (y - y0) + PAD, 1)

    def flat(points): return [c for p in points for c in (X(p[0]), Y(p[1]))]

    def run(ops):
        pen, fill, size, dashed = "ink", None, 14.0, None
        for op in ops:
            o = op["op"]
            if o == "S": dashed = 1 if op.get("style") == "dashed" else None
            elif o == "c": pen = role(op.get("color"))
            elif o == "C": fill = role(op.get("color"), fill=True)
            elif o == "F": size = float(op["size"])
            elif o in ("e", "E"):
                cx, cy, rx, ry = op["rect"]
                prims.append({"k": "E", "x": X(cx), "y": Y(cy), "rx": round(rx, 1), "ry": round(ry, 1),
                              "s": pen, "f": fill if o == "E" else None})
            elif o in ("p", "P"):
                prims.append({"k": "P", "pts": flat(op["points"]), "s": pen, "f": fill if o == "P" else None})
            elif o == "L":
                prims.append({"k": "L", "pts": flat(op["points"]), "s": pen})
            elif o in ("b", "B"):
                prims.append({"k": "B", "pts": flat(op["points"]), "s": pen, "d": dashed})
            elif o == "T":
                prims.append({"k": "T", "x": X(op["pt"][0]), "y": Y(op["pt"][1]), "s": op["text"],
                              "a": op.get("align", "c"), "z": round(size, 1), "c": pen})

    # The graph's own _draw_ is only the background rectangle: skipped, the app/SVG paint the surface.
    run(data.get("_ldraw_", []))
    for obj in data.get("objects", []):          # clusters first in the list, then nodes
        for key in ("_draw_", "_ldraw_"):
            run(obj.get(key, []))
    for edge in data.get("edges", []):
        for key in ("_draw_", "_hdraw_", "_tdraw_", "_ldraw_", "_hldraw_", "_tldraw_"):
            run(edge.get(key, []))
    return {"w": round(w + 2 * PAD, 1), "h": round(h + 2 * PAD, 1), "prims": [clean(p) for p in prims]}


# ---------------------------------------------------------------- timing diagrams

def from_wave(path):
    rows = []
    for line in open(path, encoding="utf-8"):
        line = line.rstrip("\n")
        if not line.strip() or line.lstrip().startswith(("#", "@")):
            continue
        name, wave = line.split(":", 1)
        rows.append((name.strip(), wave.strip().replace(" ", "")))
    steps = max(len(w) for _, w in rows)
    name_w, row_h, hi, lo = 78, 40, 8, 30
    step_w = 30 if steps <= 14 else 22
    prims = []
    width = name_w + steps * step_w + PAD
    height = len(rows) * row_h + 8
    # grid lines at every step (where clock edges sit)
    for i in range(steps + 1):
        x = name_w + i * step_w
        prims.append({"k": "L", "pts": [x, 4, x, height - 8], "s": "grid"})
    for r, (name, wave) in enumerate(rows):
        top = r * row_h + 4
        prims.append({"k": "T", "x": 4, "y": top + 23, "s": name, "a": "l", "z": 13, "c": "ink", "m": True})
        level = None
        pts = []
        for i, ch in enumerate(wave):
            if ch == ".":
                ch = level
            x0, x1 = name_w + i * step_w, name_w + (i + 1) * step_w
            if ch == "x":
                prims.append({"k": "P", "pts": [x0, top + hi, x1, top + hi, x1, top + lo, x0, top + lo],
                              "s": "line", "f": "soft"})
                if pts:
                    prims.append({"k": "L", "pts": pts, "s": "accent", "w": 2})
                pts, level = [], "x"
                continue
            y = top + (hi if ch == "1" else lo)
            if pts and level != ch:
                pts += [x0, y]                    # vertical edge
            elif not pts:
                pts = [x0, y]
            pts += [x1, y]
            level = ch
        if pts:
            prims.append({"k": "L", "pts": pts, "s": "accent", "w": 2})
    return {"w": width, "h": height, "prims": [clean(p) for p in prims]}


def clean(p):
    return {k: v for k, v in p.items() if v is not None}


# ---------------------------------------------------------------- SVG

LIGHT = {"ink": "#151A22", "line": "#5A6474", "accent": "#1F45C4", "soft": "#E3E9FB", "surface": "#FFFFFF",
         "grid": "#D9DEE7"}
DARK = {"ink": "#E5E9F0", "line": "#97A1B0", "accent": "#8CA6FF", "soft": "#1E2848", "surface": "#161A21",
        "grid": "#283040"}


def svg(d, title):
    css = "".join(f".s-{k}{{stroke:{v}}}.f-{k}{{fill:{v}}}" for k, v in LIGHT.items())
    css_dark = "".join(f".s-{k}{{stroke:{v}}}.f-{k}{{fill:{v}}}" for k, v in DARK.items())
    out = [f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {d["w"]} {d["h"]}" width="{d["w"]}" '
           f'height="{d["h"]}" role="img" aria-label="{esc(title)}">',
           f"<style>{css}@media (prefers-color-scheme: dark){{{css_dark}}}"
           "text{font-family:Helvetica,Arial,sans-serif}.m{font-family:Menlo,Consolas,monospace}</style>",
           f'<rect width="100%" height="100%" class="f-surface"/>']
    for p in d["prims"]:
        sw = p.get("w", 1.4)
        cls = (f's-{p["s"]}' if p.get("s") else "") + (f' f-{p["f"]}' if p.get("f") else "")
        stroke = f' class="{cls}"' + ("" if p.get("f") else ' fill="none"')
        if p["k"] == "E":
            out.append(f'<ellipse cx="{p["x"]}" cy="{p["y"]}" rx="{p["rx"]}" ry="{p["ry"]}" stroke-width="{sw}"{stroke}/>')
        elif p["k"] == "P":
            out.append(f'<polygon points="{pts(p["pts"])}" stroke-width="{sw}"{stroke}/>')
        elif p["k"] == "L":
            out.append(f'<polyline points="{pts(p["pts"])}" stroke-width="{sw}" class="s-{p["s"]}" fill="none"/>')
        elif p["k"] == "B":
            c = p["pts"]
            path = f"M{c[0]},{c[1]}" + "".join(f" C{c[i]},{c[i+1]} {c[i+2]},{c[i+3]} {c[i+4]},{c[i+5]}"
                                               for i in range(2, len(c) - 5, 6))
            dash = ' stroke-dasharray="5,4"' if p.get("d") else ""
            out.append(f'<path d="{path}" stroke-width="{sw}" class="s-{p["s"]}" fill="none"{dash}/>')
        elif p["k"] == "T":
            anchor = {"c": "middle", "l": "start", "r": "end"}[p["a"]]
            mono = " m" if p.get("m") else ""
            out.append(f'<text x="{p["x"]}" y="{p["y"]}" font-size="{p["z"]}" text-anchor="{anchor}" '
                       f'class="f-{p["c"]}{mono}">{esc(p["s"])}</text>')
    out.append("</svg>")
    return "\n".join(out) + "\n"


def pts(c):
    return " ".join(f"{c[i]},{c[i+1]}" for i in range(0, len(c), 2))


def esc(s):
    return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace('"', "&quot;")


def main():
    names = []
    for path in sorted(glob.glob(os.path.join(SRC, "*.dot")) + glob.glob(os.path.join(SRC, "*.wave"))
                       + glob.glob(os.path.join(SRC, "*.sch"))):
        name = os.path.splitext(os.path.basename(path))[0]
        if path.endswith(".dot"):
            d = from_dot(path)
        elif path.endswith(".wave"):
            d = from_wave(path)
        else:
            with open(path, encoding="utf-8") as fh:
                d = schematic.build(json.load(fh))
            d["prims"] = [clean(p) for p in d["prims"]]
        with open(os.path.join(OUT, name + ".json"), "w", encoding="utf-8") as fh:
            json.dump(d, fh, ensure_ascii=False, separators=(",", ":"))
        with open(os.path.join(OUT, name + ".svg"), "w", encoding="utf-8") as fh:
            fh.write(svg(d, name))
        names.append(name)
    print(f"{len(names)} Diagramme: {', '.join(names)}")


if __name__ == "__main__":
    main()
