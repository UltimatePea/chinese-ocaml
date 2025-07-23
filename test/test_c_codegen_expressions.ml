(** 骆言C代码生成器表达式模块全面测试套件 *)

open Alcotest
open Yyocamlc_lib.Ast
(* open Yyocamlc_lib.Types *) (* 暂时未使用 *)
open Yyocamlc_lib.C_codegen_expressions
open Yyocamlc_lib.C_codegen_context

(* 测试辅助函数和基础设施 *)

(** 创建测试用的代码生成配置 *)
let create_test_config () =
  {
    c_output_file = "test_output.c";
    include_debug = false;
    optimize = false;
    runtime_path = "./runtime";
  }

(** 创建测试用的代码生成上下文 *)
let create_test_context () =
  let config = create_test_config () in
  create_context config

(** 检查生成的C代码包含指定子串 *)
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

(** 检查生成的C代码不包含指定子串 *)
let _check_not_contains msg unexpected_substring actual_string =
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
  check bool msg false (simple_contains unexpected_substring actual_string)

(* 字面量表达式代码生成测试 *)

(** 测试整数字面量代码生成 *)
let test_integer_literal_codegen () =
  let ctx = create_test_context () in
  let expr = LitExpr (IntLit 42) in
  let result = gen_expr ctx expr in
  
  (* 验证生成的代码包含整数值 *)
  check_contains "整数字面量代码生成" "42" result;
  
  (* 测试负数 *)
  let negative_expr = LitExpr (IntLit (-100)) in
  let negative_result = gen_expr ctx negative_expr in
  check_contains "负整数字面量代码生成" "-100" negative_result;
  
  (* 测试零值 *)
  let zero_expr = LitExpr (IntLit 0) in
  let zero_result = gen_expr ctx zero_expr in
  check_contains "零值字面量代码生成" "0" zero_result

(** 测试浮点数字面量代码生成 *)
let test_float_literal_codegen () =
  let ctx = create_test_context () in
  let expr = LitExpr (FloatLit 3.14159) in
  let result = gen_expr ctx expr in
  
  (* 验证生成的代码包含浮点数值 *)
  check_contains "浮点数字面量代码生成" "3.14159" result;
  
  (* 测试科学计数法 *)
  let scientific_expr = LitExpr (FloatLit 1.23e-4) in
  let scientific_result = gen_expr ctx scientific_expr in
  check_contains "科学计数法浮点数代码生成" "0.000123" scientific_result

(** 测试字符串字面量代码生成 *)
let test_string_literal_codegen () =
  let ctx = create_test_context () in
  let expr = LitExpr (StringLit "Hello, 世界!") in
  let result = gen_expr ctx expr in
  
  (* 验证生成的代码包含正确的字符串处理 *)
  check_contains "字符串字面量代码生成包含引号" "\"" result;
  check_contains "字符串字面量包含内容" "Hello" result;
  
  (* 测试空字符串 *)
  let empty_expr = LitExpr (StringLit "") in
  let empty_result = gen_expr ctx empty_expr in
  check_contains "空字符串字面量代码生成" "\"\"" empty_result;
  
  (* 测试包含转义字符的字符串 *)
  let escape_expr = LitExpr (StringLit "Line1\nLine2\t\tTabbed") in
  let escape_result = gen_expr ctx escape_expr in
  check_contains "转义字符字符串代码生成" "\\n" escape_result;
  check_contains "制表符转义" "\\t" escape_result

(** 测试布尔字面量代码生成 *)
let test_boolean_literal_codegen () =
  let ctx = create_test_context () in
  let true_expr = LitExpr (BoolLit true) in
  let false_expr = LitExpr (BoolLit false) in
  let true_result = gen_expr ctx true_expr in
  let false_result = gen_expr ctx false_expr in
  
  (* 验证布尔值的C代码表示 *)
  check_contains "true布尔字面量代码生成" "true" true_result;
  check_contains "false布尔字面量代码生成" "false" false_result

(** 测试单元字面量代码生成 *)
let test_unit_literal_codegen () =
  let ctx = create_test_context () in
  let expr = LitExpr UnitLit in
  let result = gen_expr ctx expr in
  
  (* 验证单元值的C代码表示 *)
  check_contains "单元字面量代码生成" "unit" result

(* 变量表达式代码生成测试 *)

(** 测试简单变量表达式代码生成 *)
let test_simple_variable_codegen () =
  let ctx = create_test_context () in
  let expr = VarExpr "variable_name" in
  let result = gen_expr ctx expr in
  
  (* 验证变量名正确生成 *)
  check_contains "变量表达式代码生成" "variable_name" result

(** 测试中文变量名代码生成 *)
let test_chinese_variable_codegen () =
  let ctx = create_test_context () in
  let expr = VarExpr "数字" in
  let result = gen_expr ctx expr in
  
  (* 验证中文变量名的处理 *)
  check_contains "中文变量名代码生成" "数字" result

(* 二元运算表达式代码生成测试 *)

(** 测试算术运算表达式代码生成 *)
let test_arithmetic_binary_op_codegen () =
  let ctx = create_test_context () in
  
  (* 加法运算 *)
  let add_expr = BinaryOpExpr (LitExpr (IntLit 5), Add, LitExpr (IntLit 3)) in
  let add_result = gen_expr ctx add_expr in
  check_contains "加法运算代码生成包含操作数" "5" add_result;
  check_contains "加法运算代码生成包含操作数" "3" add_result;
  check_contains "加法运算代码生成包含运算符" "luoyan_add" add_result;
  
  (* 减法运算 *)
  let sub_expr = BinaryOpExpr (LitExpr (IntLit 10), Sub, LitExpr (IntLit 4)) in
  let sub_result = gen_expr ctx sub_expr in
  check_contains "减法运算代码生成包含运算符" "luoyan_subtract" sub_result;
  
  (* 乘法运算 *)
  let mul_expr = BinaryOpExpr (LitExpr (IntLit 6), Mul, LitExpr (IntLit 7)) in
  let mul_result = gen_expr ctx mul_expr in
  check_contains "乘法运算代码生成包含运算符" "luoyan_multiply" mul_result;
  
  (* 除法运算 *)
  let div_expr = BinaryOpExpr (LitExpr (IntLit 20), Div, LitExpr (IntLit 4)) in
  let div_result = gen_expr ctx div_expr in
  check_contains "除法运算代码生成包含运算符" "luoyan_divide" div_result

(** 测试比较运算表达式代码生成 *)
let test_comparison_binary_op_codegen () =
  let ctx = create_test_context () in
  
  (* 等于比较 *)
  let eq_expr = BinaryOpExpr (LitExpr (IntLit 5), Eq, LitExpr (IntLit 5)) in
  let eq_result = gen_expr ctx eq_expr in
  check_contains "等于比较代码生成包含运算符" "luoyan_equal" eq_result;
  
  (* 小于比较 *)
  let lt_expr = BinaryOpExpr (VarExpr "x", Lt, VarExpr "y") in
  let lt_result = gen_expr ctx lt_expr in
  check_contains "小于比较代码生成包含运算符" "luoyan_less_than" lt_result;
  check_contains "小于比较包含变量x" "x" lt_result;
  check_contains "小于比较包含变量y" "y" lt_result

(** 测试逻辑运算表达式代码生成 *)
let test_logical_binary_op_codegen () =
  let ctx = create_test_context () in
  
  (* 逻辑与运算 *)
  let and_expr = BinaryOpExpr (LitExpr (BoolLit true), And, VarExpr "condition") in
  let and_result = gen_expr ctx and_expr in
  check_contains "逻辑与运算代码生成包含运算符" "luoyan_logical_and" and_result;
  check_contains "逻辑与运算包含条件变量" "condition" and_result;
  
  (* 逻辑或运算 *)
  let or_expr = BinaryOpExpr (VarExpr "flag1", Or, VarExpr "flag2") in
  let or_result = gen_expr ctx or_expr in
  check_contains "逻辑或运算代码生成包含运算符" "luoyan_logical_or" or_result

(* 一元运算表达式代码生成测试 *)

(** 测试一元算术运算代码生成 *)
let test_unary_arithmetic_op_codegen () =
  let ctx = create_test_context () in
  
  (* 负号运算 *)
  let neg_expr = UnaryOpExpr (Neg, LitExpr (IntLit 42)) in
  let neg_result = gen_expr ctx neg_expr in
  check_contains "负号运算代码生成包含运算符" "luoyan_subtract" neg_result;
  check_contains "负号运算包含操作数" "42" neg_result

(** 测试逻辑非运算代码生成 *)
let test_unary_logical_op_codegen () =
  let ctx = create_test_context () in
  
  (* 逻辑非运算 *)
  let not_expr = UnaryOpExpr (Not, VarExpr "boolean_var") in
  let not_result = gen_expr ctx not_expr in
  check_contains "逻辑非运算代码生成包含运算符" "luoyan_logical_not" not_result;
  check_contains "逻辑非运算包含变量" "boolean_var" not_result

(* 函数调用表达式代码生成测试 *)

(** 测试简单函数调用代码生成 *)
let test_simple_function_call_codegen () =
  let ctx = create_test_context () in
  let call_expr = FunCallExpr (VarExpr "print", [LitExpr (StringLit "Hello")]) in
  let result = gen_expr ctx call_expr in
  
  (* 验证函数名和参数正确生成 *)
  check_contains "函数调用代码生成包含函数名" "print" result;
  check_contains "函数调用包含参数" "Hello" result;
  check_contains "函数调用包含括号" "(" result;
  check_contains "函数调用包含右括号" ")" result

(** 测试多参数函数调用代码生成 *)
let test_multi_param_function_call_codegen () =
  let ctx = create_test_context () in
  let call_expr = FunCallExpr (VarExpr "add", [
    LitExpr (IntLit 10);
    LitExpr (IntLit 20);
    VarExpr "third_param"
  ]) in
  let result = gen_expr ctx call_expr in
  
  (* 验证多个参数正确生成 *)
  check_contains "多参数函数调用包含函数名" "add" result;
  check_contains "多参数函数调用包含第一个参数" "10" result;
  check_contains "多参数函数调用包含第二个参数" "20" result;
  check_contains "多参数函数调用包含第三个参数" "third_param" result;
  check_contains "多参数函数调用包含逗号分隔" "," result

(** 测试无参数函数调用代码生成 *)
let test_no_param_function_call_codegen () =
  let ctx = create_test_context () in
  let call_expr = FunCallExpr (VarExpr "get_time", []) in
  let result = gen_expr ctx call_expr in
  
  (* 验证无参数函数调用 *)
  check_contains "无参数函数调用包含函数名" "get_time" result;
  check_contains "无参数函数调用包含空括号" "()" result

(* 条件表达式代码生成测试 *)

(** 测试简单条件表达式代码生成 *)
let test_simple_conditional_codegen () =
  let ctx = create_test_context () in
  let cond_expr = CondExpr (
    VarExpr "condition",
    LitExpr (IntLit 1),
    LitExpr (IntLit 0)
  ) in
  let result = gen_expr ctx cond_expr in
  
  (* 验证三元条件运算符结构 *)
  check_contains "条件表达式包含条件变量" "condition" result;
  check_contains "条件表达式包含真值" "1" result;
  check_contains "条件表达式包含假值" "0" result;
  check_contains "条件表达式包含问号" "?" result;
  check_contains "条件表达式包含冒号" ":" result

(** 测试嵌套条件表达式代码生成 *)
let test_nested_conditional_codegen () =
  let ctx = create_test_context () in
  let inner_cond = CondExpr (VarExpr "inner", LitExpr (IntLit 2), LitExpr (IntLit 3)) in
  let outer_cond = CondExpr (VarExpr "outer", inner_cond, LitExpr (IntLit 4)) in
  let result = gen_expr ctx outer_cond in
  
  (* 验证嵌套结构正确生成 *)
  check_contains "嵌套条件表达式包含外层条件" "outer" result;
  check_contains "嵌套条件表达式包含内层条件" "inner" result;
  check_contains "嵌套条件表达式包含多个值" "2" result;
  check_contains "嵌套条件表达式包含多个值" "3" result;
  check_contains "嵌套条件表达式包含多个值" "4" result

(* 列表表达式代码生成测试 *)

(** 测试简单列表表达式代码生成 *)
let test_simple_list_codegen () =
  let ctx = create_test_context () in
  let list_expr = ListExpr [
    LitExpr (IntLit 1);
    LitExpr (IntLit 2);
    LitExpr (IntLit 3)
  ] in
  let result = gen_expr ctx list_expr in
  
  (* 验证列表元素正确生成 *)
  check_contains "列表表达式包含第一个元素" "1" result;
  check_contains "列表表达式包含第二个元素" "2" result;
  check_contains "列表表达式包含第三个元素" "3" result;
  (* 列表在C中通常转换为数组或链表结构 *)
  check_contains "列表表达式包含结构标识" "{" result

(** 测试空列表表达式代码生成 *)
let test_empty_list_codegen () =
  let ctx = create_test_context () in
  let empty_list_expr = ListExpr [] in
  let result = gen_expr ctx empty_list_expr in
  
  (* 验证空列表正确处理 *)
  check_contains "空列表表达式生成" "{}" result

(* 复杂表达式组合测试 *)

(** 测试算术表达式与函数调用组合 *)
let test_complex_arithmetic_function_combo () =
  let ctx = create_test_context () in
  let complex_expr = BinaryOpExpr (
    FunCallExpr (VarExpr "square", [LitExpr (IntLit 5)]),
    Add,
    BinaryOpExpr (LitExpr (IntLit 2), Mul, VarExpr "x")
  ) in
  let result = gen_expr ctx complex_expr in
  
  (* 验证复杂表达式各部分 *)
  check_contains "复杂表达式包含函数调用" "square" result;
  check_contains "复杂表达式包含函数参数" "5" result;
  check_contains "复杂表达式包含乘法运算" "*" result;
  check_contains "复杂表达式包含变量" "x" result;
  check_contains "复杂表达式包含加法运算" "+" result

(** 测试多层嵌套表达式 *)
let test_deeply_nested_expression () =
  let ctx = create_test_context () in
  let nested_expr = BinaryOpExpr (
    BinaryOpExpr (LitExpr (IntLit 1), Add, LitExpr (IntLit 2)),
    Mul,
    BinaryOpExpr (LitExpr (IntLit 10), Sub, LitExpr (IntLit 3))
  ) in
  let result = gen_expr ctx nested_expr in
  
  (* 验证嵌套表达式的括号和运算符优先级 *)
  check_contains "嵌套表达式包含所有数字" "1" result;
  check_contains "嵌套表达式包含所有数字" "2" result;
  check_contains "嵌套表达式包含所有数字" "10" result;
  check_contains "嵌套表达式包含所有数字" "3" result;
  check_contains "嵌套表达式包含乘法" "*" result;
  check_contains "嵌套表达式包含加法" "+" result;
  check_contains "嵌套表达式包含减法" "-" result;
  (* 验证括号用于维护运算优先级 *)
  check_contains "嵌套表达式包含括号" "(" result

(* 边界条件和错误处理测试 *)

(** 测试大整数字面量处理 *)
let test_large_integer_literal () =
  let ctx = create_test_context () in
  let large_int_expr = LitExpr (IntLit 2147483647) in (* 最大32位整数 *)
  let result = gen_expr ctx large_int_expr in
  check_contains "大整数字面量代码生成" "2147483647" result

(** 测试极长字符串处理 *)
let test_long_string_literal () =
  let ctx = create_test_context () in
  let long_string = String.make 1000 'A' in
  let long_str_expr = LitExpr (StringLit long_string) in
  let result = gen_expr ctx long_str_expr in
  
  (* 验证长字符串正确处理 *)
  check_contains "长字符串包含开始字符" "AAA" result;
  check_contains "长字符串包含引号" "\"" result

(* 性能和优化测试 *)

(** 测试大型表达式树的代码生成性能 *)
let test_large_expression_tree () =
  let ctx = create_test_context () in
  
  (* 构建一个包含100个加法操作的表达式 *)
  let rec build_large_expr n =
    if n <= 0 then LitExpr (IntLit 0)
    else BinaryOpExpr (LitExpr (IntLit n), Add, build_large_expr (n - 1))
  in
  
  let large_expr = build_large_expr 100 in
  let start_time = Sys.time () in
  let result = gen_expr ctx large_expr in
  let end_time = Sys.time () in
  let duration = end_time -. start_time in
  
  (* 验证生成成功且性能可接受 *)
  check_contains "大型表达式包含最大数字" "100" result;
  check_contains "大型表达式包含最小数字" "0" result;
  check bool "大型表达式生成性能可接受" true (duration < 1.0) (* 小于1秒 *)

(* 测试套件组织 *)

let literal_tests = [
  "整数字面量代码生成", `Quick, test_integer_literal_codegen;
  "浮点数字面量代码生成", `Quick, test_float_literal_codegen;
  "字符串字面量代码生成", `Quick, test_string_literal_codegen;
  "布尔字面量代码生成", `Quick, test_boolean_literal_codegen;
  "单元字面量代码生成", `Quick, test_unit_literal_codegen;
]

let variable_tests = [
  "简单变量表达式代码生成", `Quick, test_simple_variable_codegen;
  "中文变量名代码生成", `Quick, test_chinese_variable_codegen;
]

let binary_op_tests = [
  "算术运算表达式代码生成", `Quick, test_arithmetic_binary_op_codegen;
  "比较运算表达式代码生成", `Quick, test_comparison_binary_op_codegen;
  "逻辑运算表达式代码生成", `Quick, test_logical_binary_op_codegen;
]

let unary_op_tests = [
  "一元算术运算代码生成", `Quick, test_unary_arithmetic_op_codegen;
  "逻辑非运算代码生成", `Quick, test_unary_logical_op_codegen;
]

let function_call_tests = [
  "简单函数调用代码生成", `Quick, test_simple_function_call_codegen;
  "多参数函数调用代码生成", `Quick, test_multi_param_function_call_codegen;
  "无参数函数调用代码生成", `Quick, test_no_param_function_call_codegen;
]

let conditional_tests = [
  "简单条件表达式代码生成", `Quick, test_simple_conditional_codegen;
  "嵌套条件表达式代码生成", `Quick, test_nested_conditional_codegen;
]

let list_tests = [
  "简单列表表达式代码生成", `Quick, test_simple_list_codegen;
  "空列表表达式代码生成", `Quick, test_empty_list_codegen;
]

let complex_tests = [
  "算术表达式与函数调用组合", `Quick, test_complex_arithmetic_function_combo;
  "多层嵌套表达式", `Quick, test_deeply_nested_expression;
]

let boundary_tests = [
  "大整数字面量处理", `Quick, test_large_integer_literal;
  "极长字符串处理", `Quick, test_long_string_literal;
]

let performance_tests = [
  "大型表达式树的代码生成性能", `Quick, test_large_expression_tree;
]

(* 主测试入口 *)
let () =
  run "骆言C代码生成表达式模块全面测试" [
    "字面量表达式测试", literal_tests;
    "变量表达式测试", variable_tests;
    "二元运算表达式测试", binary_op_tests;
    "一元运算表达式测试", unary_op_tests;
    "函数调用表达式测试", function_call_tests;
    "条件表达式测试", conditional_tests;
    "列表表达式测试", list_tests;
    "复杂表达式组合测试", complex_tests;
    "边界条件测试", boundary_tests;
    "性能测试", performance_tests;
  ]