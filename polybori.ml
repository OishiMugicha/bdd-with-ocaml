(****** PolyBoRi の signature ******)
module type PolyBoRiType =
sig
  (* typedef *)
  type t =
    | Zero
    | One
    | V of int * t * t (* (index, lo, hi) *)

  (* Base functions *)
  val zero : t
  val one : t
  val var : int -> t

  (* Polynomial operations *)
  val plus : t -> t -> t
  val mul : t -> t -> t
  val deg : t -> int
  val lead : t -> t
  val nf : t list -> t -> t

  (* Examining functions *)
  val equal : t -> t -> bool
  val eval : t -> int list -> bool
  val satisfy : t -> bool
end


(******* PolyBoRi の実装 ******)
module PolyBoRi =
struct
  (* PolyBoRi の型定義 *)
  type t =
    | Zero
    | One
    | V of int * t * t (* (index, lo, hi) *)


  (** Base functions **)

  (* 定数 *)
  let zero : t = Zero

  let one : t = One

  (* 変数
     注：ZDD としての 論理式 X_i を表してはいない。
   *)
  let var : int -> t = fun i -> V (i, Zero, One)


  (** Polynomial operations **)

  (* plus 関数のナイーブな実装 *)
  let rec plus : t -> t -> t = fun f g ->
    match (f, g) with
      | (Zero, _) -> g
      | (_, Zero) -> f
      | (One, One) -> Zero
      | (One, V (j, g0, g1)) -> V (j, g0, plus One g1)
      | (V (i, f0, f1), One) -> V (i, f0, plus f1 One)
      | (V (i, f0, f1), V (j, g0, g1)) ->
          if i < j then V (i, f0, plus f1 g)
          else if i > j then V (j, g0, plus f g1)
          else V (i, plus f0 g0, plus f1 g1)

  
  
  (* 
  val mul : t -> t -> t
  val deg : t -> int
  val lead : t -> t
  val nf : t list -> t -> t *)
end