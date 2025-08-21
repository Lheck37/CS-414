type nat = Z | S of nat

let rec to_int = function Z -> 0 | S n -> 1 + to_int n
let rec add x y = match x with Z -> y | S x' -> S (add x' y)
let rec mul x y = match x with Z -> Z | S x' -> add y (mul x' y)

(* simple helpers for division *)
let rec try_sub a b =
  match (a, b) with
  | a, Z -> Some a
  | Z, S _ -> None
  | S a', S b' -> try_sub a' b'

exception Div_by_zero

let divmod n d =
  if d = Z then raise Div_by_zero
  else
    let rec loop q r =
      match try_sub r d with Some r' -> loop (S q) r' | None -> (q, r)
    in
    loop Z n

let div n d = fst (divmod n d)
let rem n d = snd (divmod n d)
