type t =
  | Zero
  | One
  | VariableNode of int * t * t (* (index, lo, hi) *)

let rec pp = function
  | Zero -> "Zero"
  | One -> "One"
  | VariableNode (i, lo, hi) ->
      Printf.sprintf "VariableNode(%d, %s, %s)" i (pp lo) (pp hi)


(** Base functions **)

let const : bool -> t = fun b ->
  if b then One else Zero

let var : int -> t = fun i ->
  VariableNode (i, Zero, One)


(** Algebraic operations **)

(* 一般の二項演算子の適用（ナイーブな実装） *)
let rec apply : (bool -> bool -> bool) -> t -> t -> t = fun op f g ->
  let new_vertex : int -> t -> t -> t = fun k w0 w1 ->
    if w0 = w1 then w0 else VariableNode (k, w0, w1)
  in
  match (f, g) with
  | (Zero, Zero) -> const (op false false)
  | (Zero, One ) -> const (op false true )
  | (One , Zero) -> const (op true  false)
  | (One , One ) -> const (op true  true )
  | (Zero, VariableNode (j, g0, g1)) | (One, VariableNode (j, g0, g1)) ->
      new_vertex j (apply op f g0) (apply op f g1)
  | (VariableNode (i, f0, f1), Zero) | (VariableNode (i, f0, f1), One) ->
      new_vertex i (apply op f0 g) (apply op f1 g)
  | (VariableNode (i, f0, f1), VariableNode (j, g0, g1)) ->
      if i < j then new_vertex i (apply op f0 g) (apply op f1 g)
      else if i > j then new_vertex j (apply op f g0) (apply op f g1)
      else new_vertex i (apply op f0 g0) (apply op f1 g1)

let rec not_ : t -> t = function
  | Zero -> One
  | One  -> Zero
  | VariableNode (i, f0, f1) -> VariableNode (i, not_ f0, not_ f1)

let and_ : t -> t -> t = apply (&&)
let or_  : t -> t -> t = apply (||)
let xor_ : t -> t -> t = apply (<>)


(** Nonalgebraic operations **)

let rec restrict : t -> int -> bool -> t = fun f i b ->
  match f with
  | Zero | One -> f
  | VariableNode (j, f0, f1) ->
      if j = i
        then if b then f1 else f0
        else VariableNode (j, restrict f0 i b, restrict f1 i b)

let compose : t -> int -> t -> t = fun f i g ->
  or_ (and_ g (restrict f i true)) (and_ (not_ g) (restrict f i false))

let rec exists : t -> int list -> t = fun f is ->
  match is with
  | [] -> f
  | i :: js ->
      let g = exists f js in
      or_ (restrict g i false) (restrict g i true)

(* universal *)
let forall : t -> int list -> t = fun f is ->
  not_ (exists (not_ f) is)

let relprod : t -> t -> int list -> t = fun f g is ->
  exists (and_ f g) is


(** Examining functions **)

(* reduced である場合、equality は単に "=" *)
let equal : t -> t -> bool = (=)

let rec eval : t -> int list -> bool = fun f is ->
  match f with
  | Zero -> false
  | One  -> true
  | VariableNode (i, f0, f1) ->
      if List.mem i is then eval f1 is else eval f0 is

let satisfy : t -> bool = fun f -> not (equal Zero f)
