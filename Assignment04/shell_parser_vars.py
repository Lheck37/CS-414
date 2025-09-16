# CS 414 — Assignment 04: Extend Your Parser (variables + expressions)
# Run: python3 shell_parser_vars.py
#
# Extends A03 with:
# - variables starting with $NAME (letters/digits after $)
# - set $VAR = <expr>
# - echo $VAR
# - variables may be used as single arguments for ls/cd/cat/print/exec
# - arithmetic expressions (parse-only; no evaluation)

"""
EBNF (start symbol = command)

command     ::= ls_cmd | cd_cmd | cat_cmd | print_cmd | exec_cmd
               | set_cmd | echo_cmd ;

# original commands
ls_cmd      ::= "ls" [ arg_path ] ;
cd_cmd      ::= "cd" [ arg_path ] ;            # no argument means root
cat_cmd     ::= "cat" arg_file ;
print_cmd   ::= "print" arg_file ;
exec_cmd    ::= "exec" arg_file ;

# new commands
set_cmd     ::= "set" variable "=" expr ;
echo_cmd    ::= "echo" variable ;

# variables as single arguments
arg_path    ::= path | variable ;
arg_file    ::= filename | variable ;

# paths / filenames (same as A03)
path        ::= "/" | "/" segments ;
segments    ::= segment { "/" segment } ;
segment     ::= name8 ;
filename    ::= name8 "." ext3 ;
name8       ::= letter { letter } ;            # 1..8 letters (checked in parser)
ext3        ::= letter letter letter ;         # exactly 3 letters
letter      ::= "A".."Z" | "a".."z" ;

# variables and expressions
variable    ::= "$" identchars ;
identchars  ::= (letter | digit) { letter | digit } ;

expr        ::= term { ("+" | "-") term } ;
term        ::= factor { ("*" | "/") factor } ;
factor      ::= variable | int | "(" expr ")" | "-" factor | ident ;
int         ::= digit { digit } ;
digit       ::= "0".."9" ;

# Tokens (terminals):  LS, CD, CAT, PRINT, EXEC, SET, ECHO,
#   SLASH, DOT, IDENT, VAR, INT, EQ, PLUS, MINUS, STAR, LPAREN, RPAREN, EOF
# Nonterminals (variables): command, ls_cmd, cd_cmd, cat_cmd, print_cmd, exec_cmd,
#   set_cmd, echo_cmd, arg_path, arg_file, path, segments, segment, filename,
#   name8, ext3, variable, expr, term, factor, int
# Start symbol: command
"""

from typing import List, Tuple, Dict, Any

Tok = Tuple[str, str, int]   # (kind, lexeme, position)

def _is_letter(ch: str) -> bool:
    return ('a' <= ch <= 'z') or ('A' <= ch <= 'Z')

def _is_digit(ch: str) -> bool:
    return '0' <= ch <= '9'

KEYWORDS = {
    'ls': 'LS',
    'cd': 'CD',
    'cat': 'CAT',
    'print': 'PRINT',
    'exec': 'EXEC',
    'set': 'SET',
    'echo': 'ECHO',
}

def tokenize(s: str) -> List[Tok]:
    i, n = 0, len(s)
    toks: List[Tok] = []
    while i < n:
        ch = s[i]
        if ch.isspace():
            i += 1; continue
        if ch == '/':
            toks.append(('SLASH', '/', i)); i += 1; continue
        if ch == '.':
            toks.append(('DOT', '.', i)); i += 1; continue
        if ch == '=':
            toks.append(('EQ', '=', i)); i += 1; continue
        if ch == '+':
            toks.append(('PLUS', '+', i)); i += 1; continue
        if ch == '-':
            toks.append(('MINUS', '-', i)); i += 1; continue
        if ch == '*':
            toks.append(('STAR', '*', i)); i += 1; continue
        if ch == '(':
            toks.append(('LPAREN', '(', i)); i += 1; continue
        if ch == ')':
            toks.append(('RPAREN', ')', i)); i += 1; continue
        if ch == '$':
            j = i + 1
            if j >= n or not (_is_letter(s[j]) or _is_digit(s[j])):
                raise SyntaxError(f"bad variable name at {i}")
            while j < n and (_is_letter(s[j]) or _is_digit(s[j])):
                j += 1
            name = s[i+1:j]    # strip '$'
            toks.append(('VAR', name, i))
            i = j
            continue
        if _is_digit(ch):
            j = i
            while j < n and _is_digit(s[j]):
                j += 1
            toks.append(('INT', s[i:j], i))
            i = j
            continue
        if _is_letter(ch):
            j = i
            while j < n and _is_letter(s[j]):
                j += 1
            word = s[i:j]
            kind = KEYWORDS.get(word.lower(), 'IDENT')
            toks.append((kind, word, i))
            i = j
            continue
        raise SyntaxError(f"bad char {ch} at {i}")
    toks.append(('EOF', '', n))
    return toks

# Parser — identifiers/variables are names in the AST (syntax only). No evaluation.

class Parser:
    def __init__(self, toks: List[Tok], symtab: Dict[str, Any]):
        self.toks = toks
        self.i = 0
        self.symtab = symtab

    def _peek(self) -> Tok:
        return self.toks[self.i]

    def _eat(self, kind: str) -> Tok:
        t = self._peek()
        if t[0] != kind:
            raise SyntaxError(f"expected {kind} at {t[2]}, got {t[0]}")
        self.i += 1
        return t

    def _try(self, kind: str):
        if self._peek()[0] == kind:
            return self._eat(kind)
        return None

    # entry
    def parse_command(self) -> Dict[str, Any]:
        k = self._peek()[0]
        if k == 'LS':   return self._ls()
        if k == 'CD':   return self._cd()
        if k == 'CAT':  return self._cat()
        if k == 'PRINT':return self._print()
        if k == 'EXEC': return self._exec()
        if k == 'SET':  return self._set()
        if k == 'ECHO': return self._echo()
        t = self._peek()
        raise SyntaxError(f"unknown command at {t[2]}: {t[1]!r}")

    # original commands
    def _ls(self):
        self._eat('LS')
        arg = self._opt_arg_path()
        self._eat('EOF')
        return {'tag':'LS', 'arg': arg}

    def _cd(self):
        self._eat('CD')
        arg = self._opt_arg_path()
        self._eat('EOF')
        return {'tag':'CD', 'arg': arg}

    def _cat(self):
        self._eat('CAT')
        f = self._arg_file()
        self._eat('EOF')
        return {'tag':'CAT', 'file': f}

    def _print(self):
        self._eat('PRINT')
        f = self._arg_file()
        self._eat('EOF')
        return {'tag':'PRINT', 'file': f}

    def _exec(self):
        self._eat('EXEC')
        f = self._arg_file()
        self._eat('EOF')
        return {'tag':'EXEC', 'file': f}

    # new commands
    def _set(self):
        self._eat('SET')
        var_tok = self._eat('VAR')
        self._eat('EQ')
        e = self._expr()
        self._eat('EOF')
        # store parsed expression AST (no evaluation)
        self.symtab[var_tok[1]] = {'expr': e}
        return {'tag':'SET', 'var': var_tok[1], 'expr': e}

    def _echo(self):
        self._eat('ECHO')
        var_tok = self._eat('VAR')
        self._eat('EOF')
        # define on first use if absent
        self.symtab.setdefault(var_tok[1], {'expr': None})
        return {'tag':'ECHO', 'var': var_tok[1]}

    # arg helpers
    def _opt_arg_path(self):
        if self._peek()[0] == 'EOF':
            return None
        if self._peek()[0] == 'VAR':
            name = self._eat('VAR')[1]
            return {'kind':'var', 'name':name}
        return self._path()

    def _arg_file(self):
        if self._peek()[0] == 'VAR':
            name = self._eat('VAR')[1]
            return {'kind':'var', 'name':name}
        return self._filename()

    # path / filename parsing (same checks as A03)
    def _path(self):
        self._eat('SLASH')
        if self._peek()[0] == 'EOF':
            return {'kind':'root', 'segs':[]}
        if self._peek()[0] == 'SLASH':
            raise SyntaxError("empty path segment not allowed")
        segs = [ self._segment() ]
        while self._try('SLASH'):
            if self._peek()[0] in ('EOF','SLASH'):
                raise SyntaxError("empty path segment not allowed")
            segs.append(self._segment())
        return {'kind':'segments', 'segs':segs}

    def _segment(self):
        k, name, pos = self._eat('IDENT')
        if not (1 <= len(name) <= 8 and name.isalpha()):
            raise SyntaxError("bad folder name")
        return name

    def _filename(self):
        k, name, pos = self._eat('IDENT')
        if not (1 <= len(name) <= 8 and name.isalpha()):
            raise SyntaxError("bad file name")
        self._eat('DOT')
        k, ext, pos = self._eat('IDENT')
        if not (len(ext) == 3 and ext.isalpha()):
            raise SyntaxError("bad ext")
        return {'kind':'filename', 'name':name, 'ext':ext}

    # ---- expression parser (no evaluation) ----
    def _expr(self):
        node = self._term()
        while self._peek()[0] in ('PLUS','MINUS'):
            op = self._eat(self._peek()[0])[0]
            right = self._term()
            node = {'op':op, 'left':node, 'right':right}
        return node

    def _term(self):
        node = self._factor()
        while self._peek()[0] in ('STAR','SLASH'):
            op = self._eat(self._peek()[0])[0]
            right = self._factor()
            node = {'op':op, 'left':node, 'right':right}
        return node

    def _factor(self):
        t = self._peek()
        if t[0] == 'MINUS':
            self._eat('MINUS')
            f = self._factor()
            return {'op':'NEG', 'expr': f}
        if t[0] == 'LPAREN':
            self._eat('LPAREN')
            e = self._expr()
            self._eat('RPAREN')
            return e
        if t[0] == 'VAR':
            name = self._eat('VAR')[1]
            self.symtab.setdefault(name, {'expr': None})
            return {'var': name}
        if t[0] == 'INT':
            v = int(self._eat('INT')[1])
            return {'int': v}
        if t[0] == 'IDENT':
            s = self._eat('IDENT')[1]
            return {'ident': s}
        raise SyntaxError(f"unexpected token in expression: {t[0]} at {t[2]}")

# ---- simple runner for quick tests ----

def _pretty_symtab(symtab: Dict[str, Any]) -> str:
    parts = []
    for k in sorted(symtab.keys()):
        v = symtab[k]['expr']
        parts.append(f"{k}: {v}")
    return "{ " + ", ".join(parts) + " }"

if __name__ == "__main__":
    tests = [
        "set $A = 2 + 3*4",
        "echo $A",
        "ls $A",
        "cd $A",
        "set $B = ( $A + 8 ) / 2",
        "echo $B",
        "cat readme.txt",
        "print $B",
        "exec game.bin",
    ]
    symtab: Dict[str, Any] = {}
    for t in tests:
        toks = tokenize(t)
        ast = Parser(toks, symtab).parse_command()
        print(t, "->", ast)
        print("SYMTAB:", _pretty_symtab(symtab))

