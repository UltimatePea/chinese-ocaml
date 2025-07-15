(** 骆言语义分析器单元测试 *)

open Alcotest
open Yyocamlc_lib.Ast
open Yyocamlc_lib.Types
open Yyocamlc_lib.Semantic

(* 测试语义分析上下文创建 *)
let test_context_creation () =
  let context = create_initial_context () in
  
  (* 测试初始上下文 *)
  check int "初始作用域栈长度" 1 (List.length context.scope_stack);
  check bool "初始函数返回类型" true (context.current_function_return_type = None);
  check int "初始错误列表长度" 0 (List.length context.error_list);
  check int "初始宏定义列表长度" 0 (List.length context.macros)

(* 测试符号表条目 *)
let test_symbol_entry () =
  let symbol_entry = {
    symbol_name = "test_var";
    symbol_type = IntType_T;
    is_mutable = false;
    definition_pos = 1;
  } in
  
  check string "符号名称" "test_var" symbol_entry.symbol_name;
  check bool "符号类型" true (symbol_entry.symbol_type = IntType_T);
  check bool "符号可变性" false symbol_entry.is_mutable;
  check int "符号定义位置" 1 symbol_entry.definition_pos

(* 测试类型相等性 *)
let test_type_equality () =
  let int_type = IntType_T in
  let float_type = FloatType_T in
  let bool_type = BoolType_T in
  let string_type = StringType_T in
  
  check bool "整数类型相等" true (int_type = int_type);
  check bool "浮点数类型相等" true (float_type = float_type);
  check bool "布尔类型相等" true (bool_type = bool_type);
  check bool "字符串类型相等" true (string_type = string_type);
  
  (* 测试不同类型不相等 *)
  check bool "不同类型不相等" false (int_type = float_type);
  check bool "整数与字符串不相等" false (int_type = string_type);
  check bool "布尔与浮点不相等" false (bool_type = float_type)

(* 测试复合类型 *)
let test_compound_types () =
  let fun_type = FunType_T (IntType_T, IntType_T) in
  let tuple_type = TupleType_T [IntType_T; StringType_T] in
  let list_type = ListType_T IntType_T in
  
  check bool "函数类型相等" true (fun_type = fun_type);
  check bool "元组类型相等" true (tuple_type = tuple_type);
  check bool "列表类型相等" true (list_type = list_type);
  
  (* 测试嵌套类型 *)
  let nested_fun = FunType_T (IntType_T, FunType_T (StringType_T, BoolType_T)) in
  check bool "嵌套函数类型相等" true (nested_fun = nested_fun);
  
  (* 测试不同复合类型不相等 *)
  check bool "不同函数类型不相等" false (fun_type = nested_fun);
  check bool "函数与元组不相等" false (fun_type = tuple_type)

(* 测试类型变量 *)
let test_type_variables () =
  let type_var1 = TypeVar_T "a" in
  let type_var2 = TypeVar_T "b" in
  let type_var3 = TypeVar_T "a" in
  
  check bool "相同类型变量相等" true (type_var1 = type_var3);
  check bool "不同类型变量不相等" false (type_var1 = type_var2)

(* 测试构造类型 *)
let test_construct_types () =
  let construct1 = ConstructType_T ("Option", [IntType_T]) in
  let construct2 = ConstructType_T ("Option", [IntType_T]) in
  let construct3 = ConstructType_T ("Option", [StringType_T]) in
  let construct4 = ConstructType_T ("List", [IntType_T]) in
  
  check bool "相同构造类型相等" true (construct1 = construct2);
  check bool "不同参数类型的构造类型不相等" false (construct1 = construct3);
  check bool "不同构造器的构造类型不相等" false (construct1 = construct4)

(* 测试多态变体类型 *)
let test_polymorphic_variant_types () =
  let variant1 = PolymorphicVariantType_T [("A", Some IntType_T); ("B", None)] in
  let variant2 = PolymorphicVariantType_T [("A", Some IntType_T); ("B", None)] in
  let variant3 = PolymorphicVariantType_T [("A", Some StringType_T); ("B", None)] in
  
  check bool "相同多态变体类型相等" true (variant1 = variant2);
  check bool "不同多态变体类型不相等" false (variant1 = variant3)

(* 测试记录类型 *)
let test_record_types () =
  let record1 = RecordType_T [("field1", IntType_T); ("field2", StringType_T)] in
  let record2 = RecordType_T [("field1", IntType_T); ("field2", StringType_T)] in
  let record3 = RecordType_T [("field1", StringType_T); ("field2", IntType_T)] in
  
  check bool "相同记录类型相等" true (record1 = record2);
  check bool "不同记录类型不相等" false (record1 = record3)

(* 测试引用类型 *)
let test_reference_types () =
  let ref1 = RefType_T IntType_T in
  let ref2 = RefType_T IntType_T in
  let ref3 = RefType_T StringType_T in
  
  check bool "相同引用类型相等" true (ref1 = ref2);
  check bool "不同引用类型不相等" false (ref1 = ref3)

(* 测试数组类型 *)
let test_array_types () =
  let array1 = ArrayType_T IntType_T in
  let array2 = ArrayType_T IntType_T in
  let array3 = ArrayType_T StringType_T in
  
  check bool "相同数组类型相等" true (array1 = array2);
  check bool "不同数组类型不相等" false (array1 = array3)

(* 测试私有类型 *)
let test_private_types () =
  let private1 = PrivateType_T ("MyInt", IntType_T) in
  let private2 = PrivateType_T ("MyInt", IntType_T) in
  let private3 = PrivateType_T ("MyString", StringType_T) in
  
  check bool "相同私有类型相等" true (private1 = private2);
  check bool "不同私有类型不相等" false (private1 = private3)

(* 测试类型方案 *)
let test_type_schemes () =
  let scheme1 = TypeScheme (["a"], TypeVar_T "a") in
  let scheme2 = TypeScheme (["a"], TypeVar_T "a") in
  let scheme3 = TypeScheme (["b"], TypeVar_T "b") in
  
  check bool "相同类型方案相等" true (scheme1 = scheme2);
  check bool "不同类型方案不相等" false (scheme1 = scheme3)

(* 测试类型环境 *)
let test_type_environment () =
  let empty_env = TypeEnv.empty in
  let env_with_var = TypeEnv.add "x" (TypeScheme ([], IntType_T)) empty_env in
  
  check bool "空环境查找" true (TypeEnv.find_opt "x" empty_env = None);
  check bool "环境查找存在的变量" true (TypeEnv.find_opt "x" env_with_var <> None);
  check bool "环境查找不存在的变量" true (TypeEnv.find_opt "y" env_with_var = None)

(* 测试重载环境 *)
let test_overload_environment () =
  let empty_overload = OverloadMap.empty in
  let scheme1 = TypeScheme ([], FunType_T (IntType_T, IntType_T)) in
  let scheme2 = TypeScheme ([], FunType_T (StringType_T, StringType_T)) in
  let overload_with_func = OverloadMap.add "func" [scheme1; scheme2] empty_overload in
  
  check bool "空重载环境查找" true (OverloadMap.find_opt "func" empty_overload = None);
  check bool "重载环境查找存在的函数" true (OverloadMap.find_opt "func" overload_with_func <> None);
  
  match OverloadMap.find_opt "func" overload_with_func with
  | Some schemes -> check int "重载函数数量" 2 (List.length schemes)
  | None -> check bool "重载函数查找失败" false true

(* 测试类型显示 *)
let test_type_display () =
  let int_type = IntType_T in
  let fun_type = FunType_T (IntType_T, StringType_T) in
  let list_type = ListType_T IntType_T in
  
  (* 测试类型可以转换为字符串 *)
  let _ = show_typ int_type in
  let _ = show_typ fun_type in
  let _ = show_typ list_type in
  
  check bool "类型显示测试" true true


let () = run "Semantic单元测试" [
  ("语义分析上下文创建测试", [test_context_creation]);
  ("符号表条目测试", [test_symbol_entry]);
  ("类型相等性测试", [test_type_equality]);
  ("复合类型测试", [test_compound_types]);
  ("类型变量测试", [test_type_variables]);
  ("构造类型测试", [test_construct_types]);
  ("多态变体类型测试", [test_polymorphic_variant_types]);
  ("记录类型测试", [test_record_types]);
  ("引用类型测试", [test_reference_types]);
  ("数组类型测试", [test_array_types]);
  ("私有类型测试", [test_private_types]);
  ("类型方案测试", [test_type_schemes]);
  ("类型环境测试", [test_type_environment]);
  ("重载环境测试", [test_overload_environment]);
  ("类型显示测试", [test_type_display]);
]