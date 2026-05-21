#!/usr/bin/env python3
from pathlib import Path
import sys

def resolve_theirs(text: str) -> str:
    lines = text.splitlines(keepends=True)
    out = []
    i = 0

    while i < len(lines):
        line = lines[i]

        if line.startswith("<<<<<<< "):
            i += 1

            # skip ours until =======
            while i < len(lines) and not lines[i].startswith("======="):
                i += 1

            if i >= len(lines):
                raise ValueError("Malformed conflict: missing =======")

            i += 1  # skip =======

            # keep theirs until >>>>>>>
            theirs = []
            while i < len(lines) and not lines[i].startswith(">>>>>>> "):
                theirs.append(lines[i])
                i += 1

            if i >= len(lines):
                raise ValueError("Malformed conflict: missing >>>>>>>")

            i += 1  # skip >>>>>>>
            out.extend(theirs)
        else:
            out.append(line)
            i += 1

    return "".join(out)

def main(paths):
    for p in paths:
        path = Path(p)
        if not path.is_file():
            continue

        text = path.read_text(errors="surrogateescape")

        if "<<<<<<< " not in text or "=======" not in text or ">>>>>>> " not in text:
            continue

        resolved = resolve_theirs(text)

        path.write_text(resolved, errors="surrogateescape")

        print(f"resolved theirs: {path}")

if __name__ == "__main__":
    main(sys.argv[1:])
