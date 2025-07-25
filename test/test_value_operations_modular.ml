(** 骆言模块化值操作测试 - Modular Value Operations Test
    
    测试新的模块化值操作系统
    
    @author 骆言AI代理
    @since 2025-07-24 Fix #1046
*)

open Yyocamlc_lib.Value_types
open Yyocamlc_lib.Value_operations_basic
open Yyocamlc_lib.Value_operations_collections

let test_basic_values () =
  (* 测试基础值操作 *)
  let int_val = IntValue 42 in
  let float_val = FloatValue 3.14 in
  let str_val = StringValue "测试" in
  let bool_val = BoolValue true in
  let unit_val = UnitValue in
  
  (* 测试类型检查 *)
  assert (is_basic_value int_val);
  assert (is_basic_value float_val);
  assert (is_basic_value str_val);
  assert (is_basic_value bool_val);
  assert (is_basic_value unit_val);
  
  (* 测试字符串转换 *)
  assert (string_of_basic_value_unsafe int_val = "42");
  assert (string_of_basic_value_unsafe str_val = "测试");
  assert (string_of_basic_value_unsafe bool_val = "真");
  assert (string_of_basic_value_unsafe unit_val = "()");
  
  (* 测试数值运算 *)
  let sum = add_numeric_values (IntValue 5) (IntValue 3) in
  assert (sum = IntValue 8);
  
  let diff = subtract_numeric_values (IntValue 10) (IntValue 4) in
  assert (diff = IntValue 6);
  
  let product = multiply_numeric_values (IntValue 6) (IntValue 7) in
  assert (product = IntValue 42);
  
  (* 测试逻辑运算 *)
  let and_result = logical_and (BoolValue true) (BoolValue false) in
  assert (and_result = BoolValue false);
  
  let or_result = logical_or (BoolValue true) (BoolValue false) in
  assert (or_result = BoolValue true);
  
  let not_result = logical_not (BoolValue true) in
  assert (not_result = BoolValue false);
  
  print_endline "✅ 基础值操作测试通过"

let test_collection_values () =
  (* 测试集合值操作 *)
  let list_val = ListValue [IntValue 1; IntValue 2; IntValue 3] in
  let array_val = ArrayValue [|StringValue "a"; StringValue "b"|] in
  let tuple_val = TupleValue [BoolValue true; IntValue 42] in
  
  (* 测试类型检查 *)
  assert (is_collection_value list_val);
  assert (is_collection_value array_val);
  assert (is_collection_value tuple_val);
  
  (* 测试列表操作 *)
  let length = list_length list_val in
  assert (length = IntValue 3);
  
  let head = list_head list_val in
  assert (head = IntValue 1);
  
  let tail = list_tail list_val in
  assert (tail = ListValue [IntValue 2; IntValue 3]);
  
  (* 测试数组操作 *)
  let arr_length = array_length array_val in
  assert (arr_length = IntValue 2);
  
  let first_elem = array_get array_val (IntValue 0) in
  assert (first_elem = StringValue "a");
  
  (* 测试元组操作 *)
  let tuple_len = tuple_length tuple_val in
  assert (tuple_len = IntValue 2);
  
  let tuple_first = tuple_nth tuple_val (IntValue 0) in
  assert (tuple_first = BoolValue true);
  
  (* 测试集合通用操作 *)
  let empty_list = ListValue [] in
  let is_empty_result = is_empty empty_list in
  assert (is_empty_result = BoolValue true);
  
  let size = collection_size list_val in
  assert (size = IntValue 3);
  
  print_endline "✅ 集合值操作测试通过"

let test_value_types () =
  (* 测试值类型系统 *)
  let int_val = IntValue 42 in
  let list_val = ListValue [IntValue 1] in
  let func_val = FunctionValue (["x"], VarExpr "x", []) in
  
  (* 测试值分类 *)
  assert (categorize_value int_val = BasicValue);
  assert (categorize_value list_val = CollectionValue);
  assert (categorize_value func_val = FunctionCategory);
  
  (* 测试环境操作 *)
  let env = empty_env in
  let env1 = bind_var env "x" int_val in
  let env2 = bind_var env1 "y" list_val in
  
  assert (env_contains_var env2 "x");
  assert (env_contains_var env2 "y");
  assert (not (env_contains_var env2 "z"));
  
  let vars = get_env_vars env2 in
  assert (List.length vars = 2);
  assert (List.mem "x" vars);
  assert (List.mem "y" vars);
  
  print_endline "✅ 值类型系统测试通过"

let run_tests () =
  print_endline "🧪 开始模块化值操作测试...";
  test_basic_values ();
  test_collection_values ();
  test_value_types ();
  print_endline "🎉 所有模块化值操作测试通过！"

let () = run_tests ()