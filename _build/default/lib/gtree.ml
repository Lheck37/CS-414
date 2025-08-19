type 'a gtree =
  | Empty
  | Node of 'a list * 'a gtree list

let rec height = function
  | Empty -> 0
  | Node (_, cs) -> 1 + List.fold_left (fun acc c -> max acc (height c)) 0 cs

(* traversals over keys only *)
let rec inorder = function
  | Empty -> []
  | Node (ks, cs) ->
      let rec go ks cs =
        match ks, cs with
        | [], [c_last] -> inorder c_last
        | k::ks', c::cs' -> inorder c @ [k] @ go ks' cs'
        | _ -> []
      in
      go ks cs

let rec preorder = function
  | Empty -> []
  | Node (ks, cs) -> ks @ List.concat (List.map preorder cs)

let rec postorder = function
  | Empty -> []
  | Node (ks, cs) -> List.concat (List.map postorder cs) @ ks

(* basic insert guided by comparator; no balancing *)
let insert cmp x t =
  let rec ins = function
    | Empty -> Node ([x], [Empty; Empty])
    | Node (ks, cs) ->
        let rec find_i i = function
          | [] -> i
          | k::ks' -> if cmp x k < 0 then i else find_i (i+1) ks'
        in
        let i = find_i 0 ks in
        let rec upd j = function
          | [] -> [] (* assume well-formed *)
          | c::cs' -> if j = 0 then ins c :: cs' else c :: upd (j-1) cs'
        in
        Node (ks, upd i cs)
  in
  ins t
