(* level-by-level traversal: int list list *)
let level_traversal t =
  let rec aux current acc =
    match current with
    | [] -> List.rev acc
    | nodes ->
      let values, next =
        List.fold_right
          (fun node (vals, nxt) ->
             match node with
             | Empty -> (vals, nxt)
             | Node (v, l, r) -> (v :: vals, l :: r :: nxt))
          nodes
          ([], [])
      in
      aux next (values :: acc)
  in
  aux [t] []

(* optional: keep a flat BFS for comparison *)
let bfs_flat t =
  let rec go q acc =
    match q with
    | [] -> List.rev acc
    | Empty :: qs -> go qs acc
    | Node (v, l, r) :: qs -> go (qs @ [l; r]) (v :: acc)
  in
  go [t] []
