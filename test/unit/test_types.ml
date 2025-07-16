(** 骆言类型系统模块单元测试 *)

open Alcotest
open Yyocamlc_lib.Types
module Ast = Yyocamlc_lib.Ast

(* 测试辅助函数 *)

(* 基础类型测试 *)
let test_basic_types () =
  let int_type = IntType_T in
  let float_type = FloatType_T in
  let string_type = StringType_T in
  let bool_type = BoolType_T in
  let unit_type = UnitType_T in

  check bool "整数类型创建" true (equal_typ int_type IntType_T);
  check bool "浮点数类型创建" true (equal_typ float_type FloatType_T);
  check bool "字符串类型创建" true (equal_typ string_type StringType_T);
  check bool "布尔类型创建" true (equal_typ bool_type BoolType_T);
  check bool "单位类型创建" true (equal_typ unit_type UnitType_T)

(* 复合类型测试 *)
let test_compound_types () =
  let fun_type = FunType_T (IntType_T, StringType_T) in
  let tuple_type = TupleType_T [ IntType_T; StringType_T; BoolType_T ] in
  let list_type = ListType_T IntType_T in
  let array_type = ArrayType_T StringType_T in

  check bool "函数类型创建" true (equal_typ fun_type (FunType_T (IntType_T, StringType_T)));
  check bool "元组类型创建" true
    (equal_typ tuple_type (TupleType_T [ IntType_T; StringType_T; BoolType_T ]));
  check bool "列表类型创建" true (equal_typ list_type (ListType_T IntType_T));
  check bool "数组类型创建" true (equal_typ array_type (ArrayType_T StringType_T))

(* 类型变量测试 *)
let test_type_variables () =
  let var1 = new_type_var () in
  let var2 = new_type_var () in

  check bool "类型变量生成" true (match var1 with TypeVar_T _ -> true | _ -> false);
  check bool "类型变量唯一性" false (equal_typ var1 var2)

(* 类型替换测试 *)
let test_type_substitution () =
  let var_x = TypeVar_T "x" in
  let var_y = TypeVar_T "y" in
  let subst = single_subst "x" IntType_T in

  let result1 = apply_subst subst var_x in
  let result2 = apply_subst subst var_y in

  check bool "类型替换应用" true (equal_typ result1 IntType_T);
  check bool "类型替换不影响其他变量" true (equal_typ result2 var_y)

(* 类型合一测试 *)
let test_type_unification () =
  let var_x = TypeVar_T "x" in
  let int_type = IntType_T in

  let subst = unify var_x int_type in
  let result = apply_subst subst var_x in

  check bool "类型合一结果" true (equal_typ result int_type)

(* 类型泛化测试 *)
let test_type_generalization () =
  let env = TypeEnv.empty in
  let var_x = TypeVar_T "x" in
  let scheme = generalize env var_x in

  match scheme with TypeScheme (vars, _) -> check bool "类型泛化包含变量" true (List.mem "x" vars)

(* 类型实例化测试 *)
let test_type_instantiation () =
  let scheme = TypeScheme ([ "x" ], TypeVar_T "x") in
  let instance = instantiate scheme in

  check bool "类型实例化生成新变量" true (match instance with TypeVar_T _ -> true | _ -> false)

(* 从基础类型转换测试 *)
let test_from_base_type () =
  let int_base = Ast.IntType in
  let float_base = Ast.FloatType in
  let string_base = Ast.StringType in
  let bool_base = Ast.BoolType in
  let unit_base = Ast.UnitType in

  check bool "整数基础类型转换" true (equal_typ (from_base_type int_base) IntType_T);
  check bool "浮点数基础类型转换" true (equal_typ (from_base_type float_base) FloatType_T);
  check bool "字符串基础类型转换" true (equal_typ (from_base_type string_base) StringType_T);
  check bool "布尔基础类型转换" true (equal_typ (from_base_type bool_base) BoolType_T);
  check bool "单位基础类型转换" true (equal_typ (from_base_type unit_base) UnitType_T)

(* 字面量类型推断测试 *)
let test_literal_type () =
  let int_literal = Ast.IntLit 42 in
  let float_literal = Ast.FloatLit 3.14 in
  let string_literal = Ast.StringLit "测试" in
  let bool_literal = Ast.BoolLit true in

  check bool "整数字面量类型" true (equal_typ (literal_type int_literal) IntType_T);
  check bool "浮点数字面量类型" true (equal_typ (literal_type float_literal) FloatType_T);
  check bool "字符串字面量类型" true (equal_typ (literal_type string_literal) StringType_T);
  check bool "布尔字面量类型" true (equal_typ (literal_type bool_literal) BoolType_T)

(* 二元运算符类型测试 *)
let test_binary_op_type () =
  let left_type, right_type, result_type = binary_op_type Ast.Add in

  check bool "加法运算左操作数类型" true (equal_typ left_type IntType_T);
  check bool "加法运算右操作数类型" true (equal_typ right_type IntType_T);
  check bool "加法运算结果类型" true (equal_typ result_type IntType_T)

(* 一元运算符类型测试 *)
let test_unary_op_type () =
  let operand_type, result_type = unary_op_type Ast.Neg in

  check bool "负号运算操作数类型" true (equal_typ operand_type IntType_T);
  check bool "负号运算结果类型" true (equal_typ result_type IntType_T)

(* 自由变量测试 *)
let test_free_vars () =
  let typ = FunType_T (TypeVar_T "x", TypeVar_T "y") in
  let vars = free_vars typ in

  check bool "自由变量包含x" true (List.mem "x" vars);
  check bool "自由变量包含y" true (List.mem "y" vars);
  check int "自由变量数量" 2 (List.length vars)

(* 内置函数环境测试 *)
let test_builtin_env () =
  let env = builtin_env in

  check bool "内置环境包含打印函数" true (TypeEnv.mem "打印" env);
  check bool "内置环境包含读取函数" true (TypeEnv.mem "读取" env);
  check bool "内置环境包含长度函数" true (TypeEnv.mem "长度" env)

(* 类型推断测试 *)
let test_type_inference () =
  let env = builtin_env in
  let int_expr = Ast.LitExpr (Ast.IntLit 42) in
  let subst, typ = infer_type env int_expr in

  check bool "整数字面量类型推断" true (equal_typ typ IntType_T);
  check bool "推断不产生替换" true (SubstMap.is_empty subst)

(* 类型转换为中文显示测试 *)
let test_type_to_chinese_string () =
  let int_type = IntType_T in
  let string_type = StringType_T in
  let fun_type = FunType_T (IntType_T, StringType_T) in

  check string "整数类型中文显示" "整数" (type_to_chinese_string int_type);
  check string "字符串类型中文显示" "字符串" (type_to_chinese_string string_type);
  check string "函数类型中文显示" "整数 -> 字符串" (type_to_chinese_string fun_type)

(* 性能统计测试 *)
let test_performance_stats () =
  PerformanceStats.reset_stats ();
  let calls, _unify_calls, _subst_apps, hits, misses = PerformanceStats.get_stats () in

  check int "初始调用次数" 0 calls;
  check int "初始命中次数" 0 hits;
  check int "初始未命中次数" 0 misses;

  PerformanceStats.enable_cache ();
  check bool "缓存启用状态" true (PerformanceStats.is_cache_enabled ());

  PerformanceStats.disable_cache ();
  check bool "缓存禁用状态" false (PerformanceStats.is_cache_enabled ())

(* 记忆化缓存测试 *)
let test_memoization_cache () =
  MemoizationCache.reset_cache ();
  let hits, misses = MemoizationCache.get_cache_stats () in

  check int "初始缓存命中次数" 0 hits;
  check int "初始缓存未命中次数" 0 misses

(* 测试套件 *)
let tests =
  [
    ( "基础类型系统测试",
      [
        test_case "基础类型创建" `Quick test_basic_types;
        test_case "复合类型创建" `Quick test_compound_types;
        test_case "类型变量生成" `Quick test_type_variables;
      ] );
    ( "类型操作测试",
      [
        test_case "类型替换应用" `Quick test_type_substitution;
        test_case "类型合一算法" `Quick test_type_unification;
        test_case "类型泛化处理" `Quick test_type_generalization;
        test_case "类型实例化处理" `Quick test_type_instantiation;
        test_case "自由变量提取" `Quick test_free_vars;
      ] );
    ( "类型转换测试",
      [
        test_case "从基础类型转换" `Quick test_from_base_type;
        test_case "字面量类型推断" `Quick test_literal_type;
        test_case "二元运算符类型" `Quick test_binary_op_type;
        test_case "一元运算符类型" `Quick test_unary_op_type;
      ] );
    ( "类型推断测试",
      [
        test_case "内置函数环境" `Quick test_builtin_env;
        test_case "表达式类型推断" `Quick test_type_inference;
        test_case "类型中文显示" `Quick test_type_to_chinese_string;
      ] );
    ( "性能测试",
      [
        test_case "性能统计功能" `Quick test_performance_stats;
        test_case "记忆化缓存功能" `Quick test_memoization_cache;
      ] );
  ]

let () = run "Types模块单元测试" tests
