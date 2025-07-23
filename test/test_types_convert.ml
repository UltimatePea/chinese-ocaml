(** 骆言类型系统 - 类型转换模块测试 *)

open Alcotest
open Yyocamlc_lib.Core_types
open Yyocamlc_lib.Types_convert
open Yyocamlc_lib.Ast

(** 测试基础类型转换 *)
let test_basic_type_conversion () =
  (* 测试from_base_type函数 *)
  check 
    (testable pp_typ equal_typ) 
    "整数类型转换" 
    IntType_T 
    (from_base_type IntType);
  
  check 
    (testable pp_typ equal_typ) 
    "浮点数类型转换" 
    FloatType_T 
    (from_base_type FloatType);
  
  check 
    (testable pp_typ equal_typ) 
    "字符串类型转换" 
    StringType_T 
    (from_base_type StringType);
  
  check 
    (testable pp_typ equal_typ) 
    "布尔类型转换" 
    BoolType_T 
    (from_base_type BoolType);
  
  check 
    (testable pp_typ equal_typ) 
    "单元类型转换" 
    UnitType_T 
    (from_base_type UnitType)

(** 测试字面量类型推断 *)
let test_literal_type_inference () =
  (* 测试literal_type函数 *)
  check 
    (testable pp_typ equal_typ) 
    "整数字面量类型推断" 
    IntType_T 
    (literal_type (IntLit 42));
  
  check 
    (testable pp_typ equal_typ) 
    "浮点数字面量类型推断" 
    FloatType_T 
    (literal_type (FloatLit 3.14));
  
  check 
    (testable pp_typ equal_typ) 
    "字符串字面量类型推断" 
    StringType_T 
    (literal_type (StringLit "hello"));
  
  check 
    (testable pp_typ equal_typ) 
    "布尔字面量类型推断" 
    BoolType_T 
    (literal_type (BoolLit true));
  
  check 
    (testable pp_typ equal_typ) 
    "单元字面量类型推断" 
    UnitType_T 
    (literal_type UnitLit)

(** 测试二元运算符类型推断 *)
let test_binary_operator_types () =
  (* 测试算术运算符 *)
  let (left_type, right_type, result_type) = binary_op_type Add in
  check (testable pp_typ equal_typ) "加法左操作数类型" IntType_T left_type;
  check (testable pp_typ equal_typ) "加法右操作数类型" IntType_T right_type;
  check (testable pp_typ equal_typ) "加法结果类型" IntType_T result_type;
  
  (* 测试字符串连接 *)
  let (left_type, right_type, result_type) = binary_op_type Concat in
  check (testable pp_typ equal_typ) "字符串连接左操作数类型" StringType_T left_type;
  check (testable pp_typ equal_typ) "字符串连接右操作数类型" StringType_T right_type;
  check (testable pp_typ equal_typ) "字符串连接结果类型" StringType_T result_type;
  
  (* 测试比较运算符 *)
  let (left_type, right_type, result_type) = binary_op_type Lt in
  check (testable pp_typ equal_typ) "小于比较左操作数类型" IntType_T left_type;
  check (testable pp_typ equal_typ) "小于比较右操作数类型" IntType_T right_type;
  check (testable pp_typ equal_typ) "小于比较结果类型" BoolType_T result_type;
  
  (* 测试逻辑运算符 *)
  let (left_type, right_type, result_type) = binary_op_type And in
  check (testable pp_typ equal_typ) "逻辑与左操作数类型" BoolType_T left_type;
  check (testable pp_typ equal_typ) "逻辑与右操作数类型" BoolType_T right_type;
  check (testable pp_typ equal_typ) "逻辑与结果类型" BoolType_T result_type

(** 测试一元运算符类型推断 *)
let test_unary_operator_types () =
  (* 测试数值取反 *)
  let (operand_type, result_type) = unary_op_type Neg in
  check (testable pp_typ equal_typ) "数值取反操作数类型" IntType_T operand_type;
  check (testable pp_typ equal_typ) "数值取反结果类型" IntType_T result_type;
  
  (* 测试逻辑取反 *)
  let (operand_type, result_type) = unary_op_type Not in
  check (testable pp_typ equal_typ) "逻辑取反操作数类型" BoolType_T operand_type;
  check (testable pp_typ equal_typ) "逻辑取反结果类型" BoolType_T result_type

(** 测试类型表达式转换 *)
let test_type_expression_conversion () =
  (* 测试基础类型表达式转换 *)
  check 
    (testable pp_typ equal_typ) 
    "基础类型表达式转换 - 整数" 
    IntType_T 
    (type_expr_to_typ (BaseTypeExpr IntType));
  
  (* 测试类型变量转换 *)
  check 
    (testable pp_typ equal_typ) 
    "类型变量转换" 
    (TypeVar_T "a") 
    (type_expr_to_typ (TypeVar "a"));
  
  (* 测试函数类型转换 *)
  let fun_type = type_expr_to_typ (FunType (BaseTypeExpr IntType, BaseTypeExpr StringType)) in
  let expected_fun_type = FunType_T (IntType_T, StringType_T) in
  check 
    (testable pp_typ equal_typ) 
    "函数类型转换" 
    expected_fun_type 
    fun_type;
  
  (* 测试列表类型转换 *)
  let list_type = type_expr_to_typ (ListType (BaseTypeExpr IntType)) in
  check 
    (testable pp_typ equal_typ) 
    "列表类型转换" 
    (ListType_T IntType_T) 
    list_type;
  
  (* 测试元组类型转换 *)
  let tuple_type = type_expr_to_typ (TupleType [BaseTypeExpr IntType; BaseTypeExpr StringType]) in
  let expected_tuple = TupleType_T [IntType_T; StringType_T] in
  check 
    (testable pp_typ equal_typ) 
    "元组类型转换" 
    expected_tuple 
    tuple_type

(** 测试模式变量绑定提取 *)
let test_pattern_binding_extraction () =
  (* 测试简单变量模式 *)
  let bindings = extract_pattern_bindings (VarPattern "x") in
  check int "变量模式绑定数量" 1 (List.length bindings);
  check string "变量模式绑定名称" "x" (fst (List.hd bindings));
  
  (* 测试通配符模式 *)
  let bindings = extract_pattern_bindings WildcardPattern in
  check int "通配符模式绑定数量" 0 (List.length bindings);
  
  (* 测试字面量模式 *)
  let bindings = extract_pattern_bindings (LitPattern (IntLit 42)) in
  check int "字面量模式绑定数量" 0 (List.length bindings);
  
  (* 测试元组模式 *)
  let tuple_pattern = TuplePattern [VarPattern "x"; VarPattern "y"; WildcardPattern] in
  let bindings = extract_pattern_bindings tuple_pattern in
  check int "元组模式绑定数量" 2 (List.length bindings);
  
  (* 验证元组模式绑定包含正确的变量名 *)
  let binding_names = List.map fst bindings in
  check bool "元组模式包含变量x" true (List.mem "x" binding_names);
  check bool "元组模式包含变量y" true (List.mem "y" binding_names)

(** 测试中文类型显示功能 *)
let test_chinese_type_display () =
  (* 测试基础类型中文显示 *)
  check string "整数类型中文显示" "整数" (type_to_chinese_string IntType_T);
  check string "浮点数类型中文显示" "浮点数" (type_to_chinese_string FloatType_T);
  check string "字符串类型中文显示" "字符串" (type_to_chinese_string StringType_T);
  check string "布尔类型中文显示" "布尔值" (type_to_chinese_string BoolType_T);
  check string "单元类型中文显示" "单元" (type_to_chinese_string UnitType_T);
  
  (* 测试容器类型中文显示 *)
  let list_type_str = type_to_chinese_string (ListType_T IntType_T) in
  check string "列表类型中文显示" "整数 列表" list_type_str;
  
  let tuple_type_str = type_to_chinese_string (TupleType_T [IntType_T; StringType_T]) in
  check string "元组类型中文显示" "(整数 * 字符串)" tuple_type_str;
  
  let ref_type_str = type_to_chinese_string (RefType_T BoolType_T) in
  check string "引用类型中文显示" "布尔值 引用" ref_type_str;
  
  (* 测试函数类型中文显示 *)
  let fun_type_str = type_to_chinese_string (FunType_T (IntType_T, StringType_T)) in
  check string "函数类型中文显示" "整数 -> 字符串" fun_type_str;
  
  (* 测试类型变量中文显示 *)
  let var_type_str = type_to_chinese_string (TypeVar_T "a") in
  check string "类型变量中文显示" "'a" var_type_str

(** 测试复杂嵌套类型转换 *)
let test_complex_nested_types () =
  (* 测试嵌套函数类型 *)
  let nested_fun_expr = FunType (
    FunType (BaseTypeExpr IntType, BaseTypeExpr StringType),
    BaseTypeExpr BoolType
  ) in
  let converted = type_expr_to_typ nested_fun_expr in
  let expected = FunType_T (FunType_T (IntType_T, StringType_T), BoolType_T) in
  check (testable pp_typ equal_typ) "嵌套函数类型转换" expected converted;
  
  (* 测试嵌套列表类型 *)
  let nested_list_expr = ListType (ListType (BaseTypeExpr IntType)) in
  let converted = type_expr_to_typ nested_list_expr in
  let expected = ListType_T (ListType_T IntType_T) in
  check (testable pp_typ equal_typ) "嵌套列表类型转换" expected converted;
  
  (* 测试包含类型变量的复杂类型 *)
  let complex_expr = FunType (
    TupleType [TypeVar "a"; BaseTypeExpr IntType],
    ListType (TypeVar "a")
  ) in
  let converted = type_expr_to_typ complex_expr in
  let expected = FunType_T (
    TupleType_T [TypeVar_T "a"; IntType_T],
    ListType_T (TypeVar_T "a")
  ) in
  check (testable pp_typ equal_typ) "复杂参数化类型转换" expected converted

(** 测试构造类型转换 *)
let test_construct_type_conversion () =
  (* 测试简单构造类型（无参数） *)
  let simple_construct = ConstructType ("MyType", []) in
  let converted = type_expr_to_typ simple_construct in
  let expected = ConstructType_T ("MyType", []) in
  check (testable pp_typ equal_typ) "简单构造类型转换" expected converted;
  
  (* 测试参数化构造类型 *)
  let param_construct = ConstructType ("Option", [BaseTypeExpr IntType]) in
  let converted = type_expr_to_typ param_construct in
  let expected = ConstructType_T ("Option", [IntType_T]) in
  check (testable pp_typ equal_typ) "参数化构造类型转换" expected converted;
  
  (* 测试多参数构造类型 *)
  let multi_param_construct = ConstructType ("Either", [BaseTypeExpr IntType; BaseTypeExpr StringType]) in
  let converted = type_expr_to_typ multi_param_construct in
  let expected = ConstructType_T ("Either", [IntType_T; StringType_T]) in
  check (testable pp_typ equal_typ) "多参数构造类型转换" expected converted

(** 测试引用类型转换 *)
let test_reference_type_conversion () =
  (* 测试基础类型引用 *)
  let ref_expr = RefType (BaseTypeExpr IntType) in
  let converted = type_expr_to_typ ref_expr in
  let expected = RefType_T IntType_T in
  check (testable pp_typ equal_typ) "基础类型引用转换" expected converted;
  
  (* 测试复杂类型引用 *)
  let complex_ref_expr = RefType (TupleType [BaseTypeExpr IntType; BaseTypeExpr StringType]) in
  let converted = type_expr_to_typ complex_ref_expr in
  let expected = RefType_T (TupleType_T [IntType_T; StringType_T]) in
  check (testable pp_typ equal_typ) "复杂类型引用转换" expected converted

(** 测试错误处理和边界情况 *)
let test_error_handling () =
  (* 测试等价运算符的特殊处理 *)
  let (_left_type, _right_type, result_type) = binary_op_type Eq in
  (* 等价运算符应该返回类型变量，允许任意类型比较 *)
  check (testable pp_typ equal_typ) "等价运算符结果类型" BoolType_T result_type;
  
  (* 测试不等价运算符的特殊处理 *)
  let (_left_type, _right_type, result_type) = binary_op_type Neq in
  check (testable pp_typ equal_typ) "不等价运算符结果类型" BoolType_T result_type;
  
  (* 测试复杂模式的绑定提取 *)
  let cons_pattern = ConsPattern (VarPattern "head", VarPattern "tail") in
  let bindings = extract_pattern_bindings cons_pattern in
  check int "链表模式绑定数量" 2 (List.length bindings);
  
  let binding_names = List.map fst bindings in
  check bool "链表模式包含head绑定" true (List.mem "head" binding_names);
  check bool "链表模式包含tail绑定" true (List.mem "tail" binding_names)

(** 主测试套件 *)
let () =
  run "Types_Convert模块测试" [
    ("基础类型转换", [
      test_case "from_base_type函数测试" `Quick test_basic_type_conversion;
    ]);
    
    ("字面量类型推断", [
      test_case "literal_type函数测试" `Quick test_literal_type_inference;
    ]);
    
    ("运算符类型推断", [
      test_case "二元运算符类型测试" `Quick test_binary_operator_types;
      test_case "一元运算符类型测试" `Quick test_unary_operator_types;
    ]);
    
    ("类型表达式转换", [
      test_case "基本类型表达式转换测试" `Quick test_type_expression_conversion;
      test_case "复杂嵌套类型转换测试" `Quick test_complex_nested_types;
      test_case "构造类型转换测试" `Quick test_construct_type_conversion;
      test_case "引用类型转换测试" `Quick test_reference_type_conversion;
    ]);
    
    ("模式匹配支持", [
      test_case "模式变量绑定提取测试" `Quick test_pattern_binding_extraction;
    ]);
    
    ("中文显示功能", [
      test_case "中文类型显示测试" `Quick test_chinese_type_display;
    ]);
    
    ("错误处理和边界情况", [
      test_case "错误处理和边界情况测试" `Quick test_error_handling;
    ]);
  ]