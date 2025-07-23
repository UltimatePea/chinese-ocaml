(** 骆言类型系统 - 类型合一模块测试 *)

open Alcotest
open Yyocamlc_lib.Core_types
open Yyocamlc_lib.Types_unify
open Yyocamlc_lib.Types_errors

(** 测试基本类型合一 *)
let test_basic_type_unification () =
  (* 测试相同基本类型的合一 *)
  check bool "相同整数类型合一应返回空替换" true (SubstMap.is_empty (unify IntType_T IntType_T));

  check bool "相同字符串类型合一应返回空替换" true (SubstMap.is_empty (unify StringType_T StringType_T));

  check bool "相同布尔类型合一应返回空替换" true (SubstMap.is_empty (unify BoolType_T BoolType_T));

  (* 测试不同基本类型的合一失败 *)
  (* 测试不同基本类型的合一失败 *)
  try
    let _ = unify IntType_T StringType_T in
    fail "不同基本类型合一应抛出类型错误"
  with
  | TypeError _ -> () (* 预期的异常 *)
  | _ -> fail "应该抛出TypeError异常"

(** 测试类型变量合一 *)
let test_type_variable_unification () =
  (* 测试类型变量与类型变量的合一 *)
  let var1 = TypeVar_T "a" in
  let var2 = TypeVar_T "b" in
  let subst = unify var1 var2 in
  check bool "类型变量与不同类型变量合一应产生替换" true (not (SubstMap.is_empty subst));

  (* 测试类型变量与相同类型变量的合一 *)
  check bool "相同类型变量合一应返回空替换" true (SubstMap.is_empty (unify var1 var1));

  (* 测试类型变量与具体类型的合一 *)
  let subst = unify (TypeVar_T "x") IntType_T in
  check bool "类型变量与具体类型合一应产生替换" true (SubstMap.mem "x" subst);
  check (testable pp_typ equal_typ) "类型变量应被替换为具体类型" IntType_T (SubstMap.find "x" subst)

(** 测试循环类型检测 *)
let test_occurs_check () =
  (* 测试循环类型检查：'a -> 'a *)
  let var_a = TypeVar_T "a" in
  let fun_type = FunType_T (var_a, var_a) in
  (* 测试循环类型检查 *)
  try
    let _ = unify var_a fun_type in
    fail "循环类型检查应阻止无限类型"
  with
  | TypeError _ -> () (* 预期的异常 *)
  | _ -> fail "应该抛出TypeError异常"

(** 测试函数类型合一 *)
let test_function_type_unification () =
  (* 测试相同函数类型的合一 *)
  let fun1 = FunType_T (IntType_T, StringType_T) in
  let fun2 = FunType_T (IntType_T, StringType_T) in
  check bool "相同函数类型合一应返回空替换" true (SubstMap.is_empty (unify fun1 fun2));

  (* 测试包含类型变量的函数类型合一 *)
  let fun_with_var = FunType_T (TypeVar_T "a", IntType_T) in
  let fun_concrete = FunType_T (StringType_T, IntType_T) in
  let subst = unify fun_with_var fun_concrete in
  check bool "函数类型合一应产生参数类型替换" true (SubstMap.mem "a" subst);
  check (testable pp_typ equal_typ) "类型变量应被替换为正确的参数类型" StringType_T (SubstMap.find "a" subst);

  (* 测试不兼容函数类型的合一失败 *)
  let fun_int_to_string = FunType_T (IntType_T, StringType_T) in
  let fun_string_to_bool = FunType_T (StringType_T, BoolType_T) in
  (* 测试不兼容函数类型的合一失败 *)
  try
    let _ = unify fun_int_to_string fun_string_to_bool in
    fail "不兼容函数类型合一应抛出类型错误"
  with
  | TypeError _ -> () (* 预期的异常 *)
  | _ -> fail "应该抛出TypeError异常"

(** 测试列表类型合一 *)
let test_list_type_unification () =
  (* 测试相同元素类型的列表合一 *)
  let list_int1 = ListType_T IntType_T in
  let list_int2 = ListType_T IntType_T in
  check bool "相同元素类型的列表合一应返回空替换" true (SubstMap.is_empty (unify list_int1 list_int2));

  (* 测试包含类型变量的列表合一 *)
  let list_var = ListType_T (TypeVar_T "t") in
  let list_string = ListType_T StringType_T in
  let subst = unify list_var list_string in
  check bool "列表类型合一应产生元素类型替换" true (SubstMap.mem "t" subst);
  check (testable pp_typ equal_typ) "列表元素类型变量应被正确替换" StringType_T (SubstMap.find "t" subst)

(** 测试元组类型合一 *)
let test_tuple_type_unification () =
  (* 测试相同元组类型的合一 *)
  let tuple1 = TupleType_T [ IntType_T; StringType_T ] in
  let tuple2 = TupleType_T [ IntType_T; StringType_T ] in
  check bool "相同元组类型合一应返回空替换" true (SubstMap.is_empty (unify tuple1 tuple2));

  (* 测试包含类型变量的元组合一 *)
  let tuple_var = TupleType_T [ TypeVar_T "x"; TypeVar_T "y" ] in
  let tuple_concrete = TupleType_T [ IntType_T; BoolType_T ] in
  let subst = unify tuple_var tuple_concrete in
  check bool "元组类型合一应产生所有元素的替换" true (SubstMap.mem "x" subst && SubstMap.mem "y" subst);

  (* 测试不同长度元组的合一失败 *)
  let tuple_2 = TupleType_T [ IntType_T; StringType_T ] in
  let tuple_3 = TupleType_T [ IntType_T; StringType_T; BoolType_T ] in
  (* 测试不同长度元组的合一失败 *)
  try
    let _ = unify tuple_2 tuple_3 in
    fail "不同长度元组合一应抛出类型错误"
  with
  | TypeError _ -> () (* 预期的异常 *)
  | _ -> fail "应该抛出TypeError异常"

(** 测试记录类型合一 *)
let test_record_type_unification () =
  (* 测试相同记录类型的合一 *)
  let record1 = RecordType_T [ ("name", StringType_T); ("age", IntType_T) ] in
  let record2 = RecordType_T [ ("age", IntType_T); ("name", StringType_T) ] in
  check bool "相同记录类型合一应返回空替换（字段顺序无关）" true (SubstMap.is_empty (unify record1 record2));

  (* 测试包含类型变量的记录合一 *)
  let record_var = RecordType_T [ ("id", TypeVar_T "t"); ("active", BoolType_T) ] in
  let record_concrete = RecordType_T [ ("id", IntType_T); ("active", BoolType_T) ] in
  let subst = unify record_var record_concrete in
  check bool "记录类型合一应产生字段类型替换" true (SubstMap.mem "t" subst);
  check (testable pp_typ equal_typ) "记录字段类型变量应被正确替换" IntType_T (SubstMap.find "t" subst);

  (* 测试不同字段的记录合一失败 *)
  let record_a = RecordType_T [ ("name", StringType_T) ] in
  let record_b = RecordType_T [ ("age", IntType_T) ] in
  (* 测试不同字段的记录合一失败 *)
  try
    let _ = unify record_a record_b in
    fail "不同字段的记录合一应抛出类型错误"
  with
  | TypeError _ -> () (* 预期的异常 *)
  | _ -> fail "应该抛出TypeError异常"

(** 测试复杂类型替换应用 *)
let test_substitution_application () =
  (* 创建一个替换 'a -> IntType_T *)
  let subst = single_subst "a" IntType_T in

  (* 测试对函数类型应用替换 *)
  let fun_type = FunType_T (TypeVar_T "a", TypeVar_T "a") in
  let applied = apply_subst subst fun_type in
  let expected = FunType_T (IntType_T, IntType_T) in
  check (testable pp_typ equal_typ) "类型替换应正确应用到函数类型" expected applied;

  (* 测试对列表类型应用替换 *)
  let list_type = ListType_T (TypeVar_T "a") in
  let applied_list = apply_subst subst list_type in
  let expected_list = ListType_T IntType_T in
  check (testable pp_typ equal_typ) "类型替换应正确应用到列表类型" expected_list applied_list

(** 测试替换组合 *)
let test_substitution_composition () =
  (* 创建两个替换：'b -> IntType_T 和 'a -> 'b *)
  let subst1 = single_subst "b" IntType_T in
  let subst2 = single_subst "a" (TypeVar_T "b") in
  let composed = compose_subst subst1 subst2 in

  (* 测试组合后的替换 *)
  let var_a = TypeVar_T "a" in
  let result = apply_subst composed var_a in
  check (testable pp_typ equal_typ) "替换组合应正确组合两个替换" IntType_T result;

  (* 测试单独的替换也工作正常 *)
  let var_b = TypeVar_T "b" in
  let result_b = apply_subst composed var_b in
  check (testable pp_typ equal_typ) "替换组合应保持其他替换的正确性" IntType_T result_b

(** 测试套件 *)
let tests =
  [
    ("基本类型合一", `Quick, test_basic_type_unification);
    ("类型变量合一", `Quick, test_type_variable_unification);
    ("循环类型检测", `Quick, test_occurs_check);
    ("函数类型合一", `Quick, test_function_type_unification);
    ("列表类型合一", `Quick, test_list_type_unification);
    ("元组类型合一", `Quick, test_tuple_type_unification);
    ("记录类型合一", `Quick, test_record_type_unification);
    ("类型替换应用", `Quick, test_substitution_application);
    ("替换组合", `Quick, test_substitution_composition);
  ]

let () = run "Types_Unify模块测试" [ ("类型合一", tests) ]
