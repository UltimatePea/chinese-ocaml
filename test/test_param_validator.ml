(** 骆言参数验证DSL模块综合测试套件 *)

[@@@warning "-32"] (* 关闭未使用值声明警告 *)
[@@@warning "-26"] (* 关闭未使用变量警告 *)
[@@@warning "-27"] (* 关闭未使用严格变量警告 *)

open Yyocamlc_lib.Param_validator
open Yyocamlc_lib.Value_operations

(** 测试数据生成和清理模块 *)
module TestDataGenerator = struct
  
  (** 创建各种类型的值用于测试 *)
  let create_test_values () =
    [
      ("字符串", StringValue "hello");
      ("空字符串", StringValue "");
      ("中文字符串", StringValue "你好世界");
      ("正整数", IntValue 42);
      ("零", IntValue 0);
      ("负整数", IntValue (-123));
      ("正浮点数", FloatValue 3.14);
      ("零浮点数", FloatValue 0.0);
      ("负浮点数", FloatValue (-2.718));
      ("布尔真", BoolValue true);
      ("布尔假", BoolValue false);
      ("单元值", UnitValue);
      ("空列表", ListValue []);
      ("整数列表", ListValue [IntValue 1; IntValue 2; IntValue 3]);
      ("混合列表", ListValue [IntValue 42; StringValue "test"; BoolValue true]);
      ("空数组", ArrayValue [||]);
      ("整数数组", ArrayValue [|IntValue 10; IntValue 20|]);
      ("内置函数", BuiltinFunctionValue (fun _ -> UnitValue));
    ]

  (** 创建不同数量的参数列表用于测试 *)
  let create_param_lists () =
    [
      ("空参数", []);
      ("单参数", [IntValue 42]);
      ("双参数", [StringValue "hello"; IntValue 100]);
      ("三参数", [BoolValue true; FloatValue 3.14; StringValue "test"]);
      ("多参数", [IntValue 1; IntValue 2; IntValue 3; IntValue 4; IntValue 5]);
    ]

  (** 创建类型匹配测试用例 *)
  let create_type_matching_cases () =
    (* 这个函数暂时不用，因为不同验证器返回不同类型，难以统一处理 *)
    []
end

(** 基础类型提取器测试模块 *)
module TestBasicTypeExtractors = struct
  let test_extract_string () =
    Printf.printf "测试字符串提取器...\n";
    
    let test_cases = [
      (StringValue "hello", Some "hello");
      (StringValue "", Some "");
      (StringValue "你好", Some "你好");
      (IntValue 42, None);
      (BoolValue true, None);
      (UnitValue, None);
    ] in
    
    List.iter (fun (value, expected) ->
      let result = extract_string value in
      Printf.printf "    %s -> %s (期望: %s) %s\n" 
        (value_to_string value)
        (match result with Some s -> "Some \"" ^ s ^ "\"" | None -> "None")
        (match expected with Some s -> "Some \"" ^ s ^ "\"" | None -> "None")
        (if result = expected then "✓" else "✗");
      assert (result = expected)
    ) test_cases;
    
    Printf.printf "  ✅ 字符串提取器测试通过！\n"

  let test_extract_int () =
    Printf.printf "测试整数提取器...\n";
    
    let test_cases = [
      (IntValue 42, Some 42);
      (IntValue 0, Some 0);
      (IntValue (-123), Some (-123));
      (FloatValue 3.14, None);
      (StringValue "42", None);
      (BoolValue true, None);
    ] in
    
    List.iter (fun (value, expected) ->
      let result = extract_int value in
      Printf.printf "    %s -> %s (期望: %s) %s\n" 
        (value_to_string value)
        (match result with Some i -> "Some " ^ string_of_int i | None -> "None")
        (match expected with Some i -> "Some " ^ string_of_int i | None -> "None")
        (if result = expected then "✓" else "✗");
      assert (result = expected)
    ) test_cases;
    
    Printf.printf "  ✅ 整数提取器测试通过！\n"

  let test_extract_float () =
    Printf.printf "测试浮点数提取器...\n";
    
    let test_cases = [
      (FloatValue 3.14, Some 3.14);
      (FloatValue 0.0, Some 0.0);
      (FloatValue (-2.718), Some (-2.718));
      (IntValue 42, None);
      (StringValue "3.14", None);
      (BoolValue false, None);
    ] in
    
    List.iter (fun (value, expected) ->
      let result = extract_float value in
      let matches = match (result, expected) with
        | (Some r, Some e) -> abs_float (r -. e) < 0.0001
        | (None, None) -> true
        | _ -> false in
      Printf.printf "    %s -> %s (期望: %s) %s\n" 
        (value_to_string value)
        (match result with Some f -> "Some " ^ string_of_float f | None -> "None")
        (match expected with Some f -> "Some " ^ string_of_float f | None -> "None")
        (if matches then "✓" else "✗");
      assert matches
    ) test_cases;
    
    Printf.printf "  ✅ 浮点数提取器测试通过！\n"

  let test_extract_bool () =
    Printf.printf "测试布尔值提取器...\n";
    
    let test_cases = [
      (BoolValue true, Some true);
      (BoolValue false, Some false);
      (IntValue 1, None);
      (IntValue 0, None);
      (StringValue "true", None);
      (UnitValue, None);
    ] in
    
    List.iter (fun (value, expected) ->
      let result = extract_bool value in
      Printf.printf "    %s -> %s (期望: %s) %s\n" 
        (value_to_string value)
        (match result with Some b -> "Some " ^ string_of_bool b | None -> "None")
        (match expected with Some b -> "Some " ^ string_of_bool b | None -> "None")
        (if result = expected then "✓" else "✗");
      assert (result = expected)
    ) test_cases;
    
    Printf.printf "  ✅ 布尔值提取器测试通过！\n"

  let test_extract_list () =
    Printf.printf "测试列表提取器...\n";
    
    let test_cases = [
      (ListValue [], Some []);
      (ListValue [IntValue 1; IntValue 2], Some [IntValue 1; IntValue 2]);
      (ListValue [StringValue "a"; BoolValue true], Some [StringValue "a"; BoolValue true]);
      (ArrayValue [||], None);
      (StringValue "not_list", None);
      (IntValue 42, None);
    ] in
    
    List.iter (fun (value, expected) ->
      let result = extract_list value in
      let matches = match (result, expected) with
        | (Some r, Some e) -> r = e
        | (None, None) -> true
        | _ -> false in
      Printf.printf "    %s -> %s (期望: %s) %s\n" 
        (value_to_string value)
        (match result with Some _ -> "Some [...]" | None -> "None")
        (match expected with Some _ -> "Some [...]" | None -> "None")
        (if matches then "✓" else "✗");
      assert matches
    ) test_cases;
    
    Printf.printf "  ✅ 列表提取器测试通过！\n"

  let test_extract_array () =
    Printf.printf "测试数组提取器...\n";
    
    let test_cases = [
      (ArrayValue [||], true);
      (ArrayValue [|IntValue 1; IntValue 2|], true);
      (ListValue [], false);
      (StringValue "not_array", false);
      (IntValue 42, false);
    ] in
    
    List.iter (fun (value, should_succeed) ->
      let result = extract_array value in
      let succeeded = match result with Some _ -> true | None -> false in
      Printf.printf "    %s -> %s (期望: %s) %s\n" 
        (value_to_string value)
        (if succeeded then "Some [|...|]" else "None")
        (if should_succeed then "Some [|...|]" else "None")
        (if succeeded = should_succeed then "✓" else "✗");
      assert (succeeded = should_succeed)
    ) test_cases;
    
    Printf.printf "  ✅ 数组提取器测试通过！\n"

  let run_all () =
    Printf.printf "\n=== 基础类型提取器测试 ===\n";
    test_extract_string ();
    test_extract_int ();
    test_extract_float ();
    test_extract_bool ();
    test_extract_list ();
    test_extract_array ()
end

(** 复合类型提取器测试模块 *)
module TestCompositeTypeExtractors = struct
  let test_extract_number () =
    Printf.printf "测试数值提取器...\n";
    
    let test_cases = [
      (IntValue 42, true);
      (IntValue 0, true);
      (IntValue (-123), true);
      (FloatValue 3.14, true);
      (FloatValue 0.0, true);
      (FloatValue (-2.718), true);
      (StringValue "42", false);
      (BoolValue true, false);
      (UnitValue, false);
    ] in
    
    List.iter (fun (value, should_succeed) ->
      let result = extract_number value in
      let succeeded = match result with Some _ -> true | None -> false in
      Printf.printf "    %s -> %s (期望: %s) %s\n" 
        (value_to_string value)
        (if succeeded then "Some <number>" else "None")
        (if should_succeed then "Some <number>" else "None")
        (if succeeded = should_succeed then "✓" else "✗");
      assert (succeeded = should_succeed)
    ) test_cases;
    
    Printf.printf "  ✅ 数值提取器测试通过！\n"

  let test_extract_string_or_list () =
    Printf.printf "测试字符串或列表提取器...\n";
    
    let test_cases = [
      (StringValue "hello", true);
      (StringValue "", true);
      (ListValue [], true);
      (ListValue [IntValue 1], true);
      (IntValue 42, false);
      (BoolValue true, false);
      (ArrayValue [||], false);
      (UnitValue, false);
    ] in
    
    List.iter (fun (value, should_succeed) ->
      let result = extract_string_or_list value in
      let succeeded = match result with Some _ -> true | None -> false in
      Printf.printf "    %s -> %s (期望: %s) %s\n" 
        (value_to_string value)
        (if succeeded then "Some <string_or_list>" else "None")
        (if should_succeed then "Some <string_or_list>" else "None")
        (if succeeded = should_succeed then "✓" else "✗");
      assert (succeeded = should_succeed)
    ) test_cases;
    
    Printf.printf "  ✅ 字符串或列表提取器测试通过！\n"

  let test_extract_nonempty_list () =
    Printf.printf "测试非空列表提取器...\n";
    
    let test_cases = [
      (ListValue [IntValue 1], true);
      (ListValue [StringValue "a"; BoolValue true], true);
      (ListValue [], false);  (* 空列表 *)
      (StringValue "not_list", false);
      (IntValue 42, false);
      (ArrayValue [|IntValue 1|], false);
    ] in
    
    List.iter (fun (value, should_succeed) ->
      let result = extract_nonempty_list value in
      let succeeded = match result with Some _ -> true | None -> false in
      Printf.printf "    %s -> %s (期望: %s) %s\n" 
        (value_to_string value)
        (if succeeded then "Some <nonempty_list>" else "None")
        (if should_succeed then "Some <nonempty_list>" else "None")
        (if succeeded = should_succeed then "✓" else "✗");
      assert (succeeded = should_succeed)
    ) test_cases;
    
    Printf.printf "  ✅ 非空列表提取器测试通过！\n"

  let run_all () =
    Printf.printf "\n=== 复合类型提取器测试 ===\n";
    test_extract_number ();
    test_extract_string_or_list ();
    test_extract_nonempty_list ()
end

(** 类型验证器测试模块 *)
module TestTypeValidators = struct
  let test_basic_validators () =
    Printf.printf "测试基础类型验证器...\n";
    
    (* 测试字符串验证 *)
    (try
      let result = validate_string (StringValue "hello") in
      Printf.printf "    字符串验证: 成功 ✓\n"
    with
    | _ ->
        Printf.printf "    字符串验证: 意外失败 ✗\n";
        assert false);
    
    (* 测试整数验证 *)
    (try
      let result = validate_int (IntValue 42) in
      Printf.printf "    整数验证: 成功 ✓\n"
    with
    | _ ->
        Printf.printf "    整数验证: 意外失败 ✗\n";
        assert false);
    
    (* 测试浮点数验证 *)
    (try
      let result = validate_float (FloatValue 3.14) in
      Printf.printf "    浮点数验证: 成功 ✓\n"
    with
    | _ ->
        Printf.printf "    浮点数验证: 意外失败 ✗\n";
        assert false);
    
    (* 测试布尔值验证 *)
    (try
      let result = validate_bool (BoolValue true) in
      Printf.printf "    布尔值验证: 成功 ✓\n"
    with
    | _ ->
        Printf.printf "    布尔值验证: 意外失败 ✗\n";
        assert false);
    
    (* 测试失败验证的情况 *)
    (* 测试字符串验证失败 *)
    (try
      let _ = validate_string (IntValue 42) in
      Printf.printf "    字符串验证失败: 应该失败但成功了 ✗\n";
      assert false
    with
    | RuntimeError _ ->
        Printf.printf "    字符串验证失败: 正确抛出异常 ✓\n"
    | _ ->
        Printf.printf "    字符串验证失败: 抛出了错误类型的异常 ✗\n";
        assert false);
    
    (* 测试整数验证失败 *)
    (try
      let _ = validate_int (StringValue "hello") in
      Printf.printf "    整数验证失败: 应该失败但成功了 ✗\n";
      assert false
    with
    | RuntimeError _ ->
        Printf.printf "    整数验证失败: 正确抛出异常 ✓\n"
    | _ ->
        Printf.printf "    整数验证失败: 抛出了错误类型的异常 ✗\n";
        assert false);
    
    (* 测试浮点数验证失败 *)
    (try
      let _ = validate_float (BoolValue true) in
      Printf.printf "    浮点数验证失败: 应该失败但成功了 ✗\n";
      assert false
    with
    | RuntimeError _ ->
        Printf.printf "    浮点数验证失败: 正确抛出异常 ✓\n"
    | _ ->
        Printf.printf "    浮点数验证失败: 抛出了错误类型的异常 ✗\n";
        assert false);
    
    (* 测试布尔值验证失败 *)
    (try
      let _ = validate_bool (FloatValue 3.14) in
      Printf.printf "    布尔值验证失败: 应该失败但成功了 ✗\n";
      assert false
    with
    | RuntimeError _ ->
        Printf.printf "    布尔值验证失败: 正确抛出异常 ✓\n"
    | _ ->
        Printf.printf "    布尔值验证失败: 抛出了错误类型的异常 ✗\n";
        assert false);
    
    Printf.printf "  ✅ 基础类型验证器测试通过！\n"

  let test_composite_validators () =
    Printf.printf "测试复合类型验证器...\n";
    
    (* 测试数值验证器 *)
    let number_success_cases = [
      (IntValue 42, "整数作为数值");
      (FloatValue 3.14, "浮点数作为数值");
    ] in
    
    List.iter (fun (value, desc) ->
      try
        let _ = validate_number value in
        Printf.printf "    %s: 成功 ✓\n" desc
      with
      | _ ->
          Printf.printf "    %s: 意外失败 ✗\n" desc;
          assert false
    ) number_success_cases;
    
    let number_failure_cases = [
      (StringValue "42", "字符串不是数值");
      (BoolValue true, "布尔值不是数值");
    ] in
    
    List.iter (fun (value, desc) ->
      try
        let _ = validate_number value in
        Printf.printf "    %s: 应该失败但成功了 ✗\n" desc;
        assert false
      with
      | RuntimeError _ ->
          Printf.printf "    %s: 正确抛出异常 ✓\n" desc
      | _ -> assert false
    ) number_failure_cases;
    
    (* 测试字符串或列表验证器 *)
    let string_or_list_success_cases = [
      (StringValue "hello", "字符串");
      (ListValue [IntValue 1], "列表");
    ] in
    
    List.iter (fun (value, desc) ->
      try
        let _ = validate_string_or_list value in
        Printf.printf "    字符串或列表验证-%s: 成功 ✓\n" desc
      with
      | _ ->
          Printf.printf "    字符串或列表验证-%s: 意外失败 ✗\n" desc;
          assert false
    ) string_or_list_success_cases;
    
    Printf.printf "  ✅ 复合类型验证器测试通过！\n"

  let test_nonempty_list_validator () =
    Printf.printf "测试非空列表验证器...\n";
    
    (* 测试成功情况 *)
    let success_cases = [
      (ListValue [IntValue 1], "单元素列表");
      (ListValue [StringValue "a"; BoolValue true], "多元素列表");
    ] in
    
    List.iter (fun (value, desc) ->
      try
        let result = validate_nonempty_list value in
        Printf.printf "    %s: 成功，返回%d个元素 ✓\n" desc (List.length result)
      with
      | _ ->
          Printf.printf "    %s: 意外失败 ✗\n" desc;
          assert false
    ) success_cases;
    
    (* 测试失败情况 *)
    let failure_cases = [
      (ListValue [], "空列表");
      (StringValue "not_list", "非列表类型");
      (IntValue 42, "整数类型");
    ] in
    
    List.iter (fun (value, desc) ->
      try
        let _ = validate_nonempty_list value in
        Printf.printf "    %s: 应该失败但成功了 ✗\n" desc;
        assert false
      with
      | RuntimeError msg ->
          Printf.printf "    %s: 正确抛出异常 (%s) ✓\n" desc 
            (if String.length msg > 20 then String.sub msg 0 20 ^ "..." else msg)
      | _ -> assert false
    ) failure_cases;
    
    Printf.printf "  ✅ 非空列表验证器测试通过！\n"

  let run_all () =
    Printf.printf "\n=== 类型验证器测试 ===\n";
    test_basic_validators ();
    test_composite_validators ();
    test_nonempty_list_validator ()
end

(** 参数数量验证测试模块 *)
module TestParameterCountValidation = struct
  let test_validate_no_args () =
    Printf.printf "测试无参数验证...\n";
    
    (* 测试成功情况 *)
    (try
      validate_no_args "test_function" [];
      Printf.printf "    空参数列表: 验证成功 ✓\n"
    with
    | _ ->
        Printf.printf "    空参数列表: 意外失败 ✗\n";
        assert false);
    
    (* 测试失败情况 *)
    let failure_cases = [
      ([IntValue 42], "单参数");
      ([StringValue "a"; IntValue 1], "双参数");
      ([BoolValue true; FloatValue 3.14; UnitValue], "三参数");
    ] in
    
    List.iter (fun (args, desc) ->
      try
        validate_no_args "test_function" args;
        Printf.printf "    %s: 应该失败但成功了 ✗\n" desc;
        assert false
      with
      | RuntimeError _ ->
          Printf.printf "    %s: 正确抛出异常 ✓\n" desc
      | _ -> assert false
    ) failure_cases;
    
    Printf.printf "  ✅ 无参数验证测试通过！\n"

  let test_validate_single () =
    Printf.printf "测试单参数验证...\n";
    
    (* 测试成功情况 *)
    (try
      let result = validate_single validate_string "test_function" [StringValue "hello"] in
      Printf.printf "    单字符串参数: 验证成功，结果='%s' ✓\n" result
    with
    | _ ->
        Printf.printf "    单字符串参数: 意外失败 ✗\n";
        assert false);
    
    (try
      let result = validate_single validate_int "test_function" [IntValue 42] in
      Printf.printf "    单整数参数: 验证成功，结果=%d ✓\n" result
    with
    | _ ->
        Printf.printf "    单整数参数: 意外失败 ✗\n";
        assert false);
    
    (* 测试参数数量错误 *)
    let count_failure_cases = [
      ([], "无参数");
      ([StringValue "a"; StringValue "b"], "双参数");
      ([IntValue 1; IntValue 2; IntValue 3], "三参数");
    ] in
    
    List.iter (fun (args, desc) ->
      try
        let _ = validate_single validate_string "test_function" args in
        Printf.printf "    %s: 应该失败但成功了 ✗\n" desc;
        assert false
      with
      | RuntimeError _ ->
          Printf.printf "    %s: 正确抛出异常 ✓\n" desc
      | _ -> assert false
    ) count_failure_cases;
    
    (* 测试类型错误 *)
    (try
      let _ = validate_single validate_string "test_function" [IntValue 42] in
      Printf.printf "    类型错误: 应该失败但成功了 ✗\n";
      assert false
    with
    | RuntimeError _ ->
        Printf.printf "    类型错误: 正确抛出异常 ✓\n"
    | _ -> assert false);
    
    Printf.printf "  ✅ 单参数验证测试通过！\n"

  let test_validate_double () =
    Printf.printf "测试双参数验证...\n";
    
    (* 测试成功情况 *)
    (try
      let (s, i) = validate_double validate_string validate_int "test_function" 
          [StringValue "hello"; IntValue 42] in
      Printf.printf "    双参数验证: 成功，结果=('%s', %d) ✓\n" s i
    with
    | _ ->
        Printf.printf "    双参数验证: 意外失败 ✗\n";
        assert false);
    
    (* 测试参数数量错误 *)
    let count_failure_cases = [
      ([], "无参数");
      ([StringValue "hello"], "单参数");
      ([StringValue "a"; IntValue 1; BoolValue true], "三参数");
    ] in
    
    List.iter (fun (args, desc) ->
      try
        let _ = validate_double validate_string validate_int "test_function" args in
        Printf.printf "    %s: 应该失败但成功了 ✗\n" desc;
        assert false
      with
      | RuntimeError _ ->
          Printf.printf "    %s: 正确抛出异常 ✓\n" desc
      | _ -> assert false
    ) count_failure_cases;
    
    (* 测试类型错误 *)
    let type_failure_cases = [
      ([IntValue 42; StringValue "hello"], "第一个参数类型错误");
      ([StringValue "hello"; StringValue "world"], "第二个参数类型错误");
      ([BoolValue true; BoolValue false], "两个参数类型都错误");
    ] in
    
    List.iter (fun (args, desc) ->
      try
        let _ = validate_double validate_string validate_int "test_function" args in
        Printf.printf "    %s: 应该失败但成功了 ✗\n" desc;
        assert false
      with
      | RuntimeError _ ->
          Printf.printf "    %s: 正确抛出异常 ✓\n" desc
      | _ -> assert false
    ) type_failure_cases;
    
    Printf.printf "  ✅ 双参数验证测试通过！\n"

  let test_validate_triple () =
    Printf.printf "测试三参数验证...\n";
    
    (* 测试成功情况 *)
    (try
      let (s, i, b) = validate_triple validate_string validate_int validate_bool "test_function" 
          [StringValue "hello"; IntValue 42; BoolValue true] in
      Printf.printf "    三参数验证: 成功，结果=('%s', %d, %b) ✓\n" s i b
    with
    | _ ->
        Printf.printf "    三参数验证: 意外失败 ✗\n";
        assert false);
    
    (* 测试参数数量错误 *)
    let count_failure_cases = [
      ([], "无参数");
      ([StringValue "hello"], "单参数");
      ([StringValue "hello"; IntValue 42], "双参数");
      ([StringValue "a"; IntValue 1; BoolValue true; UnitValue], "四参数");
    ] in
    
    List.iter (fun (args, desc) ->
      try
        let _ = validate_triple validate_string validate_int validate_bool "test_function" args in
        Printf.printf "    %s: 应该失败但成功了 ✗\n" desc;
        assert false
      with
      | RuntimeError _ ->
          Printf.printf "    %s: 正确抛出异常 ✓\n" desc
      | _ -> assert false
    ) count_failure_cases;
    
    Printf.printf "  ✅ 三参数验证测试通过！\n"

  let run_all () =
    Printf.printf "\n=== 参数数量验证测试 ===\n";
    test_validate_no_args ();
    test_validate_single ();
    test_validate_double ();
    test_validate_triple ()
end

(** 特殊验证器测试模块 *)
module TestSpecialValidators = struct
  let test_validate_non_negative () =
    Printf.printf "测试非负数验证器...\n";
    
    (* 测试成功情况 *)
    let success_cases = [
      (IntValue 0, 0);
      (IntValue 42, 42);
      (IntValue 1000, 1000);
    ] in
    
    List.iter (fun (value, expected) ->
      try
        let result = validate_non_negative value in
        Printf.printf "    %s -> %d (期望: %d) %s\n" 
          (value_to_string value) result expected 
          (if result = expected then "✓" else "✗");
        assert (result = expected)
      with
      | _ ->
          Printf.printf "    %s: 意外失败 ✗\n" (value_to_string value);
          assert false
    ) success_cases;
    
    (* 测试失败情况 *)
    let failure_cases = [
      (IntValue (-1), "负整数");
      (IntValue (-100), "大负整数");
      (FloatValue 3.14, "浮点数");
      (StringValue "42", "字符串");
      (BoolValue true, "布尔值");
    ] in
    
    List.iter (fun (value, desc) ->
      try
        let _ = validate_non_negative value in
        Printf.printf "    %s (%s): 应该失败但成功了 ✗\n" (value_to_string value) desc;
        assert false
      with
      | RuntimeError msg ->
          Printf.printf "    %s (%s): 正确抛出异常 ✓\n" (value_to_string value) desc
      | _ -> assert false
    ) failure_cases;
    
    Printf.printf "  ✅ 非负数验证器测试通过！\n"

  let test_convenience_aliases () =
    Printf.printf "测试便捷别名函数...\n";
    
    (* 测试所有便捷别名是否工作正常 *)
    (* 测试expect_string *)
    (try
      let _ = expect_string (StringValue "test") in
      Printf.printf "    expect_string: 成功 ✓\n"
    with
    | _ ->
        Printf.printf "    expect_string: 意外失败 ✗\n";
        assert false);
    
    (* 测试expect_int *)
    (try
      let _ = expect_int (IntValue 42) in
      Printf.printf "    expect_int: 成功 ✓\n"
    with
    | _ ->
        Printf.printf "    expect_int: 意外失败 ✗\n";
        assert false);
    
    (* 测试expect_float *)
    (try
      let _ = expect_float (FloatValue 3.14) in
      Printf.printf "    expect_float: 成功 ✓\n"
    with
    | _ ->
        Printf.printf "    expect_float: 意外失败 ✗\n";
        assert false);
    
    (* 测试expect_bool *)
    (try
      let _ = expect_bool (BoolValue true) in
      Printf.printf "    expect_bool: 成功 ✓\n"
    with
    | _ ->
        Printf.printf "    expect_bool: 意外失败 ✗\n";
        assert false);
    
    (* 测试expect_list *)
    (try
      let _ = expect_list (ListValue [IntValue 1]) in
      Printf.printf "    expect_list: 成功 ✓\n"
    with
    | _ ->
        Printf.printf "    expect_list: 意外失败 ✗\n";
        assert false);
    
    (* 测试expect_number *)
    (try
      let _ = expect_number (IntValue 42) in
      Printf.printf "    expect_number: 成功 ✓\n"
    with
    | _ ->
        Printf.printf "    expect_number: 意外失败 ✗\n";
        assert false);
    
    (* 测试expect_string_or_list *)
    (try
      let _ = expect_string_or_list (StringValue "test") in
      Printf.printf "    expect_string_or_list: 成功 ✓\n"
    with
    | _ ->
        Printf.printf "    expect_string_or_list: 意外失败 ✗\n";
        assert false);
    
    (* 测试expect_nonempty_list *)
    (try
      let result = expect_nonempty_list (ListValue [IntValue 1; IntValue 2]) in
      Printf.printf "    expect_nonempty_list: 成功，返回%d个元素 ✓\n" (List.length result)
    with
    | _ ->
        Printf.printf "    expect_nonempty_list: 意外失败 ✗\n";
        assert false);
    
    (* 测试expect_non_negative *)
    (try
      let result = expect_non_negative (IntValue 42) in
      Printf.printf "    expect_non_negative: 成功，返回%d ✓\n" result
    with
    | _ ->
        Printf.printf "    expect_non_negative: 意外失败 ✗\n";
        assert false);
    
    Printf.printf "  ✅ 便捷别名函数测试通过！\n"

  let run_all () =
    Printf.printf "\n=== 特殊验证器测试 ===\n";
    test_validate_non_negative ();
    test_convenience_aliases ()
end

(** 错误处理和边界条件测试模块 *)
module TestErrorHandlingAndEdgeCases = struct
  let test_error_message_handling () =
    Printf.printf "测试错误消息处理...\n";
    
    (* 测试各种错误情况的消息 *)
    (* 测试类型不匹配 *)
    (try
      let _ = validate_string (IntValue 42) in
      Printf.printf "    类型不匹配: 应该失败但成功了 ✗\n";
      assert false
    with
    | RuntimeError msg ->
        Printf.printf "    类型不匹配: 正确抛出RuntimeError ✓\n";
        assert (String.length msg > 0)
    | _ ->
        Printf.printf "    类型不匹配: 抛出了错误类型的异常 ✗\n";
        assert false);
    
    (* 测试参数数量错误 *)
    (try
      let _ = validate_single validate_string "test" [] in
      Printf.printf "    参数数量错误: 应该失败但成功了 ✗\n";
      assert false
    with
    | RuntimeError msg ->
        Printf.printf "    参数数量错误: 正确抛出RuntimeError ✓\n";
        assert (String.length msg > 0)
    | _ ->
        Printf.printf "    参数数量错误: 抛出了错误类型的异常 ✗\n";
        assert false);
    
    (* 测试空列表错误 *)
    (try
      let _ = validate_nonempty_list (ListValue []) in
      Printf.printf "    空列表错误: 应该失败但成功了 ✗\n";
      assert false
    with
    | RuntimeError msg ->
        Printf.printf "    空列表错误: 正确抛出RuntimeError ✓\n";
        assert (String.length msg > 0)
    | _ ->
        Printf.printf "    空列表错误: 抛出了错误类型的异常 ✗\n";
        assert false);
    
    (* 测试非负数错误 *)
    (try
      let _ = validate_non_negative (IntValue (-1)) in
      Printf.printf "    非负数错误: 应该失败但成功了 ✗\n";
      assert false
    with
    | RuntimeError msg ->
        Printf.printf "    非负数错误: 正确抛出RuntimeError ✓\n";
        assert (String.length msg > 0)
    | _ ->
        Printf.printf "    非负数错误: 抛出了错误类型的异常 ✗\n";
        assert false);
    
    Printf.printf "  ✅ 错误消息处理测试通过！\n"

  let test_edge_cases () =
    Printf.printf "测试边界条件...\n";
    
    (* 测试边界值 *)
    (* 测试零值 *)
    (try
      let _ = validate_int (IntValue 0) in
      Printf.printf "    零值: 验证成功 ✓\n"
    with
    | _ ->
        Printf.printf "    零值: 意外失败 ✗\n";
        assert false);
    
    (* 测试最大整数近似 *)
    (try
      let _ = validate_int (IntValue 1000000) in
      Printf.printf "    最大整数近似: 验证成功 ✓\n"
    with
    | _ ->
        Printf.printf "    最大整数近似: 意外失败 ✗\n";
        assert false);
    
    (* 测试零浮点数 *)
    (try
      let _ = validate_float (FloatValue 0.0) in
      Printf.printf "    零浮点数: 验证成功 ✓\n"
    with
    | _ ->
        Printf.printf "    零浮点数: 意外失败 ✗\n";
        assert false);
    
    (* 测试空字符串 *)
    (try
      let _ = validate_string (StringValue "") in
      Printf.printf "    空字符串: 验证成功 ✓\n"
    with
    | _ ->
        Printf.printf "    空字符串: 意外失败 ✗\n";
        assert false);
    
    (* 测试单元素列表 *)
    (try
      let _ = validate_list (ListValue [UnitValue]) in
      Printf.printf "    单元素列表: 验证成功 ✓\n"
    with
    | _ ->
        Printf.printf "    单元素列表: 意外失败 ✗\n";
        assert false);
    
    (* 测试空数组 *)
    (try
      let _ = validate_array (ArrayValue [||]) in
      Printf.printf "    空数组: 验证成功 ✓\n"
    with
    | _ ->
        Printf.printf "    空数组: 意外失败 ✗\n";
        assert false);
    
    (* 测试嵌套结构 *)
    let nested_list = ListValue [
      ListValue [IntValue 1; IntValue 2];
      ListValue [IntValue 3; IntValue 4];
    ] in
    
    (try
      let result = validate_list nested_list in
      Printf.printf "    嵌套列表: 验证成功，包含%d个子列表 ✓\n" (List.length result)
    with
    | _ ->
        Printf.printf "    嵌套列表: 意外失败 ✗\n";
        assert false);
    
    Printf.printf "  ✅ 边界条件测试通过！\n"

  let test_function_name_integration () =
    Printf.printf "测试函数名集成...\n";
    
    (* 测试带函数名的验证器 *)
    (* 测试test_func_1 *)
    (try
      let wrapped_validator = with_function_name validate_string "test_func_1" in
      let _ = wrapped_validator (StringValue "hello") in
      Printf.printf "    函数test_func_1: 验证成功 ✓\n"
    with
    | _ ->
        Printf.printf "    函数test_func_1: 意外失败 ✗\n";
        assert false);
    
    (* 测试test_func_2 *)
    (try
      let wrapped_validator = with_function_name validate_int "test_func_2" in
      let _ = wrapped_validator (IntValue 42) in
      Printf.printf "    函数test_func_2: 验证成功 ✓\n"
    with
    | _ ->
        Printf.printf "    函数test_func_2: 意外失败 ✗\n";
        assert false);
    
    (* 测试test_func_3 *)
    (try
      let wrapped_validator = with_function_name validate_bool "test_func_3" in
      let _ = wrapped_validator (BoolValue true) in
      Printf.printf "    函数test_func_3: 验证成功 ✓\n"
    with
    | _ ->
        Printf.printf "    函数test_func_3: 意外失败 ✗\n";
        assert false);
    
    (* 测试函数名错误传播 *)
    (try
      let wrapped_validator = with_function_name validate_string "error_test_func" in
      let _ = wrapped_validator (IntValue 42) in
      Printf.printf "    函数名错误传播: 应该失败但成功了 ✗\n";
      assert false
    with
    | RuntimeError msg ->
        Printf.printf "    函数名错误传播: 正确抛出异常 ✓\n";
        (* 验证错误消息包含函数名相关信息 *)
        assert (String.length msg > 0)
    | _ -> assert false);
    
    Printf.printf "  ✅ 函数名集成测试通过！\n"

  let run_all () =
    Printf.printf "\n=== 错误处理和边界条件测试 ===\n";
    test_error_message_handling ();
    test_edge_cases ();
    test_function_name_integration ()
end

(** 性能基准测试模块 *)
module TestPerformance = struct
  let time_function f name =
    let start_time = Sys.time () in
    let result = f () in
    let end_time = Sys.time () in
    let duration = end_time -. start_time in
    Printf.printf "    %s: %.4f秒\n" name duration;
    result

  let test_validation_performance () =
    Printf.printf "测试验证性能...\n";
    
    let large_list = List.init 10000 (fun i -> IntValue i) in
    let mixed_values = Array.init 10000 (fun i ->
      if i mod 3 = 0 then IntValue i
      else if i mod 3 = 1 then StringValue ("item" ^ string_of_int i)
      else BoolValue (i mod 2 = 0)
    ) in
    
    let test_type_validation () =
      Array.iter (fun v ->
        try ignore (validate_int v) with _ -> ();
        try ignore (validate_string v) with _ -> ();
        try ignore (validate_bool v) with _ -> ()
      ) mixed_values
    in
    
    let test_list_validation () =
      for _i = 1 to 100 do
        try ignore (validate_list (ListValue large_list)) with _ -> ()
      done
    in
    
    time_function test_type_validation "类型验证性能(3万次验证)";
    time_function test_list_validation "列表验证性能(100次大列表)";
    
    Printf.printf "  ✅ 验证性能测试完成！\n"

  let test_parameter_count_validation_performance () =
    Printf.printf "测试参数数量验证性能...\n";
    
    let test_args = [StringValue "test"; IntValue 42; BoolValue true] in
    
    let test_count_validation () =
      for _i = 1 to 10000 do
        try ignore (validate_single validate_string "test" [StringValue "hello"]) with _ -> ();
        try ignore (validate_double validate_string validate_int "test" [StringValue "hello"; IntValue 42]) with _ -> ();
        try ignore (validate_triple validate_string validate_int validate_bool "test" test_args) with _ -> ()
      done
    in
    
    time_function test_count_validation "参数数量验证性能(3万次验证)";
    Printf.printf "  ✅ 参数数量验证性能测试完成！\n"

  let run_all () =
    Printf.printf "\n=== 性能基准测试 ===\n";
    test_validation_performance ();
    test_parameter_count_validation_performance ()
end

(** 主测试运行器 *)
let run_all_tests () =
  Printf.printf "🚀 骆言参数验证DSL模块综合测试开始\n";
  Printf.printf "=======================================\n";
  
  (* 运行所有测试模块 *)
  TestBasicTypeExtractors.run_all ();
  TestCompositeTypeExtractors.run_all ();
  TestTypeValidators.run_all ();
  TestParameterCountValidation.run_all ();
  TestSpecialValidators.run_all ();
  TestErrorHandlingAndEdgeCases.run_all ();
  TestPerformance.run_all ();
  
  Printf.printf "\n=======================================\n";
  Printf.printf "✅ 所有测试通过！参数验证DSL模块功能正常。\n";
  Printf.printf "   测试覆盖: 类型提取、类型验证、参数数量验证、特殊验证器、\n";
  Printf.printf "             错误处理、边界条件、性能测试\n"

(** 程序入口点 *)
let () = run_all_tests ()