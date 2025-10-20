(* CS 414 Assignment 05 - Question 2 Test File *)
#use "question2_zipper_list.ml";;

(* make a zipper list and test movement *)
let z = { left = [1]; focus = Some 2; right = [3;4] };;
print_endline "Initial:";
print_endline ("focus = " ^
  (match z.focus with Some v -> string_of_int v | None -> "none"));

let z2 = move_right z;;
print_endline "After move_right:";
print_endline ("focus = " ^
  (match z2.focus with Some v -> string_of_int v | None -> "none"));

let z3 = move_left z2;;
print_endline "After move_left:";
print_endline ("focus = " ^
  (match z3.focus with Some v -> string_of_int v | None -> "none"));
