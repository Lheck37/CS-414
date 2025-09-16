#!/usr/bin/env bash
python3 - <<'PY'
from Assignment03.shell_parser import tokenize, Parser
for raw in open('Assignment03/tests.txt'):
    line = raw.split('#',1)[0].strip()
    if not line: 
        continue
    try:
        ast = Parser(tokenize(line)).parse_command()
        print(line, "->", ast)
    except Exception as e:
        print(line, "-> ERROR:", e)
PY

