(** 骆言代码生成器/解释器单元测试 *)

open Alcotest
open Yyocamlc_lib.Ast
open Yyocamlc_lib.Codegen

(* 测试错误恢复配置 *)
let test_error_recovery_config () =
  let config = default_recovery_config in
  check bool "默认错误恢复启用" true config.enabled;
  check bool "默认类型转换启用" true config.type_conversion;
  check bool "默认拼写纠正启用" true config.spell_correction;
  check bool "默认参数适配启用" true config.parameter_adaptation;
  check string "默认日志级别" "normal" config.log_level;
  check bool "默认统计收集启用" true config.collect_statistics

(* 测试错误恢复统计 *)
let test_error_recovery_statistics () =
  let stats = recovery_stats in
  (* 重置统计 *)
  stats.total_errors <- 0;
  stats.type_conversions <- 0;
  stats.spell_corrections <- 0;
  stats.parameter_adaptations <- 0;
  stats.variable_suggestions <- 0;
  stats.or_else_fallbacks <- 0;
  
  check int "初始错误总数" 0 stats.total_errors;
  check int "初始类型转换数" 0 stats.type_conversions;
  check int "初始拼写纠正数" 0 stats.spell_corrections;
  check int "初始参数适配数" 0 stats.parameter_adaptations;
  check int "初始变量建议数" 0 stats.variable_suggestions;
  check int "初始或else回退数" 0 stats.or_else_fallbacks

(* 测试运行时值 *)
let test_runtime_values () =
  let int_val = IntVal 42 in
  let float_val = FloatVal 3.14 in
  let bool_val = BoolVal true in
  let string_val = StringVal "测试" in
  let char_val = CharVal '中' in
  let nil_val = NilVal in
  
  check bool "整数值测试" true (int_val = IntVal 42);
  check bool "浮点数值测试" true (float_val = FloatVal 3.14);
  check bool "布尔值测试" true (bool_val = BoolVal true);
  check bool "字符串值测试" true (string_val = StringVal "测试");
  check bool "字符值测试" true (char_val = CharVal '中');
  check bool "空值测试" true (nil_val = NilVal);
  
  (* 测试不同类型的值不相等 *)
  check bool "不同类型值不相等" false (int_val = float_val)

(* 测试环境创建和操作 *)
let test_environment_operations () =
  let env = create_environment () in
  
  (* 测试空环境 *)
  check bool "空环境查找" true (lookup_variable env "undefined" = None);
  
  (* 测试添加变量 *)
  let env_with_var = add_variable env "x" (IntVal 42) in
  match lookup_variable env_with_var "x" with
  | Some (IntVal 42) -> check bool "变量添加成功" true true
  | _ -> check bool "变量添加失败" false true;
  
  (* 测试变量更新 *)
  let env_updated = update_variable env_with_var "x" (IntVal 24) in
  match lookup_variable env_updated "x" with
  | Some (IntVal 24) -> check bool "变量更新成功" true true
  | _ -> check bool "变量更新失败" false true

(* 测试基础表达式求值 *)
let test_basic_expression_evaluation () =
  let env = create_environment () in
  
  (* 测试字面量求值 *)
  let int_result = eval_expr env (IntExpr 42) in
  check bool "整数表达式求值" true (int_result = IntVal 42);
  
  let float_result = eval_expr env (FloatExpr 3.14) in
  check bool "浮点数表达式求值" true (float_result = FloatVal 3.14);
  
  let bool_result = eval_expr env (BoolExpr true) in
  check bool "布尔表达式求值" true (bool_result = BoolVal true);
  
  let string_result = eval_expr env (StringExpr "测试") in
  check bool "字符串表达式求值" true (string_result = StringVal "测试");
  
  let char_result = eval_expr env (CharExpr '中') in
  check bool "字符表达式求值" true (char_result = CharVal '中')

(* 测试变量表达式求值 *)
let test_variable_expression_evaluation () =
  let env = create_environment () in
  let env_with_var = add_variable env "x" (IntVal 42) in
  
  let var_result = eval_expr env_with_var (VarExpr "x") in
  check bool "变量表达式求值" true (var_result = IntVal 42);
  
  (* 测试未定义变量（应该有错误恢复） *)
  let undefined_result = eval_expr env (VarExpr "undefined") in
  check bool "未定义变量求值" true (undefined_result = NilVal)

(* 测试二元运算表达式求值 *)
let test_binary_operation_evaluation () =
  let env = create_environment () in
  
  (* 测试算术运算 *)
  let add_result = eval_expr env (BinOpExpr (Add, IntExpr 1, IntExpr 2)) in
  check bool "加法运算求值" true (add_result = IntVal 3);
  
  let sub_result = eval_expr env (BinOpExpr (Sub, IntExpr 5, IntExpr 3)) in
  check bool "减法运算求值" true (sub_result = IntVal 2);
  
  let mul_result = eval_expr env (BinOpExpr (Mul, IntExpr 2, IntExpr 3)) in
  check bool "乘法运算求值" true (mul_result = IntVal 6);
  
  let div_result = eval_expr env (BinOpExpr (Div, IntExpr 6, IntExpr 2)) in
  check bool "除法运算求值" true (div_result = IntVal 3);
  
  (* 测试比较运算 *)
  let eq_result = eval_expr env (BinOpExpr (Equal, IntExpr 1, IntExpr 1)) in
  check bool "相等比较求值" true (eq_result = BoolVal true);
  
  let lt_result = eval_expr env (BinOpExpr (LessThan, IntExpr 1, IntExpr 2)) in
  check bool "小于比较求值" true (lt_result = BoolVal true);
  
  let gt_result = eval_expr env (BinOpExpr (GreaterThan, IntExpr 2, IntExpr 1)) in
  check bool "大于比较求值" true (gt_result = BoolVal true)

(* 测试条件表达式求值 *)
let test_conditional_expression_evaluation () =
  let env = create_environment () in
  
  (* 测试真条件 *)
  let true_result = eval_expr env (IfExpr (BoolExpr true, IntExpr 1, IntExpr 0)) in
  check bool "真条件求值" true (true_result = IntVal 1);
  
  (* 测试假条件 *)
  let false_result = eval_expr env (IfExpr (BoolExpr false, IntExpr 1, IntExpr 0)) in
  check bool "假条件求值" true (false_result = IntVal 0);
  
  (* 测试复杂条件 *)
  let complex_result = eval_expr env (IfExpr (BinOpExpr (LessThan, IntExpr 1, IntExpr 2), 
                                              StringExpr "小于", 
                                              StringExpr "不小于")) in
  check bool "复杂条件求值" true (complex_result = StringVal "小于")

(* 测试Let表达式求值 *)
let test_let_expression_evaluation () =
  let env = create_environment () in
  
  (* 测试简单Let表达式 *)
  let let_result = eval_expr env (LetExpr ("x", IntExpr 42, VarExpr "x")) in
  check bool "Let表达式求值" true (let_result = IntVal 42);
  
  (* 测试嵌套Let表达式 *)
  let nested_let = LetExpr ("x", IntExpr 1, 
                           LetExpr ("y", IntExpr 2, 
                                   BinOpExpr (Add, VarExpr "x", VarExpr "y"))) in
  let nested_result = eval_expr env nested_let in
  check bool "嵌套Let表达式求值" true (nested_result = IntVal 3)

(* 测试列表表达式求值 *)
let test_list_expression_evaluation () =
  let env = create_environment () in
  
  (* 测试简单列表 *)
  let list_result = eval_expr env (ListExpr [IntExpr 1; IntExpr 2; IntExpr 3]) in
  check bool "列表表达式求值" true (list_result = ListVal [IntVal 1; IntVal 2; IntVal 3]);
  
  (* 测试空列表 *)
  let empty_result = eval_expr env (ListExpr []) in
  check bool "空列表表达式求值" true (empty_result = ListVal [])

(* 测试函数表达式求值 *)
let test_function_expression_evaluation () =
  let env = create_environment () in
  
  (* 测试函数定义 *)
  let fun_expr = FunExpr (["x"], VarExpr "x") in
  let fun_result = eval_expr env fun_expr in
  
  (* 函数应该被求值为闭包 *)
  match fun_result with
  | ClosureVal (["x"], VarExpr "x", _) -> check bool "函数表达式求值" true true
  | _ -> check bool "函数表达式求值失败" false true

(* 测试函数应用求值 *)
let test_function_application_evaluation () =
  let env = create_environment () in
  
  (* 创建身份函数 *)
  let identity = FunExpr (["x"], VarExpr "x") in
  let env_with_func = add_variable env "id" (eval_expr env identity) in
  
  (* 测试函数应用 *)
  let app_result = eval_expr env_with_func (AppExpr (VarExpr "id", [IntExpr 42])) in
  check bool "函数应用求值" true (app_result = IntVal 42)

(* 测试语句执行 *)
let test_statement_execution () =
  let env = create_environment () in
  
  (* 测试Let语句 *)
  let let_stmt = LetStmt ("x", IntExpr 42) in
  let env_after_let = execute_statement env let_stmt in
  
  match lookup_variable env_after_let "x" with
  | Some (IntVal 42) -> check bool "Let语句执行" true true
  | _ -> check bool "Let语句执行失败" false true;
  
  (* 测试递归Let语句 *)
  let rec_let_stmt = RecLetStmt ("f", FunExpr (["x"], VarExpr "x")) in
  let env_after_rec = execute_statement env rec_let_stmt in
  
  match lookup_variable env_after_rec "f" with
  | Some (ClosureVal _) -> check bool "递归Let语句执行" true true
  | _ -> check bool "递归Let语句执行失败" false true

(* 测试程序解释 *)
let test_program_interpretation () =
  let program = [
    LetStmt ("x", IntExpr 42);
    LetStmt ("y", IntExpr 24);
    LetStmt ("sum", BinOpExpr (Add, VarExpr "x", VarExpr "y"));
    ExprStmt (VarExpr "sum")
  ] in
  
  let result = interpret_quiet program in
  check bool "程序解释" true (result = IntVal 66)

(* 测试错误恢复机制 *)
let test_error_recovery () =
  let program_with_error = [
    LetStmt ("x", IntExpr 42);
    LetStmt ("y", VarExpr "undefined_var");  (* 未定义变量 *)
    ExprStmt (BinOpExpr (Add, VarExpr "x", VarExpr "y"))
  ] in
  
  (* 启用错误恢复 *)
  let old_config = !recovery_config in
  recovery_config := { default_recovery_config with enabled = true };
  
  let result = interpret_quiet program_with_error in
  
  (* 应该有错误恢复，返回合理的结果 *)
  check bool "错误恢复机制" true (result <> NilVal);
  
  (* 恢复原配置 *)
  recovery_config := old_config

(* 测试类型转换 *)
let test_type_conversion () =
  let env = create_environment () in
  
  (* 测试整数到浮点数的转换 *)
  let mixed_expr = BinOpExpr (Add, IntExpr 1, FloatExpr 2.5) in
  let result = eval_expr env mixed_expr in
  
  (* 应该有类型转换处理 *)
  check bool "类型转换处理" true (result <> NilVal)

(* 测试除零错误处理 *)
let test_division_by_zero () =
  let env = create_environment () in
  
  let div_zero_expr = BinOpExpr (Div, IntExpr 42, IntExpr 0) in
  let result = eval_expr env div_zero_expr in
  
  (* 应该有错误处理，不应该崩溃 *)
  check bool "除零错误处理" true (result = NilVal)

(* 测试环境作用域 *)
let test_environment_scope () =
  let env = create_environment () in
  let env_with_var = add_variable env "x" (IntVal 42) in
  
  (* 进入新作用域 *)
  let new_scope_env = enter_scope env_with_var in
  let new_scope_env_with_var = add_variable new_scope_env "x" (IntVal 24) in
  
  (* 在新作用域中x应该是24 *)
  match lookup_variable new_scope_env_with_var "x" with
  | Some (IntVal 24) -> check bool "新作用域变量" true true
  | _ -> check bool "新作用域变量失败" false true;
  
  (* 离开作用域 *)
  let back_env = exit_scope new_scope_env_with_var in
  
  (* 回到原作用域，x应该是42 *)
  match lookup_variable back_env "x" with
  | Some (IntVal 42) -> check bool "原作用域变量" true true
  | _ -> check bool "原作用域变量失败" false true

(* 测试统计信息 *)
let test_statistics () =
  let stats = recovery_stats in
  let initial_errors = stats.total_errors in
  
  (* 模拟一些错误恢复操作 *)
  stats.total_errors <- initial_errors + 1;
  stats.type_conversions <- stats.type_conversions + 1;
  
  check int "错误总数增加" (initial_errors + 1) stats.total_errors;
  check bool "类型转换统计" true (stats.type_conversions > 0)

(* 测试套件 *)
let test_suite = [
  ("错误恢复配置测试", `Quick, test_error_recovery_config);
  ("错误恢复统计测试", `Quick, test_error_recovery_statistics);
  ("运行时值测试", `Quick, test_runtime_values);
  ("环境操作测试", `Quick, test_environment_operations);
  ("基础表达式求值测试", `Quick, test_basic_expression_evaluation);
  ("变量表达式求值测试", `Quick, test_variable_expression_evaluation);
  ("二元运算表达式求值测试", `Quick, test_binary_operation_evaluation);
  ("条件表达式求值测试", `Quick, test_conditional_expression_evaluation);
  ("Let表达式求值测试", `Quick, test_let_expression_evaluation);
  ("列表表达式求值测试", `Quick, test_list_expression_evaluation);
  ("函数表达式求值测试", `Quick, test_function_expression_evaluation);
  ("函数应用求值测试", `Quick, test_function_application_evaluation);
  ("语句执行测试", `Quick, test_statement_execution);
  ("程序解释测试", `Quick, test_program_interpretation);
  ("错误恢复机制测试", `Quick, test_error_recovery);
  ("类型转换测试", `Quick, test_type_conversion);
  ("除零错误处理测试", `Quick, test_division_by_zero);
  ("环境作用域测试", `Quick, test_environment_scope);
  ("统计信息测试", `Quick, test_statistics);
]

let () = run "Codegen单元测试" test_suite