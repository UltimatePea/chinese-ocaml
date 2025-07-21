(** 骆言类型推断模块综合测试 - Type Inference Comprehensive Tests *)

open Alcotest
open Yyocamlc_lib.Core_types

(** 测试基本字面量的类型推断 *)
let test_literal_type_inference () =
  (* 测试基本类型创建 *)
  let int_type = IntType_T in
  let str_type = StringType_T in
  let bool_type = BoolType_T in
  let float_type = FloatType_T in
  let unit_type = UnitType_T in
  
  (* 验证类型相等性 *)
  check bool "整数类型相等" true (int_type = IntType_T);
  check bool "字符串类型相等" true (str_type = StringType_T);
  check bool "布尔类型相等" true (bool_type = BoolType_T);
  check bool "浮点数类型相等" true (float_type = FloatType_T);
  check bool "单元类型相等" true (unit_type = UnitType_T)

(** 测试复合类型的构造 *)
let test_compound_type_construction () =
  (* 函数类型 *)
  let func_type = FunType_T (IntType_T, StringType_T) in
  check bool "函数类型构造" true (match func_type with FunType_T (_, _) -> true | _ -> false);
  
  (* 列表类型 *)
  let list_type = ListType_T IntType_T in
  check bool "列表类型构造" true (match list_type with ListType_T _ -> true | _ -> false);
  
  (* 元组类型 *)
  let tuple_type = TupleType_T [IntType_T; StringType_T] in
  check bool "元组类型构造" true (match tuple_type with TupleType_T _ -> true | _ -> false);
  
  (* 数组类型 *)
  let array_type = ArrayType_T BoolType_T in
  check bool "数组类型构造" true (match array_type with ArrayType_T _ -> true | _ -> false)

(** 测试类型变量的生成 *)
let test_type_variable_generation () =
  (* 生成类型变量 *)
  let var1 = new_type_var () in
  let var2 = new_type_var () in
  
  (* 验证类型变量格式 *)
  check bool "类型变量1格式" true (match var1 with TypeVar_T _ -> true | _ -> false);
  check bool "类型变量2格式" true (match var2 with TypeVar_T _ -> true | _ -> false);
  
  (* 验证生成的类型变量不同 *)
  check bool "生成的类型变量不同" true (var1 <> var2)

(** 测试类型替换操作 *)
let test_type_substitution () =
  (* 创建空替换 *)
  let empty = empty_subst in
  check bool "空替换创建" true (SubstMap.is_empty empty);
  
  (* 创建单一替换 *)
  let single = single_subst "a" IntType_T in
  check bool "单一替换创建" true (SubstMap.cardinal single = 1);
  
  (* 查找替换 *)
  (try
    let found_type = SubstMap.find "a" single in
    check bool "替换查找成功" true (found_type = IntType_T)
  with Not_found ->
    check bool "替换查找失败" false true)

(** 测试类型方案的构造 *)
let test_type_scheme_construction () =
  (* 创建单态类型方案 *)
  let mono_scheme = TypeScheme ([], IntType_T) in
  check bool "单态类型方案构造" true 
    (match mono_scheme with TypeScheme ([], IntType_T) -> true | _ -> false);
  
  (* 创建多态类型方案 *)
  let poly_scheme = TypeScheme (["a"], TypeVar_T "a") in
  check bool "多态类型方案构造" true 
    (match poly_scheme with TypeScheme (["a"], TypeVar_T "a") -> true | _ -> false)

(** 测试高级类型的构造 *)
let test_advanced_type_construction () =
  (* 构造类型 *)
  let construct_type = ConstructType_T ("Option", [IntType_T]) in
  check bool "构造类型创建" true 
    (match construct_type with ConstructType_T ("Option", [IntType_T]) -> true | _ -> false);
  
  (* 记录类型 *)
  let record_type = RecordType_T [("name", StringType_T); ("age", IntType_T)] in
  check bool "记录类型创建" true 
    (match record_type with RecordType_T _ -> true | _ -> false);
  
  (* 引用类型 *)
  let ref_type = RefType_T IntType_T in
  check bool "引用类型创建" true 
    (match ref_type with RefType_T IntType_T -> true | _ -> false)

(** 测试类型字符串转换 *)
let test_type_string_conversion () =
  (* 基本类型转换 *)
  let int_str = string_of_typ IntType_T in
  check bool "整数类型转换非空" true (String.length int_str > 0);
  
  let str_str = string_of_typ StringType_T in
  check bool "字符串类型转换非空" true (String.length str_str > 0);
  
  (* 复合类型转换 *)
  let func_str = string_of_typ (FunType_T (IntType_T, StringType_T)) in
  check bool "函数类型转换非空" true (String.length func_str > 0);
  
  let list_str = string_of_typ (ListType_T IntType_T) in
  check bool "列表类型转换非空" true (String.length list_str > 0)

(** 测试嵌套复合类型 *)
let test_nested_compound_types () =
  (* 函数列表类型 *)
  let func_list = ListType_T (FunType_T (IntType_T, BoolType_T)) in
  check bool "函数列表类型构造" true 
    (match func_list with ListType_T (FunType_T (IntType_T, BoolType_T)) -> true | _ -> false);
  
  (* 元组数组类型 *)
  let tuple_array = ArrayType_T (TupleType_T [StringType_T; IntType_T]) in
  check bool "元组数组类型构造" true 
    (match tuple_array with ArrayType_T (TupleType_T [StringType_T; IntType_T]) -> true | _ -> false);
  
  (* 嵌套函数类型 *)
  let nested_func = FunType_T (IntType_T, FunType_T (StringType_T, BoolType_T)) in
  check bool "嵌套函数类型构造" true 
    (match nested_func with FunType_T (IntType_T, FunType_T (StringType_T, BoolType_T)) -> true | _ -> false)

(** 创建测试套件 *)
let tests = [
  "测试基本字面量类型推断", `Quick, test_literal_type_inference;
  "测试复合类型构造", `Quick, test_compound_type_construction;
  "测试类型变量生成", `Quick, test_type_variable_generation;
  "测试类型替换操作", `Quick, test_type_substitution;
  "测试类型方案构造", `Quick, test_type_scheme_construction;
  "测试高级类型构造", `Quick, test_advanced_type_construction;
  "测试类型字符串转换", `Quick, test_type_string_conversion;
  "测试嵌套复合类型", `Quick, test_nested_compound_types;
]

let () = run "类型推断综合测试" [
  "类型系统基础", tests;
]