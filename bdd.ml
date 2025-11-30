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



end