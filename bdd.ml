(* BDD module の signature *)
module type BDDType =
sig
  type t
  (* Base functions *)
  val const : bool -> t
  val var : int -> t
  (* Algebraic operations *)
  val apply : (bool -> bool -> bool) -> t -> t -> t
  val not : t -> t
  val and_ : t -> t -> t
  val or_ : t -> t -> t
  val xor_ : t -> t -> t
  (* Nonalgebraic operations *)
  val restrict : t -> int -> bool -> t
  val compose : t -> int -> t -> t
  val exists : t -> int list -> t
  val forall : t -> int list -> t
  val relprod : t -> t -> int list -> t
  (* Examining functions *)
  val equal : t -> t -> bool
  val eval : t -> int list -> bool
  val satisfy : t -> bool
  val satisfy_all : t -> int list list
end

(* BDD の実装 *)
module BDD = struct
  (* BDD の型定義 *)
  type t =
    | Zero
    | One
    | V of int * t * t (* (index, lo, hi) *)
  
  (** Base functions **)
  
  (* 定数 *)
  let const : bool -> t = fun b ->
    if b then One else Zero
  
  (* 変数 *)
  let var : int -> t = fun i ->
    V (i, Zero, One)
  
  (** Algebraic operations **)

  (* 二項演算の適用（ナイーブな実装） *)
  let rec apply : (bool -> bool -> bool) -> t -> t -> t = fun op f g ->
    let new_vertex : int -> t -> t -> t = fun k w0 w1 ->
      if w0 = w1 then w0 else V(k, w0, w1)
    in
    match (f, g) with
      | (Zero, Zero) -> const (op false false)
      | (Zero, One ) -> const (op false true )
      | (One , Zero) -> const (op true  false)
      | (One , One ) -> const (op true  true )
      | (Zero, V(j, g0, g1)) | (One, V(j, g0, g1)) -> new_vertex j (apply op f g0) (apply op f g1)
      | (V(i, f0, f1), Zero) | (V(i, f0, f1), One) -> new_vertex i (apply op f0 g) (apply op f1 g)
      | (V(i, f0, f1), V(j, g0, g1)) ->
            if i < j then new_vertex i (apply op f0 g) (apply op f1 g)
            else if i > j then new_vertex j (apply op f g0) (apply op f g1)
            else new_vertex i (apply op f0 g0) (apply op f1 g1)

  (* let not : t -> t
  let and_ : t -> t -> t
  let or_ : t -> t -> t
  let xor_ : t -> t -> t *)

end