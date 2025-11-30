(****** ZDD の signature ******)
module type ZDDType =
sig
  (* typedef *)
  type t =
    | Zero
    | One
    | V of int * t * t (* (index, lo, hi) *)

  (* Base functions *)
  val const : bool -> t
  val var : int -> t

  (* Algebraic operations *)
  val apply : (bool -> bool -> bool) -> t -> t -> t
  val not_ : t -> t
  val and_ : t -> t -> t
  val or_ : t -> t -> t
  val xor_ : t -> t -> t

  (* Polynomial operations *)
  val plus : t -> t -> t
  val mul : t -> t -> t
  val deg : t -> int
  val lead : t -> t
  val nf : t list -> t -> t

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
end