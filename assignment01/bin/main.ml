module N  = Assignment01.Nat
module BT = Assignment01.Btree
module GT = Assignment01.Gtree

let () =
  (* Peano checks *)
  let three = N.S (N.S (N.S N.Z)) in
  let five  = N.S (N.S (N.S (N.S (N.S N.Z)))) in
  let (q, r) = N.divmod five (N.S (N.S N.Z)) in
  Printf.printf "3*5 = %d\n" (N.to_int (N.mul three five));
  Printf.printf "5/2 -> q=%d r=%d\n" (N.to_int q) (N.to_int r);

  (* binary tree checks *)
  let t =
    BT.Node (1,
      BT.Node (2, BT.Empty, BT.Empty),
      BT.Node (3, BT.Node (4, BT.Empty, BT.Empty), BT.Empty))
  in
  Printf.printf "btree height = %d\n" (BT.height t);
  let levels = BT.level_traversal t |> List.map string_of_int |> String.concat ", " in
  Printf.printf "level_traversal = [%s]\n" levels;
  let pruned = BT.prune t in
  Printf.printf "after prune height = %d\n" (BT.height pruned);

  (* general tree checks *)
  let cmp = Int.compare in
  let g = GT.Empty |> GT.insert cmp 10 |> GT.insert cmp 5 |> GT.insert cmp 20 in
  let inorder_g = GT.inorder g |> List.map string_of_int |> String.concat ", " in
  Printf.printf "gtree inorder = [%s]\n" inorder_g
