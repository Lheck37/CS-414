# Assignment 03 – Simple Shell Parser

Tiny hand-built tokenizer + recursive-descent parser for a simple shell.

Commands
- `ls [path]`
- `cd [path]` (no arg = root)
- `cat filename`
- `print filename`
- `exec filename`

Rules
- Folder names: 1–8 letters, `/` separates segments, `/` alone is root.
- Filenames: DOS 8.3 → 1–8 letters, dot, 3 letters.

What’s here
- `shell_parser.py` — EBNF at the top as comments; tokenizer + parser; returns small dict ASTs.

Quick test
```bash
python3 shell_parser.py

