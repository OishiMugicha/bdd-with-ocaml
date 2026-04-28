type t =
  | Zero
  | One
  | VariableNode of int * t * t (* (index, lo, hi) *)

val pp : t -> string

(* Base functions *)
val const : bool -> t
val var : int -> t

(* Algebraic operations *)
val apply : (bool -> bool -> bool) -> t -> t -> t
val not_ : t -> t
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
