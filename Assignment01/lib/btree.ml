type binary_tree =
  | Empty
  | Node of int * binary_tree * binary_tree

let rec height = function
  | Empty -> 0
  | Node (_, l, r) -> 1 + max (height l) (height r)

let rec prune = function
  | Empty -> Empty
  | Node (_, Empty, Empty) -> Empty
  | Node (v, l, r) -> Node (v, prune l, prune r)

(* BFS with a list as a queue; using (@) is fine here *)
let level_traversal t =
  let rec go q acc =
    match q with
    | [] -> List.rev acc
    | Empty :: qs -> go qs acc
    | Node (v, l, r) :: qs -> go (qs @ [l; r]) (v :: acc)
  in
  go [t] []
