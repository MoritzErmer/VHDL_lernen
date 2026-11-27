#!/usr/bin/env python3
"""Helpers for the release workflows (see .github/workflows/release.yml and content.yml).

  stamp_content.py IN OUT [--revision N] [--app-code C --app-name V --app-url URL] [--app-from OLD.json]
      Copies the content JSON and sets the publication revision and/or the newest app release.
  stamp_content.py --same-version OLD NEW
      Exit 0 if both files contain the same lesson version (nothing to publish), else 1.
"""
import json
import sys


def arg(name, default=None):
    return sys.argv[sys.argv.index(name) + 1] if name in sys.argv else default


def load(path):
    try:
        with open(path, encoding="utf-8") as fh:
            return json.load(fh)
    except (OSError, ValueError):
        return None


def main():
    if sys.argv[1] == "--same-version":
        old, new = load(sys.argv[2]), load(sys.argv[3])
        sys.exit(0 if old and new and old.get("version") == new.get("version") else 1)

    data = load(sys.argv[1])
    if data is None:
        sys.exit(f"{sys.argv[1]} fehlt oder ist kein JSON")
    if arg("--revision"):
        data["revision"] = int(arg("--revision"))
    if arg("--app-code"):
        url = arg("--app-url")
        if not url.startswith("https://github.com/"):
            sys.exit("--app-url muss auf github.com zeigen")
        data["app"] = {"versionCode": int(arg("--app-code")), "versionName": arg("--app-name"), "url": url}
    if arg("--app-from"):
        old = load(arg("--app-from"))
        if old and "app" in old:
            data["app"] = old["app"]
    with open(sys.argv[2], "w", encoding="utf-8") as fh:
        json.dump(data, fh, ensure_ascii=False, separators=(",", ":"))


if __name__ == "__main__":
    main()
