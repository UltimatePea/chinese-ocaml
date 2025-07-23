(** 骆言解释器语句执行引擎综合测试 - Chinese Programming Language Statement Executor Comprehensive Tests *)

open Alcotest
open Yyocamlc_lib.Ast
open Yyocamlc_lib.Statement_executor
open Yyocamlc_lib.Value_operations
open Yyocamlc_lib.Interpreter_utils
open Yyocamlc_lib.Interpreter_state

(** 测试辅助函数：创建基础环境 *)
let create_test_env () =
  let builtin_env = Yyocamlc_lib.Builtin_functions.builtin_functions in
  builtin_env @ []

(** 测试辅助函数：执行单个语句并返回结果 *)  
let execute_single_stmt stmt =
  let env = create_test_env () in
  try
    let new_env, value = execute_stmt env stmt in
    Ok (new_env, value)
  with
  | RuntimeError msg -> Error ("运行时错误: " ^ msg)
  | e -> Error ("未知错误: " ^ Printexc.to_string e)

(** 测试辅助函数：创建变量表达式 *)
let var name = VarExpr name

(** 测试辅助函数：创建整数字面量 *)
let int_lit n = LitExpr (IntLit n)

(** 测试辅助函数：创建字符串字面量 *)
let str_lit s = LitExpr (StringLit s)

(** 测试辅助函数：创建布尔字面量 *)
let bool_lit b = LitExpr (BoolLit b)

(** 测试辅助函数：创建单元字面量 *)
let unit_lit = LitExpr UnitLit

(** 1. 表达式语句执行测试套件 *)
let test_expr_stmt_execution () =
  (* 测试简单表达式语句 *)
  let stmt = ExprStmt (int_lit 42) in
  let result = execute_single_stmt stmt in
  match result with
  | Ok (_, IntValue 42) -> ()
  | _ -> failwith "表达式语句执行失败"

let test_expr_stmt_string () =
  (* 测试字符串表达式语句 *)
  let stmt = ExprStmt (str_lit "测试字符串") in
  let result = execute_single_stmt stmt in
  match result with
  | Ok (_, StringValue "测试字符串") -> ()
  | _ -> failwith "字符串表达式语句执行失败"

let test_expr_stmt_boolean () =
  (* 测试布尔表达式语句 *)
  let stmt = ExprStmt (bool_lit true) in
  let result = execute_single_stmt stmt in
  match result with
  | Ok (_, BoolValue true) -> ()
  | _ -> failwith "布尔表达式语句执行失败"

let test_expr_stmt_unit () =
  (* 测试单元表达式语句 *)
  let stmt = ExprStmt unit_lit in
  let result = execute_single_stmt stmt in
  match result with
  | Ok (_, UnitValue) -> ()
  | _ -> failwith "单元表达式语句执行失败"

(** 2. Let语句执行测试套件 *)
let test_let_stmt_basic () =
  (* 测试基础let语句 *)
  let stmt = LetStmt ("变量", int_lit 100) in
  let result = execute_single_stmt stmt in
  match result with
  | Ok (new_env, IntValue 100) -> 
      (* 验证变量已绑定到环境 *)
      (match lookup_var new_env "变量" with
       | IntValue 100 -> ()
       | _ -> failwith "let语句变量绑定失败")
  | _ -> failwith "let语句执行失败"

let test_let_stmt_string () =
  (* 测试字符串let语句 *)
  let stmt = LetStmt ("字符串变量", str_lit "中文字符串") in
  let result = execute_single_stmt stmt in
  match result with
  | Ok (new_env, StringValue "中文字符串") -> 
      (match lookup_var new_env "字符串变量" with
       | StringValue "中文字符串" -> ()
       | _ -> failwith "字符串let语句变量绑定失败")
  | _ -> failwith "字符串let语句执行失败"

let test_let_stmt_complex_expr () =
  (* 测试复杂表达式let语句 *)  
  let expr = BinaryOpExpr (int_lit 10, Add, int_lit 20) in
  let stmt = LetStmt ("计算结果", expr) in
  let result = execute_single_stmt stmt in
  match result with
  | Ok (new_env, IntValue 30) -> 
      (match lookup_var new_env "计算结果" with
       | IntValue 30 -> ()
       | _ -> failwith "复杂表达式let语句变量绑定失败")
  | _ -> failwith "复杂表达式let语句执行失败"

(** 3. 带类型注解的Let语句测试套件 *)
let test_let_with_type_stmt () =
  (* 测试带类型注解的let语句 *)
  let type_expr = BaseTypeExpr IntType in
  let stmt = LetStmtWithType ("类型变量", type_expr, int_lit 50) in
  let result = execute_single_stmt stmt in
  match result with
  | Ok (new_env, IntValue 50) -> 
      (match lookup_var new_env "类型变量" with
       | IntValue 50 -> ()
       | _ -> failwith "带类型let语句变量绑定失败")
  | _ -> failwith "带类型let语句执行失败"

let test_let_with_type_string () =
  (* 测试带类型注解的字符串let语句 *)
  let type_expr = BaseTypeExpr StringType in
  let stmt = LetStmtWithType ("类型字符串", type_expr, str_lit "带类型") in
  let result = execute_single_stmt stmt in
  match result with
  | Ok (new_env, StringValue "带类型") -> 
      (match lookup_var new_env "类型字符串" with
       | StringValue "带类型" -> ()
       | _ -> failwith "带类型字符串let语句变量绑定失败")
  | _ -> failwith "带类型字符串let语句执行失败"

(** 4. 递归Let语句测试套件 *)
let test_rec_let_stmt_basic () =
  (* 测试基础递归let语句 *)
  let func_expr = FunExpr (["n"], 
    CondExpr (BinaryOpExpr (var "n", Eq, int_lit 0),
            int_lit 1,
            BinaryOpExpr (var "n", Mul, 
                     FunCallExpr (var "阶乘", [BinaryOpExpr (var "n", Sub, int_lit 1)])))) in
  let stmt = RecLetStmt ("阶乘", func_expr) in
  let result = execute_single_stmt stmt in
  match result with
  | Ok (new_env, _) -> 
      (* 验证递归函数已绑定到环境 *)
      (match lookup_var new_env "阶乘" with
       | FunctionValue _ -> ()
       | _ -> failwith "递归函数绑定失败")  
  | _ -> failwith "递归let语句执行失败"

let test_rec_let_with_type () =
  (* 测试带类型注解的递归let语句 *)
  let type_expr = FunType (BaseTypeExpr IntType, BaseTypeExpr IntType) in
  let func_expr = FunExpr (["x"], int_lit 42) in
  let stmt = RecLetStmtWithType ("递归函数", type_expr, func_expr) in
  let result = execute_single_stmt stmt in
  match result with
  | Ok (new_env, _) -> 
      (match lookup_var new_env "递归函数" with
       | FunctionValue _ -> ()
       | _ -> failwith "带类型递归函数绑定失败")
  | _ -> failwith "带类型递归let语句执行失败"

(** 5. 类型定义语句测试套件 *)
let test_type_def_stmt_basic () =
  (* 测试基础类型定义语句 *)
  let variant_def = AlgebraicType [("成功", None); ("失败", Some (BaseTypeExpr StringType))] in
  let stmt = TypeDefStmt ("结果", variant_def) in
  let result = execute_single_stmt stmt in
  match result with
  | Ok (new_env, UnitValue) -> 
      (* 验证构造器已注册 *)
      (match lookup_var new_env "成功" with
       | BuiltinFunctionValue _ -> ()
       | _ -> failwith "类型构造器注册失败")
  | _ -> failwith "类型定义语句执行失败"

let test_type_def_record () =
  (* 测试记录类型定义语句 *)
  let record_def = RecordType [("姓名", BaseTypeExpr StringType); ("年龄", BaseTypeExpr IntType)] in
  let stmt = TypeDefStmt ("人员", record_def) in
  let result = execute_single_stmt stmt in
  match result with
  | Ok (_, UnitValue) -> ()
  | _ -> failwith "记录类型定义语句执行失败"

(** 6. 异常定义语句测试套件 *)
let test_exception_def_no_param () =
  (* 测试无参异常定义 *)
  let stmt = ExceptionDefStmt ("自定义异常", None) in
  let result = execute_single_stmt stmt in
  match result with
  | Ok (new_env, UnitValue) -> 
      (* 验证异常构造器已绑定 *)
      (match lookup_var new_env "自定义异常" with
       | BuiltinFunctionValue _ -> ()
       | _ -> failwith "无参异常构造器绑定失败")
  | _ -> failwith "无参异常定义语句执行失败"

let test_exception_def_with_param () =
  (* 测试带参异常定义 *)
  let param_type = BaseTypeExpr StringType in
  let stmt = ExceptionDefStmt ("带参异常", Some param_type) in
  let result = execute_single_stmt stmt in
  match result with
  | Ok (new_env, UnitValue) -> 
      (* 验证异常构造器已绑定 *)
      (match lookup_var new_env "带参异常" with
       | BuiltinFunctionValue _ -> ()
       | _ -> failwith "带参异常构造器绑定失败")
  | _ -> failwith "带参异常定义语句执行失败"

(** 7. 语义Let语句测试套件 *)
let test_semantic_let_stmt () =
  (* 测试语义let语句 *)
  let semantic_label = "数学计算" in
  let stmt = SemanticLetStmt ("数学值", semantic_label, int_lit 123) in
  let result = execute_single_stmt stmt in
  match result with
  | Ok (new_env, IntValue 123) -> 
      (match lookup_var new_env "数学值" with
       | IntValue 123 -> ()
       | _ -> failwith "语义let语句变量绑定失败")
  | _ -> failwith "语义let语句执行失败"

let test_semantic_let_string () =
  (* 测试语义let字符串语句 *)
  let semantic_label = "文本处理" in
  let stmt = SemanticLetStmt ("文本", semantic_label, str_lit "语义标签") in
  let result = execute_single_stmt stmt in
  match result with
  | Ok (new_env, StringValue "语义标签") -> 
      (match lookup_var new_env "文本" with
       | StringValue "语义标签" -> ()
       | _ -> failwith "语义let字符串变量绑定失败")
  | _ -> failwith "语义let字符串语句执行失败"

(** 8. 错误处理测试套件 *)
let test_undefined_variable_error () =
  (* 测试未定义变量错误处理 *)
  let stmt = LetStmt ("新变量", var "未定义变量") in
  let result = execute_single_stmt stmt in
  match result with
  | Error _ -> ()  (* 预期错误 *)
  | Ok _ -> failwith "未定义变量应该产生错误"

let test_type_error_handling () =
  (* 测试类型错误处理 *)
  let invalid_expr = BinaryOpExpr (str_lit "文本", Add, int_lit 10) in
  let stmt = LetStmt ("错误变量", invalid_expr) in
  let result = execute_single_stmt stmt in
  match result with
  | Error _ -> ()  (* 预期错误 *)
  | Ok _ -> failwith "类型不匹配应该产生错误"

(** 9. 程序执行测试套件 *)
let test_execute_program_simple () =
  (* 测试简单程序执行 *)
  let program = [
    LetStmt ("变量1", int_lit 10);
    LetStmt ("变量2", int_lit 20);
    ExprStmt (BinaryOpExpr (var "变量1", Add, var "变量2"))
  ] in
  let result = execute_program program in
  match result with
  | Ok (IntValue 30) -> ()
  | _ -> failwith "简单程序执行失败"

let test_execute_program_with_function () =
  (* 测试包含函数的程序执行 *)
  let program = [
    LetStmt ("加法", FunExpr (["a"; "b"], BinaryOpExpr (var "a", Add, var "b")));
    ExprStmt (FunCallExpr (var "加法", [int_lit 15, int_lit 25]))
  ] in
  let result = execute_program program in
  match result with
  | Ok (IntValue 40) -> ()
  | _ -> failwith "包含函数的程序执行失败"

let test_execute_program_error () =
  (* 测试程序执行错误处理 *)
  let program = [
    ExprStmt (var "不存在的变量")
  ] in
  let result = execute_program program in
  match result with
  | Error _ -> ()  (* 预期错误 *)
  | Ok _ -> failwith "错误程序应该返回错误"

(** 10. 环境管理和作用域测试套件 *)
let test_variable_scoping () =
  (* 测试变量作用域管理 *)
  let env = create_test_env () in
  let env1, _ = execute_stmt env (LetStmt ("外层变量", int_lit 100)) in
  let env2, _ = execute_stmt env1 (LetStmt ("内层变量", int_lit 200)) in
  (* 验证两个变量都可访问 *)
  match (lookup_var env2 "外层变量", lookup_var env2 "内层变量") with
  | (IntValue 100, IntValue 200) -> ()
  | _ -> failwith "变量作用域管理失败"

let test_variable_shadowing () =
  (* 测试变量遮蔽 *)
  let env = create_test_env () in
  let env1, _ = execute_stmt env (LetStmt ("变量", int_lit 100)) in
  let env2, _ = execute_stmt env1 (LetStmt ("变量", str_lit "新值")) in
  (* 验证变量被正确遮蔽 *)
  match lookup_var env2 "变量" with
  | StringValue "新值" -> ()
  | _ -> failwith "变量遮蔽失败"

(** 测试套件汇总 *)
let statement_executor_tests = [
  (* 表达式语句测试 *)
  ("表达式语句_整数执行", `Quick, test_expr_stmt_execution);
  ("表达式语句_字符串执行", `Quick, test_expr_stmt_string);
  ("表达式语句_布尔执行", `Quick, test_expr_stmt_boolean);
  ("表达式语句_单元执行", `Quick, test_expr_stmt_unit);
  
  (* Let语句测试 *)
  ("Let语句_基础整数", `Quick, test_let_stmt_basic);
  ("Let语句_字符串", `Quick, test_let_stmt_string);
  ("Let语句_复杂表达式", `Quick, test_let_stmt_complex_expr);
  
  (* 带类型注解Let语句测试 *)
  ("带类型Let语句_整数", `Quick, test_let_with_type_stmt);
  ("带类型Let语句_字符串", `Quick, test_let_with_type_string);
  
  (* 递归Let语句测试 *)
  ("递归Let语句_基础", `Quick, test_rec_let_stmt_basic);
  ("递归Let语句_带类型", `Quick, test_rec_let_with_type);
  
  (* 类型定义语句测试 *)
  ("类型定义语句_变体", `Quick, test_type_def_stmt_basic);
  ("类型定义语句_记录", `Quick, test_type_def_record);
  
  (* 异常定义语句测试 *)
  ("异常定义_无参数", `Quick, test_exception_def_no_param);
  ("异常定义_带参数", `Quick, test_exception_def_with_param);
  
  (* 语义Let语句测试 *)
  ("语义Let语句_整数", `Quick, test_semantic_let_stmt);
  ("语义Let语句_字符串", `Quick, test_semantic_let_string);
  
  (* 错误处理测试 *)
  ("错误处理_未定义变量", `Quick, test_undefined_variable_error);
  ("错误处理_类型错误", `Quick, test_type_error_handling);
  
  (* 程序执行测试 *)
  ("程序执行_简单程序", `Quick, test_execute_program_simple);
  ("程序执行_包含函数", `Quick, test_execute_program_with_function);
  ("程序执行_错误程序", `Quick, test_execute_program_error);
  
  (* 环境管理测试 *)
  ("环境管理_变量作用域", `Quick, test_variable_scoping);
  ("环境管理_变量遮蔽", `Quick, test_variable_shadowing);
]

(** 主测试运行函数 *)
let () = run "骆言语句执行引擎综合测试" [ ("语句执行引擎", statement_executor_tests) ]