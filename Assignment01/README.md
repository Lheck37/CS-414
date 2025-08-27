# CS 414 — Assignment01

## Build
dune build

## Run
dune exec ./_build/default/src/treedemo.exe

## Test
dune runtest

## Files
- `src/treedemo.ml` — demo program that exercises the tree functions
- `tree/tree.ml` — binary tree library (height, prune, level traversal)
- `test/test_treedemo.ml` — minimal tests for prune + level traversal
- `lib/nat.ml` (if present) — Peano arithmetic (add, mul, divmod)
- `lib/gtree.ml` (if present) — general tree functions
