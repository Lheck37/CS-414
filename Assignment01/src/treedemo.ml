let values = [10; 5; 15; 3; 7]

let a_bintree =
  List.fold_left
    (fun t x -> Bintree.Tree.insert t x)
    Bintree.Tree.Empty
    values

let () =
  (* print the whole tree *)
  let s = Bintree.Tree.string_of_tree a_bintree in
  print_endline s;

  (* show Assignment 1 required functions *)
  print_endline "Level-order:";
  Bintree.Tree.level_traversal a_bintree
  |> List.map string_of_int
  |> String.concat " "
  |> print_endline;

  print_endline "Pruned:";
  print_endline (Bintree.Tree.string_of_tree (Bintree.Tree.prune a_bintree))

