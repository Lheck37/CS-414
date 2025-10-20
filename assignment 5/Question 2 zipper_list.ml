(* CS 414 Assignment 05 - Question 2 *)
(* OCaml zipper list using parametric types *)

type 'a zipper = {
  left  : 'a list;
  focus : 'a option;
  right : 'a list;
}

let empty : 'a zipper = { left = []; focus = None; right = [] }

let move_left z =
  match z.left, z.focus with
  | [], _ -> z
  | x :: xs, f ->
      let new_right =
        match f with
        | None -> z.right
        | Some v -> v :: z.right in
      { left = xs; focus = Some x; right = new_right }

let move_right z =
  match z.right, z.focus with
  | [], _ -> z
  | x :: xs, f ->
      let new_left =
        match f with
        | None -> z.left
        | Some v -> v :: z.left in
      { left = new_left; focus = Some x; right = xs }

let push_front x z =
  match z.focus with
  | None -> { left = []; focus = Some x; right = [] }
  | Some _ -> { z with left = x :: z.left }

let push_back x z =
  match z.focus with
  | None -> { left = []; focus = Some x; right = [] }
  | Some _ -> { z with right = x :: z.right }

let focus z = z.focus
