# CS 414 — Assignment01

## Build
cd Assignment01
dune build

## Run (demo)
dune exec ./_build/default/src/treedemo.exe

## Test
dune runtest

## Layout
Assignment01/
  dune-project
  assignment01.opam
  src/
    dune
    treedemo.ml
  tree/
    dune
    tree.ml
  test/
    dune
    test_treedemo.ml

## Notes
- Level traversal uses lists as a queue.
- Formatting via .ocamlformat.
- Build artifacts are ignored via .gitignore.
