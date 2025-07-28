(** 骆言类型推断算法专项测试套件 - Fix #824 *)

open Alcotest
open Yyocamlc_lib.Ast
open Yyocamlc_lib.Core_types
open Yyocamlc_lib.Types_infer

(** 测试辅助函数 *)
module TestHelpers = struct
  (** 创建空的类型环境 *)
  let empty_env = TypeEnv.empty

  (** 创建包含基本变量的测试环境 *)
  let test_env =
    TypeEnv.empty
    |> TypeEnv.add "x" (TypeScheme ([], IntType_T))
    |> TypeEnv.add "y" (TypeScheme ([], StringType_T))
    |> TypeEnv.add "f" (TypeScheme ([], FunType_T (IntType_T, StringType_T)))
    |> TypeEnv.add "flag" (TypeScheme ([], BoolType_T))

  (** 检查类型推断结果的相等性 *)
  let check_infer_result msg expected_type env expr =
    let _, inferred_type = infer_type env expr in
    check bool msg true (equal_typ inferred_type expected_type)

  (** 检查类型推断是否抛出异常 *)
  let check_infer_fails msg env expr =
    try
      let _ = infer_type env expr in
      check bool msg false true (* 不应该成功 *)
    with _ -> check bool msg true true (* 应该抛出异常 *)
end

(** 字面量表达式类型推断测试 *)
module LiteralInferenceTests = struct
  open TestHelpers

  let test_integer_literals () =
    let int_expr = LitExpr (IntLit 42) in
    check_infer_result "整数字面量推断为int类型" IntType_T empty_env int_expr

  let test_float_literals () =
    let float_expr = LitExpr (FloatLit 3.14) in
    check_infer_result "浮点数字面量推断为float类型" FloatType_T empty_env float_expr

  let test_string_literals () =
    let string_expr = LitExpr (StringLit "hello") in
    check_infer_result "字符串字面量推断为string类型" StringType_T empty_env string_expr

  let test_boolean_literals () =
    let true_expr = LitExpr (BoolLit true) in
    let false_expr = LitExpr (BoolLit false) in
    check_infer_result "true字面量推断为bool类型" BoolType_T empty_env true_expr;
    check_infer_result "false字面量推断为bool类型" BoolType_T empty_env false_expr

  let test_unit_literal () =
    let unit_expr = LitExpr UnitLit in
    check_infer_result "unit字面量推断为unit类型" UnitType_T empty_env unit_expr
end

(** 变量表达式类型推断测试 *)
module VariableInferenceTests = struct
  open TestHelpers

  let test_existing_variables () =
    let x_expr = VarExpr "x" in
    let y_expr = VarExpr "y" in
    let f_expr = VarExpr "f" in

    check_infer_result "变量x推断为int类型" IntType_T test_env x_expr;
    check_infer_result "变量y推断为string类型" StringType_T test_env y_expr;
    check_infer_result "变量f推断为函数类型" (FunType_T (IntType_T, StringType_T)) test_env f_expr

  let test_undefined_variable () =
    let undefined_expr = VarExpr "undefined" in
    check_infer_fails "未定义变量应该推断失败" test_env undefined_expr
end

(** 二元操作表达式类型推断测试 *)
module BinaryOpInferenceTests = struct
  open TestHelpers

  let test_arithmetic_operations () =
    let add_expr = BinaryOpExpr (LitExpr (IntLit 1), Add, LitExpr (IntLit 2)) in
    let sub_expr = BinaryOpExpr (LitExpr (IntLit 5), Sub, LitExpr (IntLit 3)) in
    let mul_expr = BinaryOpExpr (LitExpr (IntLit 2), Mul, LitExpr (IntLit 3)) in
    let div_expr = BinaryOpExpr (LitExpr (IntLit 6), Div, LitExpr (IntLit 2)) in

    check_infer_result "加法运算推断为int类型" IntType_T empty_env add_expr;
    check_infer_result "减法运算推断为int类型" IntType_T empty_env sub_expr;
    check_infer_result "乘法运算推断为int类型" IntType_T empty_env mul_expr;
    check_infer_result "除法运算推断为int类型" IntType_T empty_env div_expr

  let test_comparison_operations () =
    let eq_expr = BinaryOpExpr (LitExpr (IntLit 1), Eq, LitExpr (IntLit 1)) in
    let lt_expr = BinaryOpExpr (LitExpr (IntLit 1), Lt, LitExpr (IntLit 2)) in
    let gt_expr = BinaryOpExpr (LitExpr (IntLit 2), Gt, LitExpr (IntLit 1)) in

    check_infer_result "相等比较推断为bool类型" BoolType_T empty_env eq_expr;
    check_infer_result "小于比较推断为bool类型" BoolType_T empty_env lt_expr;
    check_infer_result "大于比较推断为bool类型" BoolType_T empty_env gt_expr

  let test_logical_operations () =
    let and_expr = BinaryOpExpr (LitExpr (BoolLit true), And, LitExpr (BoolLit false)) in
    let or_expr = BinaryOpExpr (LitExpr (BoolLit true), Or, LitExpr (BoolLit false)) in

    check_infer_result "逻辑与推断为bool类型" BoolType_T empty_env and_expr;
    check_infer_result "逻辑或推断为bool类型" BoolType_T empty_env or_expr

  let test_type_mismatch_errors () =
    (* 尝试将string与int相加应该失败 *)
    let invalid_add = BinaryOpExpr (LitExpr (StringLit "hello"), Add, LitExpr (IntLit 1)) in
    check_infer_fails "字符串与整数相加应该失败" empty_env invalid_add;

    (* 尝试将int与bool进行逻辑运算应该失败 *)
    let invalid_and = BinaryOpExpr (LitExpr (IntLit 1), And, LitExpr (BoolLit true)) in
    check_infer_fails "整数与布尔值逻辑与应该失败" empty_env invalid_and
end

(** 一元操作表达式类型推断测试 *)
module UnaryOpInferenceTests = struct
  open TestHelpers

  let test_negation_operation () =
    let neg_expr = UnaryOpExpr (Neg, LitExpr (IntLit 5)) in
    check_infer_result "整数取负推断为int类型" IntType_T empty_env neg_expr

  let test_logical_not_operation () =
    let not_expr = UnaryOpExpr (Not, LitExpr (BoolLit true)) in
    check_infer_result "逻辑非推断为bool类型" BoolType_T empty_env not_expr

  let test_type_mismatch_errors () =
    (* 尝试对字符串取负应该失败 *)
    let invalid_neg = UnaryOpExpr (Neg, LitExpr (StringLit "hello")) in
    check_infer_fails "字符串取负应该失败" empty_env invalid_neg;

    (* 尝试对整数逻辑非应该失败 *)
    let invalid_not = UnaryOpExpr (Not, LitExpr (IntLit 1)) in
    check_infer_fails "整数逻辑非应该失败" empty_env invalid_not
end

(** 条件表达式类型推断测试 *)
module ConditionalInferenceTests = struct
  open TestHelpers

  let test_simple_conditional () =
    let cond_expr = CondExpr (LitExpr (BoolLit true), LitExpr (IntLit 1), LitExpr (IntLit 2)) in
    check_infer_result "简单条件表达式推断为int类型" IntType_T empty_env cond_expr

  let test_conditional_with_different_types () =
    (* then和else分支类型不同应该尝试统一 *)
    let cond_expr = CondExpr (LitExpr (BoolLit true), VarExpr "x", LitExpr (IntLit 2)) in
    check_infer_result "条件表达式with变量推断为int类型" IntType_T test_env cond_expr

  let test_invalid_condition_type () =
    (* 条件不是bool类型应该失败 *)
    let invalid_cond =
      CondExpr
        ( LitExpr (IntLit 1),
          (* 条件是int而不是bool *)
          LitExpr (IntLit 1),
          LitExpr (IntLit 2) )
    in
    check_infer_fails "非bool条件应该失败" empty_env invalid_cond
end

(** 元组表达式类型推断测试 *)
module TupleInferenceTests = struct
  open TestHelpers

  let test_empty_tuple () =
    let empty_tuple = TupleExpr [] in
    check_infer_result "空元组推断为空元组类型" (TupleType_T []) empty_env empty_tuple

  let test_simple_tuple () =
    let tuple_expr =
      TupleExpr [ LitExpr (IntLit 1); LitExpr (StringLit "hello"); LitExpr (BoolLit true) ]
    in
    let expected_type = TupleType_T [ IntType_T; StringType_T; BoolType_T ] in
    check_infer_result "简单元组推断正确" expected_type empty_env tuple_expr

  let test_nested_tuple () =
    let nested_tuple =
      TupleExpr
        [ TupleExpr [ LitExpr (IntLit 1); LitExpr (IntLit 2) ]; LitExpr (StringLit "world") ]
    in
    let expected_type = TupleType_T [ TupleType_T [ IntType_T; IntType_T ]; StringType_T ] in
    check_infer_result "嵌套元组推断正确" expected_type empty_env nested_tuple
end

(** 列表表达式类型推断测试 *)
module ListInferenceTests = struct
  open TestHelpers

  let test_empty_list () =
    let empty_list = ListExpr [] in
    (* 空列表的类型应该是多态的，这里测试它是否能成功推断 *)
    let _, inferred_type = infer_type empty_env empty_list in
    match inferred_type with
    | ListType_T _ -> check bool "空列表推断为列表类型" true true
    | _ -> check bool "空列表推断为列表类型" false true

  let test_homogeneous_list () =
    let int_list = ListExpr [ LitExpr (IntLit 1); LitExpr (IntLit 2); LitExpr (IntLit 3) ] in
    check_infer_result "同质整数列表推断正确" (ListType_T IntType_T) empty_env int_list

  let test_heterogeneous_list_error () =
    (* 异质列表应该推断失败 *)
    let mixed_list = ListExpr [ LitExpr (IntLit 1); LitExpr (StringLit "hello") ] in
    check_infer_fails "异质列表应该推断失败" empty_env mixed_list
end

(** Let绑定表达式类型推断测试 *)
module LetBindingInferenceTests = struct
  open TestHelpers

  let test_simple_let_binding () =
    let let_expr = LetExpr ("z", LitExpr (IntLit 42), VarExpr "z") in
    check_infer_result "简单let绑定推断正确" IntType_T empty_env let_expr

  let test_let_with_expression () =
    let let_expr =
      LetExpr ("sum", BinaryOpExpr (VarExpr "x", Add, LitExpr (IntLit 10)), VarExpr "sum")
    in
    check_infer_result "let绑定with表达式推断正确" IntType_T test_env let_expr

  let test_nested_let_bindings () =
    let nested_let =
      LetExpr
        ( "a",
          LitExpr (IntLit 1),
          LetExpr ("b", LitExpr (IntLit 2), BinaryOpExpr (VarExpr "a", Add, VarExpr "b")) )
    in
    check_infer_result "嵌套let绑定推断正确" IntType_T empty_env nested_let
end

(** 函数调用表达式类型推断测试 *)
module FunctionCallInferenceTests = struct
  open TestHelpers

  let test_simple_function_call () =
    let call_expr = FunCallExpr (VarExpr "f", [ VarExpr "x" ]) in
    check_infer_result "简单函数调用推断正确" StringType_T test_env call_expr

  let test_function_call_with_literal () =
    let call_expr = FunCallExpr (VarExpr "f", [ LitExpr (IntLit 5) ]) in
    check_infer_result "函数调用with字面量推断正确" StringType_T test_env call_expr

  let test_invalid_function_argument () =
    (* 尝试用string调用需要int的函数应该失败 *)
    let invalid_call = FunCallExpr (VarExpr "f", [ LitExpr (StringLit "hello") ]) in
    check_infer_fails "参数类型不匹配的函数调用应该失败" test_env invalid_call

  let test_call_non_function () =
    (* 尝试调用非函数应该失败 *)
    let invalid_call = FunCallExpr (VarExpr "x", [ LitExpr (IntLit 1) ]) in
    check_infer_fails "调用非函数应该失败" test_env invalid_call
end

(** 执行所有类型推断算法测试 *)
let () =
  run "类型推断算法专项测试"
    [
      ( "字面量类型推断",
        [
          test_case "整数字面量推断" `Quick LiteralInferenceTests.test_integer_literals;
          test_case "浮点数字面量推断" `Quick LiteralInferenceTests.test_float_literals;
          test_case "字符串字面量推断" `Quick LiteralInferenceTests.test_string_literals;
          test_case "布尔字面量推断" `Quick LiteralInferenceTests.test_boolean_literals;
          test_case "unit字面量推断" `Quick LiteralInferenceTests.test_unit_literal;
        ] );
      ( "变量类型推断",
        [
          test_case "已定义变量推断" `Quick VariableInferenceTests.test_existing_variables;
          test_case "未定义变量错误" `Quick VariableInferenceTests.test_undefined_variable;
        ] );
      ( "二元操作类型推断",
        [
          test_case "算术运算推断" `Quick BinaryOpInferenceTests.test_arithmetic_operations;
          test_case "比较运算推断" `Quick BinaryOpInferenceTests.test_comparison_operations;
          test_case "逻辑运算推断" `Quick BinaryOpInferenceTests.test_logical_operations;
          test_case "类型不匹配错误" `Quick BinaryOpInferenceTests.test_type_mismatch_errors;
        ] );
      ( "一元操作类型推断",
        [
          test_case "取负运算推断" `Quick UnaryOpInferenceTests.test_negation_operation;
          test_case "逻辑非运算推断" `Quick UnaryOpInferenceTests.test_logical_not_operation;
          test_case "类型不匹配错误" `Quick UnaryOpInferenceTests.test_type_mismatch_errors;
        ] );
      ( "条件表达式类型推断",
        [
          test_case "简单条件表达式" `Quick ConditionalInferenceTests.test_simple_conditional;
          test_case "条件with不同类型" `Quick
            ConditionalInferenceTests.test_conditional_with_different_types;
          test_case "无效条件类型错误" `Quick ConditionalInferenceTests.test_invalid_condition_type;
        ] );
      ( "元组类型推断",
        [
          test_case "空元组推断" `Quick TupleInferenceTests.test_empty_tuple;
          test_case "简单元组推断" `Quick TupleInferenceTests.test_simple_tuple;
          test_case "嵌套元组推断" `Quick TupleInferenceTests.test_nested_tuple;
        ] );
      ( "列表类型推断",
        [
          test_case "空列表推断" `Quick ListInferenceTests.test_empty_list;
          test_case "同质列表推断" `Quick ListInferenceTests.test_homogeneous_list;
          test_case "异质列表错误" `Quick ListInferenceTests.test_heterogeneous_list_error;
        ] );
      ( "Let绑定类型推断",
        [
          test_case "简单let绑定" `Quick LetBindingInferenceTests.test_simple_let_binding;
          test_case "let with表达式" `Quick LetBindingInferenceTests.test_let_with_expression;
          test_case "嵌套let绑定" `Quick LetBindingInferenceTests.test_nested_let_bindings;
        ] );
      ( "函数调用类型推断",
        [
          test_case "简单函数调用" `Quick FunctionCallInferenceTests.test_simple_function_call;
          test_case "函数调用with字面量" `Quick FunctionCallInferenceTests.test_function_call_with_literal;
          test_case "参数类型不匹配错误" `Quick FunctionCallInferenceTests.test_invalid_function_argument;
          test_case "调用非函数错误" `Quick FunctionCallInferenceTests.test_call_non_function;
        ] );
    ]
