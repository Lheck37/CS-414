#use "rose.ml";;

(* a sample tree: 
        1
       / \
      2   3
         /
        4
*)
let t = Node (1, [Node (2, []); Node (3, [Node (4, [])])]);;

(* test size *)
let () = Printf.printf "size = %d\n" (size t);;

(* test fold: sum all values *)
let sum = fold (fun v cs -> v + List.fold_left (+) 0 cs) t;;
let () = Printf.printf "sum = %d\n" sum;;

(* test map: multiply all values by 10 *)
let t2 = map (fun x -> x * 10) t;;
let () = Printf.printf "mapped size = %d\n" (size t2);;

