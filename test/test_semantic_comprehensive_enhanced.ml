(** 骆言语义分析器增强综合测试 - Fix #985 
    提升语义分析模块测试覆盖率从37.5%到65%+的专项测试模块 *)

open Alcotest
open Yyocamlc_lib.Ast
open Yyocamlc_lib.Types
open Yyocamlc_lib.Semantic

(** 测试工具函数 *)
let create_test_context () =
  let context = create_initial_context () in
  add_builtin_functions context

let check_expression_type context expr expected_type =
  let _, type_opt = analyze_expression context expr in
  match type_opt with
  | Some typ -> typ = expected_type
  | None -> false

let check_expression_analysis_succeeds context expr =
  let _, type_opt = analyze_expression context expr in
  Option.is_some type_opt

let check_expression_analysis_fails context expr =
  let new_context, type_opt = analyze_expression context expr in
  type_opt = None || List.length new_context.error_list > 0

(** 基本表达式语义测试 *)
let test_literal_expressions () =
  let context = create_test_context () in
  
  (* 整数字面量 *)
  let int_expr = LitExpr (IntLit 42) in
  check bool "整数字面量类型推导" true (check_expression_type context int_expr IntType_T);
  
  (* 字符串字面量 *)
  let str_expr = LitExpr (StringLit "你好骆言") in
  check bool "字符串字面量类型推导" true (check_expression_type context str_expr StringType_T);
  
  (* 布尔字面量 *)
  let bool_true = LitExpr (BoolLit true) in
  let bool_false = LitExpr (BoolLit false) in
  check bool "布尔真字面量类型推导" true (check_expression_type context bool_true BoolType_T);
  check bool "布尔假字面量类型推导" true (check_expression_type context bool_false BoolType_T);
  
  (* 单位字面量 *)
  let unit_expr = LitExpr UnitLit in
  check bool "单位字面量类型推导" true (check_expression_type context unit_expr UnitType_T);
  
  (* 浮点字面量（如果支持） *)
  let float_expr = LitExpr (FloatLit 3.14) in
  check bool "浮点字面量分析" true (check_expression_analysis_succeeds context float_expr)

let test_variable_expressions () =
  let context = create_test_context () in
  let context_with_scope = enter_scope context in
  
  (* 定义变量 *)
  let context_with_int_var = add_symbol context_with_scope "整数变量" IntType_T false in
  let context_with_str_var = add_symbol context_with_int_var "字符串变量" StringType_T false in
  let context_with_bool_var = add_symbol context_with_str_var "布尔变量" BoolType_T false in
  
  (* 访问已定义变量 *)
  let int_var_expr = VarExpr "整数变量" in
  let str_var_expr = VarExpr "字符串变量" in
  let bool_var_expr = VarExpr "布尔变量" in
  
  check bool "整数变量访问" true (check_expression_type context_with_bool_var int_var_expr IntType_T);
  check bool "字符串变量访问" true (check_expression_type context_with_bool_var str_var_expr StringType_T);
  check bool "布尔变量访问" true (check_expression_type context_with_bool_var bool_var_expr BoolType_T);
  
  (* 未定义变量应该产生错误 *)
  let undefined_var_expr = VarExpr "未定义的变量" in
  check bool "未定义变量检测" true (check_expression_analysis_fails context_with_bool_var undefined_var_expr)

let test_binary_operations () =
  let context = create_test_context () in
  
  (* 算术运算 *)
  let add_expr = BinaryOpExpr (LitExpr (IntLit 1), Add, LitExpr (IntLit 2)) in
  let sub_expr = BinaryOpExpr (LitExpr (IntLit 5), Sub, LitExpr (IntLit 3)) in
  let mul_expr = BinaryOpExpr (LitExpr (IntLit 3), Mul, LitExpr (IntLit 4)) in
  let div_expr = BinaryOpExpr (LitExpr (IntLit 8), Div, LitExpr (IntLit 2)) in
  let mod_expr = BinaryOpExpr (LitExpr (IntLit 7), Mod, LitExpr (IntLit 3)) in
  
  check bool "加法运算类型推导" true (check_expression_type context add_expr IntType_T);
  check bool "减法运算类型推导" true (check_expression_type context sub_expr IntType_T);
  check bool "乘法运算类型推导" true (check_expression_type context mul_expr IntType_T);
  check bool "除法运算类型推导" true (check_expression_type context div_expr IntType_T);
  check bool "取模运算类型推导" true (check_expression_type context mod_expr IntType_T);
  
  (* 比较运算 *)
  let eq_expr = BinaryOpExpr (LitExpr (IntLit 1), Eq, LitExpr (IntLit 1)) in
  let neq_expr = BinaryOpExpr (LitExpr (IntLit 1), Neq, LitExpr (IntLit 2)) in
  let lt_expr = BinaryOpExpr (LitExpr (IntLit 1), Lt, LitExpr (IntLit 2)) in
  let le_expr = BinaryOpExpr (LitExpr (IntLit 1), Le, LitExpr (IntLit 2)) in
  let gt_expr = BinaryOpExpr (LitExpr (IntLit 2), Gt, LitExpr (IntLit 1)) in
  let ge_expr = BinaryOpExpr (LitExpr (IntLit 2), Ge, LitExpr (IntLit 1)) in
  
  check bool "等于运算类型推导" true (check_expression_type context eq_expr BoolType_T);
  check bool "不等于运算类型推导" true (check_expression_type context neq_expr BoolType_T);
  check bool "小于运算类型推导" true (check_expression_type context lt_expr BoolType_T);
  check bool "小于等于运算类型推导" true (check_expression_type context le_expr BoolType_T);
  check bool "大于运算类型推导" true (check_expression_type context gt_expr BoolType_T);
  check bool "大于等于运算类型推导" true (check_expression_type context ge_expr BoolType_T);

  (* 逻辑运算 *)
  let and_expr = BinaryOpExpr (LitExpr (BoolLit true), And, LitExpr (BoolLit false)) in
  let or_expr = BinaryOpExpr (LitExpr (BoolLit true), Or, LitExpr (BoolLit false)) in
  
  check bool "逻辑与运算类型推导" true (check_expression_type context and_expr BoolType_T);
  check bool "逻辑或运算类型推导" true (check_expression_type context or_expr BoolType_T);
  
  (* 字符串连接 *)
  let concat_expr = BinaryOpExpr (LitExpr (StringLit "你好"), Concat, LitExpr (StringLit "世界")) in
  check bool "字符串连接分析" true (check_expression_analysis_succeeds context concat_expr)

let test_unary_operations () =
  let context = create_test_context () in
  
  (* 一元减号 *)
  let neg_expr = UnaryOpExpr (Neg, LitExpr (IntLit 5)) in
  check bool "一元减号类型推导" true (check_expression_type context neg_expr IntType_T);
  
  (* 逻辑非 *)
  let not_expr = UnaryOpExpr (Not, LitExpr (BoolLit true)) in
  check bool "逻辑非类型推导" true (check_expression_type context not_expr BoolType_T)

let test_conditional_expressions () =
  let context = create_test_context () in
  
  (* 简单条件表达式 *)
  let simple_cond = CondExpr (
    LitExpr (BoolLit true),
    LitExpr (IntLit 1),
    LitExpr (IntLit 2)
  ) in
  check bool "简单条件表达式类型推导" true (check_expression_type context simple_cond IntType_T);
  
  (* 复杂条件表达式 *)
  let complex_cond = CondExpr (
    BinaryOpExpr (LitExpr (IntLit 1), Lt, LitExpr (IntLit 2)),
    LitExpr (StringLit "小于"),
    LitExpr (StringLit "大于等于")
  ) in
  check bool "复杂条件表达式类型推导" true (check_expression_type context complex_cond StringType_T);
  
  (* 嵌套条件表达式 *)
  let nested_cond = CondExpr (
    LitExpr (BoolLit true),
    CondExpr (LitExpr (BoolLit false), LitExpr (IntLit 1), LitExpr (IntLit 2)),
    LitExpr (IntLit 3)
  ) in
  check bool "嵌套条件表达式类型推导" true (check_expression_type context nested_cond IntType_T)

let test_function_expressions () =
  let context = create_test_context () in
  
  (* 简单函数表达式 *)
  let identity_fun = FunExpr (["x"], VarExpr "x") in
  check bool "恒等函数创建成功" true (check_expression_analysis_succeeds context identity_fun);
  
  (* 多参数函数 *)
  let add_fun = FunExpr (["x"; "y"], 
    BinaryOpExpr (VarExpr "x", Add, VarExpr "y")) in
  check bool "多参数函数创建成功" true (check_expression_analysis_succeeds context add_fun);
  
  (* 高阶函数 *)
  let apply_fun = FunExpr (["f"; "x"], 
    FunCallExpr (VarExpr "f", [VarExpr "x"])) in
  check bool "高阶函数创建成功" true (check_expression_analysis_succeeds context apply_fun);
  
  (* 带类型标注的函数 *)
  let typed_fun = FunExprWithType (
    [("n", Some (BaseTypeExpr IntType))], 
    Some (BaseTypeExpr IntType),
    BinaryOpExpr (VarExpr "n", Add, LitExpr (IntLit 1))
  ) in
  check bool "带类型标注函数创建成功" true (check_expression_analysis_succeeds context typed_fun)

let test_function_calls () =
  let context = create_test_context () in
  let context_with_scope = enter_scope context in
  
  (* 定义函数 *)
  let context_with_add_fun = add_symbol context_with_scope "加法函数" 
    (FunType_T (IntType_T, FunType_T (IntType_T, IntType_T))) false in
  let context_with_identity = add_symbol context_with_add_fun "恒等函数"
    (FunType_T (IntType_T, IntType_T)) false in
  
  (* 单参数函数调用 *)
  let identity_call = FunCallExpr (VarExpr "恒等函数", [LitExpr (IntLit 42)]) in
  check bool "单参数函数调用分析" true (check_expression_analysis_succeeds context_with_identity identity_call);
  
  (* 多参数函数调用 *)
  let add_call = FunCallExpr (VarExpr "加法函数", [LitExpr (IntLit 1); LitExpr (IntLit 2)]) in
  check bool "多参数函数调用分析" true (check_expression_analysis_succeeds context_with_identity add_call);
  
  (* 部分应用 *)
  let partial_call = FunCallExpr (VarExpr "加法函数", [LitExpr (IntLit 1)]) in
  check bool "部分应用函数调用分析" true (check_expression_analysis_succeeds context_with_identity partial_call)

let test_tuple_expressions () =
  let context = create_test_context () in
  
  (* 二元组 *)
  let pair = TupleExpr [LitExpr (IntLit 1); LitExpr (StringLit "hello")] in
  check bool "二元组表达式分析成功" true (check_expression_analysis_succeeds context pair);
  
  (* 三元组 *)
  let triple = TupleExpr [LitExpr (IntLit 1); LitExpr (StringLit "hello"); LitExpr (BoolLit true)] in
  check bool "三元组表达式分析成功" true (check_expression_analysis_succeeds context triple);
  
  (* 嵌套元组 *)
  let nested_tuple = TupleExpr [
    TupleExpr [LitExpr (IntLit 1); LitExpr (IntLit 2)];
    LitExpr (StringLit "nested")
  ] in
  check bool "嵌套元组表达式分析成功" true (check_expression_analysis_succeeds context nested_tuple);
  
  (* 空元组（单位类型） *)
  let unit_tuple = TupleExpr [] in
  check bool "空元组分析成功" true (check_expression_analysis_succeeds context unit_tuple)

let test_list_expressions () =
  let context = create_test_context () in
  
  (* 整数列表 *)
  let int_list = ListExpr [LitExpr (IntLit 1); LitExpr (IntLit 2); LitExpr (IntLit 3)] in
  check bool "整数列表表达式分析成功" true (check_expression_analysis_succeeds context int_list);
  
  (* 字符串列表 *)
  let str_list = ListExpr [LitExpr (StringLit "你好"); LitExpr (StringLit "世界")] in
  check bool "字符串列表表达式分析成功" true (check_expression_analysis_succeeds context str_list);
  
  (* 空列表 *)
  let empty_list = ListExpr [] in
  check bool "空列表分析成功" true (check_expression_analysis_succeeds context empty_list);
  
  (* 嵌套列表 *)
  let nested_list = ListExpr [
    ListExpr [LitExpr (IntLit 1); LitExpr (IntLit 2)];
    ListExpr [LitExpr (IntLit 3); LitExpr (IntLit 4)]
  ] in
  check bool "嵌套列表表达式分析成功" true (check_expression_analysis_succeeds context nested_list)

let test_reference_expressions () =
  let context = create_test_context () in
  
  (* 引用创建 *)
  let int_ref = RefExpr (LitExpr (IntLit 42)) in
  let str_ref = RefExpr (LitExpr (StringLit "引用测试")) in
  let bool_ref = RefExpr (LitExpr (BoolLit true)) in
  
  check bool "整数引用表达式分析成功" true (check_expression_analysis_succeeds context int_ref);
  check bool "字符串引用表达式分析成功" true (check_expression_analysis_succeeds context str_ref);
  check bool "布尔引用表达式分析成功" true (check_expression_analysis_succeeds context bool_ref);
  
  (* 引用解除 *)
  let context_with_scope = enter_scope context in
  let context_with_ref = add_symbol context_with_scope "int_ref_var" 
    (RefType_T IntType_T) false in
  let deref_expr = DerefExpr (VarExpr "int_ref_var") in
  check bool "解引用表达式分析成功" true (check_expression_analysis_succeeds context_with_ref deref_expr)

let test_array_expressions () =
  let context = create_test_context () in
  
  (* 数组创建 *)
  let int_array = ArrayExpr [LitExpr (IntLit 1); LitExpr (IntLit 2); LitExpr (IntLit 3)] in
  let str_array = ArrayExpr [LitExpr (StringLit "数组"); LitExpr (StringLit "测试")] in
  
  check bool "整数数组表达式分析成功" true (check_expression_analysis_succeeds context int_array);
  check bool "字符串数组表达式分析成功" true (check_expression_analysis_succeeds context str_array);
  
  (* 数组访问 *)
  let context_with_scope = enter_scope context in
  let context_with_array = add_symbol context_with_scope "test_array" 
    (ArrayType_T IntType_T) false in
  let access_expr = ArrayAccessExpr (VarExpr "test_array", LitExpr (IntLit 0)) in
  let access_expr2 = ArrayAccessExpr (VarExpr "test_array", LitExpr (IntLit 2)) in
  
  check bool "数组访问表达式分析成功" true (check_expression_analysis_succeeds context_with_array access_expr);
  check bool "数组访问表达式2分析成功" true (check_expression_analysis_succeeds context_with_array access_expr2)

let test_pattern_matching () =
  let context = create_test_context () in
  
  (* 简单字面量模式匹配 *)
  let simple_match = MatchExpr (
    LitExpr (IntLit 1),
    [
      { pattern = LitPattern (IntLit 1); expr = LitExpr (StringLit "一"); guard = None };
      { pattern = LitPattern (IntLit 2); expr = LitExpr (StringLit "二"); guard = None };
      { pattern = WildcardPattern; expr = LitExpr (StringLit "其他"); guard = None }
    ]
  ) in
  check bool "简单模式匹配表达式分析成功" true (check_expression_analysis_succeeds context simple_match);
  
  (* 变量模式匹配 *)
  let var_match = MatchExpr (
    LitExpr (IntLit 42),
    [
      { pattern = VarPattern "n"; expr = BinaryOpExpr (VarExpr "n", Add, LitExpr (IntLit 1)); guard = None };
    ]
  ) in
  check bool "变量模式匹配表达式分析成功" true (check_expression_analysis_succeeds context var_match);
  
  (* 元组模式匹配 *)
  let tuple_match = MatchExpr (
    TupleExpr [LitExpr (IntLit 1); LitExpr (StringLit "hello")],
    [
      { pattern = TuplePattern [VarPattern "x"; VarPattern "y"]; 
        expr = TupleExpr [VarExpr "y"; VarExpr "x"]; guard = None };
    ]
  ) in
  check bool "元组模式匹配表达式分析成功" true (check_expression_analysis_succeeds context tuple_match)

let test_try_catch_expressions () =
  let context = create_test_context () in
  
  (* 基本try-catch表达式 *)
  let basic_try = TryExpr (
    LitExpr (IntLit 42),
    [
      { pattern = WildcardPattern; expr = LitExpr (IntLit 0); guard = None }
    ],
    None
  ) in
  check bool "基本Try-catch表达式分析成功" true (check_expression_analysis_succeeds context basic_try);
  
  (* 带finally的try-catch表达式 *)
  let try_with_finally = TryExpr (
    BinaryOpExpr (LitExpr (IntLit 10), Div, LitExpr (IntLit 0)),
    [
      { pattern = VarPattern "e"; expr = LitExpr (IntLit (-1)); guard = None }
    ],
    Some (LitExpr UnitLit)
  ) in
  check bool "带finally的Try-catch表达式分析成功" true (check_expression_analysis_succeeds context try_with_finally);
  
  (* 多个catch分支 *)
  let multi_catch = TryExpr (
    LitExpr (IntLit 100),
    [
      { pattern = VarPattern "e1"; expr = LitExpr (IntLit 1); guard = None };
      { pattern = VarPattern "e2"; expr = LitExpr (IntLit 2); guard = None };
      { pattern = WildcardPattern; expr = LitExpr (IntLit 0); guard = None }
    ],
    Some (LitExpr (StringLit "cleanup"))
  ) in
  check bool "多catch分支Try表达式分析成功" true (check_expression_analysis_succeeds context multi_catch)

let test_or_else_expressions () =
  let context = create_test_context () in
  
  (* 基本OrElse表达式 *)
  let basic_or_else = OrElseExpr (
    LitExpr (IntLit 1),
    LitExpr (IntLit 2)
  ) in
  check bool "基本OrElse表达式分析成功" true (check_expression_analysis_succeeds context basic_or_else);
  
  (* 复杂OrElse表达式 *)
  let complex_or_else = OrElseExpr (
    BinaryOpExpr (LitExpr (IntLit 5), Div, LitExpr (IntLit 0)),
    LitExpr (IntLit 0)
  ) in
  check bool "复杂OrElse表达式分析成功" true (check_expression_analysis_succeeds context complex_or_else);
  
  (* 嵌套OrElse表达式 *)
  let nested_or_else = OrElseExpr (
    OrElseExpr (LitExpr (IntLit 1), LitExpr (IntLit 2)),
    LitExpr (IntLit 3)
  ) in
  check bool "嵌套OrElse表达式分析成功" true (check_expression_analysis_succeeds context nested_or_else)

(** 语句分析测试 *)
let test_let_statements () =
  let context = create_test_context () in
  
  (* 简单let语句 *)
  let simple_let = LetStmt ("x", LitExpr (IntLit 42)) in
  let new_context, _ = analyze_statement context simple_let in
  let symbol_opt = lookup_symbol new_context.scope_stack "x" in
  check bool "简单Let语句符号添加成功" true (Option.is_some symbol_opt);
  
  (* 复杂let语句 *)
  let complex_let = LetStmt ("result", 
    BinaryOpExpr (LitExpr (IntLit 10), Mul, LitExpr (IntLit 5))) in
  let new_context2, _ = analyze_statement context complex_let in
  let symbol_opt2 = lookup_symbol new_context2.scope_stack "result" in
  check bool "复杂Let语句符号添加成功" true (Option.is_some symbol_opt2);
  
  (* 函数定义let语句 *)
  let fun_let = LetStmt ("square", 
    FunExpr (["n"], BinaryOpExpr (VarExpr "n", Mul, VarExpr "n"))) in
  let new_context3, _ = analyze_statement context fun_let in
  let symbol_opt3 = lookup_symbol new_context3.scope_stack "square" in
  check bool "函数定义Let语句符号添加成功" true (Option.is_some symbol_opt3)

let test_recursive_let_statements () =
  let context = create_test_context () in
  
  (* 递归阶乘函数 *)
  let factorial_stmt = RecLetStmt ("factorial", 
    FunExpr (["n"], 
      CondExpr (
        BinaryOpExpr (VarExpr "n", Le, LitExpr (IntLit 1)),
        LitExpr (IntLit 1),
        BinaryOpExpr (VarExpr "n", Mul, 
          FunCallExpr (VarExpr "factorial", 
            [BinaryOpExpr (VarExpr "n", Sub, LitExpr (IntLit 1))]))
      )
    )
  ) in
  let new_context, _ = analyze_statement context factorial_stmt in
  let symbol_opt = lookup_symbol new_context.scope_stack "factorial" in
  check bool "递归阶乘函数符号添加成功" true (Option.is_some symbol_opt);
  
  (* 递归斐波那契函数 *)
  let fib_stmt = RecLetStmt ("fibonacci",
    FunExpr (["n"],
      CondExpr (
        BinaryOpExpr (VarExpr "n", Le, LitExpr (IntLit 1)),
        VarExpr "n",
        BinaryOpExpr (
          FunCallExpr (VarExpr "fibonacci", [BinaryOpExpr (VarExpr "n", Sub, LitExpr (IntLit 1))]),
          Add,
          FunCallExpr (VarExpr "fibonacci", [BinaryOpExpr (VarExpr "n", Sub, LitExpr (IntLit 2))])
        )
      )
    )
  ) in
  let new_context2, _ = analyze_statement context fib_stmt in
  let symbol_opt2 = lookup_symbol new_context2.scope_stack "fibonacci" in
  check bool "递归斐波那契函数符号添加成功" true (Option.is_some symbol_opt2)

let test_expression_statements () =
  let context = create_test_context () in
  
  (* 简单表达式语句 *)
  let simple_expr_stmt = ExprStmt (LitExpr (IntLit 42)) in
  let _, result = analyze_statement context simple_expr_stmt in
  check bool "简单表达式语句分析成功" true (result <> None);
  
  (* 复杂表达式语句 *)
  let complex_expr_stmt = ExprStmt (
    BinaryOpExpr (LitExpr (IntLit 3), Mul, LitExpr (IntLit 14))
  ) in
  let _, result2 = analyze_statement context complex_expr_stmt in
  check bool "复杂表达式语句分析成功" true (result2 <> None);
  
  (* 函数调用表达式语句 *)
  let context_with_scope = enter_scope context in
  let context_with_fun = add_symbol context_with_scope "test_fun" 
    (FunType_T (IntType_T, IntType_T)) false in
  let call_expr_stmt = ExprStmt (
    FunCallExpr (VarExpr "test_fun", [LitExpr (IntLit 5)])
  ) in
  let _, result3 = analyze_statement context_with_fun call_expr_stmt in
  check bool "函数调用表达式语句分析成功" true (result3 <> None)

let test_type_definitions () =
  let context = create_test_context () in
  
  (* 简单类型别名 *)
  let int_alias = TypeDefStmt ("MyInt", AliasType (BaseTypeExpr IntType)) in
  let new_context, _ = analyze_statement context int_alias in
  let type_opt = lookup_type_definition new_context "MyInt" in
  check bool "整数类型别名定义成功" true (Option.is_some type_opt);
  
  (* 字符串类型别名 *)
  let str_alias = TypeDefStmt ("MyString", AliasType (BaseTypeExpr StringType)) in
  let new_context2, _ = analyze_statement context str_alias in
  let type_opt2 = lookup_type_definition new_context2 "MyString" in
  check bool "字符串类型别名定义成功" true (Option.is_some type_opt2);
  
  (* 函数类型别名 *)
  let fun_alias = TypeDefStmt ("IntToInt", 
    AliasType (FunType (BaseTypeExpr IntType, BaseTypeExpr IntType))) in
  let new_context3, _ = analyze_statement context fun_alias in
  let type_opt3 = lookup_type_definition new_context3 "IntToInt" in
  check bool "函数类型别名定义成功" true (Option.is_some type_opt3)

(** 错误处理测试 *)
let test_semantic_error_detection () =
  let context = create_test_context () in
  
  (* 未定义变量错误 *)
  let undefined_var = VarExpr "不存在的变量" in
  let new_context, _ = analyze_expression context undefined_var in
  check bool "未定义变量错误检测" true (List.length new_context.error_list > 0);
  
  (* 未定义函数错误 *)
  let undefined_fun_call = FunCallExpr (VarExpr "不存在的函数", [LitExpr (IntLit 1)]) in
  let new_context2, _ = analyze_expression context undefined_fun_call in
  check bool "未定义函数错误检测" true (List.length new_context2.error_list > 0)

let test_type_error_detection () =
  let context = create_test_context () in
  
  (* 构造一个可能的类型错误场景 *)
  let context_with_scope = enter_scope context in
  let context_with_int = add_symbol context_with_scope "int_var" IntType_T false in
  let context_with_str = add_symbol context_with_int "str_var" StringType_T false in
  
  (* 尝试将字符串变量用于算术运算 *)
  let type_error_expr = BinaryOpExpr (VarExpr "str_var", Add, LitExpr (IntLit 1)) in
  let new_context, type_opt = analyze_expression context_with_str type_error_expr in
  
  (* 应该检测到类型错误 *)
  check bool "类型错误检测" true (type_opt = None || List.length new_context.error_list > 0)

(** 作用域管理测试 *)
let test_scope_isolation () =
  let context = create_test_context () in
  
  (* 进入作用域并添加局部变量 *)
  let context1 = enter_scope context in
  let context2 = add_symbol context1 "local_var" IntType_T false in
  
  (* 在内层作用域中变量可见 *)
  let inner_lookup = lookup_symbol context2.scope_stack "local_var" in
  check bool "内层作用域变量可见" true (Option.is_some inner_lookup);
  
  (* 退出作用域 *)
  let context3 = exit_scope context2 in
  
  (* 在外层作用域中局部变量不可见 *)
  let outer_lookup = lookup_symbol context3.scope_stack "local_var" in
  check bool "作用域隔离测试" true (outer_lookup = None)

let test_nested_scopes () =
  let context = create_test_context () in
  
  (* 第一层作用域 *)
  let context1 = enter_scope context in
  let context2 = add_symbol context1 "outer_var" IntType_T false in
  
  (* 第二层作用域 *)
  let context3 = enter_scope context2 in
  let context4 = add_symbol context3 "middle_var" StringType_T false in
  
  (* 第三层作用域 *)
  let context5 = enter_scope context4 in
  let context6 = add_symbol context5 "inner_var" BoolType_T false in
  
  (* 在最内层作用域中，所有变量都应该可见 *)
  let outer_lookup = lookup_symbol context6.scope_stack "outer_var" in
  let middle_lookup = lookup_symbol context6.scope_stack "middle_var" in
  let inner_lookup = lookup_symbol context6.scope_stack "inner_var" in
  
  check bool "嵌套作用域外层变量访问" true (Option.is_some outer_lookup);
  check bool "嵌套作用域中层变量访问" true (Option.is_some middle_lookup);
  check bool "嵌套作用域内层变量访问" true (Option.is_some inner_lookup);
  
  (* 逐层退出作用域并检查变量可见性 *)
  let context7 = exit_scope context6 in
  let inner_lookup_after_exit = lookup_symbol context7.scope_stack "inner_var" in
  check bool "退出内层作用域后内层变量不可见" true (inner_lookup_after_exit = None);
  
  let context8 = exit_scope context7 in
  let middle_lookup_after_exit = lookup_symbol context8.scope_stack "middle_var" in
  check bool "退出中层作用域后中层变量不可见" true (middle_lookup_after_exit = None)

let test_variable_shadowing () =
  let context = create_test_context () in
  
  (* 外层作用域定义变量 *)
  let context1 = enter_scope context in
  let context2 = add_symbol context1 "var" IntType_T false in
  
  (* 内层作用域遮蔽同名变量 *)
  let context3 = enter_scope context2 in
  let context4 = add_symbol context3 "var" StringType_T false in
  
  (* 在内层作用域中应该看到字符串类型的变量 *)
  let inner_lookup = lookup_symbol context4.scope_stack "var" in
  check bool "变量遮蔽测试" true (
    match inner_lookup with
    | Some symbol -> symbol.symbol_type = StringType_T
    | None -> false
  );
  
  (* 退出内层作用域后应该看到整数类型的变量 *)
  let context5 = exit_scope context4 in
  let outer_lookup = lookup_symbol context5.scope_stack "var" in
  check bool "退出遮蔽作用域后原变量恢复" true (
    match outer_lookup with
    | Some symbol -> symbol.symbol_type = IntType_T
    | None -> false
  )

(** 程序级别测试 *)
let test_simple_program_analysis () =
  let program = [
    LetStmt ("x", LitExpr (IntLit 10));
    LetStmt ("y", LitExpr (IntLit 20));
    ExprStmt (BinaryOpExpr (VarExpr "x", Add, VarExpr "y"))
  ] in
  let result = analyze_program program in
  check bool "简单程序分析成功" true (match result with Ok _ -> true | Error _ -> false)

let test_complex_program_analysis () =
  let program = [
    (* 定义常量 *)
    LetStmt ("PI", LitExpr (FloatLit 3.14159));
    
    (* 定义简单函数 *)
    LetStmt ("double", FunExpr (["x"], BinaryOpExpr (VarExpr "x", Mul, LitExpr (IntLit 2))));
    
    (* 定义递归函数 *)
    RecLetStmt ("power", 
      FunExpr (["base"; "exp"], 
        CondExpr (
          BinaryOpExpr (VarExpr "exp", Eq, LitExpr (IntLit 0)),
          LitExpr (IntLit 1),
          BinaryOpExpr (VarExpr "base", Mul, 
            FunCallExpr (VarExpr "power", 
              [VarExpr "base"; BinaryOpExpr (VarExpr "exp", Sub, LitExpr (IntLit 1))]))
        )
      )
    );
    
    (* 使用定义的函数 *)
    ExprStmt (FunCallExpr (VarExpr "double", [LitExpr (IntLit 21)]));
    ExprStmt (FunCallExpr (VarExpr "power", [LitExpr (IntLit 2); LitExpr (IntLit 8)]));
    
    (* 复杂表达式 *)
    ExprStmt (CondExpr (
      BinaryOpExpr (LitExpr (IntLit 5), Gt, LitExpr (IntLit 3)),
      LitExpr (StringLit "大于"),
      LitExpr (StringLit "小于等于")
    ))
  ] in
  let result = analyze_program program in
  check bool "复杂程序分析成功" true (match result with Ok _ -> true | Error _ -> false)

let test_program_with_errors () =
  let program = [
    LetStmt ("x", LitExpr (IntLit 10));
    LetStmt ("y", VarExpr "undefined_var");  (* 使用未定义变量 *)
    ExprStmt (BinaryOpExpr (VarExpr "x", Add, VarExpr "y"))
  ] in
  let result = analyze_program program in
  check bool "错误程序检测成功" true (match result with Ok _ -> false | Error _ -> true)

let test_program_with_type_definitions () =
  let program = [
    (* 定义类型别名 *)
    TypeDefStmt ("Point", AliasType (TupleType [BaseTypeExpr IntType; BaseTypeExpr IntType]));
    
    (* 使用类型别名 *)
    LetStmt ("origin", TupleExpr [LitExpr (IntLit 0); LitExpr (IntLit 0)]);
    LetStmt ("point1", TupleExpr [LitExpr (IntLit 3); LitExpr (IntLit 4)]);
    
    (* 定义操作点的函数 *)
    LetStmt ("distance_from_origin", 
      FunExpr (["p"], 
        MatchExpr (VarExpr "p", [
          { pattern = TuplePattern [VarPattern "x"; VarPattern "y"];
            expr = BinaryOpExpr (
              BinaryOpExpr (VarExpr "x", Mul, VarExpr "x"),
              Add,
              BinaryOpExpr (VarExpr "y", Mul, VarExpr "y")
            );
            guard = None }
        ])
      )
    );
    
    (* 使用函数 *)
    ExprStmt (FunCallExpr (VarExpr "distance_from_origin", [VarExpr "point1"]))
  ] in
  let result = analyze_program program in
  check bool "带类型定义程序分析成功" true (match result with Ok _ -> true | Error _ -> false)

(** 运行所有测试 *)
let () =
  run "语义分析器增强综合测试 - Fix #985"
    [
      ("基本表达式语义测试", [
        test_case "字面量表达式类型推导" `Quick test_literal_expressions;
        test_case "变量表达式语义检查" `Quick test_variable_expressions;
        test_case "二元运算语义分析" `Quick test_binary_operations;
        test_case "一元运算语义分析" `Quick test_unary_operations;
        test_case "条件表达式语义分析" `Quick test_conditional_expressions;
      ]);
      
      ("函数表达式语义测试", [
        test_case "函数表达式创建与分析" `Quick test_function_expressions;
        test_case "函数调用语义检查" `Quick test_function_calls;
      ]);
      
      ("数据结构表达式语义测试", [
        test_case "元组表达式语义分析" `Quick test_tuple_expressions;
        test_case "列表表达式语义分析" `Quick test_list_expressions;
        test_case "引用表达式语义分析" `Quick test_reference_expressions;
        test_case "数组表达式语义分析" `Quick test_array_expressions;
      ]);
      
      ("高级表达式语义测试", [
        test_case "模式匹配语义分析" `Quick test_pattern_matching;
        test_case "Try-Catch表达式语义分析" `Quick test_try_catch_expressions;
        test_case "OrElse表达式语义分析" `Quick test_or_else_expressions;
      ]);
      
      ("语句语义分析测试", [
        test_case "Let语句语义分析" `Quick test_let_statements;
        test_case "递归Let语句语义分析" `Quick test_recursive_let_statements;
        test_case "表达式语句语义分析" `Quick test_expression_statements;
        test_case "类型定义语句语义分析" `Quick test_type_definitions;
      ]);
      
      ("错误处理语义测试", [
        test_case "语义错误检测与报告" `Quick test_semantic_error_detection;
        test_case "类型错误检测与报告" `Quick test_type_error_detection;
      ]);
      
      ("作用域管理语义测试", [
        test_case "作用域隔离测试" `Quick test_scope_isolation;
        test_case "嵌套作用域测试" `Quick test_nested_scopes;
        test_case "变量遮蔽测试" `Quick test_variable_shadowing;
      ]);
      
      ("程序级别语义测试", [
        test_case "简单程序语义分析" `Quick test_simple_program_analysis;
        test_case "复杂程序语义分析" `Quick test_complex_program_analysis;
        test_case "错误程序语义检测" `Quick test_program_with_errors;
        test_case "带类型定义程序语义分析" `Quick test_program_with_type_definitions;
      ]);
    ]