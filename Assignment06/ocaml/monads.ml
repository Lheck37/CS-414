(* Assignment06/ocaml/monads.ml *)
(* Monads in OCaml - Option, Result, List *)

(* ------------------ MONAD SIGNATURE ------------------ *)
module type MONAD = sig
  type 'a t
  val return : 'a -> 'a t
  val bind   : 'a t -> ('a -> 'b t) -> 'b t
  val map    : ('a -> 'b) -> 'a t -> 'b t
end

(* Helper to add infix operators like >>= and let* *)
module Make_infix (M : MONAD) = struct
  let ( >>= ) = M.bind
  let ( let* ) = M.bind   (* allows 'let*' syntax sugar *)
  let ( >|= ) m f = M.map f m
end

(* ------------------ OPTION MONAD ------------------ *)
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

module O = Make_infix(OptionM)

(* ------------------ RESULT MONAD ------------------ *)
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

module R = Make_infix(ResultM)

(* ------------------ LIST MONAD ------------------ *)
module ListM : MONAD = struct
  type 'a t = 'a list
  let return x = [x]
  let bind xs f = List.concat (List.map f xs)
  let map f xs = List.map f xs
end

module L = Make_infix(ListM)

(* ------------------ SAFE DIV HELPERS ------------------ *)
let safe_div_opt (a : int) (b : int) : int option =
  if b = 0 then None else Some (a / b)

let safe_div_res (a : int) (b : int) : (int, string) result =
  if b = 0 then Error "division by zero" else Ok (a / b)

(* ------------------ MONAD EXAMPLES ------------------ *)

(* Example 1: (((x / y) / z) / 2) using Option and let* *)
let divide_chain_opt (x : int) (y : int) (z : int) : int option =
  let open O in
  let* a1 = safe_div_opt x y in
  let* a2 = safe_div_opt a1 z in
  let* a3 = safe_div_opt a2 2 in
  OptionM.return a3

(* Example 2: same logic but using Result *)
let divide_chain_res (x : int) (y : int) (z : int) : (int, string) result =
  let open R in
  let* a1 = safe_div_res x y in
  let* a2 = safe_div_res a1 z in
  let* a3 = safe_div_res a2 2 in
  ResultM.return a3
