(** 骆言C代码生成器语句模块全面测试套件 *)

open Alcotest
open Yyocamlc_lib.Ast
(* open Yyocamlc_lib.Types *) (* 暂时未使用 *)
open Yyocamlc_lib.C_codegen_statements
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

(* 表达式语句代码生成测试 *)

(** 测试简单表达式语句代码生成 *)
let test_simple_expression_statement () =
  let ctx = create_test_context () in
  let stmt = ExprStmt (LitExpr (IntLit 42)) in
  let result = gen_stmt ctx stmt in
  
  (* 验证表达式语句正确生成 *)
  check_contains "表达式语句包含数值" "42" result;
  check_contains "表达式语句包含语句结束符" ";" result

(** 测试函数调用表达式语句 *)
let test_function_call_expression_statement () =
  let ctx = create_test_context () in
  let call_expr = FunCallExpr (VarExpr "print", [LitExpr (StringLit "Hello, World!")]) in
  let stmt = ExprStmt call_expr in
  let result = gen_stmt ctx stmt in
  
  (* 验证函数调用语句 *)
  check_contains "函数调用语句包含函数名" "print" result;
  check_contains "函数调用语句包含参数" "Hello, World!" result;
  check_contains "函数调用语句包含语句结束符" ";" result

(** 测试算术表达式语句 *)
let test_arithmetic_expression_statement () =
  let ctx = create_test_context () in
  let arith_expr = BinaryOpExpr (LitExpr (IntLit 10), Add, LitExpr (IntLit 20)) in
  let stmt = ExprStmt arith_expr in
  let result = gen_stmt ctx stmt in
  
  (* 验证算术表达式语句 *)
  check_contains "算术表达式语句包含操作数" "10" result;
  check_contains "算术表达式语句包含操作数" "20" result;
  check_contains "算术表达式语句包含运算符" "+" result;
  check_contains "算术表达式语句包含语句结束符" ";" result

(* Let语句代码生成测试 *)

(** 测试简单let语句代码生成 *)
let test_simple_let_statement () =
  let ctx = create_test_context () in
  let stmt = LetStmt ("x", LitExpr (IntLit 100)) in
  let result = gen_stmt ctx stmt in
  
  (* 验证let语句绑定变量 *)
  check_contains "let语句包含变量名" "x" result;
  check_contains "let语句包含绑定值" "100" result;
  check_contains "let语句包含绑定函数" "luoyan_env_bind" result

(** 测试字符串值let语句 *)
let test_string_let_statement () =
  let ctx = create_test_context () in
  let stmt = LetStmt ("message", LitExpr (StringLit "Hello")) in
  let result = gen_stmt ctx stmt in
  
  (* 验证字符串let语句 *)
  check_contains "字符串let语句包含变量名" "message" result;
  check_contains "字符串let语句包含字符串值" "Hello" result;
  check_contains "字符串let语句包含绑定函数" "luoyan_env_bind" result

(** 测试表达式值let语句 *)
let test_expression_let_statement () =
  let ctx = create_test_context () in
  let expr = BinaryOpExpr (LitExpr (IntLit 5), Mul, LitExpr (IntLit 6)) in
  let stmt = LetStmt ("result", expr) in
  let result = gen_stmt ctx stmt in
  
  (* 验证表达式let语句 *)
  check_contains "表达式let语句包含变量名" "result" result;
  check_contains "表达式let语句包含乘法运算" "*" result;
  check_contains "表达式let语句包含操作数" "5" result;
  check_contains "表达式let语句包含操作数" "6" result;
  check_contains "表达式let语句包含绑定函数" "luoyan_env_bind" result

(** 测试中文变量名let语句 *)
let test_chinese_variable_let_statement () =
  let ctx = create_test_context () in
  let stmt = LetStmt ("数字", LitExpr (IntLit 888)) in
  let result = gen_stmt ctx stmt in
  
  (* 验证中文变量名处理 *)
  check_contains "中文变量let语句包含变量名" "数字" result;
  check_contains "中文变量let语句包含值" "888" result;
  check_contains "中文变量let语句包含绑定函数" "luoyan_env_bind" result

(* 递归Let语句代码生成测试 *)

(** 测试简单递归let语句 *)
let test_simple_recursive_let_statement () =
  let ctx = create_test_context () in
  let factorial_body = FunExpr (["n"], CondExpr (
    BinaryOpExpr (VarExpr "n", Eq, LitExpr (IntLit 0)),
    LitExpr (IntLit 1),
    BinaryOpExpr (VarExpr "n", Mul, 
      FunCallExpr (VarExpr "factorial", [BinaryOpExpr (VarExpr "n", Sub, LitExpr (IntLit 1))]))
  )) in
  let stmt = RecLetStmt ("factorial", factorial_body) in
  let result = gen_stmt ctx stmt in
  
  (* 验证递归let语句的特殊处理 *)
  check_contains "递归let语句包含函数名" "factorial" result;
  check_contains "递归let语句包含单元初始化" "luoyan_unit()" result;
  check_contains "递归let语句包含参数" "n" result;
  check_contains "递归let语句包含递归调用" "factorial" result

(** 测试递归函数的多参数情况 *)
let test_multi_param_recursive_let () =
  let ctx = create_test_context () in
  let gcd_body = FunExpr (["a"; "b"], CondExpr (
    BinaryOpExpr (VarExpr "b", Eq, LitExpr (IntLit 0)),
    VarExpr "a",
    FunCallExpr (VarExpr "gcd", [VarExpr "b"; BinaryOpExpr (VarExpr "a", Mod, VarExpr "b")])
  )) in
  let stmt = RecLetStmt ("gcd", gcd_body) in
  let result = gen_stmt ctx stmt in
  
  (* 验证多参数递归函数 *)
  check_contains "多参数递归let包含函数名" "gcd" result;
  check_contains "多参数递归let包含参数a" "a" result;
  check_contains "多参数递归let包含参数b" "b" result;
  check_contains "多参数递归let包含单元初始化" "luoyan_unit()" result

(* 复杂语句组合测试 *)

(** 测试let语句与表达式语句组合 *)
let test_let_and_expression_combo () =
  let ctx = create_test_context () in
  
  (* 先生成let语句 *)
  let let_stmt = LetStmt ("x", LitExpr (IntLit 10)) in
  let let_result = gen_stmt ctx let_stmt in
  
  (* 再生成使用该变量的表达式语句 *)
  let expr_stmt = ExprStmt (BinaryOpExpr (VarExpr "x", Add, LitExpr (IntLit 5))) in
  let expr_result = gen_stmt ctx expr_stmt in
  
  (* 验证两个语句都正确生成 *)
  check_contains "let语句包含变量定义" "x" let_result;
  check_contains "let语句包含初始值" "10" let_result;
  check_contains "表达式语句使用变量" "x" expr_result;
  check_contains "表达式语句包含操作" "+" expr_result;
  check_contains "表达式语句包含常量" "5" expr_result

(** 测试嵌套函数定义语句 *)
let test_nested_function_definition () =
  let ctx = create_test_context () in
  let inner_func = FunExpr (["y"], BinaryOpExpr (VarExpr "y", Mul, LitExpr (IntLit 2))) in
  let outer_func = FunExpr (["x"], LetExpr ("double", inner_func, 
    FunCallExpr (VarExpr "double", [VarExpr "x"]))) in
  let stmt = LetStmt ("nested_example", outer_func) in
  let result = gen_stmt ctx stmt in
  
  (* 验证嵌套函数定义 *)
  check_contains "嵌套函数包含外层函数名" "nested_example" result;
  check_contains "嵌套函数包含内层绑定" "double" result;
  check_contains "嵌套函数包含参数" "x" result;
  check_contains "嵌套函数包含参数" "y" result;
  check_contains "嵌套函数包含乘法运算" "*" result

(* 条件语句相关测试 *)

(** 测试包含条件表达式的语句 *)
let test_conditional_expression_statement () =
  let ctx = create_test_context () in
  let cond_expr = CondExpr (
    BinaryOpExpr (VarExpr "age", Gt, LitExpr (IntLit 18)),
    LitExpr (StringLit "adult"),
    LitExpr (StringLit "minor")
  ) in
  let stmt = LetStmt ("status", cond_expr) in
  let result = gen_stmt ctx stmt in
  
  (* 验证条件表达式语句 *)
  check_contains "条件表达式语句包含变量名" "status" result;
  check_contains "条件表达式语句包含条件变量" "age" result;
  check_contains "条件表达式语句包含比较值" "18" result;
  check_contains "条件表达式语句包含比较运算符" ">" result;
  check_contains "条件表达式语句包含真值" "adult" result;
  check_contains "条件表达式语句包含假值" "minor" result

(** 测试复杂条件语句 *)
let test_complex_conditional_statement () =
  let ctx = create_test_context () in
  let complex_cond = CondExpr (
    BinaryOpExpr (
      BinaryOpExpr (VarExpr "score", Ge, LitExpr (IntLit 60)),
      And,
      BinaryOpExpr (VarExpr "score", Le, LitExpr (IntLit 100))),
    LitExpr (StringLit "pass"),
    LitExpr (StringLit "fail")
  ) in
  let stmt = ExprStmt complex_cond in
  let result = gen_stmt ctx stmt in
  
  (* 验证复杂条件语句 *)
  check_contains "复杂条件语句包含变量" "score" result;
  check_contains "复杂条件语句包含下限" "60" result;
  check_contains "复杂条件语句包含上限" "100" result;
  check_contains "复杂条件语句包含逻辑与" "&&" result;
  check_contains "复杂条件语句包含大于等于" ">=" result;
  check_contains "复杂条件语句包含小于等于" "<=" result

(* 特殊字符和转义处理测试 *)

(** 测试包含特殊字符的字符串语句 *)
let test_special_character_string_statement () =
  let ctx = create_test_context () in
  let special_string = "Hello\nWorld\t\"Quote\"\\Backslash" in
  let stmt = LetStmt ("special", LitExpr (StringLit special_string)) in
  let result = gen_stmt ctx stmt in
  
  (* 验证特殊字符正确转义 *)
  check_contains "特殊字符语句包含变量名" "special" result;
  check_contains "特殊字符语句包含换行符转义" "\\n" result;
  check_contains "特殊字符语句包含制表符转义" "\\t" result;
  check_contains "特殊字符语句包含引号转义" "\\\"" result;
  check_contains "特殊字符语句包含反斜杠转义" "\\\\" result

(** 测试Unicode字符串语句 *)
let test_unicode_string_statement () =
  let ctx = create_test_context () in
  let unicode_string = "你好世界！🌍" in
  let stmt = LetStmt ("greeting", LitExpr (StringLit unicode_string)) in
  let result = gen_stmt ctx stmt in
  
  (* 验证Unicode字符串处理 *)
  check_contains "Unicode字符串语句包含变量名" "greeting" result;
  check_contains "Unicode字符串语句包含中文" "你好世界" result;
  check_contains "Unicode字符串语句包含emoji" "🌍" result

(* 错误处理和边界条件测试 *)

(** 测试空字符串变量名处理 *)
let test_empty_variable_name_handling () =
  let ctx = create_test_context () in
  let stmt = LetStmt ("", LitExpr (IntLit 42)) in
  let result = gen_stmt ctx stmt in
  
  (* 验证空变量名的处理 *)
  check_contains "空变量名语句包含值" "42" result;
  check_contains "空变量名语句包含绑定函数" "luoyan_env_bind" result

(** 测试极长变量名处理 *)
let test_long_variable_name_handling () =
  let ctx = create_test_context () in
  let long_var_name = String.make 1000 'x' in
  let stmt = LetStmt (long_var_name, LitExpr (IntLit 999)) in
  let result = gen_stmt ctx stmt in
  
  (* 验证长变量名正确处理 *)
  check_contains "长变量名语句包含变量开头" "xxx" result;
  check_contains "长变量名语句包含值" "999" result;
  check_contains "长变量名语句包含绑定函数" "luoyan_env_bind" result

(* 性能和大规模测试 *)

(** 测试大型语句的代码生成性能 *)
let test_large_statement_performance () =
  let ctx = create_test_context () in
  
  (* 构建一个包含深度嵌套的表达式语句 *)
  let rec build_nested_expr depth =
    if depth <= 0 then LitExpr (IntLit 1)
    else BinaryOpExpr (LitExpr (IntLit depth), Add, build_nested_expr (depth - 1))
  in
  
  let large_expr = build_nested_expr 500 in
  let stmt = LetStmt ("large_computation", large_expr) in
  
  let start_time = Sys.time () in
  let result = gen_stmt ctx stmt in
  let end_time = Sys.time () in
  let duration = end_time -. start_time in
  
  (* 验证性能可接受且功能正确 *)
  check_contains "大型语句包含变量名" "large_computation" result;
  check_contains "大型语句包含最大深度值" "500" result;
  check_contains "大型语句包含基础值" "1" result;
  check_contains "大型语句包含加法运算" "+" result;
  check bool "大型语句生成性能可接受" true (duration < 2.0) (* 小于2秒 *)

(** 测试批量语句生成 *)
let test_batch_statement_generation () =
  let ctx = create_test_context () in
  
  (* 生成100个不同的let语句 *)
  let generate_stmt_batch size =
    let rec generate_stmts acc n =
      if n <= 0 then acc
      else
        let var_name = "var_" ^ (string_of_int n) in
        let stmt = LetStmt (var_name, LitExpr (IntLit n)) in
        let result = gen_stmt ctx stmt in
        generate_stmts (result :: acc) (n - 1)
    in
    generate_stmts [] size
  in
  
  let start_time = Sys.time () in
  let batch_results = generate_stmt_batch 100 in
  let end_time = Sys.time () in
  let duration = end_time -. start_time in
  
  (* 验证批量生成成功 *)
  check int "批量语句生成数量" 100 (List.length batch_results);
  check bool "批量语句生成性能可接受" true (duration < 1.0); (* 小于1秒 *)
  
  (* 验证第一个和最后一个语句内容 *)
  let first_stmt = List.hd (List.rev batch_results) in
  let last_stmt = List.hd batch_results in
  check_contains "批量生成首个语句" "var_1" first_stmt;
  check_contains "批量生成首个语句值" "1" first_stmt;
  check_contains "批量生成末个语句" "var_100" last_stmt;
  check_contains "批量生成末个语句值" "100" last_stmt

(* 集成测试 *)

(** 测试完整程序语句序列 *)
let test_complete_program_statements () =
  let ctx = create_test_context () in
  
  (* 模拟一个完整的小程序 *)
  let statements = [
    LetStmt ("PI", LitExpr (FloatLit 3.14159));
    LetStmt ("radius", LitExpr (IntLit 5));
    LetStmt ("area", BinaryOpExpr (VarExpr "PI", Mul, 
      BinaryOpExpr (VarExpr "radius", Mul, VarExpr "radius")));
    ExprStmt (FunCallExpr (VarExpr "print", [VarExpr "area"]));
  ] in
  
  let results = List.map (gen_stmt ctx) statements in
  let combined_result = String.concat "\n" results in
  
  (* 验证完整程序各部分 *)
  check_contains "完整程序包含PI定义" "PI" combined_result;
  check_contains "完整程序包含PI值" "3.14159" combined_result;
  check_contains "完整程序包含radius定义" "radius" combined_result;
  check_contains "完整程序包含radius值" "5" combined_result;
  check_contains "完整程序包含area计算" "area" combined_result;
  check_contains "完整程序包含乘法运算" "*" combined_result;
  check_contains "完整程序包含print调用" "print" combined_result;
  check_contains "完整程序包含所有绑定" "luoyan_env_bind" combined_result

(* 测试套件组织 *)

let expression_statement_tests = [
  "简单表达式语句代码生成", `Quick, test_simple_expression_statement;
  "函数调用表达式语句", `Quick, test_function_call_expression_statement;
  "算术表达式语句", `Quick, test_arithmetic_expression_statement;
]

let let_statement_tests = [
  "简单let语句代码生成", `Quick, test_simple_let_statement;
  "字符串值let语句", `Quick, test_string_let_statement;
  "表达式值let语句", `Quick, test_expression_let_statement;
  "中文变量名let语句", `Quick, test_chinese_variable_let_statement;
]

let recursive_let_tests = [
  "简单递归let语句", `Quick, test_simple_recursive_let_statement;
  "多参数递归let语句", `Quick, test_multi_param_recursive_let;
]

let complex_statement_tests = [
  "let语句与表达式语句组合", `Quick, test_let_and_expression_combo;
  "嵌套函数定义语句", `Quick, test_nested_function_definition;
]

let conditional_statement_tests = [
  "包含条件表达式的语句", `Quick, test_conditional_expression_statement;
  "复杂条件语句", `Quick, test_complex_conditional_statement;
]

let special_character_tests = [
  "包含特殊字符的字符串语句", `Quick, test_special_character_string_statement;
  "Unicode字符串语句", `Quick, test_unicode_string_statement;
]

let boundary_condition_tests = [
  "空字符串变量名处理", `Quick, test_empty_variable_name_handling;
  "极长变量名处理", `Quick, test_long_variable_name_handling;
]

let performance_tests = [
  "大型语句的代码生成性能", `Quick, test_large_statement_performance;
  "批量语句生成", `Quick, test_batch_statement_generation;
]

let integration_tests = [
  "完整程序语句序列", `Quick, test_complete_program_statements;
]

(* 主测试入口 *)
let () =
  run "骆言C代码生成语句模块全面测试" [
    "表达式语句测试", expression_statement_tests;
    "Let语句测试", let_statement_tests;
    "递归Let语句测试", recursive_let_tests;
    "复杂语句组合测试", complex_statement_tests;
    "条件语句测试", conditional_statement_tests;
    "特殊字符处理测试", special_character_tests;
    "边界条件测试", boundary_condition_tests;
    "性能测试", performance_tests;
    "集成测试", integration_tests;
  ]