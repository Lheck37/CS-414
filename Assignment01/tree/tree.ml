type t = Empty | Node of int * t * t

let rec height = function
  | Empty -> 0
  | Node (_, l, r) -> 1 + max (height l) (height r)

let rec insert t x =
  match t with
  | Empty -> Node (x, Empty, Empty)
  | Node (v, l, r) ->
      if x < v then Node (v, insert l x, r)
      else if x > v then Node (v, l, insert r x)
      else t

let rec string_of_tree = function
  | Empty -> "()"
  | Node (v, l, r) ->
      "Node(" ^ string_of_int v ^ ", "
      ^ string_of_tree l ^ ", "
      ^ string_of_tree r ^ ")"

let rec prune = function
  | Empty -> Empty
  | Node (_, Empty, Empty) -> Empty
  | Node (v, l, r) -> Node (v, prune l, prune r)

let level_traversal t =
  let rec go q acc =
    match q with
    | [] -> List.rev acc
    | Empty :: qs -> go qs acc
    | Node (v, l, r) :: qs -> go (qs @ [l; r]) (v :: acc)
  in
  go [t] []

