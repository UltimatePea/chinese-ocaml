(** 骆言语义分析器单元测试 *)

open Alcotest
open Yyocamlc_lib.Ast
open Yyocamlc_lib.Types
open Yyocamlc_lib.Semantic

(* 测试符号表基础功能 *)
let test_symbol_table_basic () =
  let context = create_initial_context () in
  
  (* 测试空上下文 *)
  check int "初始作用域栈长度" 1 (List.length context.scope_stack);
  check bool "初始函数返回类型" true (context.current_function_return_type = None);
  check int "初始错误列表长度" 0 (List.length context.error_list);
  check int "初始宏定义列表长度" 0 (List.length context.macros);
  
  (* 测试符号表条目创建 *)
  let symbol_entry = {
    symbol_name = "test_var";
    symbol_type = IntType;
    is_mutable = false;
    definition_pos = 1;
  } in
  
  check string "符号名称" "test_var" symbol_entry.symbol_name;
  check bool "符号类型" true (symbol_entry.symbol_type = IntType);
  check bool "符号可变性" false symbol_entry.is_mutable;
  check int "符号定义位置" 1 symbol_entry.definition_pos

(* 测试作用域管理 *)
let test_scope_management () =
  let context = create_initial_context () in
  
  (* 测试进入新作用域 *)
  let context_with_new_scope = enter_new_scope context in
  check int "进入新作用域后栈长度" 2 (List.length context_with_new_scope.scope_stack);
  
  (* 测试离开作用域 *)
  let context_back = exit_scope context_with_new_scope in
  check int "离开作用域后栈长度" 1 (List.length context_back.scope_stack)

(* 测试符号添加和查找 *)
let test_symbol_operations () =
  let context = create_initial_context () in
  
  (* 测试添加符号 *)
  let symbol_entry = {
    symbol_name = "x";
    symbol_type = IntType;
    is_mutable = false;
    definition_pos = 1;
  } in
  
  let context_with_symbol = add_symbol context "x" symbol_entry in
  
  (* 测试查找符号 *)
  match lookup_symbol context_with_symbol "x" with
  | Some found_symbol -> 
      check string "查找到的符号名称" "x" found_symbol.symbol_name;
      check bool "查找到的符号类型" true (found_symbol.symbol_type = IntType)
  | None -> check bool "符号查找失败" false true;
  
  (* 测试查找不存在的符号 *)
  match lookup_symbol context_with_symbol "y" with
  | Some _ -> check bool "不应该找到不存在的符号" false true
  | None -> check bool "正确返回None" true true

(* 测试类型兼容性检查 *)
let test_type_compatibility () =
  (* 测试基础类型兼容性 *)
  check bool "相同类型兼容" true (types_compatible IntType IntType);
  check bool "不同类型不兼容" false (types_compatible IntType FloatType);
  
  (* 测试函数类型兼容性 *)
  let fun_type1 = FunType (IntType, IntType) in
  let fun_type2 = FunType (IntType, IntType) in
  let fun_type3 = FunType (IntType, FloatType) in
  
  check bool "相同函数类型兼容" true (types_compatible fun_type1 fun_type2);
  check bool "不同函数类型不兼容" false (types_compatible fun_type1 fun_type3);
  
  (* 测试列表类型兼容性 *)
  let list_type1 = ListType IntType in
  let list_type2 = ListType IntType in
  let list_type3 = ListType FloatType in
  
  check bool "相同列表类型兼容" true (types_compatible list_type1 list_type2);
  check bool "不同列表类型不兼容" false (types_compatible list_type1 list_type3)

(* 测试表达式类型推断 *)
let test_expression_type_inference () =
  let context = create_initial_context () in
  
  (* 测试基础字面量类型推断 *)
  check bool "整数字面量类型推断" true (infer_expression_type context (IntExpr 42) = IntType);
  check bool "浮点数字面量类型推断" true (infer_expression_type context (FloatExpr 3.14) = FloatType);
  check bool "布尔字面量类型推断" true (infer_expression_type context (BoolExpr true) = BoolType);
  check bool "字符串字面量类型推断" true (infer_expression_type context (StringExpr "test") = StringType);
  check bool "字符字面量类型推断" true (infer_expression_type context (CharExpr 'a') = CharType);
  
  (* 测试二元运算类型推断 *)
  let add_expr = BinOpExpr (Add, IntExpr 1, IntExpr 2) in
  check bool "加法运算类型推断" true (infer_expression_type context add_expr = IntType);
  
  let lt_expr = BinOpExpr (LessThan, IntExpr 1, IntExpr 2) in
  check bool "比较运算类型推断" true (infer_expression_type context lt_expr = BoolType);
  
  (* 测试条件表达式类型推断 *)
  let if_expr = IfExpr (BoolExpr true, IntExpr 1, IntExpr 2) in
  check bool "条件表达式类型推断" true (infer_expression_type context if_expr = IntType)

(* 测试变量类型推断 *)
let test_variable_type_inference () =
  let context = create_initial_context () in
  
  (* 添加变量到符号表 *)
  let symbol_entry = {
    symbol_name = "x";
    symbol_type = IntType;
    is_mutable = false;
    definition_pos = 1;
  } in
  let context_with_var = add_symbol context "x" symbol_entry in
  
  (* 测试变量类型推断 *)
  let var_expr = VarExpr "x" in
  check bool "变量类型推断" true (infer_expression_type context_with_var var_expr = IntType);
  
  (* 测试未定义变量 *)
  let undefined_var = VarExpr "undefined" in
  try
    let _type = infer_expression_type context undefined_var in
    check bool "未定义变量应该报错" false true
  with
  | SemanticError _ -> check bool "未定义变量正确处理" true true
  | _ -> check bool "错误类型不正确" false true

(* 测试函数类型推断 *)
let test_function_type_inference () =
  let context = create_initial_context () in
  
  (* 测试简单函数类型推断 *)
  let fun_expr = FunExpr (["x"], IntExpr 42) in
  let fun_type = infer_expression_type context fun_expr in
  
  (* 函数类型应该是 'a -> int *)
  match fun_type with
  | FunType (_, return_type) -> 
      check bool "函数返回类型推断" true (return_type = IntType)
  | _ -> check bool "函数类型推断错误" false true

(* 测试Let表达式类型推断 *)
let test_let_expression_type_inference () =
  let context = create_initial_context () in
  
  (* 测试Let表达式类型推断 *)
  let let_expr = LetExpr ("x", IntExpr 42, VarExpr "x") in
  check bool "Let表达式类型推断" true (infer_expression_type context let_expr = IntType);
  
  (* 测试复杂Let表达式 *)
  let complex_let = LetExpr ("x", IntExpr 1, 
                           LetExpr ("y", IntExpr 2, 
                                   BinOpExpr (Add, VarExpr "x", VarExpr "y"))) in
  check bool "复杂Let表达式类型推断" true (infer_expression_type context complex_let = IntType)

(* 测试列表类型推断 *)
let test_list_type_inference () =
  let context = create_initial_context () in
  
  (* 测试列表表达式类型推断 *)
  let list_expr = ListExpr [IntExpr 1; IntExpr 2; IntExpr 3] in
  check bool "列表类型推断" true (infer_expression_type context list_expr = ListType IntType);
  
  (* 测试空列表 *)
  let empty_list = ListExpr [] in
  (* 空列表应该有多态类型，这里简化为Any类型 *)
  check bool "空列表类型推断" true (infer_expression_type context empty_list = ListType AnyType)

(* 测试语句语义检查 *)
let test_statement_semantics () =
  let context = create_initial_context () in
  
  (* 测试Let语句 *)
  let let_stmt = LetStmt ("x", IntExpr 42) in
  let context_after_let = check_statement_semantics context let_stmt in
  
  (* 检查变量是否被正确添加到符号表 *)
  match lookup_symbol context_after_let "x" with
  | Some symbol -> 
      check string "Let语句添加的变量名" "x" symbol.symbol_name;
      check bool "Let语句添加的变量类型" true (symbol.symbol_type = IntType)
  | None -> check bool "Let语句变量添加失败" false true;
  
  (* 测试表达式语句 *)
  let expr_stmt = ExprStmt (IntExpr 42) in
  let context_after_expr = check_statement_semantics context expr_stmt in
  check bool "表达式语句处理" true (context_after_expr = context)

(* 测试程序语义检查 *)
let test_program_semantics () =
  let context = create_initial_context () in
  
  (* 测试简单程序 *)
  let program = [
    LetStmt ("x", IntExpr 42);
    LetStmt ("y", IntExpr 24);
    ExprStmt (BinOpExpr (Add, VarExpr "x", VarExpr "y"))
  ] in
  
  let context_after_program = check_program_semantics context program in
  
  (* 检查两个变量都被正确添加 *)
  match lookup_symbol context_after_program "x" with
  | Some _ -> check bool "程序中第一个变量存在" true true
  | None -> check bool "程序中第一个变量不存在" false true;
  
  match lookup_symbol context_after_program "y" with
  | Some _ -> check bool "程序中第二个变量存在" true true
  | None -> check bool "程序中第二个变量不存在" false true

(* 测试错误处理 *)
let test_error_handling () =
  let context = create_initial_context () in
  
  (* 测试未定义变量错误 *)
  try
    let _type = infer_expression_type context (VarExpr "undefined") in
    check bool "未定义变量应该报错" false true
  with
  | SemanticError msg -> 
      check bool "语义错误消息包含变量名" true (String.contains msg "undefined")
  | _ -> check bool "错误类型不正确" false true;
  
  (* 测试类型不匹配错误 *)
  try
    let _type = infer_expression_type context (BinOpExpr (Add, IntExpr 1, StringExpr "test")) in
    check bool "类型不匹配应该报错" false true
  with
  | SemanticError _ -> check bool "类型不匹配正确处理" true true
  | _ -> check bool "错误类型不正确" false true

(* 测试类型定义 *)
let test_type_definitions () =
  let context = create_initial_context () in
  
  (* 测试类型别名定义 *)
  let type_alias = TypeDefStmt ("MyInt", [], AliasType IntType) in
  let context_with_type = check_statement_semantics context type_alias in
  
  (* 检查类型是否被正确添加 *)
  match lookup_type_definition context_with_type "MyInt" with
  | Some typ -> check bool "类型别名定义" true (typ = IntType)
  | None -> check bool "类型别名定义失败" false true

(* 测试套件 *)
let test_suite = [
  ("符号表基础功能测试", `Quick, test_symbol_table_basic);
  ("作用域管理测试", `Quick, test_scope_management);
  ("符号操作测试", `Quick, test_symbol_operations);
  ("类型兼容性测试", `Quick, test_type_compatibility);
  ("表达式类型推断测试", `Quick, test_expression_type_inference);
  ("变量类型推断测试", `Quick, test_variable_type_inference);
  ("函数类型推断测试", `Quick, test_function_type_inference);
  ("Let表达式类型推断测试", `Quick, test_let_expression_type_inference);
  ("列表类型推断测试", `Quick, test_list_type_inference);
  ("语句语义检查测试", `Quick, test_statement_semantics);
  ("程序语义检查测试", `Quick, test_program_semantics);
  ("错误处理测试", `Quick, test_error_handling);
  ("类型定义测试", `Quick, test_type_definitions);
]

let () = run "Semantic单元测试" test_suite