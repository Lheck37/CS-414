#!/usr/bin/env bash
python3 - <<'PY'
from Assignment04.shell_parser_vars import tokenize, Parser, _pretty_symtab
symtab = {}
for raw in open('Assignment04/tests.txt'):
    line = raw.split('#',1)[0].strip()
    if not line:
        continue
    try:
        ast = Parser(tokenize(line), symtab).parse_command()
        print(line, "->", ast)
        print("SYMTAB:", _pretty_symtab(symtab))
    except Exception as e:
        print(line, "-> ERROR:", e)
PY

