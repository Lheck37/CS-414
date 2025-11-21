(* Assignment 07 - Fun With Objects (Functional Version)
   Logan Heck
   OCaml Strategy Pattern using functions + functors
*)

(* ----- Strategy functions ----- *)

let quicksort lst =
  List.sort compare lst

let rec mergesort lst =
  let rec merge a b =
    match a, b with
    | [], x -> x
    | x, [] -> x
    | h1::t1, h2::t2 ->
        if h1 <= h2 then h1 :: merge t1 b
        else h2 :: merge a t2
  in
  match lst with
  | [] | [_] -> lst
  | _ ->
      let left, right =
        List.split_n (List.length lst / 2) lst
      in
      merge (mergesort left) (mergesort right)

let rec bubblesort lst =
  let rec pass = function
    | x::y::rest ->
        if x > y then y :: pass (x :: rest)
        else x :: pass (y :: rest)
    | x -> x
  in
  let rec loop lst k =
    if k = 0 then lst
    else loop (pass lst) (k - 1)
  in
  loop lst (List.length lst)

(* ----- Higher-order “context” function ----- *)

let sort_with strategy lst =
  strategy lst

(* ----- Example data ----- *)
let data = [5; 2; 9; 1; 5; 6]

(* ----- Print helper ----- *)
let print_list lst =
  List.iter (fun x -> Printf.printf "%d " x) lst;
  print_endline ""

(* ----- Functor version (optional extra credit) ----- *)

module type SORT = sig
  val sort : int list -> int list
end

module SortContext (S : SORT) = struct
  let execute_strategy lst = S.sort lst
end

module Quick : SORT = struct
  let sort lst = List.sort compare lst
end

module Merge : SORT = struct
  let sort lst = mergesort lst
end

(* ----- “main” ----- *)
let () =
  Printf.printf "Using sort_with quicksort:\n";
  print_list (sort_with quicksort data);

  Printf.printf "Using sort_with mergesort:\n";
  print_list (sort_with mergesort data);

  Printf.printf "Using functor SortContext with Quick:\n";
  let module C1 = SortContext(Quick) in
  print_list (C1.execute_strategy data);

  Printf.printf "Using functor SortContext with Merge:\n";
  let module C2 = SortContext(Merge) in
  print_list (C2.execute_strategy data);
