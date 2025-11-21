(* sort_context.ml *)

(* A module type describing a sorting strategy *)
module type SORT = sig
  val sort : int list -> int list
end

(* QuickSort strategy using the built–in List.sort for simplicity *)
module QuickSort : SORT = struct
  let sort lst = List.sort compare lst
end

(* A basic MergeSort implementation *)
module MergeSort : SORT = struct
  let rec merge a b =
    match a, b with
    | [], x -> x
    | x, [] -> x
    | ha :: ta, hb :: tb ->
        if ha <= hb then ha :: merge ta b
        else hb :: merge a tb

  let rec split = function
    | [] -> [], []
    | [x] -> [x], []
    | x :: y :: rest ->
        let a, b = split rest in
        (x :: a, y :: b)

  let rec mergesort = function
    | [] -> []
    | [x] -> [x]
    | lst ->
        let left, right = split lst in
        merge (mergesort left) (mergesort right)

  let sort lst = mergesort lst
end

(* BubbleSort strategy *)
module BubbleSort : SORT = struct
  let rec pass = function
    | [] -> [], false
    | [x] -> [x], false
    | a :: b :: rest ->
        let tail, swapped = pass (b :: rest) in
        if a > b then (b :: a :: tail), true
        else (a :: b :: tail), swapped

  let rec bubble lst =
    let lst', swapped = pass lst in
    if swapped then bubble lst' else lst'

  let sort lst = bubble lst
end

(* Strategy context functor *)
module SortContext (S : SORT) = struct
  let execute_strategy lst = S.sort lst
end

(* Example usage *)
let () =
  let module C = SortContext(QuickSort) in
  let sorted = C.execute_strategy [5; 2; 9; 1; 5; 6] in
  List.iter (fun x -> Printf.printf "%d " x) sorted;
  print_newline ()
