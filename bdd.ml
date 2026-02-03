(****** BDD の signature ******)
module type BDDType =
sig
  (* typedef *)
  type t =
    | Zero
    | One
    | VariableNode of int * t * t (* (index, lo, hi) *)

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
end


(****** BDD の実装 ******)
module BDD : BDDType = 
struct
  (* BDD の型定義 *)
  type t =
    | Zero
    | One
    | VariableNode of int * t * t (* (index, lo, hi) *)

  (** Base functions **)

  (* 定数 *)
  let const : bool -> t = fun b ->
    if b then One else Zero

  (* 変数 *)
  let var : int -> t = fun i ->
    VariableNode (i, Zero, One)


  (** Algebraic operations **)

  (* 一般の二項演算子の適用（ナイーブな実装） *)
  let rec apply : (bool -> bool -> bool) -> t -> t -> t = fun op f g ->
    let new_vertex : int -> t -> t -> t = fun k w0 w1 ->
      if w0 = w1 then w0 else VariableNode(k, w0, w1)
    in
    match (f, g) with
      | (Zero, Zero) -> const (op false false)
      | (Zero, One ) -> const (op false true )
      | (One , Zero) -> const (op true  false)
      | (One , One ) -> const (op true  true )
      | (Zero, VariableNode(j, g0, g1)) | (One, VariableNode(j, g0, g1)) -> new_vertex j (apply op f g0) (apply op f g1)
      | (VariableNode(i, f0, f1), Zero) | (VariableNode(i, f0, f1), One) -> new_vertex i (apply op f0 g) (apply op f1 g)
      | (VariableNode(i, f0, f1), VariableNode(j, g0, g1)) ->
            if i < j then new_vertex i (apply op f0 g) (apply op f1 g)
            else if i > j then new_vertex j (apply op f g0) (apply op f g1)
            else new_vertex i (apply op f0 g0) (apply op f1 g1)

  (* 単項 not 演算 *)
  let rec not_ : t -> t = fun f ->
    match f with
      | Zero -> One
      | One -> Zero
      | VariableNode(i, f0, f1) -> VariableNode(i, not_ f0, not_ f1)

  (* and 演算 *)
  let and_ : t -> t -> t = apply (&&)

  (* or 演算 *)
  let or_ : t -> t -> t = apply (||)

  (* xor 演算 *)
  let xor_ : t -> t -> t = apply (<>)


  (** Nonalgebraic operations **)

  (* restriction *)
  let rec restrict : t -> int -> bool -> t = fun f i b ->
    match f with
      | Zero | One -> f
      | VariableNode(j, f0, f1) ->
          if j = i
            then if b then f1 else f0
            else VariableNode(j, restrict f0 i b, restrict f1 i b)

  (* composition *)
  let compose : t -> int -> t -> t = fun f i g ->
    or_ (and_ g (restrict f i true)) (and_ (not_ g) (restrict f i false))

  (* existential *)
  let rec exists : t -> int list -> t = fun f is ->
    match is with
      | [] -> f
      | (i::js) ->
          let g = exists f js in
          or_ (restrict g i false) (restrict g i true)

  (* univarsal *)
  let forall : t -> int list -> t = fun f is -> 
    not_ (exists (not_ f) is)

  (* relational product *)
  let relprod : t -> t -> int list -> t = fun f g is ->
    exists (and_ f g) is


  (** Examining functions **)

  (* reduce である場合、equality は単に "=" *)
  let equal : t -> t -> bool = (=)

  (* evaluation *)
  let rec eval : t -> int list -> bool = fun f is ->
    match f with
      | Zero -> false
      | One -> true
      | VariableNode (i, f0, f1) -> if List.mem i is then eval f1 is else eval f0 is

  (* satisfiability *)
  let satisfy : t -> bool = fun f -> not (equal Zero f)
end


(****** テスト ******)

open BDD

let test_const_true () =
  assert( equal (const true) One )

let test_const_false () =
  assert( equal (const false) Zero )

let test_var_0 () =
  assert( equal (var 0) (VariableNode (0, Zero, One)) )

let test_and_true_and_true () =
  assert( equal (and_ (const true) (const true)) (const true) )

let test_and_true_and_false () =
  assert( equal (and_ (const true) (const false)) (const false) )

let test_or_true_and_false () =
  assert( equal (or_ (const true) (const false)) (const true) )

let test_or_false_and_false () =
  assert( equal (or_ (const false) (const false)) (const false) )

let test_not_true () =
  assert( equal (not_ (const true)) (const false) )

let test_not_false () =
  assert( equal (not_ (const false)) (const true) )

let test_xor_true_and_false () =
  assert( equal (xor_ (const true) (const false)) (const true) )

let test_exists_on_single_variable () =
  let bdd = var 0 in
  assert( equal (exists bdd [0]) One )

let test_forall_on_single_variable () =
  let bdd = var 0 in
  assert( equal (forall bdd [0]) Zero )

let test_restrict_true_on_variable () =
  let bdd = var 0 in
  assert( equal (restrict bdd 0 true) One )

let test_restrict_false_on_variable () =
  let bdd = var 0 in
  assert( equal (restrict bdd 0 false) Zero )

let test_relprod_of_two_vars () =
  let bdd1 = var 0 in
  let bdd2 = var 1 in
  assert( equal (relprod bdd1 bdd2 [0; 1]) One )

let test () =
    test_const_true ();
    test_const_false ();
    test_var_0 ();
    test_and_true_and_true ();
    test_and_true_and_false ();
    test_or_true_and_false ();
    test_or_false_and_false ();
    test_not_true ();
    test_not_false ();
    test_xor_true_and_false ();
    test_exists_on_single_variable ();
    test_forall_on_single_variable ();
    test_restrict_true_on_variable ();
    test_restrict_false_on_variable ();
    test_relprod_of_two_vars (); 
    print_endline "All tests passed!"