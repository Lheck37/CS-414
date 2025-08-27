let () =
  let open Bintree.Tree in
  let t = List.fold_left insert Empty [10;5;15] in
  assert (level_traversal t = [10;5;15]);
  assert (height (prune t) = 1)
