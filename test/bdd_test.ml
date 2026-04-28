open Bdd

let bdd = Alcotest.testable
  (fun ppf t -> Format.pp_print_string ppf (pp t))
  equal

(** const **)

let test_const_true () =
  Alcotest.(check bdd) "const true = One" One (const true)

let test_const_false () =
  Alcotest.(check bdd) "const false = Zero" Zero (const false)


(** var **)

let test_var_0 () =
  Alcotest.(check bdd) "var 0" (VariableNode (0, Zero, One)) (var 0)


(** and_ **)

let test_and_true_and_true () =
  Alcotest.(check bdd) "true and true = true" (const true) (and_ (const true) (const true))

let test_and_true_and_false () =
  Alcotest.(check bdd) "true and false = false" (const false) (and_ (const true) (const false))


(** or_ **)

let test_or_true_and_false () =
  Alcotest.(check bdd) "true or false = true" (const true) (or_ (const true) (const false))

let test_or_false_and_false () =
  Alcotest.(check bdd) "false or false = false" (const false) (or_ (const false) (const false))


(** not_ **)

let test_not_true () =
  Alcotest.(check bdd) "not true = false" (const false) (not_ (const true))

let test_not_false () =
  Alcotest.(check bdd) "not false = true" (const true) (not_ (const false))


(** xor_ **)

let test_xor_true_and_false () =
  Alcotest.(check bdd) "true xor false = true" (const true) (xor_ (const true) (const false))


(** restrict **)

let test_restrict_true_on_variable () =
  Alcotest.(check bdd) "restrict (var 0) 0 true = One" One (restrict (var 0) 0 true)

let test_restrict_false_on_variable () =
  Alcotest.(check bdd) "restrict (var 0) 0 false = Zero" Zero (restrict (var 0) 0 false)


(** exists **)

let test_exists_on_single_variable () =
  Alcotest.(check bdd) "exists (var 0) [0] = One" One (exists (var 0) [0])


(** forall **)

let test_forall_on_single_variable () =
  Alcotest.(check bdd) "forall (var 0) [0] = Zero" Zero (forall (var 0) [0])


(** relprod **)

let test_relprod_of_two_vars () =
  Alcotest.(check bdd) "relprod (var 0) (var 1) [0;1] = One"
    One (relprod (var 0) (var 1) [0; 1])


(** eval **)

let test_eval_var_true () =
  Alcotest.(check Alcotest.bool) "eval (var 0) [0] = true" true (eval (var 0) [0])

let test_eval_var_false () =
  Alcotest.(check Alcotest.bool) "eval (var 0) [] = false" false (eval (var 0) [])


(** compose **)

let test_compose_var () =
  (* compose (var 0) 0 (var 1) は var 0 を var 1 で置き換えるので var 1 と等しい *)
  Alcotest.(check bdd) "compose (var 0) 0 (var 1) = var 1"
    (var 1) (compose (var 0) 0 (var 1))


(** テスト登録 **)

let () =
  Alcotest.run "BDD" [
    "const", [
      Alcotest.test_case "true"  `Quick test_const_true;
      Alcotest.test_case "false" `Quick test_const_false;
    ];
    "var", [
      Alcotest.test_case "var 0" `Quick test_var_0;
    ];
    "and_", [
      Alcotest.test_case "true and true"  `Quick test_and_true_and_true;
      Alcotest.test_case "true and false" `Quick test_and_true_and_false;
    ];
    "or_", [
      Alcotest.test_case "true or false"   `Quick test_or_true_and_false;
      Alcotest.test_case "false or false"  `Quick test_or_false_and_false;
    ];
    "not_", [
      Alcotest.test_case "not true"  `Quick test_not_true;
      Alcotest.test_case "not false" `Quick test_not_false;
    ];
    "xor_", [
      Alcotest.test_case "true xor false" `Quick test_xor_true_and_false;
    ];
    "restrict", [
      Alcotest.test_case "true on var 0"  `Quick test_restrict_true_on_variable;
      Alcotest.test_case "false on var 0" `Quick test_restrict_false_on_variable;
    ];
    "exists", [
      Alcotest.test_case "single variable" `Quick test_exists_on_single_variable;
    ];
    "forall", [
      Alcotest.test_case "single variable" `Quick test_forall_on_single_variable;
    ];
    "relprod", [
      Alcotest.test_case "two vars" `Quick test_relprod_of_two_vars;
    ];
    "eval", [
      Alcotest.test_case "var 0 assigned true"  `Quick test_eval_var_true;
      Alcotest.test_case "var 0 assigned false" `Quick test_eval_var_false;
    ];
    "compose", [
      Alcotest.test_case "var 0 with var 1" `Quick test_compose_var;
    ];
  ]
