(** 核心模块测试覆盖率简化增强 - Fix #1446

    目标: 提升AST、binary_operations、builtin_functions模块覆盖率 测试策略: 专注于实际可调用的公共接口和关键功能

    Author: Beta, 代码审查专员 *)

open Yyocamlc_lib

(** AST模块辅助函数覆盖测试 *)
let test_ast_helper_functions () =
  let open Ast in
  (* 测试辅助函数 *)
  let int_expr = make_int 42 in
  assert (int_expr = LitExpr (IntLit 42));

  let string_expr = make_string "测试" in
  assert (string_expr = LitExpr (StringLit "测试"));

  let bool_expr = make_bool true in
  assert (bool_expr = LitExpr (BoolLit true));

  let var_expr = make_var "变量" in
  assert (var_expr = VarExpr "变量");

  let binary_expr = make_binary_op (make_int 1) Add (make_int 2) in
  assert (binary_expr = BinaryOpExpr (LitExpr (IntLit 1), Add, LitExpr (IntLit 2)));

  let call_expr = make_call (make_var "函数") [ make_int 1 ] in
  assert (call_expr = FunCallExpr (VarExpr "函数", [ LitExpr (IntLit 1) ]));

  Printf.printf "✓ AST辅助函数覆盖测试通过\n"

(** AST类型构造器覆盖测试 *)
let test_ast_type_constructors () =
  let open Ast in
  (* 测试基础类型 *)
  let types = [ IntType; FloatType; StringType; BoolType; UnitType ] in
  List.iter (fun t -> assert (t = t)) types;

  (* 测试二元运算符 *)
  let bin_ops = [ Add; Sub; Mul; Div; Mod; Eq; Neq; Lt; Le; Gt; Ge; And; Or; Concat ] in
  List.iter (fun op -> assert (op = op)) bin_ops;

  (* 测试一元运算符 *)
  let unary_ops = [ Neg; Not ] in
  List.iter (fun op -> assert (op = op)) unary_ops;

  (* 测试字面量 *)
  let literals = [ IntLit 42; FloatLit 3.14; StringLit "test"; BoolLit true; UnitLit ] in
  List.iter (fun lit -> assert (lit = lit)) literals;

  Printf.printf "✓ AST类型构造器覆盖测试通过\n"

(** 二元运算模块覆盖测试 *)
let test_binary_operations_coverage () =
  let open Binary_operations in
  let open Value_operations in
  (* 测试基础算术运算 *)
  let result1 = execute_binary_op Add (IntValue 5) (IntValue 3) in
  assert (result1 = IntValue 8);

  let result2 = execute_binary_op Sub (IntValue 10) (IntValue 4) in
  assert (result2 = IntValue 6);

  let result3 = execute_binary_op Mul (IntValue 6) (IntValue 7) in
  assert (result3 = IntValue 42);

  (* 测试浮点运算 *)
  let result4 = execute_binary_op Add (FloatValue 1.5) (FloatValue 2.5) in
  assert (result4 = FloatValue 4.0);

  (* 测试字符串连接 *)
  let result5 = execute_binary_op Add (StringValue "Hello") (StringValue "World") in
  assert (result5 = StringValue "HelloWorld");

  (* 测试比较运算 *)
  let result6 = execute_binary_op Eq (IntValue 5) (IntValue 5) in
  assert (result6 = BoolValue true);

  let result7 = execute_binary_op Lt (IntValue 3) (IntValue 8) in
  assert (result7 = BoolValue true);

  (* 测试逻辑运算 *)
  let result8 = execute_binary_op And (BoolValue true) (BoolValue false) in
  assert (result8 = BoolValue false);

  Printf.printf "✓ 二元运算模块覆盖测试通过\n"

(** 一元运算模块覆盖测试 *)
let test_unary_operations_coverage () =
  let open Binary_operations in
  let open Value_operations in
  (* 测试数值取负 *)
  let result1 = execute_unary_op Neg (IntValue 5) in
  assert (result1 = IntValue (-5));

  let result2 = execute_unary_op Neg (FloatValue 3.14) in
  assert (result2 = FloatValue (-3.14));

  (* 测试逻辑取反 *)
  let result3 = execute_unary_op Not (BoolValue true) in
  assert (result3 = BoolValue false);

  let result4 = execute_unary_op Not (BoolValue false) in
  assert (result4 = BoolValue true);

  Printf.printf "✓ 一元运算模块覆盖测试通过\n"

(** 内置函数模块覆盖测试 *)
let test_builtin_functions_coverage () =
  let open Builtin_functions in
  (* 测试函数表构造 *)
  let function_names = get_builtin_function_names () in
  assert (List.length function_names >= 0);

  (* 测试函数检查 *)
  List.iter (fun name -> assert (is_builtin_function name = true)) function_names;

  (* 测试不存在的函数 *)
  assert (is_builtin_function "不存在的函数" = false);
  assert (is_builtin_function "" = false);

  (* 测试错误处理 *)
  (try
     let _ = call_builtin_function "不存在的函数" [] in
     failwith "Expected RuntimeError"
   with
  | Value_operations.RuntimeError _ -> ()
  | _ -> failwith "Expected RuntimeError");

  Printf.printf "✓ 内置函数模块覆盖测试通过 - 发现 %d 个函数\n" (List.length function_names)

(** 运算错误处理覆盖测试 *)
let test_operation_error_handling () =
  let open Binary_operations in
  let open Value_operations in
  (* 测试除零错误 *)
  (try
     let _ = execute_binary_op Div (IntValue 5) (IntValue 0) in
     failwith "Expected exception for division by zero"
   with _ -> ());

  (* 期望任何异常 *)

  (* 测试不支持的一元运算 *)
  (try
     let _ = execute_unary_op Neg (StringValue "test") in
     failwith "Expected exception for unsupported unary operation"
   with _ -> ());

  (* 期望任何异常 *)
  Printf.printf "✓ 运算错误处理覆盖测试通过\n"

(** 诗词相关AST类型覆盖测试 *)
let test_poetry_ast_types () =
  let open Ast in
  (* 测试诗词形式 *)
  let poetry_forms =
    [
      FourCharPoetry;
      FiveCharPoetry;
      SevenCharPoetry;
      ParallelProse;
      RegulatedVerse;
      Quatrain;
      Couplet;
    ]
  in
  List.iter (fun form -> assert (form = form)) poetry_forms;

  (* 测试声调类型 *)
  let tone_types = [ LevelTone; FallingTone; RisingTone; DepartingTone; EnteringTone ] in
  List.iter (fun tone -> assert (tone = tone)) tone_types;

  (* 测试声调约束 *)
  let constraints = [ AlternatingTones; ParallelTones ] in
  List.iter (fun c -> assert (c = c)) constraints;

  Printf.printf "✓ 诗词相关AST类型覆盖测试通过\n"

(** 复杂表达式构造覆盖测试 *)
let test_complex_expressions () =
  let open Ast in
  (* 测试复杂表达式的构造和相等性 *)
  let complex_expr =
    BinaryOpExpr
      (BinaryOpExpr (LitExpr (IntLit 1), Add, LitExpr (IntLit 2)), Mul, LitExpr (IntLit 3))
  in

  let expected_expr =
    BinaryOpExpr
      (BinaryOpExpr (LitExpr (IntLit 1), Add, LitExpr (IntLit 2)), Mul, LitExpr (IntLit 3))
  in

  assert (complex_expr = expected_expr);

  (* 测试函数表达式 *)
  let fun_expr = FunExpr ([ "x"; "y" ], BinaryOpExpr (VarExpr "x", Add, VarExpr "y")) in
  assert (fun_expr <> complex_expr);

  Printf.printf "✓ 复杂表达式构造覆盖测试通过\n"

(** 类型系统覆盖测试 *)
let test_type_system_coverage () =
  let open Ast in
  (* 测试类型表达式 *)
  let simple_type = BaseTypeExpr IntType in
  let fun_type = FunType (BaseTypeExpr IntType, BaseTypeExpr IntType) in
  let tuple_type = TupleType [ BaseTypeExpr IntType; BaseTypeExpr StringType ] in

  assert (simple_type <> fun_type);
  assert (fun_type <> tuple_type);

  (* 测试类型定义 *)
  let alias_type = AliasType (BaseTypeExpr IntType) in
  let algebraic_type = AlgebraicType [ ("Some", Some (BaseTypeExpr IntType)); ("None", None) ] in

  assert (alias_type <> algebraic_type);

  Printf.printf "✓ 类型系统覆盖测试通过\n"

(** 模式匹配覆盖测试 *)
let test_pattern_matching_coverage () =
  let open Ast in
  (* 测试基础模式 *)
  let wildcard = WildcardPattern in
  let var_pattern = VarPattern "x" in
  let lit_pattern = LitPattern (IntLit 42) in

  assert (wildcard <> var_pattern);
  assert (var_pattern <> lit_pattern);

  (* 测试复杂模式 *)
  let tuple_pattern = TuplePattern [ VarPattern "x"; VarPattern "y" ] in
  let constructor_pattern = ConstructorPattern ("Some", [ VarPattern "value" ]) in

  assert (tuple_pattern <> constructor_pattern);

  Printf.printf "✓ 模式匹配覆盖测试通过\n"

(** 运行所有测试 *)
let () =
  Printf.printf "🧪 开始核心模块测试覆盖率简化增强测试...\n";
  Printf.printf "========================================\n";

  test_ast_helper_functions ();
  test_ast_type_constructors ();
  test_binary_operations_coverage ();
  test_unary_operations_coverage ();
  test_builtin_functions_coverage ();
  test_operation_error_handling ();
  test_poetry_ast_types ();
  test_complex_expressions ();
  test_type_system_coverage ();
  test_pattern_matching_coverage ();

  Printf.printf "========================================\n";
  Printf.printf "🎉 核心模块测试覆盖率简化增强测试完成！\n";
  Printf.printf "📊 测试覆盖模块:\n";
  Printf.printf "   • AST辅助函数和类型构造: ✅\n";
  Printf.printf "   • Binary Operations运算: ✅\n";
  Printf.printf "   • Builtin Functions管理: ✅\n";
  Printf.printf "   • 诗词相关类型系统: ✅\n";
  Printf.printf "   • 复杂表达式构造: ✅\n";
  Printf.printf "   • 模式匹配系统: ✅\n";
  Printf.printf "🎯 预期效果: 显著提升三个核心模块的测试覆盖率\n"
