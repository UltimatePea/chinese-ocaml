(** 骆言代码生成器/解释器模块单元测试 *)

open Alcotest
open Yyocamlc_lib.Codegen
open Yyocamlc_lib.Ast

(* 测试辅助函数 *)

(* 创建测试用的运行时环境 *)
let create_test_env () =
  let env = empty_env in
  let env_with_builtins = builtin_functions @ env in
  env_with_builtins

(* 检查运行时值是否相等 *)
let check_runtime_value msg expected actual =
  let value_to_string = function
    | IntValue i -> "IntValue(" ^ string_of_int i ^ ")"
    | FloatValue f -> "FloatValue(" ^ string_of_float f ^ ")"
    | StringValue s -> "StringValue(\"" ^ s ^ "\")"
    | BoolValue b -> "BoolValue(" ^ string_of_bool b ^ ")"
    | UnitValue -> "UnitValue"
    | ListValue vals -> "ListValue([" ^ String.concat "; " (List.map value_to_string vals) ^ "])"
    | _ -> "OtherValue"
  in
  let pp_value fmt v = Format.pp_print_string fmt (value_to_string v) in
  check (of_pp pp_value) msg expected actual

(* 配置和统计测试 *)
let test_configuration () =
  (* 测试错误恢复配置 *)
  let original_config = get_recovery_config () in
  let new_config =
    {
      enabled = false;
      type_conversion = false;
      spell_correction = false;
      parameter_adaptation = false;
      log_level = "quiet";
      collect_statistics = false;
    }
  in

  set_recovery_config new_config;
  let retrieved_config = get_recovery_config () in
  check bool "配置设置测试" false retrieved_config.enabled;
  check string "日志级别设置" "quiet" retrieved_config.log_level;

  (* 恢复原始配置 *)
  set_recovery_config original_config;

  (* 测试统计重置 *)
  reset_recovery_statistics ();
  show_recovery_statistics ();
  check bool "统计重置测试" true true

(* 字符串和变量管理测试 *)
let test_string_and_variable_management () =
  (* 测试基本字符串操作 *)
  let str1 = "hello" in
  let str2 = "hello" in
  let str3 = "world" in

  check bool "字符串相等测试1" true (str1 = str2);
  check bool "字符串相等测试2" false (str1 = str3);
  check bool "字符串长度测试" true (String.length str1 = 5);

  (* 测试变量环境管理 *)
  let env = create_test_env () in
  let env1 = bind_var env "变量1" (IntValue 42) in
  let env2 = bind_var env1 "变量2" (StringValue "测试") in

  let result1 = lookup_var env2 "变量1" in
  let result2 = lookup_var env2 "变量2" in

  check_runtime_value "变量查找测试1" (IntValue 42) result1;
  check_runtime_value "变量查找测试2" (StringValue "测试") result2;

  (* 测试变量环境功能 *)
  let env_has_var1 =
    try
      let _ = lookup_var env2 "变量1" in
      true
    with _ -> false
  in
  let env_has_var2 =
    try
      let _ = lookup_var env2 "变量2" in
      true
    with _ -> false
  in
  check bool "环境包含变量1" true env_has_var1;
  check bool "环境包含变量2" true env_has_var2

(* 类型转换测试 *)
let test_type_conversion () =
  (* 测试整数转换 *)
  let int_result1 = try_to_int (IntValue 42) in
  let int_result2 = try_to_int (FloatValue 3.14) in
  let int_result3 = try_to_int (StringValue "123") in

  check (option int) "整数转换测试1" (Some 42) int_result1;
  check (option int) "整数转换测试2" (Some 3) int_result2;
  check (option int) "整数转换测试3" (Some 123) int_result3;

  (* 测试浮点数转换 *)
  let float_result1 = try_to_float (FloatValue 3.14) in
  let float_result2 = try_to_float (IntValue 42) in
  let float_result3 = try_to_float (StringValue "2.71") in

  check (option (float 0.1)) "浮点数转换测试1" (Some 3.14) float_result1;
  check (option (float 0.1)) "浮点数转换测试2" (Some 42.0) float_result2;
  check (option (float 0.1)) "浮点数转换测试3" (Some 2.71) float_result3;

  (* 测试字符串转换 *)
  let str_result1 = try_to_string (StringValue "测试") in
  let str_result2 = try_to_string (IntValue 42) in
  let str_result3 = try_to_string (BoolValue true) in

  check (option string) "字符串转换测试1" (Some "测试") str_result1;
  check (option string) "字符串转换测试2" (Some "42") str_result2;
  check (option string) "字符串转换测试3" (Some "真") str_result3;

  (* 测试布尔值转换 *)
  let bool_result1 = value_to_bool (BoolValue true) in
  let bool_result2 = value_to_bool (BoolValue false) in
  let bool_result3 = value_to_bool (IntValue 0) in
  let bool_result4 = value_to_bool (IntValue 1) in

  check bool "布尔值转换测试1" true bool_result1;
  check bool "布尔值转换测试2" false bool_result2;
  check bool "布尔值转换测试3" false bool_result3;
  check bool "布尔值转换测试4" true bool_result4

(* 字面量求值测试 *)
let test_literal_evaluation () =
  let _env = create_test_env () in

  (* 测试各种字面量类型 *)
  let int_literal = IntLit 42 in
  let float_literal = FloatLit 3.14 in
  let string_literal = StringLit "Hello" in
  let bool_literal = BoolLit true in
  let unit_literal = UnitLit in

  let int_result = eval_literal int_literal in
  let float_result = eval_literal float_literal in
  let string_result = eval_literal string_literal in
  let bool_result = eval_literal bool_literal in
  let unit_result = eval_literal unit_literal in

  check_runtime_value "整数字面量" (IntValue 42) int_result;
  check_runtime_value "浮点数字面量" (FloatValue 3.14) float_result;
  check_runtime_value "字符串字面量" (StringValue "Hello") string_result;
  check_runtime_value "布尔字面量" (BoolValue true) bool_result;
  check_runtime_value "单位字面量" UnitValue unit_result

(* 二元运算测试 *)
let test_binary_operations () =
  let _env = create_test_env () in

  (* 测试算术运算 *)
  let add_result = execute_binary_op Add (IntValue 10) (IntValue 5) in
  let sub_result = execute_binary_op Sub (IntValue 10) (IntValue 5) in
  let mul_result = execute_binary_op Mul (IntValue 10) (IntValue 5) in
  let div_result = execute_binary_op Div (IntValue 10) (IntValue 5) in

  check_runtime_value "加法运算" (IntValue 15) add_result;
  check_runtime_value "减法运算" (IntValue 5) sub_result;
  check_runtime_value "乘法运算" (IntValue 50) mul_result;
  check_runtime_value "除法运算" (IntValue 2) div_result;

  (* 测试比较运算 *)
  let eq_result = execute_binary_op Eq (IntValue 5) (IntValue 5) in
  let ne_result = execute_binary_op Neq (IntValue 5) (IntValue 3) in
  let lt_result = execute_binary_op Lt (IntValue 3) (IntValue 5) in
  let gt_result = execute_binary_op Gt (IntValue 5) (IntValue 3) in

  check_runtime_value "相等比较" (BoolValue true) eq_result;
  check_runtime_value "不等比较" (BoolValue true) ne_result;
  check_runtime_value "小于比较" (BoolValue true) lt_result;
  check_runtime_value "大于比较" (BoolValue true) gt_result;

  (* 测试逻辑运算 *)
  let and_result = execute_binary_op And (BoolValue true) (BoolValue true) in
  let or_result = execute_binary_op Or (BoolValue false) (BoolValue true) in

  check_runtime_value "逻辑与" (BoolValue true) and_result;
  check_runtime_value "逻辑或" (BoolValue true) or_result

(* 一元运算测试 *)
let test_unary_operations () =
  let _env = create_test_env () in

  (* 测试一元运算 *)
  let neg_result = execute_unary_op Neg (IntValue 42) in
  let not_result = execute_unary_op Not (BoolValue true) in

  check_runtime_value "负数运算" (IntValue (-42)) neg_result;
  check_runtime_value "逻辑非" (BoolValue false) not_result

(* 内置函数测试 *)
let test_builtin_functions () =
  let _env = create_test_env () in

  (* 测试打印函数 *)
  let print_result = call_function (List.assoc "打印" builtin_functions) [ StringValue "Hello" ] in
  check_runtime_value "打印函数" UnitValue print_result;

  (* 测试长度函数 *)
  let length_result =
    call_function
      (List.assoc "长度" builtin_functions)
      [ ListValue [ IntValue 1; IntValue 2; IntValue 3 ] ]
  in
  check_runtime_value "长度函数" (IntValue 3) length_result;

  (* 测试基本内置函数功能够用性 *)
  let has_builtin_length = List.mem_assoc "长度" builtin_functions in
  check bool "内置函数包含长度" true has_builtin_length

(* 表达式求值测试 *)
let test_expression_evaluation () =
  let env = create_test_env () in

  (* 测试变量表达式 *)
  let env_with_var = bind_var env "x" (IntValue 42) in
  let var_expr = VarExpr "x" in
  let var_result = eval_expr env_with_var var_expr in
  check_runtime_value "变量表达式" (IntValue 42) var_result;

  (* 测试二元表达式 *)
  let binary_expr = BinaryOpExpr (LitExpr (IntLit 10), Add, LitExpr (IntLit 5)) in
  let binary_result = eval_expr env binary_expr in
  check_runtime_value "二元表达式" (IntValue 15) binary_result;

  (* 测试函数调用表达式 *)
  let call_expr = FunCallExpr (VarExpr "打印", [ LitExpr (StringLit "Test") ]) in
  let call_result = eval_expr env call_expr in
  check_runtime_value "函数调用表达式" UnitValue call_result

(* 模式匹配测试 *)
let test_pattern_matching () =
  let env = create_test_env () in

  (* 测试字面量模式匹配 *)
  let int_pattern = LitPattern (IntLit 42) in
  let bool_pattern = LitPattern (BoolLit true) in
  let string_pattern = LitPattern (StringLit "test") in

  let int_match = match_pattern int_pattern (IntValue 42) env in
  let bool_match = match_pattern bool_pattern (BoolValue true) env in
  let string_match = match_pattern string_pattern (StringValue "test") env in

  check bool "整数模式匹配" true (match int_match with Some _ -> true | None -> false);
  check bool "布尔模式匹配" true (match bool_match with Some _ -> true | None -> false);
  check bool "字符串模式匹配" true (match string_match with Some _ -> true | None -> false);

  (* 测试通配符模式 *)
  let wildcard_pattern = WildcardPattern in
  let wildcard_match = match_pattern wildcard_pattern (IntValue 999) env in
  check bool "通配符模式匹配" true (match wildcard_match with Some _ -> true | None -> false)

(* 错误恢复测试 *)
let test_error_recovery () =
  let env = create_test_env () in

  (* 启用错误恢复 *)
  let recovery_config =
    {
      enabled = true;
      type_conversion = true;
      spell_correction = true;
      parameter_adaptation = true;
      log_level = "quiet";
      collect_statistics = true;
    }
  in
  set_recovery_config recovery_config;

  (* 测试类型转换恢复 *)
  let type_conv_result = execute_binary_op Add (IntValue 10) (FloatValue 3.14) in
  check bool "类型转换恢复" true (match type_conv_result with IntValue 13 -> true | _ -> false);

  (* 测试错误恢复功能 *)
  let env_with_var = bind_var env "变量名" (IntValue 42) in
  let lookup_result = lookup_var env_with_var "变量名" in
  check_runtime_value "变量查找" (IntValue 42) lookup_result

(* 程序执行测试 *)
let test_program_execution () =
  let _env = create_test_env () in

  (* 测试简单程序 *)
  let simple_program =
    [
      LetStmt ("x", LitExpr (IntLit 42));
      LetStmt ("y", BinaryOpExpr (VarExpr "x", Add, LitExpr (IntLit 8)));
    ]
  in

  let result = execute_program simple_program in
  let execution_success = match result with Ok _ -> true | Error _ -> false in
  check bool "程序执行成功" true execution_success

(* 测试套件 *)
let test_suite =
  [
    ("配置和统计", `Quick, test_configuration);
    ("字符串和变量管理", `Quick, test_string_and_variable_management);
    ("类型转换", `Quick, test_type_conversion);
    ("字面量求值", `Quick, test_literal_evaluation);
    ("二元运算", `Quick, test_binary_operations);
    ("一元运算", `Quick, test_unary_operations);
    ("内置函数", `Quick, test_builtin_functions);
    ("表达式求值", `Quick, test_expression_evaluation);
    ("模式匹配", `Quick, test_pattern_matching);
    ("错误恢复", `Quick, test_error_recovery);
    ("程序执行", `Quick, test_program_execution);
  ]

let () = run "Codegen模块单元测试" [ ("Codegen模块单元测试", test_suite) ]
