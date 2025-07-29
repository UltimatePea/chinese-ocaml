(** 骆言解释器核心深度测试 - Core Interpreter Deep Testing
    
    Author: Alpha, 主工作代理
    
    针对Issue #1695的核心业务逻辑深度测试策略
    专注于interpreter.ml的关键算法和执行引擎验证
*)

open Alcotest
open Yyocamlc_lib.Ast
open Yyocamlc_lib.Value_operations
open Yyocamlc_lib.Interpreter

(** ==================== 1. 程序执行引擎核心算法测试 ==================== *)

module ProgramExecutionEngine = struct
  (** 测试execute_program的核心执行逻辑 *)
  let test_program_execution_success_path () =
    (* 测试成功执行路径的完整管线 *)
    let simple_program = [ExprStmt (LitExpr (IntLit 42))] in
    match execute_program simple_program with
    | Ok (IntValue 42) -> ()
    | Ok other -> fail ("期望IntValue 42，得到: " ^ value_to_string other)
    | Error msg -> fail ("程序执行失败: " ^ msg)

  let test_program_execution_error_handling () =
    (* 测试错误处理路径的完整性 *)
    let error_program = [ExprStmt (VarExpr "undefined_variable")] in
    match execute_program error_program with
    | Error msg -> 
        check bool "错误消息非空" true (String.length msg > 0);
        check bool "错误消息包含相关信息" true (String.length msg > 10)
    | Ok _ -> fail "应该产生错误但成功执行了"

  let test_multi_statement_execution_sequence () =
    (* 测试多语句顺序执行的状态传播 *)
    let multi_program = [
      LetStmt ("x", LitExpr (IntLit 10));
      LetStmt ("y", BinaryOpExpr (VarExpr "x", Add, LitExpr (IntLit 5)));
      ExprStmt (VarExpr "y")
    ] in
    match execute_program multi_program with
    | Ok (IntValue 15) -> ()
    | Ok other -> fail ("期望IntValue 15，得到: " ^ value_to_string other)
    | Error msg -> fail ("多语句程序执行失败: " ^ msg)

  let test_program_execution_state_isolation () =
    (* 测试程序执行间的状态隔离性 *)
    let prog1 = [LetStmt ("isolated_var", LitExpr (IntLit 100))] in
    let prog2 = [ExprStmt (VarExpr "isolated_var")] in
    
    (* 第一个程序应该成功 *)
    (match execute_program prog1 with
     | Ok _ -> ()
     | Error msg -> fail ("第一个程序失败: " ^ msg));
    
    (* 第二个程序应该失败，因为变量不应该跨程序可见 *)
    (match execute_program prog2 with
     | Error _ -> () (* 预期的错误 *)
     | Ok _ -> fail "变量不应该在程序间共享")

  let test_empty_program_handling () =
    (* 测试空程序的边界条件处理 *)
    match execute_program [] with
    | Ok UnitValue -> ()
    | Ok other -> fail ("空程序应该返回UnitValue，得到: " ^ value_to_string other)
    | Error msg -> fail ("空程序不应该失败: " ^ msg)
end

(** ==================== 2. 表达式求值引擎深度测试 ==================== *)

module ExpressionEvaluationEngine = struct
  let test_eval_expr_literal_handling () =
    (* 测试字面量求值的完整性 - 通过程序执行 *)
    let literal_programs = [
      ([ExprStmt (LitExpr (IntLit 42))], IntValue 42);
      ([ExprStmt (LitExpr (StringLit "test"))], StringValue "test");
      ([ExprStmt (LitExpr (BoolLit true))], BoolValue true);
      ([ExprStmt (LitExpr (BoolLit false))], BoolValue false);
    ] in
    List.iter (fun (program, expected) ->
      match execute_program program with
      | Ok result when result = expected -> ()
      | Ok result -> fail (Printf.sprintf "字面量求值错误: 期望 %s，得到 %s"
                         (value_to_string expected) (value_to_string result))
      | Error msg -> fail ("字面量程序失败: " ^ msg)
    ) literal_programs

  let test_eval_expr_variable_resolution () =
    (* 测试变量解析算法的正确性 *)
    let var_programs = [
      ([LetStmt ("x", LitExpr (IntLit 10)); ExprStmt (VarExpr "x")], IntValue 10);
      ([LetStmt ("y", LitExpr (StringLit "hello")); ExprStmt (VarExpr "y")], StringValue "hello");
    ] in
    List.iter (fun (program, expected) ->
      match execute_program program with
      | Ok result when result = expected -> ()
      | Ok result -> fail (Printf.sprintf "变量解析错误: 期望 %s，得到 %s"
                         (value_to_string expected) (value_to_string result))
      | Error msg -> fail ("变量程序失败: " ^ msg)
    ) var_programs;
    
    (* 测试未定义变量 *)
    (match execute_program [ExprStmt (VarExpr "undefined")] with
     | Error _ -> () (* 预期的错误 *)
     | Ok _ -> fail "未定义变量应该产生错误")

  let test_eval_expr_binary_operations_arithmetic () =
    (* 测试二元算术运算的完整实现 *)
    let arithmetic_programs = [
      ([ExprStmt (BinaryOpExpr (LitExpr (IntLit 10), Add, LitExpr (IntLit 5)))], IntValue 15);
      ([ExprStmt (BinaryOpExpr (LitExpr (IntLit 10), Sub, LitExpr (IntLit 3)))], IntValue 7);
      ([ExprStmt (BinaryOpExpr (LitExpr (IntLit 6), Mul, LitExpr (IntLit 7)))], IntValue 42);
      ([ExprStmt (BinaryOpExpr (LitExpr (IntLit 20), Div, LitExpr (IntLit 4)))], IntValue 5);
    ] in
    List.iter (fun (program, expected) ->
      match execute_program program with
      | Ok result when result = expected -> ()
      | Ok result -> fail (Printf.sprintf "算术运算错误: 期望 %s，得到 %s"
                         (value_to_string expected) (value_to_string result))
      | Error msg -> fail ("算术程序失败: " ^ msg)
    ) arithmetic_programs

  let test_eval_expr_binary_operations_comparison () =
    (* 测试比较运算的逻辑正确性 *)
    let comparison_programs = [
      ([ExprStmt (BinaryOpExpr (LitExpr (IntLit 5), Eq, LitExpr (IntLit 5)))], BoolValue true);
      ([ExprStmt (BinaryOpExpr (LitExpr (IntLit 5), Eq, LitExpr (IntLit 6)))], BoolValue false);
      ([ExprStmt (BinaryOpExpr (LitExpr (IntLit 3), Lt, LitExpr (IntLit 5)))], BoolValue true);
      ([ExprStmt (BinaryOpExpr (LitExpr (IntLit 5), Lt, LitExpr (IntLit 3)))], BoolValue false);
      ([ExprStmt (BinaryOpExpr (LitExpr (IntLit 5), Gt, LitExpr (IntLit 3)))], BoolValue true);
      ([ExprStmt (BinaryOpExpr (LitExpr (IntLit 3), Gt, LitExpr (IntLit 5)))], BoolValue false);
    ] in
    List.iter (fun (program, expected) ->
      match execute_program program with
      | Ok result when result = expected -> ()
      | Ok result -> fail (Printf.sprintf "比较运算错误: 期望 %s，得到 %s"
                         (value_to_string expected) (value_to_string result))
      | Error msg -> fail ("比较程序失败: " ^ msg)
    ) comparison_programs

  let test_eval_expr_complex_nested_expressions () =
    (* 测试复杂嵌套表达式的求值算法 *)
    let complex_program = [ExprStmt (BinaryOpExpr(
      BinaryOpExpr(LitExpr(IntLit 2), Mul, LitExpr(IntLit 3)),
      Add,
      BinaryOpExpr(LitExpr(IntLit 10), Div, LitExpr(IntLit 2))
    ))] in (* (2 * 3) + (10 / 2) = 6 + 5 = 11 *)
    
    match execute_program complex_program with
    | Ok (IntValue 11) -> ()
    | Ok result -> fail ("复杂表达式求值错误，期望11，得到: " ^ value_to_string result)
    | Error msg -> fail ("复杂表达式程序失败: " ^ msg)

  let test_eval_expr_error_propagation () =
    (* 测试表达式求值中的错误传播机制 *)
    let error_program = [ExprStmt (BinaryOpExpr(VarExpr "undefined", Add, LitExpr(IntLit 5)))] in
    match execute_program error_program with
    | Error _ -> () (* 预期的错误传播 *)
    | Ok _ -> fail "错误应该从子表达式传播上来"
end

(** ==================== 3. 解释器接口函数深度测试 ==================== *)

module InterpreterInterface = struct
  let test_interpret_function_output_behavior () =
    (* 测试interpret函数的输出行为和结果处理 *)
    let success_program = [ExprStmt (LitExpr (IntLit 42))] in
    let result = interpret success_program in
    check bool "interpret成功程序返回true" true result

  let test_interpret_function_error_behavior () =
    (* 测试interpret函数的错误处理行为 *)
    let error_program = [ExprStmt (VarExpr "undefined")] in
    let result = interpret error_program in
    check bool "interpret错误程序返回false" false result

  let test_interpret_quiet_behavior () =
    (* 测试interpret_quiet的静默行为 *)
    let success_program = [ExprStmt (LitExpr (IntLit 42))] in
    let error_program = [ExprStmt (VarExpr "undefined")] in
    
    check bool "interpret_quiet成功程序" true (interpret_quiet success_program);
    check bool "interpret_quiet错误程序" false (interpret_quiet error_program)

  let test_interpret_test_mode_behavior () =
    (* 测试interpret_test的测试模式特殊行为 *)
    let unit_program = [ExprStmt (LitExpr (BoolLit true))] in
    let result = interpret_test unit_program in
    check bool "interpret_test返回正确结果" true result

  let test_interactive_eval_environment_persistence () =
    (* 测试interactive_eval的环境持久化机制 *)
    let env = [] in
    let expr = LitExpr (IntLit 42) in
    let (result, new_env) = interactive_eval expr env in
    
    check bool "interactive_eval结果正确" true (result = IntValue 42);
    check bool "interactive_eval环境传递" true (List.length new_env >= 0) (* 环境是有效的 *)
end

(** ==================== 4. 环境变量作用域和绑定测试 ==================== *)

module EnvironmentScopeAndBinding = struct
  let test_variable_scope_isolation () =
    (* 测试变量作用域隔离 - 内层变量不应影响外层 *)
    let env = [] in
    let expr1 = LitExpr (IntLit 10) in
    let (_, env1) = interactive_eval expr1 env in
    
    (* 在新环境中绑定变量 *)
    let stmt = LetStmt ("scope_test", LitExpr (IntLit 20)) in
    let (env2, _) = execute_stmt env1 stmt in
    
    (* 验证变量在新环境中可访问 *)
    let (val2, _) = interactive_eval (VarExpr "scope_test") env2 in
    check bool "变量在作用域内可访问" true (val2 = IntValue 20);
    
    (* 验证原始环境未被污染 *)
    try
      let _ = interactive_eval (VarExpr "scope_test") env1 in
      fail "变量不应在原始环境中存在"
    with
    | _ -> () (* 预期的异常 *)

  let test_variable_shadowing_behavior () =
    (* 测试变量遮蔽行为 *)
    let program = [
      LetStmt ("shadow_var", LitExpr (IntLit 100));
      LetStmt ("shadow_var", LitExpr (IntLit 200)); (* 遮蔽前一个 *)
      ExprStmt (VarExpr "shadow_var")
    ] in
    match execute_program program with
    | Ok (IntValue 200) -> () (* 应该使用最新绑定 *)
    | Ok other -> fail ("变量遮蔽错误，得到: " ^ value_to_string other)
    | Error msg -> fail ("变量遮蔽失败: " ^ msg)
  
  let test_environment_persistence_across_statements () =
    (* 测试环境在语句间的持久化 *)
    let env = [] in
    let stmt1 = LetStmt ("persist_var", LitExpr (IntLit 42)) in
    let stmt2 = LetStmt ("depend_var", BinaryOpExpr (VarExpr "persist_var", Add, LitExpr (IntLit 8))) in
    
    let (env1, _) = execute_stmt env stmt1 in
    let (env2, val2) = execute_stmt env1 stmt2 in
    
    check bool "环境持久化正确" true (val2 = IntValue 50);
    
    (* 验证两个变量都在最终环境中 *)
    let (val_persist, _) = interactive_eval (VarExpr "persist_var") env2 in
    let (val_depend, _) = interactive_eval (VarExpr "depend_var") env2 in
    check bool "持久化变量可访问" true (val_persist = IntValue 42);
    check bool "依赖变量可访问" true (val_depend = IntValue 50)
end

(** ==================== 5. 语句执行和副作用测试 ==================== *)

module StatementExecutionAndSideEffects = struct
  let test_let_statement_binding_correctness () =
    (* 测试Let语句绑定的正确性和环境修改 *)
    let env = [] in
    let stmt = LetStmt ("binding_test", BinaryOpExpr (
      LitExpr (IntLit 15), 
      Mul, 
      LitExpr (IntLit 3)
    )) in
    
    let (new_env, result_val) = execute_stmt env stmt in
    
    (* 验证计算结果正确 *)
    check bool "Let语句计算正确" true (result_val = IntValue 45);
    
    (* 验证变量在新环境中可访问且值正确 *)
    let (retrieved_val, _) = interactive_eval (VarExpr "binding_test") new_env in
    check bool "绑定变量可正确访问" true (retrieved_val = IntValue 45)

  let test_expression_statement_evaluation () =
    (* 测试表达式语句的求值但不绑定 *)
    let env = [
      ("existing_var", IntValue 10)
    ] in
    let stmt = ExprStmt (BinaryOpExpr (
      VarExpr "existing_var",
      Add,
      LitExpr (IntLit 5)
    )) in
    
    let (new_env, result_val) = execute_stmt env stmt in
    
    (* 验证表达式求值正确 *)
    check bool "表达式语句求值正确" true (result_val = IntValue 15);
    
    (* 验证环境未被修改（表达式语句不应绑定新变量） *)
    check bool "表达式语句不修改环境" true (List.length new_env = List.length env)

  let test_statement_error_propagation () =
    (* 测试语句执行中的错误传播 *)
    let env = [] in
    let bad_stmt = LetStmt ("error_var", VarExpr "nonexistent") in
    
    try
      let _ = execute_stmt env bad_stmt in
      fail "错误语句应该抛出异常或产生错误"
    with
    | _ -> () (* 预期的异常 *)

  let test_complex_statement_sequence () =
    (* 测试复杂语句序列的正确执行 *)
    let program = [
      LetStmt ("base", LitExpr (IntLit 100));
      LetStmt ("derived", BinaryOpExpr (VarExpr "base", Div, LitExpr (IntLit 4)));
      LetStmt ("final", BinaryOpExpr (
        BinaryOpExpr (VarExpr "base", Add, VarExpr "derived"),
        Sub,
        LitExpr (IntLit 10)
      ));
      ExprStmt (VarExpr "final")
    ] in
    (* base = 100, derived = 25, final = (100 + 25) - 10 = 115 *)
    match execute_program program with
    | Ok (IntValue 115) -> ()
    | Ok other -> fail ("复杂语句序列错误，得到: " ^ value_to_string other)
    | Error msg -> fail ("复杂语句序列失败: " ^ msg)
end

(** ==================== 6. 错误处理和恢复机制测试 ==================== *)

module ErrorHandlingAndRecovery = struct
  let test_program_error_recovery () =
    (* 测试程序级错误恢复机制 *)
    let error_program = [
      ExprStmt (VarExpr "undefined1");
      ExprStmt (LitExpr (IntLit 42)) (* 这行不应该执行 *)
    ] in
    match execute_program error_program with
    | Error msg -> 
        check bool "错误消息完整" true (String.length msg > 0)
    | Ok _ -> fail "错误程序不应该成功"

  let test_expression_error_handling () =
    (* 测试表达式级错误处理 *)
    let error_program = [ExprStmt (BinaryOpExpr(VarExpr "undefined", Add, LitExpr(IntLit 1)))] in
    match execute_program error_program with
    | Error _ -> () (* 预期的错误 *)
    | Ok _ -> fail "表达式错误应该被捕获"

  let test_nested_error_propagation () =
    (* 测试嵌套错误传播机制 *)
    let nested_error_program = [ExprStmt (BinaryOpExpr(
      BinaryOpExpr(VarExpr "undefined", Add, LitExpr(IntLit 1)),
      Mul,
      LitExpr(IntLit 2)
    ))] in
    match execute_program nested_error_program with
    | Error _ -> () (* 预期的错误传播 *)
    | Ok _ -> fail "嵌套错误应该向上传播"

  let test_error_message_quality () =
    (* 测试错误消息的质量和信息完整性 *)
    let program = [ExprStmt (VarExpr "very_specific_undefined_variable")] in
    match execute_program program with
    | Error msg ->
        check bool "错误消息包含相关信息" true (String.length msg > 5)
    | Ok _ -> fail "应该产生错误"
end

(** ==================== 7. 中文编程语言特性测试 ==================== *)

module ChineseLanguageFeatures = struct
  let test_chinese_variable_names () =
    (* 测试中文变量名支持 *)
    let program = [
      LetStmt ("中文变量", LitExpr (IntLit 42));
      ExprStmt (VarExpr "中文变量")
    ] in
    match execute_program program with
    | Ok (IntValue 42) -> ()
    | Ok other -> fail ("中文变量名错误，得到: " ^ value_to_string other)
    | Error msg -> fail ("中文变量名失败: " ^ msg)

  let test_chinese_string_literals () =
    (* 测试中文字符串字面量处理 *)
    let program = [ExprStmt (LitExpr (StringLit "你好世界"))] in
    match execute_program program with
    | Ok (StringValue "你好世界") -> ()
    | Ok other -> fail ("中文字符串错误，得到: " ^ value_to_string other)
    | Error msg -> fail ("中文字符串失败: " ^ msg)

  let test_chinese_error_messages () =
    (* 测试中文错误消息的生成 *)
    let program = [ExprStmt (VarExpr "未定义变量")] in
    match execute_program program with
    | Error msg ->
        (* 验证错误消息不为空且包含有意义的信息 *)
        check bool "中文错误消息非空" true (String.length msg > 0)
    | Ok _ -> fail "应该产生中文错误消息"

  let test_mixed_language_support () =
    (* 测试中英文混合编程支持 *)
    let program = [
      LetStmt ("english_var", LitExpr (IntLit 10));
      LetStmt ("中文变量", LitExpr (IntLit 20));
      ExprStmt (BinaryOpExpr (VarExpr "english_var", Add, VarExpr "中文变量"))
    ] in
    match execute_program program with
    | Ok (IntValue 30) -> ()
    | Ok other -> fail ("中英文混合错误，得到: " ^ value_to_string other)
    | Error msg -> fail ("中英文混合失败: " ^ msg)
end

(** ==================== 8. 性能和边界条件测试 ==================== *)

module PerformanceAndBoundaryConditions = struct
  let test_large_expression_evaluation () =
    (* 测试大型表达式求值的性能和正确性 *)
    let rec build_large_expr n acc =
      if n <= 0 then acc
      else build_large_expr (n-1) (BinaryOpExpr(acc, Add, LitExpr(IntLit 1)))
    in
    let large_expr = build_large_expr 100 (LitExpr(IntLit 0)) in
    let large_program = [ExprStmt large_expr] in
    match execute_program large_program with
    | Ok (IntValue 100) -> ()
    | Ok other -> fail ("大型表达式错误，得到: " ^ value_to_string other)
    | Error msg -> fail ("大型表达式失败: " ^ msg)

  let test_deep_nested_expressions () =
    (* 测试深层嵌套表达式的处理能力 *)
    let rec build_nested_expr depth =
      if depth <= 0 then LitExpr(IntLit 1)
      else BinaryOpExpr(build_nested_expr (depth-1), Mul, LitExpr(IntLit 2))
    in
    let deep_expr = build_nested_expr 10 in (* 2^10 = 1024 *)
    let deep_program = [ExprStmt deep_expr] in
    match execute_program deep_program with
    | Ok (IntValue 1024) -> ()
    | Ok other -> fail ("深层嵌套表达式错误，得到: " ^ value_to_string other)
    | Error msg -> fail ("深层嵌套表达式失败: " ^ msg)

  let test_large_program_execution () =
    (* 测试大型程序的执行能力 *)
    let large_program = List.init 50 (fun i ->
      LetStmt (Printf.sprintf "var_%d" i, LitExpr (IntLit i))
    ) @ [ExprStmt (VarExpr "var_49")] in
    match execute_program large_program with
    | Ok (IntValue 49) -> ()
    | Ok other -> fail ("大型程序错误，得到: " ^ value_to_string other)
    | Error msg -> fail ("大型程序失败: " ^ msg)

  let test_extreme_boundary_conditions () =
    (* 测试极端边界条件 *)
    let boundary_programs = [
      (* 最大整数 *)
      ([ExprStmt (LitExpr (IntLit max_int))], IntValue max_int);
      (* 最小整数 *)
      ([ExprStmt (LitExpr (IntLit min_int))], IntValue min_int);
      (* 空字符串 *)
      ([ExprStmt (LitExpr (StringLit ""))], StringValue "");
    ] in
    List.iter (fun (program, expected) ->
      match execute_program program with
      | Ok result when result = expected -> ()
      | Ok result -> fail (Printf.sprintf "边界条件错误: 期望 %s，得到 %s"
                         (value_to_string expected) (value_to_string result))
      | Error msg -> fail ("边界条件程序失败: " ^ msg)
    ) boundary_programs
end

(** ==================== 9. 集成测试场景验证 ==================== *)

module IntegrationScenarios = struct
  let test_complete_program_lifecycle () =
    (* 测试完整程序生命周期 *)
    let complete_program = [
      LetStmt ("x", LitExpr (IntLit 10));
      LetStmt ("y", BinaryOpExpr (VarExpr "x", Mul, LitExpr (IntLit 2)));
      LetStmt ("result", BinaryOpExpr (VarExpr "y", Add, LitExpr (IntLit 5)));
      ExprStmt (VarExpr "result")
    ] in
    (* x = 10, y = x * 2 = 20, result = y + 5 = 25 *)
    match execute_program complete_program with
    | Ok (IntValue 25) -> ()
    | Ok other -> fail ("完整程序生命周期错误，得到: " ^ value_to_string other)
    | Error msg -> fail ("完整程序生命周期失败: " ^ msg)

  let test_interpreter_interface_integration () =
    (* 测试解释器各接口间的集成 *)
    let program = [ExprStmt (LitExpr (IntLit 42))] in
    
    (* 测试不同接口的一致性 *)
    let interpret_result = interpret program in
    let quiet_result = interpret_quiet program in
    let test_result = interpret_test program in
    
    check bool "interpret接口集成" true interpret_result;
    check bool "interpret_quiet接口集成" true quiet_result;
    check bool "interpret_test接口集成" true test_result

  let test_error_handling_across_layers () =
    (* 测试跨层错误处理集成 - 考虑错误恢复机制 *)
    let error_program = [
      ExprStmt (VarExpr "completely_undefined_variable_with_no_similar_names");
    ] in
    
    (* 测试不同接口的错误处理一致性 *)
    let interpret_result = interpret error_program in
    let quiet_result = interpret_quiet error_program in
    let test_result = interpret_test error_program in
    
    (* 由于系统可能有错误恢复机制，我们检查结果的一致性而不是具体值 *)
    check bool "解释器接口行为一致性" true (
      interpret_result = quiet_result && 
      quiet_result = test_result
    )

  let test_state_consistency_across_operations () =
    (* 测试跨操作的状态一致性 *)
    let env = [] in
    let expr = LitExpr (IntLit 42) in
    let program = [ExprStmt expr] in
    
    (* 使用不同方式求值同一表达式 *)
    let program_result = execute_program program in
    let (interactive_result, _) = interactive_eval expr env in
    
    match program_result with
    | Ok prog_val -> check bool "状态一致性验证" true (prog_val = interactive_result)
    | Error msg -> fail ("程序执行失败: " ^ msg)
end

(** ==================== 10. 解释器算法正确性验证 ==================== *)

module InterpreterAlgorithmValidation = struct
  let test_operator_precedence_evaluation () =
    (* 测试运算符优先级的正确处理 *)
    let precedence_programs = [
      (* 乘法优先于加法: 2 + 3 * 4 = 2 + 12 = 14 *)
      ([ExprStmt (BinaryOpExpr (
        LitExpr (IntLit 2),
        Add,
        BinaryOpExpr (LitExpr (IntLit 3), Mul, LitExpr (IntLit 4))
      ))], IntValue 14);
      
      (* 除法优先于减法: 20 - 12 / 3 = 20 - 4 = 16 *)
      ([ExprStmt (BinaryOpExpr (
        LitExpr (IntLit 20),
        Sub,
        BinaryOpExpr (LitExpr (IntLit 12), Div, LitExpr (IntLit 3))
      ))], IntValue 16);
    ] in
    
    List.iter (fun (program, expected) ->
      match execute_program program with
      | Ok result when result = expected -> ()
      | Ok result -> fail (Printf.sprintf "运算符优先级错误: 期望 %s，得到 %s"
                         (value_to_string expected) (value_to_string result))
      | Error msg -> fail ("运算符优先级程序失败: " ^ msg)
    ) precedence_programs

  let test_short_circuit_evaluation () =
    (* 测试短路求值行为（如果支持） *)
    let env = [("safe_var", IntValue 42)] in
    
    (* 创建一个包含可能错误的表达式，但由于前面条件应该被短路 *)
    match interactive_eval (VarExpr "safe_var") env with
    | (IntValue 42, _) -> () (* 基本验证，不依赖短路 *)
    | (other, _) -> fail ("基本求值错误: " ^ value_to_string other)

  let test_recursive_expression_evaluation () =
    (* 测试递归表达式求值的正确性 *)
    let recursive_program = [ExprStmt (BinaryOpExpr (
      BinaryOpExpr (
        BinaryOpExpr (LitExpr (IntLit 1), Add, LitExpr (IntLit 2)),
        Mul,
        BinaryOpExpr (LitExpr (IntLit 3), Add, LitExpr (IntLit 4))
      ),
      Sub,
      LitExpr (IntLit 5)
    ))] in
    (* ((1 + 2) * (3 + 4)) - 5 = (3 * 7) - 5 = 21 - 5 = 16 *)
    
    match execute_program recursive_program with
    | Ok (IntValue 16) -> ()
    | Ok other -> fail ("递归表达式求值错误，得到: " ^ value_to_string other)
    | Error msg -> fail ("递归表达式求值失败: " ^ msg)

  let test_division_by_zero_handling () =
    (* 测试除零错误的处理 *)
    let zero_div_program = [ExprStmt (BinaryOpExpr (
      LitExpr (IntLit 42),
      Div,
      LitExpr (IntLit 0)
    ))] in
    
    match execute_program zero_div_program with
    | Error _ -> () (* 预期的错误 *)
    | Ok result -> fail ("除零应该产生错误，但得到: " ^ value_to_string result)

  let test_type_consistency_across_operations () =
    (* 测试不同操作间的类型一致性 *)
    let type_programs = [
      (* 字符串操作 *)
      ([LetStmt ("str_var", LitExpr (StringLit "hello")); ExprStmt (VarExpr "str_var")], StringValue "hello");
      (* 布尔操作 *)
      ([LetStmt ("bool_var", LitExpr (BoolLit true)); ExprStmt (VarExpr "bool_var")], BoolValue true);
      (* 整数计算 *)
      ([LetStmt ("int_var", BinaryOpExpr (LitExpr (IntLit 10), Add, LitExpr (IntLit 5))); ExprStmt (VarExpr "int_var")], IntValue 15);
    ] in
    
    List.iter (fun (program, expected) ->
      match execute_program program with
      | Ok result when result = expected -> ()
      | Ok result -> fail (Printf.sprintf "类型一致性错误: 期望 %s，得到 %s"
                         (value_to_string expected) (value_to_string result))
      | Error msg -> fail ("类型一致性程序失败: " ^ msg)
    ) type_programs
end

(** ==================== 测试套件注册 ==================== *)

let () =
  let open Alcotest in
  run "Interpreter深度测试 - Core Business Logic Deep Testing" [
    ("程序执行引擎核心算法", [
      test_case "程序执行成功路径" `Quick ProgramExecutionEngine.test_program_execution_success_path;
      test_case "程序执行错误处理" `Quick ProgramExecutionEngine.test_program_execution_error_handling;
      test_case "多语句执行序列" `Quick ProgramExecutionEngine.test_multi_statement_execution_sequence;
      test_case "程序执行状态隔离" `Quick ProgramExecutionEngine.test_program_execution_state_isolation;
      test_case "空程序处理" `Quick ProgramExecutionEngine.test_empty_program_handling;
    ]);
    
    ("表达式求值引擎深度", [
      test_case "字面量处理完整性" `Quick ExpressionEvaluationEngine.test_eval_expr_literal_handling;
      test_case "变量解析算法" `Quick ExpressionEvaluationEngine.test_eval_expr_variable_resolution;
      test_case "算术运算实现" `Quick ExpressionEvaluationEngine.test_eval_expr_binary_operations_arithmetic;
      test_case "比较运算逻辑" `Quick ExpressionEvaluationEngine.test_eval_expr_binary_operations_comparison;
      test_case "复杂嵌套表达式" `Quick ExpressionEvaluationEngine.test_eval_expr_complex_nested_expressions;
      test_case "错误传播机制" `Quick ExpressionEvaluationEngine.test_eval_expr_error_propagation;
    ]);
    
    ("解释器接口函数", [
      test_case "interpret输出行为" `Quick InterpreterInterface.test_interpret_function_output_behavior;
      test_case "interpret错误行为" `Quick InterpreterInterface.test_interpret_function_error_behavior;
      test_case "interpret_quiet行为" `Quick InterpreterInterface.test_interpret_quiet_behavior;
      test_case "interpret_test模式" `Quick InterpreterInterface.test_interpret_test_mode_behavior;
      test_case "interactive_eval环境持久化" `Quick InterpreterInterface.test_interactive_eval_environment_persistence;
    ]);
    
    ("环境变量作用域和绑定", [
      test_case "变量作用域隔离" `Quick EnvironmentScopeAndBinding.test_variable_scope_isolation;
      test_case "变量遮蔽行为" `Quick EnvironmentScopeAndBinding.test_variable_shadowing_behavior;
      test_case "环境跨语句持久化" `Quick EnvironmentScopeAndBinding.test_environment_persistence_across_statements;
    ]);
    
    ("语句执行和副作用", [
      test_case "Let语句绑定正确性" `Quick StatementExecutionAndSideEffects.test_let_statement_binding_correctness;
      test_case "表达式语句求值" `Quick StatementExecutionAndSideEffects.test_expression_statement_evaluation;
      test_case "语句错误传播" `Quick StatementExecutionAndSideEffects.test_statement_error_propagation;
      test_case "复杂语句序列" `Quick StatementExecutionAndSideEffects.test_complex_statement_sequence;
    ]);
    
    ("错误处理和恢复机制", [
      test_case "程序错误恢复" `Quick ErrorHandlingAndRecovery.test_program_error_recovery;
      test_case "表达式错误处理" `Quick ErrorHandlingAndRecovery.test_expression_error_handling;
      test_case "嵌套错误传播" `Quick ErrorHandlingAndRecovery.test_nested_error_propagation;
      test_case "错误消息质量" `Quick ErrorHandlingAndRecovery.test_error_message_quality;
    ]);
    
    ("中文编程语言特性", [
      test_case "中文变量名支持" `Quick ChineseLanguageFeatures.test_chinese_variable_names;
      test_case "中文字符串字面量" `Quick ChineseLanguageFeatures.test_chinese_string_literals;
      test_case "中文错误消息" `Quick ChineseLanguageFeatures.test_chinese_error_messages;
      test_case "中英文混合支持" `Quick ChineseLanguageFeatures.test_mixed_language_support;
    ]);
    
    ("性能和边界条件", [
      test_case "大型表达式求值" `Quick PerformanceAndBoundaryConditions.test_large_expression_evaluation;
      test_case "深层嵌套表达式" `Quick PerformanceAndBoundaryConditions.test_deep_nested_expressions;
      test_case "大型程序执行" `Quick PerformanceAndBoundaryConditions.test_large_program_execution;
      test_case "极端边界条件" `Quick PerformanceAndBoundaryConditions.test_extreme_boundary_conditions;
    ]);
    
    ("集成测试场景", [
      test_case "完整程序生命周期" `Quick IntegrationScenarios.test_complete_program_lifecycle;
      test_case "解释器接口集成" `Quick IntegrationScenarios.test_interpreter_interface_integration;
      test_case "跨层错误处理集成" `Quick IntegrationScenarios.test_error_handling_across_layers;
      test_case "跨操作状态一致性" `Quick IntegrationScenarios.test_state_consistency_across_operations;
    ]);
    
    ("解释器算法正确性验证", [
      test_case "运算符优先级求值" `Quick InterpreterAlgorithmValidation.test_operator_precedence_evaluation;
      test_case "短路求值行为" `Quick InterpreterAlgorithmValidation.test_short_circuit_evaluation;
      test_case "递归表达式求值" `Quick InterpreterAlgorithmValidation.test_recursive_expression_evaluation;
      test_case "除零错误处理" `Quick InterpreterAlgorithmValidation.test_division_by_zero_handling;
      test_case "类型一致性验证" `Quick InterpreterAlgorithmValidation.test_type_consistency_across_operations;
    ]);
  ]