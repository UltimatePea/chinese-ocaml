(** 骆言内置常量模块测试 - Chinese Programming Language Builtin Constants Tests *)

open Alcotest
open Yyocamlc_lib.Value_operations
open Yyocamlc_lib.Builtin_constants
(* open Yyocamlc_lib.Builtin_error *)

(** 测试工具函数 *)
let create_test_int i = IntValue i
(* let create_test_string s = StringValue s *)

let extract_value_from_builtin_function func args =
  match func with BuiltinFunctionValue f -> f args | _ -> failwith "期望内置函数值"

(* 检查运行时值是否相等 *)
let check_runtime_value msg expected actual =
  let value_to_string = function
    | IntValue i -> "IntValue(" ^ string_of_int i ^ ")"
    | FloatValue f -> "FloatValue(" ^ string_of_float f ^ ")"
    | StringValue s -> "StringValue(\"" ^ s ^ "\")"
    | BoolValue b -> "BoolValue(" ^ string_of_bool b ^ ")"
    | UnitValue -> "UnitValue"
    | ListValue _ -> "ListValue(...)"
    | _ -> "OtherValue"
  in
  let pp_runtime_value ppf v = Fmt.string ppf (value_to_string v) in
  let runtime_value_testable = testable pp_runtime_value ( = ) in
  check runtime_value_testable msg expected actual

(** 中文数字常量生成函数测试套件 *)
let test_make_chinese_number_constant () =
  (* 测试数字0对应的中文常量 *)
  let zero_constant = make_chinese_number_constant 0 in
  let result = extract_value_from_builtin_function zero_constant [] in
  check_runtime_value "零常量测试" (create_test_int 0) result;

  (* 测试数字5对应的中文常量 *)
  let five_constant = make_chinese_number_constant 5 in
  let result = extract_value_from_builtin_function five_constant [] in
  check_runtime_value "五常量测试" (create_test_int 5) result;

  (* 测试数字9对应的中文常量 *)
  let nine_constant = make_chinese_number_constant 9 in
  let result = extract_value_from_builtin_function nine_constant [] in
  check_runtime_value "九常量测试" (create_test_int 9) result

(** 中文数字常量异常处理测试套件 *)
let test_chinese_number_constant_error_handling () =
  (* 测试带参数的常量调用应该产生错误 *)
  let test_error_case value expected_error_fragment =
    let constant = make_chinese_number_constant value in
    try
      let _ = extract_value_from_builtin_function constant [ create_test_int 1 ] in
      fail "应该抛出运行时错误"
    with
    | RuntimeError msg ->
        check bool
          ("错误消息包含" ^ expected_error_fragment)
          true
          (String.contains msg expected_error_fragment.[0])
    | _ -> fail "应该抛出运行时错误"
  in

  test_error_case 0 "零不需要参数";
  test_error_case 1 "一不需要参数";
  test_error_case 2 "二不需要参数";
  test_error_case 9 "九不需要参数"

(** 中文数字常量表完整性测试套件 *)
let test_chinese_number_constants_table () =
  (* 验证所有中文数字都在表中 *)
  let expected_numbers = [ "零"; "一"; "二"; "三"; "四"; "五"; "六"; "七"; "八"; "九" ] in
  let actual_numbers = List.map fst chinese_number_constants in
  List.iter
    (fun expected -> check bool ("常量表包含" ^ expected) true (List.mem expected actual_numbers))
    expected_numbers;

  (* 验证常量表长度 *)
  check int "常量表长度" 10 (List.length chinese_number_constants)

(** 中文数字常量值正确性测试套件 *)
let test_chinese_number_constants_values () =
  (* 测试每个中文数字常量的值 *)
  let test_cases =
    [
      ("零", 0);
      ("一", 1);
      ("二", 2);
      ("三", 3);
      ("四", 4);
      ("五", 5);
      ("六", 6);
      ("七", 7);
      ("八", 8);
      ("九", 9);
    ]
  in

  List.iter
    (fun (chinese_name, expected_value) ->
      match List.assoc chinese_name chinese_number_constants with
      | BuiltinFunctionValue f ->
          let result = f [] in
          check_runtime_value (chinese_name ^ "常量值测试") (create_test_int expected_value) result
      | _ -> fail ("常量" ^ chinese_name ^ "应该是内置函数值"))
    test_cases

(** 常量不变性测试套件 *)
let test_constants_immutability () =
  (* 测试常量多次调用返回相同值 *)
  let test_constant_consistency chinese_name expected_value =
    match List.assoc chinese_name chinese_number_constants with
    | BuiltinFunctionValue f ->
        let result1 = f [] in
        let result2 = f [] in
        let result3 = f [] in
        check_runtime_value (chinese_name ^ "第一次调用") (create_test_int expected_value) result1;
        check_runtime_value (chinese_name ^ "第二次调用") (create_test_int expected_value) result2;
        check_runtime_value (chinese_name ^ "第三次调用") (create_test_int expected_value) result3
    | _ -> fail ("常量" ^ chinese_name ^ "应该是内置函数值")
  in

  test_constant_consistency "零" 0;
  test_constant_consistency "五" 5;
  test_constant_consistency "九" 9

(** 边界条件测试套件 *)
let test_edge_cases () =
  (* 测试最小值常量 *)
  let zero_constant = List.assoc "零" chinese_number_constants in
  let result = extract_value_from_builtin_function zero_constant [] in
  check_runtime_value "最小值常量（零）" (create_test_int 0) result;

  (* 测试最大值常量 *)
  let nine_constant = List.assoc "九" chinese_number_constants in
  let result = extract_value_from_builtin_function nine_constant [] in
  check_runtime_value "最大值常量（九）" (create_test_int 9) result;

  (* 测试中间值常量 *)
  let five_constant = List.assoc "五" chinese_number_constants in
  let result = extract_value_from_builtin_function five_constant [] in
  check_runtime_value "中间值常量（五）" (create_test_int 5) result

(** 超出范围数字处理测试套件 *)
let test_out_of_range_numbers () =
  (* 测试超出0-9范围的数字处理 *)
  let test_out_of_range value =
    let constant = make_chinese_number_constant value in
    try
      let _ = extract_value_from_builtin_function constant [ create_test_int 1 ] in
      fail "应该抛出运行时错误"
    with
    | RuntimeError msg -> check bool "错误消息包含数字" true (String.length msg > 0)
    | _ -> fail "应该抛出运行时错误"
  in

  test_out_of_range 10;
  test_out_of_range (-1);
  test_out_of_range 100

(** 常量类型检查测试套件 *)
let test_constants_type_checking () =
  (* 验证所有常量都是BuiltinFunctionValue类型 *)
  List.iter
    (fun (name, value) ->
      match value with
      | BuiltinFunctionValue _ -> check bool (name ^ "是内置函数值") true true
      | _ -> fail (name ^ "应该是内置函数值类型"))
    chinese_number_constants

(** 常量表索引测试套件 *)
let test_constants_table_indexing () =
  (* 测试通过名称查找常量 *)
  let find_test name =
    try
      let _ = List.assoc name chinese_number_constants in
      check bool (name ^ "可以找到") true true
    with Not_found -> fail (name ^ "应该在常量表中")
  in

  List.iter find_test [ "零"; "一"; "二"; "三"; "四"; "五"; "六"; "七"; "八"; "九" ];

  (* 测试查找不存在的常量 *)
  try
    let _ = List.assoc "十" chinese_number_constants in
    fail "不应该找到'十'"
  with Not_found -> check bool "正确处理不存在的常量" true true

(** 主测试套件 *)
let () =
  run "骆言内置常量模块测试"
    [
      ("常量生成", [ test_case "中文数字常量生成测试" `Quick test_make_chinese_number_constant ]);
      ("错误处理", [ test_case "常量异常处理测试" `Quick test_chinese_number_constant_error_handling ]);
      ("常量表", [ test_case "中文数字常量表测试" `Quick test_chinese_number_constants_table ]);
      ("常量值", [ test_case "中文数字常量值测试" `Quick test_chinese_number_constants_values ]);
      ("不变性", [ test_case "常量不变性测试" `Quick test_constants_immutability ]);
      ("边界条件", [ test_case "边界条件测试" `Quick test_edge_cases ]);
      ("超出范围", [ test_case "超出范围数字测试" `Quick test_out_of_range_numbers ]);
      ("类型检查", [ test_case "常量类型检查测试" `Quick test_constants_type_checking ]);
      ("表索引", [ test_case "常量表索引测试" `Quick test_constants_table_indexing ]);
    ]
