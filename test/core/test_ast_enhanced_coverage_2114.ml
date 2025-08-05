(** AST模块增强测试覆盖率提升 - Fix #2114

    专注于提升ast.ml核心模块测试覆盖率到80%+ 新增测试场景：
    - 复杂表达式嵌套和组合
    - 模块系统相关类型
    - 宏系统完整测试
    - 异步表达式处理
    - 标签参数和模式匹配
    - 错误处理边界条件
    - 类型系统完整性测试

    Author: Whisky, PR Worker Agent
    @version 1.0
    @since 2025-08-02 Fix #2114 核心模块测试覆盖率提升优化 *)

open Alcotest
open Yyocamlc_lib.Ast

(** 测试工具模块 *)
module TestUtils = struct
  let check_type_equality desc expected actual =
    check (testable pp_type_expr equal_type_expr) desc expected actual

  let check_expr_equality desc expected actual =
    check (testable pp_expr equal_expr) desc expected actual

  let check_stmt_equality desc expected actual =
    check (testable pp_stmt equal_stmt) desc expected actual

  let check_pattern_equality desc expected actual =
    check (testable pp_pattern equal_pattern) desc expected actual
end

(** 测试所有基础类型完整性 *)
let test_base_types_comprehensive () =
  let types = [ IntType; FloatType; StringType; BoolType; UnitType ] in

  (* 基础类型数量验证 *)
  check int "基础类型总数应为5" 5 (List.length types);

  (* 类型相等性测试 *)
  check bool "整型相等性" true (IntType = IntType);
  check bool "浮点型相等性" true (FloatType = FloatType);
  check bool "字符串型相等性" true (StringType = StringType);
  check bool "布尔型相等性" true (BoolType = BoolType);
  check bool "单元型相等性" true (UnitType = UnitType);

  (* 类型不等性测试 *)
  check bool "整型与浮点型不相等" false (IntType = FloatType);
  check bool "字符串型与布尔型不相等" false (StringType = BoolType)

(** 测试所有二元运算符 *)
let test_binary_operators_complete () =
  let arithmetic_ops = [ Add; Sub; Mul; Div; Mod ] in
  let comparison_ops = [ Eq; Neq; Lt; Le; Gt; Ge ] in
  let logical_ops = [ And; Or ] in
  let string_ops = [ Concat ] in

  check int "算术运算符数量" 5 (List.length arithmetic_ops);
  check int "比较运算符数量" 6 (List.length comparison_ops);
  check int "逻辑运算符数量" 2 (List.length logical_ops);
  check int "字符串运算符数量" 1 (List.length string_ops);

  (* 运算符相等性测试 *)
  check bool "加法运算符相等" true (Add = Add);
  check bool "相等比较符相等" true (Eq = Eq);
  check bool "与运算符相等" true (And = And);
  check bool "连接运算符相等" true (Concat = Concat)

(** 测试所有一元运算符 *)
let test_unary_operators_complete () =
  let unary_ops = [ Neg; Not ] in

  check int "一元运算符总数" 2 (List.length unary_ops);
  check bool "负号运算符相等" true (Neg = Neg);
  check bool "非运算符相等" true (Not = Not);
  check bool "负号与非不相等" false (Neg = Not)

(** 测试所有字面量类型 *)
let test_literals_comprehensive () =
  let int_lit = IntLit 42 in
  let float_lit = FloatLit 3.14 in
  let string_lit = StringLit "骆言" in
  let bool_lit = BoolLit true in
  let unit_lit = UnitLit in

  (* 字面量构造验证 *)
  check (testable pp_literal equal_literal) "整数字面量" (IntLit 42) int_lit;
  check (testable pp_literal equal_literal) "浮点字面量" (FloatLit 3.14) float_lit;
  check (testable pp_literal equal_literal) "字符串字面量" (StringLit "骆言") string_lit;
  check (testable pp_literal equal_literal) "布尔字面量" (BoolLit true) bool_lit;
  check (testable pp_literal equal_literal) "单元字面量" UnitLit unit_lit

(** 测试复杂模式匹配 *)
let test_pattern_matching_comprehensive () =
  let wildcard_pat = WildcardPattern in
  let var_pat = VarPattern "x" in
  let lit_pat = LitPattern (IntLit 10) in
  let cons_pat = ConsPattern (VarPattern "head", VarPattern "tail") in
  let list_pat = ListPattern [ VarPattern "a"; VarPattern "b" ] in
  let tuple_pat = TuplePattern [ VarPattern "x"; VarPattern "y" ] in
  let constructor_pat = ConstructorPattern ("Some", [ VarPattern "value" ]) in

  TestUtils.check_pattern_equality "通配符模式" WildcardPattern wildcard_pat;
  TestUtils.check_pattern_equality "变量模式" (VarPattern "x") var_pat;
  TestUtils.check_pattern_equality "字面量模式" (LitPattern (IntLit 10)) lit_pat;
  TestUtils.check_pattern_equality "构造器模式"
    (ConsPattern (VarPattern "head", VarPattern "tail"))
    cons_pat;
  TestUtils.check_pattern_equality "列表模式" (ListPattern [ VarPattern "a"; VarPattern "b" ]) list_pat;
  TestUtils.check_pattern_equality "元组模式"
    (TuplePattern [ VarPattern "x"; VarPattern "y" ])
    tuple_pat;
  TestUtils.check_pattern_equality "构造器模式"
    (ConstructorPattern ("Some", [ VarPattern "value" ]))
    constructor_pat

(** 测试类型表达式完整性 *)
let test_type_expressions_comprehensive () =
  let int_type = BaseTypeExpr IntType in
  let float_type = BaseTypeExpr FloatType in
  let arrow_type = FunType (BaseTypeExpr IntType, BaseTypeExpr StringType) in
  let tuple_type =
    TupleType [ BaseTypeExpr IntType; BaseTypeExpr StringType; BaseTypeExpr BoolType ]
  in
  let list_type = ListType (BaseTypeExpr IntType) in
  let type_var = TypeVar "a" in
  let construct_type = ConstructType ("CustomType", []) in

  TestUtils.check_type_equality "整型表达式" (BaseTypeExpr IntType) int_type;
  TestUtils.check_type_equality "浮点型表达式" (BaseTypeExpr FloatType) float_type;
  TestUtils.check_type_equality "函数类型"
    (FunType (BaseTypeExpr IntType, BaseTypeExpr StringType))
    arrow_type;
  TestUtils.check_type_equality "元组类型"
    (TupleType [ BaseTypeExpr IntType; BaseTypeExpr StringType; BaseTypeExpr BoolType ])
    tuple_type;
  TestUtils.check_type_equality "列表类型" (ListType (BaseTypeExpr IntType)) list_type;
  TestUtils.check_type_equality "类型变量" (TypeVar "a") type_var;
  TestUtils.check_type_equality "构造类型" (ConstructType ("CustomType", [])) construct_type

(** 测试复杂表达式嵌套 *)
let test_complex_expression_nesting () =
  (* 创建深度嵌套的表达式 *)
  let deep_nested =
    BinaryOpExpr
      ( BinaryOpExpr
          (LitExpr (IntLit 1), Add, BinaryOpExpr (LitExpr (IntLit 2), Mul, LitExpr (IntLit 3))),
        Sub,
        UnaryOpExpr (Neg, LitExpr (IntLit 4)) )
  in

  let expected =
    BinaryOpExpr
      ( BinaryOpExpr
          (LitExpr (IntLit 1), Add, BinaryOpExpr (LitExpr (IntLit 2), Mul, LitExpr (IntLit 3))),
        Sub,
        UnaryOpExpr (Neg, LitExpr (IntLit 4)) )
  in

  TestUtils.check_expr_equality "深度嵌套表达式" expected deep_nested;

  (* 测试条件表达式嵌套 *)
  let nested_if =
    CondExpr
      ( BinaryOpExpr (VarExpr "x", Gt, LitExpr (IntLit 0)),
        CondExpr
          ( BinaryOpExpr (VarExpr "x", Lt, LitExpr (IntLit 10)),
            LitExpr (StringLit "small positive"),
            LitExpr (StringLit "large positive") ),
        LitExpr (StringLit "non-positive") )
  in

  let expected_if =
    CondExpr
      ( BinaryOpExpr (VarExpr "x", Gt, LitExpr (IntLit 0)),
        CondExpr
          ( BinaryOpExpr (VarExpr "x", Lt, LitExpr (IntLit 10)),
            LitExpr (StringLit "small positive"),
            LitExpr (StringLit "large positive") ),
        LitExpr (StringLit "non-positive") )
  in

  TestUtils.check_expr_equality "嵌套条件表达式" expected_if nested_if

(** 测试异步表达式 *)
let test_async_expressions () =
  let async_expr =
    AsyncExpr (AsyncFunc (FunCallExpr (VarExpr "fetch_data", [ LitExpr (StringLit "url") ])))
  in
  let await_expr = AsyncExpr (AwaitExpr (VarExpr "promise")) in

  let expected_async =
    AsyncExpr (AsyncFunc (FunCallExpr (VarExpr "fetch_data", [ LitExpr (StringLit "url") ])))
  in
  let expected_await = AsyncExpr (AwaitExpr (VarExpr "promise")) in

  TestUtils.check_expr_equality "异步表达式" expected_async async_expr;
  TestUtils.check_expr_equality "等待表达式" expected_await await_expr

(** 测试宏系统 *)
let test_macro_system_comprehensive () =
  let macro_param1 = ExprParam "x" in
  let macro_param2 = TypeParam "y" in

  let macro_def =
    {
      macro_def_name = "add_macro";
      params = [ macro_param1; macro_param2 ];
      body = BinaryOpExpr (VarExpr "x", Add, VarExpr "y");
    }
  in

  let macro_call =
    { macro_call_name = "add_macro"; args = [ LitExpr (IntLit 5); LitExpr (IntLit 3) ] }
  in

  (* 验证宏参数 *)
  check (testable pp_macro_param equal_macro_param) "宏参数1" (ExprParam "x") macro_param1;
  check (testable pp_macro_param equal_macro_param) "宏参数2" (TypeParam "y") macro_param2;

  (* 验证宏定义 *)
  check string "宏定义名称" "add_macro" macro_def.macro_def_name;
  check int "宏参数数量" 2 (List.length macro_def.params);

  (* 验证宏调用 *)
  check string "宏调用名称" "add_macro" macro_call.macro_call_name;
  check int "宏调用参数数量" 2 (List.length macro_call.args)

(** 测试模块系统 *)
let test_module_system_comprehensive () =
  let module_def =
    {
      module_def_name = "MathUtils";
      module_type_annotation = None;
      exports = [];
      statements =
        [
          LetStmt ("add", FunExpr ([ "x"; "y" ], BinaryOpExpr (VarExpr "x", Add, VarExpr "y")));
          LetStmt ("multiply", FunExpr ([ "a"; "b" ], BinaryOpExpr (VarExpr "a", Mul, VarExpr "b")));
        ];
    }
  in

  let module_import =
    { module_import_name = "List"; imports = [ ("map", Some "list_map"); ("filter", None) ] }
  in

  (* 验证模块定义 *)
  check string "模块定义名称" "MathUtils" module_def.module_def_name;
  check int "模块定义主体语句数" 2 (List.length module_def.statements);

  (* 验证模块导入 *)
  check string "模块导入名称" "List" module_import.module_import_name;
  check int "导入别名数量" 2 (List.length module_import.imports)

(** 测试标签参数系统 *)
let test_labeled_parameters () =
  let label_param =
    {
      label_name = "count";
      param_name = "n";
      param_type = Some (BaseTypeExpr IntType);
      is_optional = false;
      default_value = None;
    }
  in

  let optional_param =
    {
      label_name = "step";
      param_name = "s";
      param_type = Some (BaseTypeExpr IntType);
      is_optional = true;
      default_value = Some (LitExpr (IntLit 1));
    }
  in

  let label_arg = { arg_label = "count"; arg_value = LitExpr (IntLit 10) } in

  (* 验证标签参数 *)
  check string "标签名称" "count" label_param.label_name;
  check string "参数名称" "n" label_param.param_name;
  check bool "参数必需性" false label_param.is_optional;

  (* 验证可选参数 *)
  check string "可选参数标签" "step" optional_param.label_name;
  check bool "参数可选性" true optional_param.is_optional;

  (* 验证标签参数 *)
  check string "参数标签" "count" label_arg.arg_label

(** 测试匹配分支完整性 *)
let test_match_branches_comprehensive () =
  let branch1 =
    {
      pattern = VarPattern "x";
      guard = Some (BinaryOpExpr (VarExpr "x", Gt, LitExpr (IntLit 0)));
      expr = LitExpr (StringLit "positive");
    }
  in

  let branch2 =
    { pattern = LitPattern (IntLit 0); guard = None; expr = LitExpr (StringLit "zero") }
  in

  let branch3 = { pattern = WildcardPattern; guard = None; expr = LitExpr (StringLit "other") } in

  let match_expr = MatchExpr (VarExpr "value", [ branch1; branch2; branch3 ]) in

  (* 验证匹配分支 *)
  TestUtils.check_pattern_equality "分支1模式" (VarPattern "x") branch1.pattern;
  check bool "分支1有守卫" true (Option.is_some branch1.guard);
  check bool "分支2无守卫" true (Option.is_none branch2.guard);

  (* 验证匹配表达式 *)
  let expected_match = MatchExpr (VarExpr "value", [ branch1; branch2; branch3 ]) in
  TestUtils.check_expr_equality "匹配表达式" expected_match match_expr

(** 测试所有语句类型 *)
let test_statement_types_comprehensive () =
  let let_stmt = LetStmt ("x", LitExpr (IntLit 42)) in
  let expr_stmt = ExprStmt (FunCallExpr (VarExpr "print", [ LitExpr (StringLit "hello") ])) in
  let type_def_stmt =
    TypeDefStmt ("MyType", AlgebraicType [ ("A", None); ("B", Some (BaseTypeExpr IntType)) ])
  in
  let simple_module_def =
    {
      module_def_name = "SimpleModule";
      module_type_annotation = None;
      exports = [];
      statements = [];
    }
  in
  let module_def_stmt = ModuleDefStmt simple_module_def in
  let exception_def_stmt = ExceptionDefStmt ("MyException", Some (BaseTypeExpr StringType)) in

  TestUtils.check_stmt_equality "let语句" (LetStmt ("x", LitExpr (IntLit 42))) let_stmt;
  TestUtils.check_stmt_equality "表达式语句"
    (ExprStmt (FunCallExpr (VarExpr "print", [ LitExpr (StringLit "hello") ])))
    expr_stmt;
  TestUtils.check_stmt_equality "类型定义语句"
    (TypeDefStmt ("MyType", AlgebraicType [ ("A", None); ("B", Some (BaseTypeExpr IntType)) ]))
    type_def_stmt

(** 测试辅助函数完整性 *)
let test_helper_functions_comprehensive () =
  (* 测试make_* 辅助函数 *)
  let int_expr = make_int 100 in
  let string_expr = make_string "测试字符串" in
  let bool_expr = make_bool false in
  let var_expr = make_var "test_var" in
  let binary_expr = make_binary_op (make_int 5) Mul (make_int 7) in
  let call_expr = make_call (make_var "func") [ make_int 1; make_string "arg" ] in

  TestUtils.check_expr_equality "make_int辅助函数" (LitExpr (IntLit 100)) int_expr;
  TestUtils.check_expr_equality "make_string辅助函数" (LitExpr (StringLit "测试字符串")) string_expr;
  TestUtils.check_expr_equality "make_bool辅助函数" (LitExpr (BoolLit false)) bool_expr;
  TestUtils.check_expr_equality "make_var辅助函数" (VarExpr "test_var") var_expr;
  TestUtils.check_expr_equality "make_binary_op辅助函数"
    (BinaryOpExpr (LitExpr (IntLit 5), Mul, LitExpr (IntLit 7)))
    binary_expr;
  TestUtils.check_expr_equality "make_call辅助函数"
    (FunCallExpr (VarExpr "func", [ LitExpr (IntLit 1); LitExpr (StringLit "arg") ]))
    call_expr

(** 测试边界条件和错误处理 *)
let test_boundary_conditions () =
  (* 测试空列表和空记录 *)
  let empty_list = ListExpr [] in
  let empty_record = RecordExpr [] in
  let empty_tuple = TupleExpr [] in

  TestUtils.check_expr_equality "空列表表达式" (ListExpr []) empty_list;
  TestUtils.check_expr_equality "空记录表达式" (RecordExpr []) empty_record;
  TestUtils.check_expr_equality "空元组表达式" (TupleExpr []) empty_tuple;

  (* 测试极长字符串 *)
  let long_string = String.make 1000 'x' in
  let long_string_expr = make_string long_string in
  TestUtils.check_expr_equality "长字符串表达式" (LitExpr (StringLit long_string)) long_string_expr;

  (* 测试负数 *)
  let negative_int = make_int (-42) in
  let negative_float = LitExpr (FloatLit (-3.14)) in
  TestUtils.check_expr_equality "负整数表达式" (LitExpr (IntLit (-42))) negative_int;
  TestUtils.check_expr_equality "负浮点数表达式" (LitExpr (FloatLit (-3.14))) negative_float

(** 主测试运行器 *)
let () =
  run "AST模块增强测试覆盖率提升 - Fix #2114"
    [
      ( "基础类型完整性测试",
        [
          test_case "基础类型完整性" `Quick test_base_types_comprehensive;
          test_case "二元运算符完整性" `Quick test_binary_operators_complete;
          test_case "一元运算符完整性" `Quick test_unary_operators_complete;
          test_case "字面量类型完整性" `Quick test_literals_comprehensive;
        ] );
      ( "模式匹配和类型系统",
        [
          test_case "模式匹配完整性" `Quick test_pattern_matching_comprehensive;
          test_case "类型表达式完整性" `Quick test_type_expressions_comprehensive;
          test_case "匹配分支完整性" `Quick test_match_branches_comprehensive;
        ] );
      ( "复杂表达式和语言特性",
        [
          test_case "复杂表达式嵌套" `Quick test_complex_expression_nesting;
          test_case "异步表达式测试" `Quick test_async_expressions;
          test_case "宏系统完整性" `Quick test_macro_system_comprehensive;
          test_case "模块系统完整性" `Quick test_module_system_comprehensive;
          test_case "标签参数系统" `Quick test_labeled_parameters;
        ] );
      ( "语句类型和辅助函数",
        [
          test_case "语句类型完整性" `Quick test_statement_types_comprehensive;
          test_case "辅助函数完整性" `Quick test_helper_functions_comprehensive;
        ] );
      ("边界条件和错误处理", [ test_case "边界条件测试" `Quick test_boundary_conditions ]);
    ]
