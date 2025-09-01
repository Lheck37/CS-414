let values = [10; 5; 15; 3; 7]

let a_bintree =
  List.fold_left
    (fun t x -> Bintree.Tree.insert t x)
    Bintree.Tree.Empty
    values

(* helper to print list-of-lists like [[10]; [5; 15]; [3; 7]] *)
let show_levels lvls =
  lvls
  |> List.map (fun lvl ->
       "[" ^ (lvl |> List.map string_of_int |> String.concat "; ") ^ "]")
  |> String.concat "; "

let () =
  (* print the whole tree *)
  let s = Bintree.Tree.string_of_tree a_bintree in
  print_endline s;

  (* show Assignment 1 required functions *)
  print_endline "Level-by-level:";
  let levels = Bintree.Tree.level_traversal a_bintree in
  print_endline ("[" ^ show_levels levels ^ "]");

  print_endline "Pruned:";
  print_endline (Bintree.Tree.string_of_tree (Bintree.Tree.prune a_bintree))
