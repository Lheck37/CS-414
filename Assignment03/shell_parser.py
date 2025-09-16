# CS 414 — Assignment 03: Simple Shell Parser
# Run: python3 shell_parser.py

"""
EBNF (start symbol = command)

command    ::= ls_cmd | cd_cmd | cat_cmd | print_cmd | exec_cmd ;
ls_cmd     ::= "ls" [ path ] ;
cd_cmd     ::= "cd" [ path ] ;          # no argument means root
cat_cmd    ::= "cat" filename ;
print_cmd  ::= "print" filename ;
exec_cmd   ::= "exec" filename ;

path       ::= "/" | "/" segments ;
segments   ::= segment { "/" segment } ;
segment    ::= name8 ;

filename   ::= name8 "." ext3 ;

# Tokens (terminals):  LS, CD, CAT, PRINT, EXEC, SLASH, DOT, IDENT, EOF
# Nonterminals (variables): command, ls_cmd, cd_cmd, cat_cmd, print_cmd, exec_cmd,
#                           path, segments, segment, filename, name8, ext3
# Start symbol: command
"""

# ---------- tokenizer ----------

def _is_letter(ch):
    return ('a' <= ch <= 'z') or ('A' <= ch <= 'Z')

KEYWORDS = {
    'ls': 'LS',
    'cd': 'CD',
    'cat': 'CAT',
    'print': 'PRINT',
    'exec': 'EXEC'
}

def tokenize(s):
    i, n = 0, len(s)
    toks = []
    while i < n:
        ch = s[i]
        if ch.isspace():
            i += 1
            continue
        if ch == '/':
            toks.append(('SLASH', '/', i)); i += 1; continue
        if ch == '.':
            toks.append(('DOT', '.', i)); i += 1; continue
        if _is_letter(ch):
            j = i
            while j < n and _is_letter(s[j]):
                j += 1
            word = s[i:j]
            key = word.lower()
            kind = KEYWORDS.get(key, 'IDENT')
            toks.append((kind, word, i))
            i = j
            continue
        raise SyntaxError(f"bad char {ch} at {i}")
    toks.append(('EOF', '', n))
    return toks

# ---------- parser ----------

# Note: identifiers are treated as names in the AST (syntax only).
# Any meaning is resolved later by an environment when commands are executed.

class Parser:
    def __init__(self, toks):
        self.toks = toks
        self.i = 0

    def _peek(self):
        return self.toks[self.i]

    def _eat(self, kind):
        k, lex, pos = self._peek()
        if k != kind:
            raise SyntaxError(f"expected {kind} at {pos}, got {k}")
        self.i += 1
        return lex

    def _try(self, kind):
        if self._peek()[0] == kind:
            return self._eat(kind)
        return None

    def parse_command(self):
        k = self._peek()[0]
        if k == 'LS': return self._ls()
        if k == 'CD': return self._cd()
        if k == 'CAT': return self._cat()
        if k == 'PRINT': return self._print()
        if k == 'EXEC': return self._exec()
        raise SyntaxError("unknown command")

    def _ls(self):
        self._eat('LS')
        path = self._opt_path()
        self._eat('EOF')
        return {'tag': 'LS', 'path': path}

    def _cd(self):
        self._eat('CD')
        path = self._opt_path()
        self._eat('EOF')
        return {'tag': 'CD', 'path': path}

    def _cat(self):
        self._eat('CAT')
        f = self._filename()
        self._eat('EOF')
        return {'tag': 'CAT', 'file': f}

    def _print(self):
        self._eat('PRINT')
        f = self._filename()
        self._eat('EOF')
        return {'tag': 'PRINT', 'file': f}

    def _exec(self):
        self._eat('EXEC')
        f = self._filename()
        self._eat('EOF')
        return {'tag': 'EXEC', 'file': f}

    def _opt_path(self):
        if self._peek()[0] == 'EOF':
            return None
        k = self._peek()[0]
        if k == 'SLASH':
            return self._path()
        if k == 'IDENT':  # allow a single relative folder name
            name = self._segment()
            return {'root': False, 'segs': [name]}
        raise SyntaxError("path must start with / or be a single name")

    def _path(self):
        self._eat('SLASH')
        if self._peek()[0] == 'EOF':
            return {'root': True, 'segs': []}
        segs = [self._segment()]
        while self._try('SLASH'):
            segs.append(self._segment())
        return {'root': False, 'segs': segs}

    def _segment(self):
        name = self._eat('IDENT')
        if not (1 <= len(name) <= 8 and name.isalpha()):
            raise SyntaxError("bad folder name")
        return name

    def _filename(self):
        name = self._eat('IDENT')
        if not (1 <= len(name) <= 8 and name.isalpha()):
            raise SyntaxError("bad file name")
        self._eat('DOT')
        ext = self._eat('IDENT')
        if not (len(ext) == 3 and ext.isalpha()):
            raise SyntaxError("bad ext")
        return {'name': name, 'ext': ext}

# ---------- quick test ----------

if __name__ == '__main__':
    tests = [
        "ls", "ls /", "ls /docs", "ls docs",
        "cd", "cd /", "cd /games", "cd games",
        "cat readme.txt", "print report.prn", "exec game.bin"
    ]
    for t in tests:
        toks = tokenize(t)
        ast = Parser(toks).parse_command()
        print(t, "->", ast)

