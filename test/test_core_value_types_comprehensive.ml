(** 骆言核心值类型模块综合测试
 * 
 * 全面测试 value_types.ml 模块中定义的所有值类型和相关函数
 * 
 * Author: Beta, 代码审查员 - Fix #1408
 * @version 1.0
 * @since 2025-07-26 *)

open Alcotest
open Yyocamlc_lib
open Yyocamlc_lib.Value_types

(* 创建测试用例助手函数 *)
let test_basic_value_types () =
  let int_val = IntValue 42 in
  let float_val = FloatValue 3.14 in
  let string_val = StringValue "骆言编程" in
  let bool_val = BoolValue true in
  let unit_val = UnitValue in
  
  [
    "integer value is basic", `Quick, (fun () ->
      check bool "int value should be basic" true (is_basic_value int_val));
    "float value is basic", `Quick, (fun () ->
      check bool "float value should be basic" true (is_basic_value float_val));
    "string value is basic", `Quick, (fun () ->
      check bool "string value should be basic" true (is_basic_value string_val));
    "bool value is basic", `Quick, (fun () ->
      check bool "bool value should be basic" true (is_basic_value bool_val));
    "unit value is basic", `Quick, (fun () ->
      check bool "unit value should be basic" true (is_basic_value unit_val));
    "int type string", `Quick, (fun () ->
      check string "int type string" "整数" (string_of_value_type int_val));
    "float type string", `Quick, (fun () ->
      check string "float type string" "浮点数" (string_of_value_type float_val));
    "string type string", `Quick, (fun () ->
      check string "string type string" "字符串" (string_of_value_type string_val));
    "bool type string", `Quick, (fun () ->
      check string "bool type string" "布尔值" (string_of_value_type bool_val));
    "unit type string", `Quick, (fun () ->
      check string "unit type string" "单元值" (string_of_value_type unit_val));
  ]

let test_collection_value_types () =
  let list_val = ListValue [IntValue 1; IntValue 2; IntValue 3] in
  let array_val = ArrayValue [|StringValue "a"; StringValue "b"|] in
  let tuple_val = TupleValue [IntValue 10; StringValue "test"] in
  
  [
    "list value is collection", `Quick, (fun () ->
      check bool "list value should be collection" true (is_collection_value list_val));
    "array value is collection", `Quick, (fun () ->
      check bool "array value should be collection" true (is_collection_value array_val));
    "tuple value is collection", `Quick, (fun () ->
      check bool "tuple value should be collection" true (is_collection_value tuple_val));
    "list type string", `Quick, (fun () ->
      check string "list type string" "列表" (string_of_value_type list_val));
    "array type string", `Quick, (fun () ->
      check string "array type string" "数组" (string_of_value_type array_val));
    "tuple type string", `Quick, (fun () ->
      check string "tuple type string" "元组" (string_of_value_type tuple_val));
  ]

let test_environment_operations () =
  let env = empty_env in
  let env1 = bind_var env "x" (IntValue 10) in
  let env2 = bind_var env1 "y" (StringValue "hello") in
  
  [
    "empty environment", `Quick, (fun () ->
      check (list (pair string (fun _ -> ""))) "empty env should be empty" [] env);
    "bind variable creates non-empty env", `Quick, (fun () ->
      check bool "env should not be empty after binding" true (env1 <> []));
    "environment contains variable x", `Quick, (fun () ->
      check bool "env should contain x" true (env_contains_var env2 "x"));
    "environment contains variable y", `Quick, (fun () ->
      check bool "env should contain y" true (env_contains_var env2 "y"));
    "environment does not contain variable z", `Quick, (fun () ->
      check bool "env should not contain z" false (env_contains_var env2 "z"));
    "get environment variables", `Quick, (fun () ->
      let vars = List.sort compare (get_env_vars env2) in
      check (list string) "env vars should match" ["x"; "y"] vars);
  ]

let test_value_categorization () =
  let all_values = [
    ("IntValue", IntValue 1, BasicValue);
    ("FloatValue", FloatValue 1.0, BasicValue);
    ("StringValue", StringValue "test", BasicValue);
    ("BoolValue", BoolValue true, BasicValue);
    ("UnitValue", UnitValue, BasicValue);
    ("ListValue", ListValue [], CollectionValue);
    ("ArrayValue", ArrayValue [||], CollectionValue);
    ("TupleValue", TupleValue [], CollectionValue);
    ("RecordValue", RecordValue [], StructuredValue);
    ("ConstructorValue", ConstructorValue ("Test", []), StructuredValue);
    ("ModuleValue", ModuleValue [], StructuredValue);
    ("ExceptionValue", ExceptionValue ("Error", None), AdvancedValue);
    ("RefValue", RefValue (ref UnitValue), AdvancedValue);
    ("PolymorphicVariantValue", PolymorphicVariantValue ("Tag", None), AdvancedValue);
  ] in
  
  List.map (fun (name, value, expected_cat) ->
    name ^ " categorization", `Quick, (fun () ->
      check bool (name ^ " should have correct category") true 
        (categorize_value value = expected_cat))
  ) all_values

(* 主测试套件 *)
let () =
  run "Value Types Comprehensive Tests" [
    "Basic Value Types", test_basic_value_types ();
    "Collection Value Types", test_collection_value_types ();
    "Environment Operations", test_environment_operations ();
    "Value Categorization", test_value_categorization ();
  ]