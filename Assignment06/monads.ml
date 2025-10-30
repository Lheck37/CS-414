(* Assignment06/ocaml/monads.ml *)
(* simple monads in OCaml: Option, Result(string), List
   keeping this basic so it's easy to read/grade. *)

(* ---- monad signature (minimal) ---- *)
module type MONAD = sig
  type 'a t
  val return : 'a -> 'a t
  val bind   : 'a t -> ('a -> 'b t) -> 'b t
  val map    : ('a -> 'b) -> 'a t -> 'b t
end

(* I only want >>= and let* since that’s what we use in examples. *)
module Infix (M : MONAD) = struct
  let ( >>= ) = M.bind
  let ( let* ) = M.bind
end

(* -------- Option monad (Maybe) -------- *)
module OptionM : MONAD = struct
  type 'a t = 'a option

  let return x = Some x

  let bind m f =
    match m with
    | None -> None
    | Some x -> f x

  let map f m =
    match m with
    | None -> None
    | Some x -> Some (f x)
end

module O = Infix(OptionM)

(* -------- Result monad (error is a string) -------- *)
module ResultM : MONAD = struct
  type 'a t = ('a, string) result

  let return x = Ok x

  let bind m f =
    match m with
    | Error e -> Error e
    | Ok x -> f x

  let map f m =
    match m with
    | Error e -> Error e
    | Ok x -> Ok (f x)
end

module R = Infix(ResultM)

(* -------- List monad (nondeterminism) -------- *)
module ListM : MONAD = struct
  type 'a t = 'a list

  let return x = [x]

  let bind xs f =
    (* map each x to a list, then flatten *)
    let rec concat acc = function
      | [] -> acc
      | ys::rest -> concat (acc @ ys) rest
    in
    let mapped = List.map f xs in
    concat [] mapped

  let map f xs = List.map f xs
end

module L = Infix(ListM)

(* ---- tiny helpers we actually use in the assignment ---- *)

(* Option: safe divide (None if divide by zero) *)
let safe_div_opt (a:int) (b:int) : int option =
  if b = 0 then None else Some (a / b)

(* Result: safe divide with a message *)
let safe_div_res (a:int) (b:int) : (int, string) result =
  if b = 0 then Error "division by zero" else Ok (a / b)

(* Q3: (((x / y) / z) / 2) using Option + let* *)
let pipeline_opt (x:int) (y:int) (z:int) : int option =
  let open O in
  let* a1 = safe_div_opt x y in
  let* a2 = safe_div_opt a1 z in
  let* a3 = safe_div_opt a2 2 in
  OptionM.return a3

(* Same idea but with Result so we keep an error message *)
let pipeline_res (x:int) (y:int) (z:int) : (int, string) result =
  let open R in
  let* a1 = safe_div_res x y in
  let* a2 = safe_div_res a1 z in
  let* a3 = safe_div_res a2 2 in
  ResultM.return a3

(* a couple small examples I can run in utop:
   # pipeline_opt 36 2 3;;         (* Some 3 *)
   # pipeline_opt 10 0 5;;         (* None *)
   # pipeline_res 42 6 7;;         (* Ok 0 *)
   # pipeline_res 5 0 1;;          (* Error "division by zero" *)
*)
