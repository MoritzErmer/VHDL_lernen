"""Gate-level schematics with symbols after DIN EN 60617 (rectangular symbols).

A schematic is a JSON file (diagrams/src/*.sch) with explicitly placed parts and orthogonal wires:

{
  "inputs":  {"a": [40, 40]},                    # pin position; label left of it
  "outputs": {"y": [300, 50]},                   # pin position; label right of it
  "parts": {
    "g1": {"type": "and", "x": 100, "y": 20, "n": 2},      # and, or, xor, nand, nor, xnor, not, buf
    "ff": {"type": "dff", "x": 200, "y": 20},              # pins d, c, r (low active), q
    "m":  {"type": "block", "x": 80, "y": 10, "title": "halbaddierer",
           "in": ["a", "b"], "out": ["s", "c"], "w": 90}   # module with named ports
  },
  "wires": [
    ["a", "g1.i0"],                                        # input pin to gate input 0
    ["g1.o", "y", {"label": "h", "mx": 180, "dot": [180, 50], "hl": true, "via": [[x, y], ...]}]
  ],
  "notes": [[x, y, "text"]]
}
Gate pins: i0..i(n-1) on the left, o on the right. Wires run horizontal - vertical (at mx) - horizontal,
or through the given via points. "hl" draws the wire in the accent colour, "dot" adds a junction dot.
"""

SYM = {"and": "&", "nand": "&", "or": "≥1", "nor": "≥1", "xor": "=1", "xnor": "=1", "not": "1", "buf": "1"}
INV = {"nand", "nor", "xnor", "not"}
STUB = 10


def build(spec):
    prims, pins = [], {}

    def line(pts, role="line", w=1.4):
        prims.append({"k": "L", "pts": [v for p in pts for v in p], "s": role, "w": w})

    def text(x, y, s, a="c", z=13, c="ink", m=False):
        prims.append({"k": "T", "x": x, "y": y, "s": s, "a": a, "z": z, "c": c, "m": m})

    def box(x, y, w, h):
        prims.append({"k": "P", "pts": [x, y, x + w, y, x + w, y + h, x, y + h], "s": "ink", "f": "surface", "w": 1.6})

    def bubble(cx, cy):
        prims.append({"k": "E", "x": cx, "y": cy, "rx": 4, "ry": 4, "s": "ink", "f": "surface"})

    for name, part in spec.get("parts", {}).items():
        t, x, y = part["type"], part["x"], part["y"]
        if t in SYM:
            n = 1 if t in ("not", "buf") else part.get("n", 2)
            w, h = 40, 20 * (n + 1)
            box(x, y, w, h)
            text(x + w / 2, y + 19, SYM[t], z=15)
            for k in range(n):
                py = y + 20 * (k + 1) if n > 1 else y + h / 2
                line([(x - STUB, py), (x, py)])
                pins[f"{name}.i{k}"] = (x - STUB, py)
            oy = y + h / 2
            if t in INV:
                bubble(x + w + 4, oy)
                line([(x + w + 8, oy), (x + w + STUB + 4, oy)])
                pins[f"{name}.o"] = (x + w + STUB + 4, oy)
            else:
                line([(x + w, oy), (x + w + STUB, oy)])
                pins[f"{name}.o"] = (x + w + STUB, oy)
            if part.get("label"):
                text(x + w / 2, y - 5, part["label"], z=10, c="line")
        elif t == "dff":
            w, h = 50, 80
            box(x, y, w, h)
            for key, py, lab in (("d", y + 20, "1D"), ("c", y + 40, "C1"), ("r", y + 60, "R")):
                text(x + 6 + (6 if key == "c" else 0), py + 4, lab, a="l", z=12)
                if key == "r":
                    bubble(x - 4, py)
                    line([(x - 8, py), (x - STUB - 4, py)])
                    pins[f"{name}.r"] = (x - STUB - 4, py)
                else:
                    line([(x - STUB, py), (x, py)])
                    pins[f"{name}.{key}"] = (x - STUB, py)
            # dynamic (edge-triggered) clock input
            prims.append({"k": "L", "pts": [x, y + 34, x + 8, y + 40, x, y + 46], "s": "ink", "w": 1.4})
            line([(x + w, y + 20), (x + w + STUB, y + 20)])
            pins[f"{name}.q"] = (x + w + STUB, y + 20)
            if part.get("label"):
                text(x + w / 2, y - 5, part["label"], z=10, c="line", m=True)
        elif t == "block":
            ins, outs = part.get("in", []), part.get("out", [])
            w = part.get("w", 90)
            h = 20 * (max(len(ins), len(outs)) + 1) + 14
            box(x, y, w, h)
            text(x + w / 2, y + 16, part["title"], z=12, m=True, c="accent")
            if part.get("label"):
                text(x + w / 2, y - 5, part["label"], z=10, c="line", m=True)
            for k, p in enumerate(ins):
                py = y + 14 + 20 * (k + 1)
                line([(x - STUB, py), (x, py)])
                text(x + 5, py + 4, p, a="l", z=11, m=True)
                pins[f"{name}.{p}"] = (x - STUB, py)
            for k, p in enumerate(outs):
                py = y + 14 + 20 * (k + 1)
                line([(x + w, py), (x + w + STUB, py)])
                text(x + w - 5, py + 4, p, a="r", z=11, m=True)
                pins[f"{name}.{p}"] = (x + w + STUB, py)
        else:
            raise SystemExit(f"Unbekannter Bauteiltyp {t}")

    for name, (x, y) in spec.get("inputs", {}).items():
        pins[name] = (x, y)
        text(x - 5, y + 4, name, a="r", m=True)
    for name, (x, y) in spec.get("outputs", {}).items():
        pins[name] = (x, y)
        text(x + 5, y + 4, name, a="l", m=True)

    for wire in spec.get("wires", []):
        src, dst = pins[wire[0]], pins[wire[1]]
        opt = wire[2] if len(wire) > 2 else {}
        role = "accent" if opt.get("hl") else "line"
        if "via" in opt:
            pts = [src] + [tuple(p) for p in opt["via"]] + [dst]
        elif src[1] == dst[1]:
            pts = [src, dst]
        else:
            mx = opt.get("mx", (src[0] + dst[0]) / 2)
            pts = [src, (mx, src[1]), (mx, dst[1]), dst]
        line(pts, role, 2 if opt.get("hl") else 1.4)
        if "dot" in opt:
            prims.append({"k": "E", "x": opt["dot"][0], "y": opt["dot"][1], "rx": 3, "ry": 3, "s": role, "f": role})
        if "label" in opt:
            lx = opt.get("lx", (pts[0][0] + pts[1][0]) / 2)
            ly = opt.get("ly", pts[0][1] - 5)
            text(lx, ly, opt["label"], z=11, c="accent" if opt.get("hl") else "line", m=True)

    for x, y, s in spec.get("notes", []):
        text(x, y, s, a="l", z=11, c="line")

    xs = [v for p in prims for v in (p["pts"][0::2] if "pts" in p else [p["x"]])]
    ys = [v for p in prims for v in (p["pts"][1::2] if "pts" in p else [p["y"]])]
    # text extends left/right of its anchor: generous margins
    minx, maxx, miny, maxy = min(xs) - 60, max(xs) + 60, min(ys) - 16, max(ys) + 12
    for p in prims:
        if "pts" in p:
            p["pts"] = [round(v - minx if i % 2 == 0 else v - miny, 1) for i, v in enumerate(p["pts"])]
        else:
            p["x"], p["y"] = round(p["x"] - minx, 1), round(p["y"] - miny, 1)
    return {"w": round(maxx - minx, 1), "h": round(maxy - miny, 1), "prims": prims}
