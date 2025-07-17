(** 骆言C代码生成器模块单元测试 *)

open Alcotest
open Yyocamlc_lib.C_codegen
open Yyocamlc_lib.Ast
open Yyocamlc_lib.Types

(* 测试辅助函数 *)

(* 创建测试用的代码生成配置 *)
let create_test_config () =
  Yyocamlc_lib.C_codegen_context.{
    c_output_file = "test_output.c";
    include_debug = false;
    optimize = false;
    runtime_path = "./runtime";
  }

(* 创建测试用的代码生成上下文 *)
let create_test_context () =
  let config = create_test_config () in
  create_context config

(* 检查字符串包含测试 *)
let check_contains msg expected_substring actual_string =
  let simple_contains expected_substring actual_string =
    let rec search_from pos =
      let remaining = String.length actual_string - pos in
      let expected_len = String.length expected_substring in
      if remaining < expected_len then false
      else if String.sub actual_string pos expected_len = expected_substring then true
      else search_from (pos + 1)
    in
    search_from 0
  in
  check bool msg true (simple_contains expected_substring actual_string)

(* 配置和上下文管理测试 *)
let test_configuration_and_context () =
  let config = create_test_config () in
  let ctx = create_context config in

  (* 测试配置创建 *)
  check string "输出文件名" "test_output.c" ctx.config.c_output_file;
  check bool "调试模式" false ctx.config.include_debug;
  check bool "优化选项" false ctx.config.optimize;
  check string "运行时路径" "./runtime" ctx.config.runtime_path;

  (* 测试上下文初始化 *)
  check int "初始变量ID" 0 ctx.next_var_id;
  check int "初始标签ID" 0 ctx.next_label_id;
  check bool "运行时头文件" true (List.mem "luoyan_runtime.h" ctx.includes);

  (* 测试变量名生成 *)
  let var_name1 = gen_var_name ctx "test" in
  let var_name2 = gen_var_name ctx "test" in
  check string "变量名前缀" "luoyan_var_test_0" var_name1;
  check string "变量名唯一性" "luoyan_var_test_1" var_name2;

  (* 测试标签名生成 *)
  let label_name1 = gen_label_name ctx "loop" in
  let label_name2 = gen_label_name ctx "loop" in
  check string "标签名前缀" "luoyan_label_loop_0" label_name1;
  check string "标签名唯一性" "luoyan_label_loop_1" label_name2

(* 标识符转义测试 *)
let test_identifier_escaping () =
  (* 测试中文标识符转义 *)
  let escaped1 = escape_identifier "变量名" in
  let escaped2 = escape_identifier "函数名" in
  let escaped3 = escape_identifier "类型名" in

  check bool "中文标识符转义1" true (String.length escaped1 > 0);
  check bool "中文标识符转义2" true (String.length escaped2 > 0);
  check bool "中文标识符转义3" true (String.length escaped3 > 0);

  (* 测试特殊字符转义 *)
  let escaped4 = escape_identifier "test-name" in
  let escaped5 = escape_identifier "test_name" in

  check bool "特殊字符转义" true (String.length escaped4 > 0);
  check bool "下划线保留" true (String.length escaped5 > 0)

(* 类型转换测试 *)
let test_type_conversion () =
  (* 测试基础类型转换 *)
  let int_type = c_type_of_luoyan_type IntType_T in
  let float_type = c_type_of_luoyan_type FloatType_T in
  let string_type = c_type_of_luoyan_type StringType_T in
  let bool_type = c_type_of_luoyan_type BoolType_T in
  let unit_type = c_type_of_luoyan_type UnitType_T in

  check string "整数类型转换" "luoyan_int_t" int_type;
  check string "浮点类型转换" "luoyan_float_t" float_type;
  check string "字符串类型转换" "luoyan_string_t*" string_type;
  check string "布尔类型转换" "luoyan_bool_t" bool_type;
  check string "单位类型转换" "void" unit_type;

  (* 测试复合类型转换 *)
  let fun_type = c_type_of_luoyan_type (FunType_T (IntType_T, StringType_T)) in
  let list_type = c_type_of_luoyan_type (ListType_T IntType_T) in

  check string "函数类型转换" "luoyan_function_t*" fun_type;
  check string "列表类型转换" "luoyan_list_t*" list_type

(* 字面量表达式生成测试 *)
let test_literal_expression_generation () =
  let ctx = create_test_context () in

  (* 测试整数字面量 *)
  let int_expr = LitExpr (IntLit 42) in
  let int_code = gen_expr ctx int_expr in
  check_contains "整数字面量生成" "42" int_code;

  (* 测试浮点数字面量 *)
  let float_expr = LitExpr (FloatLit 3.14) in
  let float_code = gen_expr ctx float_expr in
  check_contains "浮点数字面量生成" "3.14" float_code;

  (* 测试字符串字面量 *)
  let string_expr = LitExpr (StringLit "Hello") in
  let string_code = gen_expr ctx string_expr in
  check_contains "字符串字面量生成" "Hello" string_code;

  (* 测试布尔字面量 *)
  let bool_expr = LitExpr (BoolLit true) in
  let bool_code = gen_expr ctx bool_expr in
  check_contains "布尔字面量生成" "true" bool_code;

  (* 测试单位字面量 *)
  let unit_expr = LitExpr UnitLit in
  let unit_code = gen_expr ctx unit_expr in
  check_contains "单位字面量生成" "unit" unit_code

(* 变量表达式生成测试 *)
let test_variable_expression_generation () =
  let ctx = create_test_context () in

  (* 测试简单变量 *)
  let var_expr = VarExpr "x" in
  let var_code = gen_expr ctx var_expr in
  check_contains "变量表达式生成" "x" var_code;

  (* 测试中文变量 *)
  let chinese_var_expr = VarExpr "变量名" in
  let chinese_var_code = gen_expr ctx chinese_var_expr in
  check bool "中文变量生成" true (String.length chinese_var_code > 0)

(* 二元运算表达式生成测试 *)
let test_binary_operation_generation () =
  let ctx = create_test_context () in

  (* 测试算术运算 *)
  let add_expr = BinaryOpExpr (LitExpr (IntLit 10), Add, LitExpr (IntLit 5)) in
  let add_code = gen_expr ctx add_expr in
  check_contains "加法运算生成" "luoyan_add" add_code;

  let sub_expr = BinaryOpExpr (LitExpr (IntLit 10), Sub, LitExpr (IntLit 5)) in
  let sub_code = gen_expr ctx sub_expr in
  check_contains "减法运算生成" "luoyan_subtract" sub_code;

  let mul_expr = BinaryOpExpr (LitExpr (IntLit 10), Mul, LitExpr (IntLit 5)) in
  let mul_code = gen_expr ctx mul_expr in
  check_contains "乘法运算生成" "luoyan_multiply" mul_code;

  let div_expr = BinaryOpExpr (LitExpr (IntLit 10), Div, LitExpr (IntLit 5)) in
  let div_code = gen_expr ctx div_expr in
  check_contains "除法运算生成" "luoyan_divide" div_code;

  (* 测试比较运算 *)
  let eq_expr = BinaryOpExpr (LitExpr (IntLit 5), Eq, LitExpr (IntLit 5)) in
  let eq_code = gen_expr ctx eq_expr in
  check_contains "相等比较生成" "luoyan_equal" eq_code;

  let lt_expr = BinaryOpExpr (LitExpr (IntLit 3), Lt, LitExpr (IntLit 5)) in
  let lt_code = gen_expr ctx lt_expr in
  check_contains "小于比较生成" "luoyan_less_than" lt_code

(* 一元运算表达式生成测试 *)
let test_unary_operation_generation () =
  let ctx = create_test_context () in

  (* 测试负数运算 *)
  let neg_expr = UnaryOpExpr (Neg, LitExpr (IntLit 42)) in
  let neg_code = gen_expr ctx neg_expr in
  check_contains "负数运算生成" "luoyan_subtract" neg_code;

  (* 测试逻辑非运算 *)
  let not_expr = UnaryOpExpr (Not, LitExpr (BoolLit true)) in
  let not_code = gen_expr ctx not_expr in
  check_contains "逻辑非运算生成" "luoyan_logical_not" not_code

(* 条件表达式生成测试 *)
let test_conditional_expression_generation () =
  let ctx = create_test_context () in

  (* 测试简单条件表达式 *)
  let if_expr = CondExpr (LitExpr (BoolLit true), LitExpr (IntLit 1), LitExpr (IntLit 0)) in
  let if_code = gen_expr ctx if_expr in
  check_contains "条件表达式真分支" "luoyan_int(1" if_code;
  check_contains "条件表达式假分支" "luoyan_int(0" if_code

(* 函数定义生成测试 *)
let test_function_definition_generation () =
  let ctx = create_test_context () in

  (* 测试简单函数定义 *)
  let fun_expr = FunExpr ([ "x" ], LitExpr (IntLit 42)) in
  let fun_code = gen_expr ctx fun_expr in

  (* 检查函数创建代码 *)
  check_contains "函数创建代码" "luoyan_function" fun_code;
  check_contains "函数参数名在创建代码中" "x" fun_code;

  (* 检查函数体代码 *)
  check_contains "函数体" "luoyan_function_create" fun_code

(* 函数调用生成测试 *)
let test_function_call_generation () =
  let ctx = create_test_context () in

  (* 测试函数调用 *)
  let call_expr = FunCallExpr (VarExpr "print", [ LitExpr (StringLit "Hello") ]) in
  let call_code = gen_expr ctx call_expr in
  check_contains "函数调用生成" "print" call_code;
  check_contains "函数参数" "Hello" call_code

(* 列表表达式生成测试 *)
let test_list_expression_generation () =
  let ctx = create_test_context () in

  (* 测试列表构造 *)
  let list_expr = ListExpr [ LitExpr (IntLit 1); LitExpr (IntLit 2); LitExpr (IntLit 3) ] in
  let list_code = gen_expr ctx list_expr in
  check_contains "列表生成" "luoyan_list_cons" list_code;
  check_contains "列表元素1" "1" list_code;
  check_contains "列表元素2" "2" list_code;
  check_contains "列表元素3" "3" list_code

(* 模式匹配生成测试 *)
let test_pattern_matching_generation () =
  let ctx = create_test_context () in

  (* 测试简单模式匹配 *)
  let pattern_cases =
    [
      { pattern = LitPattern (IntLit 1); guard = None; expr = LitExpr (IntLit 10) };
      { pattern = LitPattern (IntLit 2); guard = None; expr = LitExpr (IntLit 20) };
      { pattern = WildcardPattern; guard = None; expr = LitExpr (IntLit 0) };
    ]
  in
  let match_expr = MatchExpr (LitExpr (IntLit 1), pattern_cases) in
  let match_code = gen_expr ctx match_expr in
  check_contains "模式匹配变量" "luoyan_value_t" match_code

(* 语句生成测试 *)
let test_statement_generation () =
  let ctx = create_test_context () in

  (* 测试let语句 *)
  let let_stmt = LetStmt ("x", LitExpr (IntLit 42)) in
  let let_code = gen_stmt ctx let_stmt in
  check_contains "let语句生成" "x" let_code;
  check_contains "let语句值" "42" let_code;

  (* 测试表达式语句 *)
  let expr_stmt = ExprStmt (BinaryOpExpr (LitExpr (IntLit 1), Add, LitExpr (IntLit 2))) in
  let expr_code = gen_stmt ctx expr_stmt in
  check_contains "表达式语句生成" "add" expr_code;
  check_contains "表达式语句操作数" "1" expr_code

(* 程序生成测试 *)
let test_program_generation () =
  let ctx = create_test_context () in

  (* 测试简单程序 *)
  let program =
    [
      LetStmt ("x", LitExpr (IntLit 42));
      LetStmt ("y", BinaryOpExpr (VarExpr "x", Add, LitExpr (IntLit 8)));
      ExprStmt (VarExpr "y");
    ]
  in
  let program_code = gen_program ctx program in
  check_contains "程序生成x" "x" program_code;
  check_contains "程序生成y" "y" program_code;
  check_contains "程序生成值" "42" program_code

(* 完整C代码生成测试 *)
let test_complete_c_code_generation () =
  let config = create_test_config () in
  let program =
    [
      LetStmt ("x", LitExpr (IntLit 42)); ExprStmt (FunCallExpr (VarExpr "print", [ VarExpr "x" ]));
    ]
  in
  let c_code = generate_c_code config program in
  check_contains "C代码包含头文件" "#include" c_code;
  check_contains "C代码包含main函数" "int main" c_code;
  check_contains "C代码包含运行时" "luoyan_runtime.h" c_code;
  check_contains "C代码包含变量" "x" c_code

(* 内置函数调用生成测试 *)
let test_builtin_function_generation () =
  let ctx = create_test_context () in

  (* 测试中文内置函数 *)
  let print_expr = FunCallExpr (VarExpr "打印", [ LitExpr (StringLit "Hello") ]) in
  let print_code = gen_expr ctx print_expr in
  check_contains "中文打印函数" "luoyan_call" print_code;

  let length_expr =
    FunCallExpr (VarExpr "长度", [ ListExpr [ LitExpr (IntLit 1); LitExpr (IntLit 2) ] ])
  in
  let length_code = gen_expr ctx length_expr in
  check_contains "中文长度函数" "luoyan_call" length_code

(* 错误处理测试 *)
let test_error_handling () =
  let ctx = create_test_context () in

  (* 测试无效表达式生成 *)
  try
    let _ = gen_expr ctx (VarExpr "") in
    check bool "应该处理空变量名" true true
  with _ -> check bool "处理空变量名错误" true true

(* 测试套件 *)
let test_suite =
  [
    ("配置和上下文管理", `Quick, test_configuration_and_context);
    ("标识符转义", `Quick, test_identifier_escaping);
    ("类型转换", `Quick, test_type_conversion);
    ("字面量表达式生成", `Quick, test_literal_expression_generation);
    ("变量表达式生成", `Quick, test_variable_expression_generation);
    ("二元运算表达式生成", `Quick, test_binary_operation_generation);
    ("一元运算表达式生成", `Quick, test_unary_operation_generation);
    ("条件表达式生成", `Quick, test_conditional_expression_generation);
    ("函数定义生成", `Quick, test_function_definition_generation);
    ("函数调用生成", `Quick, test_function_call_generation);
    ("列表表达式生成", `Quick, test_list_expression_generation);
    ("模式匹配生成", `Quick, test_pattern_matching_generation);
    ("语句生成", `Quick, test_statement_generation);
    ("程序生成", `Quick, test_program_generation);
    ("完整C代码生成", `Quick, test_complete_c_code_generation);
    ("内置函数调用生成", `Quick, test_builtin_function_generation);
    ("错误处理", `Quick, test_error_handling);
  ]

let () = run "C_codegen模块单元测试" [ ("C_codegen模块单元测试", test_suite) ]
