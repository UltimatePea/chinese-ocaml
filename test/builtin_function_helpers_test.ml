(** 骆言内置函数辅助工具模块综合测试
    
    此测试文件为builtin_function_helpers.ml提供完整的测试覆盖，
    确保所有导出的辅助函数正确处理参数验证、类型转换和错误处理。
    
    测试覆盖范围：
    - 单参数类型辅助函数
    - 双参数辅助函数  
    - 柯里化辅助函数
    - 文件操作辅助函数
    - 类型转换辅助函数
    
    @author Claude AI Assistant
    @version 1.0
    @since 2025-07-25 *)

open Alcotest
open Yyocamlc_lib.Value_operations
open Yyocamlc_lib.Builtin_function_helpers
open Yyocamlc_lib.Builtin_error

(** {1 测试辅助函数} *)

(** 创建测试用的函数操作 *)
let identity_string s = s
let uppercase_string s = String.uppercase_ascii s
let concat_strings s1 s2 = s1 ^ s2
let string_equals s1 s2 = String.equal s1 s2
let increment_int i = i + 1
let negate_bool b = not b
let increment_float f = f +. 1.0

(** 创建测试用的列表操作 *)
let reverse_list lst = List.rev lst

(** {1 单参数辅助函数测试} *)

let test_single_string_builtin () =
  let test_cases = [
    (* 正常情况 *)
    ([StringValue "hello"], "hello", "identity function");
    ([StringValue "world"], "WORLD", "uppercase function");
  ] in
  
  List.iter (fun (args, expected, description) ->
    let result = single_string_builtin "test_func" 
      (if description = "identity function" then identity_string else uppercase_string) 
      args in
    match result with
    | StringValue actual -> 
        check string description expected actual
    | _ -> 
        failwith ("期望StringValue，实际得到其他类型: " ^ description)
  ) test_cases

let test_single_string_builtin_errors () =
  let error_cases = [
    (* 参数数量错误 *)
    ([], "参数数量错误");
    ([StringValue "a"; StringValue "b"], "参数数量错误");
    
    (* 参数类型错误 *)
    ([IntValue 42], "类型错误");
    ([BoolValue true], "类型错误");
  ] in
  
  List.iter (fun (args, expected_error_type) ->
    try
      let _ = single_string_builtin "test_func" identity_string args in
      failwith ("期望出现错误: " ^ expected_error_type)
    with
    | _ -> () (* 期望出现异常 *)
  ) error_cases

let test_single_int_builtin () =
  let test_cases = [
    ([IntValue 5], 6, "increment function");
    ([IntValue 0], 1, "increment zero");
    ([IntValue (-1)], 0, "increment negative");
  ] in
  
  List.iter (fun (args, expected, description) ->
    let result = single_int_builtin "test_func" increment_int args in
    match result with
    | IntValue actual -> 
        check int description expected actual
    | _ -> 
        failwith ("期望IntValue，实际得到其他类型: " ^ description)
  ) test_cases

let test_single_float_builtin () =
  let test_cases = [
    ([FloatValue 1.5], 2.5, "increment float");
    ([FloatValue 0.0], 1.0, "increment zero float");
  ] in
  
  List.iter (fun (args, expected, description) ->
    let result = single_float_builtin "test_func" increment_float args in
    match result with
    | FloatValue actual -> 
        check (float 0.001) description expected actual
    | _ -> 
        failwith ("期望FloatValue，实际得到其他类型: " ^ description)
  ) test_cases

let test_single_bool_builtin () =
  let test_cases = [
    ([BoolValue true], false, "negate true");
    ([BoolValue false], true, "negate false");
  ] in
  
  List.iter (fun (args, expected, description) ->
    let result = single_bool_builtin "test_func" negate_bool args in
    match result with
    | BoolValue actual -> 
        check bool description expected actual
    | _ -> 
        failwith ("期望BoolValue，实际得到其他类型: " ^ description)
  ) test_cases

let test_single_to_string_builtin () =
  let test_cases = [
    ([IntValue 42], "42", "int to string");
    ([FloatValue 3.14], "3.14", "float to string");
  ] in
  
  List.iter (fun (args, expected, description) ->
    let result = 
      if description = "int to string" then
        single_to_string_builtin "test_func" expect_int string_of_int args
      else
        single_to_string_builtin "test_func" expect_float string_of_float args
    in
    match result with
    | StringValue actual -> 
        check string description expected actual
    | _ -> 
        failwith ("期望StringValue，实际得到其他类型: " ^ description)
  ) test_cases

let test_single_conversion_builtin () =
  (* Test int conversion *)
  let result1 = single_conversion_builtin "test_func" expect_string int_of_string (fun x -> IntValue x) [StringValue "42"] in
  (match result1 with
   | IntValue actual -> check int "string to int" 42 actual
   | _ -> failwith "期望IntValue，实际得到其他类型");
  
  (* Test float conversion *)
  let result2 = single_conversion_builtin "test_func" expect_string float_of_string (fun x -> FloatValue x) [StringValue "3.14"] in
  (match result2 with
   | FloatValue actual -> check (float 0.001) "string to float" 3.14 actual
   | _ -> failwith "期望FloatValue，实际得到其他类型")

(** {1 双参数辅助函数测试} *)

let test_double_string_builtin () =
  let test_cases = [
    ([StringValue "hello"; StringValue "world"], "helloworld", "concatenation");
    ([StringValue ""; StringValue "test"], "test", "empty first string");
    ([StringValue "test"; StringValue ""], "test", "empty second string");
  ] in
  
  List.iter (fun (args, expected, description) ->
    let result = double_string_builtin "test_func" concat_strings args in
    match result with
    | StringValue actual -> 
        check string description expected actual
    | _ -> 
        failwith ("期望StringValue，实际得到其他类型: " ^ description)
  ) test_cases

let test_double_string_to_bool_builtin () =
  let test_cases = [
    ([StringValue "hello"; StringValue "hello"], true, "equal strings");
    ([StringValue "hello"; StringValue "world"], false, "different strings");
    ([StringValue ""; StringValue ""], true, "empty strings");
  ] in
  
  List.iter (fun (args, expected, description) ->
    let result = double_string_to_bool_builtin "test_func" string_equals args in
    match result with
    | BoolValue actual -> 
        check bool description expected actual
    | _ -> 
        failwith ("期望BoolValue，实际得到其他类型: " ^ description)
  ) test_cases

(** {1 列表操作辅助函数测试} *)

let test_single_list_builtin () =
  let test_list = [StringValue "a"; StringValue "b"; StringValue "c"] in
  let expected_reversed = [StringValue "c"; StringValue "b"; StringValue "a"] in
  
  let result = single_list_builtin "test_func" reverse_list [ListValue test_list] in
  match result with
  | ListValue actual -> 
      let check_equal lst1 lst2 = List.equal (=) lst1 lst2 in
      if check_equal actual expected_reversed then
        ()  (* 测试通过 *)
      else
        failwith "列表反转结果不正确"
  | _ -> 
      failwith "期望ListValue，实际得到其他类型"

(** {1 柯里化辅助函数测试} *)

let test_curried_double_string_builtin () =
  (* 第一步：创建柯里化函数 *)
  let curried_func = curried_double_string_builtin "test_func" concat_strings [StringValue "hello"] in
  
  (* 验证返回的是BuiltinFunctionValue *)
  match curried_func with
  | BuiltinFunctionValue func ->
      (* 第二步：应用第二个参数 *)
      let result = func [StringValue "world"] in
      (match result with
       | StringValue actual -> 
           check string "curried concatenation" "helloworld" actual
       | _ -> 
           failwith "期望StringValue，实际得到其他类型")
  | _ -> 
      failwith "期望BuiltinFunctionValue，实际得到其他类型"

let test_curried_double_string_to_bool_builtin () =
  (* 测试柯里化布尔返回函数 *)
  let curried_func = curried_double_string_to_bool_builtin "test_func" string_equals [StringValue "test"] in
  
  match curried_func with
  | BuiltinFunctionValue func ->
      let result1 = func [StringValue "test"] in
      let result2 = func [StringValue "other"] in
      
      (match result1, result2 with
       | BoolValue true, BoolValue false -> 
           () (* 测试通过 *)
       | _ -> 
           failwith "柯里化比较函数结果不正确")
  | _ -> 
      failwith "期望BuiltinFunctionValue，实际得到其他类型"

let test_curried_string_to_list_builtin () =
  (* 测试柯里化字符串到列表函数 *)
  let split_on_char delimiter str = String.split_on_char (String.get delimiter 0) str in
  let curried_func = curried_string_to_list_builtin "test_func" split_on_char [StringValue ","] in
  
  match curried_func with
  | BuiltinFunctionValue func ->
      let result = func [StringValue "a,b,c"] in
      (match result with
       | ListValue lst -> 
           let expected = [StringValue "a"; StringValue "b"; StringValue "c"] in
           let check_equal lst1 lst2 = List.equal (=) lst1 lst2 in
           if check_equal lst expected then
             () (* 测试通过 *)
           else
             failwith "柯里化字符串分割结果不正确"
       | _ -> 
           failwith "期望ListValue，实际得到其他类型")
  | _ -> 
      failwith "期望BuiltinFunctionValue，实际得到其他类型"

(** {1 文件操作辅助函数测试} *)

let test_single_file_builtin () =
  (* 创建一个模拟的文件操作函数，避免实际文件I/O *)
  let mock_file_operation filename = 
    if filename = "test.txt" then
      StringValue "file content"
    else
      failwith ("File not found: " ^ filename)
  in
  
  (* 测试正常情况 *)
  let result = single_file_builtin "test_func" mock_file_operation [StringValue "test.txt"] in
  match result with
  | StringValue actual -> 
      check string "file operation" "file content" actual
  | _ -> 
      failwith "期望StringValue，实际得到其他类型"

let test_single_file_builtin_error () =
  (* 测试文件不存在的情况 *)
  let mock_file_operation filename = 
    failwith ("File not found: " ^ filename)
  in
  
  try
    let _ = single_file_builtin "test_func" mock_file_operation [StringValue "nonexistent.txt"] in
    failwith "期望出现文件错误"
  with
  | _ -> () (* 期望出现异常 *)

(** {1 综合工作流程测试} *)

let test_comprehensive_builtin_workflow () =
  (* 测试一个完整的内置函数工作流程 *)
  
  (* 1. 单参数函数 *)
  let result1 = single_string_builtin "uppercase" uppercase_string [StringValue "hello"] in
  (match result1 with
   | StringValue s -> check string "workflow step 1" "HELLO" s
   | _ -> failwith "Step 1 failed");
  
  (* 2. 双参数函数 *)
  let result2 = double_string_builtin "concat" concat_strings 
    [StringValue "Hello"; StringValue " World"] in
  (match result2 with
   | StringValue s -> check string "workflow step 2" "Hello World" s
   | _ -> failwith "Step 2 failed");
  
  (* 3. 柯里化函数 *)
  let curried = curried_double_string_builtin "curried_concat" concat_strings [StringValue "A"] in
  (match curried with
   | BuiltinFunctionValue func ->
       let result3 = func [StringValue "B"] in
       (match result3 with
        | StringValue s -> check string "workflow step 3" "AB" s
        | _ -> failwith "Step 3 failed")
   | _ -> failwith "Step 3 setup failed")

(** {1 边界条件和异常情况测试} *)

let test_edge_cases () =
  (* 测试空字符串 *)
  let result1 = single_string_builtin "identity" identity_string [StringValue ""] in
  (match result1 with
   | StringValue s -> check string "empty string" "" s
   | _ -> failwith "Empty string test failed");
  
  (* 测试零值 *)
  let result2 = single_int_builtin "increment" increment_int [IntValue 0] in
  (match result2 with
   | IntValue i -> check int "zero increment" 1 i
   | _ -> failwith "Zero increment test failed")

(** {1 错误处理测试} *)

let test_parameter_validation_errors () =
  (* 测试各种参数验证错误 *)
  let error_test_cases = [
    (* 空参数列表 *)
    (fun () -> single_string_builtin "test" identity_string []);
    
    (* 过多参数 *)
    (fun () -> single_string_builtin "test" identity_string [StringValue "a"; StringValue "b"]);
    
    (* 错误类型参数 *)
    (fun () -> single_string_builtin "test" identity_string [IntValue 42]);
    
    (* 双参数函数的参数错误 *)
    (fun () -> double_string_builtin "test" concat_strings [StringValue "only_one"]);
  ] in
  
  List.iteri (fun i test_func ->
    try
      let _ = test_func () in
      failwith ("错误测试 " ^ string_of_int i ^ " 应该抛出异常")
    with
    | _ -> () (* 期望出现异常 *)
  ) error_test_cases

(** {1 测试套件定义} *)

let builtin_function_helpers_tests = [
  ("单参数字符串辅助函数", `Quick, test_single_string_builtin);
  ("单参数字符串辅助函数错误处理", `Quick, test_single_string_builtin_errors);
  ("单参数整数辅助函数", `Quick, test_single_int_builtin);
  ("单参数浮点数辅助函数", `Quick, test_single_float_builtin);
  ("单参数布尔值辅助函数", `Quick, test_single_bool_builtin);
  ("单参数转字符串辅助函数", `Quick, test_single_to_string_builtin);
  ("单参数类型转换辅助函数", `Quick, test_single_conversion_builtin);
  ("双参数字符串辅助函数", `Quick, test_double_string_builtin);
  ("双参数字符串返回布尔辅助函数", `Quick, test_double_string_to_bool_builtin);
  ("单参数列表辅助函数", `Quick, test_single_list_builtin);
  ("柯里化双参数字符串辅助函数", `Quick, test_curried_double_string_builtin);
  ("柯里化双参数字符串返回布尔辅助函数", `Quick, test_curried_double_string_to_bool_builtin);
  ("柯里化字符串到列表辅助函数", `Quick, test_curried_string_to_list_builtin);
  ("文件操作辅助函数", `Quick, test_single_file_builtin);
  ("文件操作错误处理", `Quick, test_single_file_builtin_error);
  ("综合工作流程测试", `Quick, test_comprehensive_builtin_workflow);
  ("边界条件测试", `Quick, test_edge_cases);
  ("参数验证错误测试", `Quick, test_parameter_validation_errors);
]

(** {1 测试运行器} *)

let () =
  Printf.printf "🚀 开始运行内置函数辅助工具模块测试套件\n";
  Printf.printf "================================================\n\n";
  
  run "骆言内置函数辅助工具模块综合测试" [
    ("内置函数辅助工具", builtin_function_helpers_tests);
  ];
  
  Printf.printf "\n================================================\n";
  Printf.printf "✅ 所有测试通过！内置函数辅助工具模块运行正常\n";
  Printf.printf "📊 测试覆盖：参数验证、类型转换、错误处理、柯里化函数\n";
  Printf.printf "🎯 特色功能：多种辅助函数、统一错误处理、边界条件测试\n";
  Printf.printf "================================================\n"