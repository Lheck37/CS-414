type 'a rose = Node of 'a * 'a rose list

let rec size (Node (_, kids)) =
  1 + List.fold_left (fun acc c -> acc + size c) 0 kids

let rec map f (Node (v, kids)) =
  Node (f v, List.map (map f) kids)

let rec fold f (Node (v, kids)) =
  let folded = List.map (fold f) kids in
  f v folded

