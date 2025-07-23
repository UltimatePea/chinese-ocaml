(** 骆言解释器执行引擎集成测试 - Chinese Programming Language Execution Engine Integration Tests *)

open Alcotest
open Yyocamlc_lib.Ast
open Yyocamlc_lib.Statement_executor
open Yyocamlc_lib.Function_caller
open Yyocamlc_lib.Pattern_matcher
open Yyocamlc_lib.Expression_evaluator
open Yyocamlc_lib.Value_operations
open Yyocamlc_lib.Interpreter_utils

(** 测试辅助函数：创建基础环境 *)
let create_test_env () =
  let builtin_env = Yyocamlc_lib.Builtin_functions.builtin_functions in
  builtin_env @ []

(** 测试辅助函数：执行完整程序 *)
let execute_test_program program =
  try
    let result = execute_program program in
    result
  with
  | e -> Error ("执行错误: " ^ Printexc.to_string e)

(** 测试辅助函数：创建变量表达式 *)
let var name = VarExpr name

(** 测试辅助函数：创建整数字面量 *)
let int_lit n = LitExpr (IntLit n)

(** 测试辅助函数：创建字符串字面量 *)
let str_lit s = LitExpr (StringLit s)

(** 测试辅助函数：创建布尔字面量 *)
let bool_lit b = LitExpr (BoolLit b)

(** 1. 基础执行引擎集成测试套件 *)
let test_simple_arithmetic_program () =
  (* 测试简单算术程序集成执行 *)
  let program = [
    LetStmt ("数值1", int_lit 15);
    LetStmt ("数值2", int_lit 25);
    LetStmt ("加法结果", BinaryOp (var "数值1", Add, var "数值2"));
    LetStmt ("乘法结果", BinaryOp (var "加法结果", Multiply, int_lit 2));
    ExprStmt (var "乘法结果")
  ] in
  let result = execute_test_program program in
  match result with
  | Ok (IntegerValue 80) -> ()  (* (15 + 25) * 2 = 80 *)
  | _ -> failwith "简单算术程序集成执行失败"

let test_string_processing_program () =
  (* 测试字符串处理程序集成执行 *)
  let program = [
    LetStmt ("前缀", str_lit "骆言");
    LetStmt ("后缀", str_lit "编程语言");
    LetStmt ("分隔符", str_lit " - ");
    LetStmt ("完整名称", BinaryOp (
      BinaryOp (var "前缀", Add, var "分隔符"), 
      Add, var "后缀"
    ));
    ExprStmt (var "完整名称")
  ] in
  let result = execute_test_program program in
  match result with
  | Ok (StringValue "骆言 - 编程语言") -> ()
  | _ -> failwith "字符串处理程序集成执行失败"

let test_conditional_execution_program () =
  (* 测试条件执行程序集成 *)
  let program = [
    LetStmt ("年龄", int_lit 25);
    LetStmt ("分类", IfElse (
      BinaryOp (var "年龄", GreaterEqual, int_lit 18),
      str_lit "成年人",
      str_lit "未成年人"
    ));
    ExprStmt (var "分类")
  ] in
  let result = execute_test_program program in
  match result with
  | Ok (StringValue "成年人") -> ()
  | _ -> failwith "条件执行程序集成失败"

(** 2. 函数定义和调用集成测试套件 *)
let test_function_definition_and_call () =
  (* 测试函数定义和调用集成 *)
  let program = [
    LetStmt ("加法函数", FunctionLiteral (["a"; "b"], 
      BinaryOp (var "a", Add, var "b")
    ));
    LetStmt ("结果", FunctionCall (var "加法函数", [int_lit 10; int_lit 20]));
    ExprStmt (var "结果")
  ] in
  let result = execute_test_program program in
  match result with
  | Ok (IntegerValue 30) -> ()
  | _ -> failwith "函数定义和调用集成失败"

let test_recursive_function_integration () =
  (* 测试递归函数集成 *)
  let program = [
    RecLetStmt ("阶乘", FunctionLiteral (["n"],
      IfElse (BinaryOp (var "n", LessEqual, int_lit 1),
              int_lit 1,
              BinaryOp (var "n", Multiply,
                       FunctionCall (var "阶乘", [BinaryOp (var "n", Subtract, int_lit 1)])))
    ));
    LetStmt ("结果", FunctionCall (var "阶乘", [int_lit 5]));
    ExprStmt (var "结果")
  ] in
  let result = execute_test_program program in
  match result with
  | Ok (IntegerValue 120) -> ()  (* 5! = 120 *)
  | _ -> failwith "递归函数集成失败"

let test_higher_order_function () =
  (* 测试高阶函数集成 *)
  let program = [
    LetStmt ("应用函数", FunctionLiteral (["函数"; "值"],
      FunctionCall (var "函数", [var "值"])
    ));
    LetStmt ("平方函数", FunctionLiteral (["x"],
      BinaryOp (var "x", Multiply, var "x")
    ));
    LetStmt ("结果", FunctionCall (var "应用函数", [var "平方函数"; int_lit 7]));
    ExprStmt (var "结果")
  ] in
  let result = execute_test_program program in
  match result with
  | Ok (IntegerValue 49) -> ()  (* 7^2 = 49 *)
  | _ -> failwith "高阶函数集成失败"

(** 3. 模式匹配集成测试套件 *)
let test_simple_pattern_matching () =
  (* 测试简单模式匹配集成 *)
  let program = [
    LetStmt ("测试值", int_lit 42);
    LetStmt ("匹配结果", Match (var "测试值", [
      { pattern = LitPattern (IntLit 0); guard = None; expr = str_lit "零" };
      { pattern = LitPattern (IntLit 42); guard = None; expr = str_lit "答案" };
      { pattern = WildcardPattern; guard = None; expr = str_lit "其他" };
    ]));
    ExprStmt (var "匹配结果")
  ] in
  let result = execute_test_program program in
  match result with
  | Ok (StringValue "答案") -> ()
  | _ -> failwith "简单模式匹配集成失败"

let test_list_pattern_matching () =
  (* 测试列表模式匹配集成 *)
  let program = [
    LetStmt ("测试列表", ListLiteral [int_lit 1; int_lit 2; int_lit 3]);
    LetStmt ("处理结果", Match (var "测试列表", [
      { pattern = EmptyListPattern; guard = None; expr = str_lit "空列表" };
      { pattern = ConsPattern (VarPattern "头", VarPattern "尾"); guard = None; 
        expr = BinaryOp (str_lit "头部: ", Add, 
                        FunctionCall (var "整数转字符串", [var "头"])) };
    ]));
    ExprStmt (var "处理结果")
  ] in
  let result = execute_test_program program in
  match result with
  | Ok (StringValue "头部: 1") -> ()
  | _ -> failwith "列表模式匹配集成失败"

let test_guard_pattern_matching () =
  (* 测试带guard的模式匹配集成 *)
  let program = [
    LetStmt ("数值", int_lit 15);
    LetStmt ("分类", Match (var "数值", [
      { pattern = VarPattern "n"; 
        guard = Some (BinaryOp (var "n", Less, int_lit 0)); 
        expr = str_lit "负数" };
      { pattern = VarPattern "n"; 
        guard = Some (BinaryOp (var "n", Greater, int_lit 10)); 
        expr = str_lit "大于10" };
      { pattern = WildcardPattern; guard = None; expr = str_lit "其他" };
    ]));
    ExprStmt (var "分类")
  ] in
  let result = execute_test_program program in
  match result with
  | Ok (StringValue "大于10") -> ()
  | _ -> failwith "带guard的模式匹配集成失败"

(** 4. 类型定义和构造器集成测试套件 *)
let test_algebraic_type_definition () =
  (* 测试代数类型定义集成 *)
  let program = [
    TypeDefStmt ("结果", VariantType [("成功", Some (TypeExpr "int")); ("失败", Some (TypeExpr "string"))]);
    LetStmt ("成功值", FunctionCall (var "成功", [int_lit 42]));
    LetStmt ("失败值", FunctionCall (var "失败", [str_lit "错误信息"]));
    LetStmt ("处理成功", Match (var "成功值", [
      { pattern = ConstructorPattern ("成功", [VarPattern "值"]); guard = None; 
        expr = BinaryOp (str_lit "成功: ", Add, FunctionCall (var "整数转字符串", [var "值"])) };
      { pattern = ConstructorPattern ("失败", [VarPattern "错误"]); guard = None; 
        expr = BinaryOp (str_lit "失败: ", Add, var "错误") };
    ]));
    ExprStmt (var "处理成功")
  ] in
  let result = execute_test_program program in
  match result with
  | Ok (StringValue "成功: 42") -> ()
  | _ -> failwith "代数类型定义集成失败"

(** 5. 异常处理集成测试套件 *)
let test_exception_definition_and_handling () =
  (* 测试异常定义和处理集成 *)
  let program = [
    ExceptionDefStmt ("自定义错误", Some (TypeExpr "string"));
    LetStmt ("抛出异常", FunctionLiteral (["信息"],
      ThrowExpr (FunctionCall (var "自定义错误", [var "信息"]))
    ));
    LetStmt ("处理结果", TryWith (
      FunctionCall (var "抛出异常", [str_lit "测试异常"]),
      [{ pattern = ConstructorPattern ("自定义错误", [VarPattern "错误信息"]); 
         guard = None; 
         expr = BinaryOp (str_lit "捕获到: ", Add, var "错误信息") }]
    ));
    ExprStmt (var "处理结果")
  ] in
  let result = execute_test_program program in
  match result with
  | Ok (StringValue "捕获到: 测试异常") -> ()
  | _ -> failwith "异常定义和处理集成失败"

(** 6. 复杂数据结构集成测试套件 *)
let test_list_operations_integration () = 
  (* 测试列表操作集成 *)
  let program = [
    LetStmt ("原始列表", ListLiteral [int_lit 1; int_lit 2; int_lit 3]);
    LetStmt ("映射函数", FunctionLiteral (["列表"; "函数"],
      Match (var "列表", [
        { pattern = EmptyListPattern; guard = None; expr = ListLiteral [] };
        { pattern = ConsPattern (VarPattern "头", VarPattern "尾"); guard = None;
          expr = ConsExpr (
            FunctionCall (var "函数", [var "头"]),
            FunctionCall (var "映射函数", [var "尾"; var "函数"])
          ) };
      ])
    ));
    LetStmt ("双倍函数", FunctionLiteral (["x"], BinaryOp (var "x", Multiply, int_lit 2)));
    LetStmt ("结果列表", FunctionCall (var "映射函数", [var "原始列表"; var "双倍函数"]));
    ExprStmt (var "结果列表")
  ] in
  let result = execute_test_program program in
  match result with
  | Ok (ListValue [IntegerValue 2; IntegerValue 4; IntegerValue 6]) -> ()
  | _ -> failwith "列表操作集成失败"

let test_record_operations_integration () =
  (* 测试记录操作集成 *)
  let program = [
    LetStmt ("人员记录", RecordLiteral [("姓名", str_lit "张三"); ("年龄", int_lit 30)]);
    LetStmt ("获取姓名", FieldAccess (var "人员记录", "姓名"));
    LetStmt ("获取年龄", FieldAccess (var "人员记录", "年龄"));
    LetStmt ("描述", BinaryOp (
      BinaryOp (var "获取姓名", Add, str_lit "今年"),
      Add, BinaryOp (FunctionCall (var "整数转字符串", [var "获取年龄"]), Add, str_lit "岁")
    ));
    ExprStmt (var "描述")
  ] in
  let result = execute_test_program program in
  match result with
  | Ok (StringValue "张三今年30岁") -> ()
  | _ -> failwith "记录操作集成失败"

(** 7. 错误处理和恢复集成测试套件 *)
let test_error_recovery_integration () =
  (* 测试错误恢复集成 *)
  Yyocamlc_lib.Error_recovery.enable_recovery ();
  let program = [
    LetStmt ("容错函数", FunctionLiteral (["x"],
      BinaryOp (var "x", Add, int_lit 10)
    ));
    (* 调用时参数过多，但启用了错误恢复 *)
    LetStmt ("结果", FunctionCall (var "容错函数", [int_lit 5; int_lit 100; int_lit 200]));
    ExprStmt (var "结果")
  ] in
  let result = execute_test_program program in
  match result with
  | Ok (IntegerValue 15) -> ()  (* 只使用第一个参数: 5 + 10 = 15 *)
  | _ -> failwith "错误恢复集成失败"

let test_nested_function_calls () =
  (* 测试嵌套函数调用集成 *)
  let program = [
    LetStmt ("加法", FunctionLiteral (["a"; "b"], BinaryOp (var "a", Add, var "b")));
    LetStmt ("乘法", FunctionLiteral (["x"; "y"], BinaryOp (var "x", Multiply, var "y")));
    LetStmt ("复合计算", FunctionLiteral (["n"],
      FunctionCall (var "乘法", [
        FunctionCall (var "加法", [var "n"; int_lit 5]);
        int_lit 3
      ])
    ));
    LetStmt ("结果", FunctionCall (var "复合计算", [int_lit 7]));
    ExprStmt (var "结果")
  ] in
  let result = execute_test_program program in
  match result with
  | Ok (IntegerValue 36) -> ()  (* (7 + 5) * 3 = 36 *)
  | _ -> failwith "嵌套函数调用集成失败"

(** 8. 作用域和环境管理集成测试套件 *)
let test_variable_scoping_integration () =
  (* 测试变量作用域集成管理 *)
  let program = [
    LetStmt ("全局变量", int_lit 100);
    LetStmt ("局部函数", FunctionLiteral (["参数"],
      LetExpr ("局部变量", int_lit 50,
        BinaryOp (
          BinaryOp (var "全局变量", Add, var "局部变量"),
          Add, var "参数"
        )
      )
    ));
    LetStmt ("调用结果", FunctionCall (var "局部函数", [int_lit 25]));
    ExprStmt (var "调用结果")
  ] in
  let result = execute_test_program program in
  match result with
  | Ok (IntegerValue 175) -> ()  (* 100 + 50 + 25 = 175 *)
  | _ -> failwith "变量作用域集成管理失败"

let test_closure_capture_integration () =
  (* 测试闭包捕获集成 *)
  let program = [
    LetStmt ("外部值", int_lit 10);
    LetStmt ("闭包生成器", FunctionLiteral (["增量"],
      FunctionLiteral (["输入"],
        BinaryOp (
          BinaryOp (var "外部值", Add, var "增量"),
          Add, var "输入"
        )
      )
    ));
    LetStmt ("特定闭包", FunctionCall (var "闭包生成器", [int_lit 20]));
    LetStmt ("最终结果", FunctionCall (var "特定闭包", [int_lit 5]));
    ExprStmt (var "最终结果")
  ] in
  let result = execute_test_program program in
  match result with
  | Ok (IntegerValue 35) -> ()  (* 10 + 20 + 5 = 35 *)
  | _ -> failwith "闭包捕获集成失败"

(** 9. 性能和资源管理集成测试套件 *)
let test_tail_recursion_integration () =
  (* 测试尾递归集成 *)
  let program = [
    RecLetStmt ("尾递归累加", FunctionLiteral (["n"; "累计"],
      IfElse (BinaryOp (var "n", LessEqual, int_lit 0),
              var "累计",
              FunctionCall (var "尾递归累加", [
                BinaryOp (var "n", Subtract, int_lit 1);
                BinaryOp (var "累计", Add, var "n")
              ]))
    ));
    LetStmt ("结果", FunctionCall (var "尾递归累加", [int_lit 10; int_lit 0]));
    ExprStmt (var "结果")
  ] in
  let result = execute_test_program program in
  match result with
  | Ok (IntegerValue 55) -> ()  (* 1+2+...+10 = 55 *)
  | _ -> failwith "尾递归集成失败"

(** 10. 完整应用程序集成测试套件 *)
let test_complete_mini_application () =
  (* 测试完整的迷你应用程序集成 *)
  let program = [
    (* 定义数据类型 *)
    TypeDefStmt ("用户", RecordType [("姓名", TypeExpr "string"); ("余额", TypeExpr "int")]);
    ExceptionDefStmt ("余额不足", Some (TypeExpr "string"));
    
    (* 定义操作函数 *)
    LetStmt ("创建用户", FunctionLiteral (["姓名"; "初始余额"],
      RecordLiteral [("姓名", var "姓名"); ("余额", var "初始余额")]
    ));
    
    LetStmt ("提取资金", FunctionLiteral (["用户"; "金额"],
      LetExpr ("当前余额", FieldAccess (var "用户", "余额"),
        IfElse (BinaryOp (var "当前余额", GreaterEqual, var "金额"),
                RecordUpdate (var "用户", [("余额", BinaryOp (var "当前余额", Subtract, var "金额"))]),
                ThrowExpr (FunctionCall (var "余额不足", [str_lit "资金不足"])))
      )
    ));
    
    (* 执行业务逻辑 *)
    LetStmt ("用户1", FunctionCall (var "创建用户", [str_lit "张三"; int_lit 1000]));
    LetStmt ("操作结果", TryWith (
      FunctionCall (var "提取资金", [var "用户1"; int_lit 300]),
      [{ pattern = ConstructorPattern ("余额不足", [VarPattern "信息"]); 
         guard = None; 
         expr = str_lit "操作失败" }]
    ));
    LetStmt ("最终余额", FieldAccess (var "操作结果", "余额"));
    ExprStmt (var "最终余额")
  ] in
  let result = execute_test_program program in
  match result with
  | Ok (IntegerValue 700) -> ()  (* 1000 - 300 = 700 *)
  | _ -> failwith "完整迷你应用程序集成失败"

(** 测试套件汇总 *)
let execution_engine_integration_tests = [
  (* 基础执行引擎集成测试 *)
  ("基础集成_算术程序", `Quick, test_simple_arithmetic_program);
  ("基础集成_字符串处理", `Quick, test_string_processing_program);
  ("基础集成_条件执行", `Quick, test_conditional_execution_program);
  
  (* 函数定义和调用集成测试 *)
  ("函数集成_定义和调用", `Quick, test_function_definition_and_call);
  ("函数集成_递归函数", `Quick, test_recursive_function_integration);
  ("函数集成_高阶函数", `Quick, test_higher_order_function);
  
  (* 模式匹配集成测试 *)
  ("模式匹配集成_简单匹配", `Quick, test_simple_pattern_matching);
  ("模式匹配集成_列表匹配", `Quick, test_list_pattern_matching);
  ("模式匹配集成_Guard条件", `Quick, test_guard_pattern_matching);
  
  (* 类型定义和构造器集成测试 *)
  ("类型集成_代数类型", `Quick, test_algebraic_type_definition);
  
  (* 异常处理集成测试 *)
  ("异常集成_定义和处理", `Quick, test_exception_definition_and_handling);
  
  (* 复杂数据结构集成测试 *)
  ("数据结构集成_列表操作", `Quick, test_list_operations_integration);
  ("数据结构集成_记录操作", `Quick, test_record_operations_integration);
  
  (* 错误处理和恢复集成测试 *)
  ("错误恢复集成_参数适配", `Quick, test_error_recovery_integration);
  ("函数调用集成_嵌套调用", `Quick, test_nested_function_calls);
  
  (* 作用域和环境管理集成测试 *)
  ("作用域集成_变量管理", `Quick, test_variable_scoping_integration);
  ("作用域集成_闭包捕获", `Quick, test_closure_capture_integration);
  
  (* 性能和资源管理集成测试 *)
  ("性能集成_尾递归", `Quick, test_tail_recursion_integration);
  
  (* 完整应用程序集成测试 *)
  ("完整应用_迷你程序", `Quick, test_complete_mini_application);
]

(** 主测试运行函数 *)
let () = run "骆言执行引擎集成测试" [ ("执行引擎集成", execution_engine_integration_tests) ]