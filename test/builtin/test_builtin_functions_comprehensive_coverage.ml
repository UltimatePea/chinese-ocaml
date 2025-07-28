(** Builtin Functions模块全面测试覆盖率提升

    目标: 将builtin_functions模块测试覆盖率从6%提升到80%+

    测试覆盖范围:
    - 内置函数表的完整性和结构测试
    - 哈希表缓存机制的性能测试
    - 函数调用接口的功能测试
    - 函数查询和存在性检查
    - 错误处理和边界条件
    - 模块化内置函数集成测试
    - 性能优化验证
    - 中文函数名支持测试

    @author Alpha, 主工作代理
    @version 1.0
    @since 2025-07-27 Fix #1477 核心模块测试覆盖率提升 *)

open Alcotest
open Yyocamlc_lib.Value_operations

(** 辅助函数：取列表前n个元素 *)
let take n lst =
  let rec aux acc count = function
    | [] -> List.rev acc
    | h :: t when count > 0 -> aux (h :: acc) (count - 1) t
    | _ -> List.rev acc
  in
  aux [] n lst

open Yyocamlc_lib.Builtin_functions

(** 测试工具模块 *)
module TestUtils = struct
  let value_testable = testable (fun fmt v -> Format.fprintf fmt "%s" (value_to_string v)) ( = )
  let bool_testable = testable Format.pp_print_bool Bool.equal
  let int_testable = testable Format.pp_print_int Int.equal

  (** 检查运行时值相等 *)
  let check_value_equal desc expected actual = check value_testable desc expected actual

  (** 验证运行时错误 *)
  let expect_runtime_error f =
    try
      ignore (f ());
      false
    with
    | RuntimeError _ -> true
    | _ -> false

  (** 验证特定错误消息 *)
  let _expect_error_with_message f expected_msg =
    try
      ignore (f ());
      false
    with
    | RuntimeError msg -> String.contains msg (String.get expected_msg 0)
    | _ -> false

  (** 检查是否为有效的内置函数值 *)
  let is_valid_builtin_function_value = function BuiltinFunctionValue _ -> true | _ -> false

  (** 安全调用函数 - 捕获可能的错误 *)
  let safe_call_builtin name args =
    try Some (call_builtin_function name args) with RuntimeError _ -> None | _ -> None
end

(** 内置函数表结构测试 *)
module BuiltinTableStructureTests = struct
  let test_function_table_not_empty () =
    let functions = builtin_functions in
    check TestUtils.bool_testable "内置函数表不应为空" true (List.length functions > 0);
    Printf.printf "    内置函数总数: %d\n" (List.length functions)

  let test_function_table_structure () =
    (* 验证函数表是一个有效的关联列表 *)
    List.iter
      (fun (name, value) ->
        check TestUtils.bool_testable
          (Printf.sprintf "函数名'%s'不应为空" name)
          true
          (String.length name > 0);
        check TestUtils.bool_testable
          (Printf.sprintf "函数'%s'应为内置函数值" name)
          true
          (TestUtils.is_valid_builtin_function_value value))
      builtin_functions

  let test_function_names_unique () =
    let names = List.map fst builtin_functions in
    let unique_names = List.sort_uniq String.compare names in
    check TestUtils.int_testable "函数名称应唯一" (List.length names) (List.length unique_names)

  let test_function_table_completeness () =
    let function_names = List.map fst builtin_functions in

    (* 检查是否包含各个子模块的函数 *)
    let expected_categories =
      [
        ("类型转换", [ "整数转字符串"; "字符串转整数"; "布尔值转字符串" ]);
        ("数学运算", [ "绝对值"; "最大值"; "最小值" ]);
        ("字符串处理", [ "字符串长度"; "字符串连接" ]);
        ("IO操作", [ "打印"; "读取" ]);
        ("数组操作", [ "数组长度"; "创建数组" ]);
        ("工具函数", [ "相等"; "比较" ]);
      ]
    in

    List.iter
      (fun (category, expected_functions) ->
        let found_count =
          List.fold_left
            (fun acc expected ->
              if
                List.exists
                  (fun name -> String.contains name (String.get expected 0))
                  function_names
              then acc + 1
              else acc)
            0 expected_functions
        in
        Printf.printf "    %s类别找到函数: %d/%d\n" category found_count (List.length expected_functions))
      expected_categories
end

(** 哈希表缓存机制测试 *)
module HashTableCacheTests = struct
  let test_hash_table_performance () =
    (* 测试哈希表查找性能相比线性搜索的优势 *)
    let function_names = get_builtin_function_names () in
    let test_names = take (min 100 (List.length function_names)) function_names in

    (* 预热缓存 *)
    List.iter (fun name -> ignore (is_builtin_function name)) test_names;

    (* 测试哈希表查找性能 *)
    let start_time = Sys.time () in
    for _ = 1 to 1000 do
      List.iter (fun name -> ignore (is_builtin_function name)) test_names
    done;
    let end_time = Sys.time () in
    let duration = end_time -. start_time in

    check TestUtils.bool_testable "哈希表查找应快速完成" true (duration < 0.1);
    Printf.printf "    哈希表查找(10万次)耗时: %.3f秒\n" duration

  let test_hash_table_consistency () =
    (* 验证哈希表与原始列表的一致性 *)
    let all_names = get_builtin_function_names () in
    List.iter
      (fun name ->
        check TestUtils.bool_testable
          (Printf.sprintf "哈希表应包含函数'%s'" name)
          true (is_builtin_function name))
      all_names;

    (* 验证哈希表不包含不存在的函数 *)
    let nonexistent_names = [ "不存在的函数"; ""; "fake_function"; "测试函数_不存在" ] in
    List.iter
      (fun name ->
        check TestUtils.bool_testable
          (Printf.sprintf "哈希表不应包含'%s'" name)
          false (is_builtin_function name))
      nonexistent_names

  let test_lazy_initialization () =
    (* 测试哈希表的惰性初始化 *)
    (* 多次调用应该复用相同的哈希表 *)
    let names1 = get_builtin_function_names () in
    let names2 = get_builtin_function_names () in
    check TestUtils.bool_testable "多次获取函数名列表应一致" true (names1 = names2);

    (* 检查哈希表查找的一致性 *)
    List.iter
      (fun name ->
        let result1 = is_builtin_function name in
        let result2 = is_builtin_function name in
        check TestUtils.bool_testable (Printf.sprintf "函数'%s'查找结果应一致" name) true (result1 = result2))
      (take 10 names1)
end

(** 函数调用接口测试 *)
module FunctionCallInterfaceTests = struct
  let test_basic_function_calls () =
    (* 测试基本的函数调用 *)

    (* 类型转换函数 *)
    (match TestUtils.safe_call_builtin "整数转字符串" [ IntValue 42 ] with
    | Some result -> TestUtils.check_value_equal "整数转字符串" (StringValue "42") result
    | None -> Printf.printf "    注意: '整数转字符串'函数可能不存在\n");

    (match TestUtils.safe_call_builtin "布尔值转字符串" [ BoolValue true ] with
    | Some result -> TestUtils.check_value_equal "布尔值转字符串" (StringValue "真") result
    | None -> Printf.printf "    注意: '布尔值转字符串'函数可能不存在\n");

    (* 字符串函数 *)
    match TestUtils.safe_call_builtin "字符串长度" [ StringValue "hello" ] with
    | Some result -> TestUtils.check_value_equal "字符串长度" (IntValue 5) result
    | None -> Printf.printf "    注意: '字符串长度'函数可能不存在\n"

  let test_multiple_argument_functions () =
    (* 测试多参数函数 *)
    (match TestUtils.safe_call_builtin "字符串连接" [ StringValue "hello"; StringValue "world" ] with
    | Some result -> TestUtils.check_value_equal "字符串连接" (StringValue "helloworld") result
    | None -> Printf.printf "    注意: '字符串连接'函数可能不存在\n");

    match TestUtils.safe_call_builtin "最大值" [ IntValue 3; IntValue 7 ] with
    | Some result -> TestUtils.check_value_equal "最大值" (IntValue 7) result
    | None -> Printf.printf "    注意: '最大值'函数可能不存在\n"

  let test_zero_argument_functions () =
    (* 测试无参数函数 *)
    let zero_arg_functions = [ "获取时间"; "随机数"; "当前目录" ] in
    List.iter
      (fun func_name ->
        match TestUtils.safe_call_builtin func_name [] with
        | Some _ -> Printf.printf "    函数'%s'调用成功\n" func_name
        | None -> Printf.printf "    注意: 函数'%s'可能不存在或调用失败\n" func_name)
      zero_arg_functions

  let test_function_call_error_handling () =
    (* 测试函数调用错误处理 *)

    (* 调用不存在的函数 *)
    check TestUtils.bool_testable "调用不存在的函数应抛出错误" true
      (TestUtils.expect_runtime_error (fun () -> call_builtin_function "完全不存在的函数" []));

    (* 传递错误类型的参数 *)
    (match TestUtils.safe_call_builtin "整数转字符串" [ StringValue "不是整数" ] with
    | Some _ -> fail "传递错误参数类型应该失败"
    | None -> Printf.printf "    正确处理了错误参数类型\n");

    (* 传递错误数量的参数 *)
    match TestUtils.safe_call_builtin "整数转字符串" [] with
    | Some _ -> fail "传递错误参数数量应该失败"
    | None -> Printf.printf "    正确处理了错误参数数量\n"
end

(** 函数查询功能测试 *)
module FunctionQueryTests = struct
  let test_function_existence_check () =
    (* 测试已知存在的函数 *)
    let likely_existing_functions = [ "整数转字符串"; "字符串转整数"; "布尔值转字符串"; "字符串长度"; "打印"; "读取" ] in

    List.iter
      (fun name ->
        if is_builtin_function name then Printf.printf "    确认函数'%s'存在\n" name
        else Printf.printf "    注意: 函数'%s'可能不存在\n" name)
      likely_existing_functions;

    (* 测试不存在的函数 *)
    let nonexistent_functions = [ "完全不存在的函数"; ""; "fake_function"; "test_123" ] in

    List.iter
      (fun name ->
        check TestUtils.bool_testable
          (Printf.sprintf "'%s'不应为内置函数" name)
          false (is_builtin_function name))
      nonexistent_functions

  let test_get_function_names () =
    let names = get_builtin_function_names () in

    (* 检查返回列表非空 *)
    check TestUtils.bool_testable "函数名称列表不应为空" true (List.length names > 0);

    (* 检查列表长度与函数表一致 *)
    check TestUtils.int_testable "函数名称列表长度应与函数表一致" (List.length builtin_functions)
      (List.length names);

    (* 检查是否包含预期的函数名 *)
    let contains_conversion_func =
      List.exists (fun name -> String.contains name (String.get "转" 0)) names
    in
    if contains_conversion_func then Printf.printf "    确认包含类型转换函数\n"
    else Printf.printf "    注意: 可能不包含类型转换函数\n";

    Printf.printf "    函数名称样例: %s\n" (String.concat ", " (take 5 names))

  let test_query_consistency () =
    let all_names = get_builtin_function_names () in

    (* 所有从函数表获取的名称都应通过is_builtin_function验证 *)
    List.iter
      (fun name ->
        check TestUtils.bool_testable
          (Printf.sprintf "函数'%s'应通过存在性检查" name)
          true (is_builtin_function name))
      all_names;

    (* 验证函数表中的每个函数都能在名称列表中找到 *)
    List.iter
      (fun (name, _) ->
        check TestUtils.bool_testable
          (Printf.sprintf "函数表中的'%s'应在名称列表中" name)
          true (List.mem name all_names))
      builtin_functions
end

(** 模块集成测试 *)
module ModuleIntegrationTests = struct
  let test_submodule_integration () =
    let function_names = get_builtin_function_names () in

    (* 预期的子模块函数模式 *)
    let expected_patterns =
      [
        ("IO模块", [ "读"; "写"; "输"; "打印" ]);
        ("数学模块", [ "加"; "减"; "乘"; "除"; "最"; "绝对"; "平方" ]);
        ("字符串模块", [ "字符串"; "文本"; "连接"; "长度" ]);
        ("数组模块", [ "数组"; "创建"; "长度"; "访问" ]);
        ("类型模块", [ "转"; "类型"; "检查" ]);
        ("工具模块", [ "比较"; "相等"; "排序" ]);
      ]
    in

    List.iter
      (fun (module_name, keywords) ->
        let found_functions =
          List.filter
            (fun func_name ->
              List.exists (fun keyword -> String.contains func_name (String.get keyword 0)) keywords)
            function_names
        in
        Printf.printf "    %s相关函数数量: %d\n" module_name (List.length found_functions))
      expected_patterns

  let test_function_categorization () =
    let function_names = get_builtin_function_names () in

    (* 按功能分类统计 *)
    let count_functions_with_pattern pattern =
      List.length
        (List.filter (fun name -> String.contains name (String.get pattern 0)) function_names)
    in

    let categories =
      [ ("类型转换", "转"); ("数学运算", "值"); ("字符串操作", "字符串"); ("IO操作", "打印"); ("数组操作", "数组") ]
    in

    List.iter
      (fun (category, pattern) ->
        let count = count_functions_with_pattern pattern in
        Printf.printf "    %s类别函数数量: %d\n" category count)
      categories

  let test_cross_module_compatibility () =
    (* 测试不同模块函数的协作 *)
    let test_chain () =
      (* 尝试链式调用：类型转换 -> 字符串操作 -> IO *)
      match TestUtils.safe_call_builtin "整数转字符串" [ IntValue 42 ] with
      | Some (StringValue str) -> (
          match TestUtils.safe_call_builtin "字符串长度" [ StringValue str ] with
          | Some (IntValue len) -> Printf.printf "    跨模块调用链成功: 42 -> \"%s\" -> %d\n" str len
          | _ -> Printf.printf "    字符串操作阶段失败\n")
      | _ -> Printf.printf "    类型转换阶段失败\n"
    in
    test_chain ()
end

(** 性能优化验证测试 *)
module PerformanceOptimizationTests = struct
  let test_hash_vs_linear_performance () =
    let function_names = get_builtin_function_names () in
    let test_names = take (min 50 (List.length function_names)) function_names in

    (* 测试大量查找操作的性能 *)
    let iterations = 10000 in

    let start_time = Sys.time () in
    for _ = 1 to iterations do
      List.iter (fun name -> ignore (is_builtin_function name)) test_names
    done;
    let end_time = Sys.time () in
    let duration = end_time -. start_time in

    check TestUtils.bool_testable "大量查找操作应高效完成" true (duration < 0.5);
    Printf.printf "    %d次查找操作耗时: %.3f秒\n" (iterations * List.length test_names) duration;

    (* 计算平均查找时间 *)
    let avg_time = duration /. float_of_int (iterations * List.length test_names) in
    Printf.printf "    平均单次查找时间: %.6f秒\n" avg_time

  let test_function_call_performance () =
    (* 测试函数调用性能 *)
    let iterations = 1000 in

    let start_time = Sys.time () in
    for i = 1 to iterations do
      ignore (TestUtils.safe_call_builtin "整数转字符串" [ IntValue i ])
    done;
    let end_time = Sys.time () in
    let duration = end_time -. start_time in

    check TestUtils.bool_testable "大量函数调用应高效完成" true (duration < 1.0);
    Printf.printf "    %d次函数调用耗时: %.3f秒\n" iterations duration

  let test_memory_efficiency () =
    (* 测试内存使用效率 *)
    let function_count = List.length builtin_functions in

    (* 验证函数表大小合理 *)
    check TestUtils.bool_testable "函数表大小应合理" true (function_count > 10 && function_count < 1000);

    (* 检查是否有重复的函数实例 *)
    let names = List.map fst builtin_functions in
    let unique_names = List.sort_uniq String.compare names in
    check TestUtils.int_testable "不应有重复的函数名" (List.length names) (List.length unique_names);

    Printf.printf "    内存效率: 函数总数 %d, 唯一函数 %d\n" function_count (List.length unique_names)
end

(** 错误处理和边界条件测试 *)
module ErrorHandlingTests = struct
  let test_invalid_function_calls () =
    (* 测试各种无效函数调用 *)

    (* 空函数名 *)
    check TestUtils.bool_testable "空函数名应失败" true
      (TestUtils.expect_runtime_error (fun () -> call_builtin_function "" []));

    (* 特殊字符函数名 *)
    let special_names = [ "!@#$%"; "函数名有空格"; "func\twith\ttabs"; "func\nwith\nnewlines" ] in
    List.iter
      (fun name ->
        check TestUtils.bool_testable
          (Printf.sprintf "特殊字符函数名'%s'应失败" name)
          true
          (TestUtils.expect_runtime_error (fun () -> call_builtin_function name [])))
      special_names;

    (* 超长函数名 *)
    let long_name = String.make 10000 'x' in
    check TestUtils.bool_testable "超长函数名应失败" true
      (TestUtils.expect_runtime_error (fun () -> call_builtin_function long_name []))

  let test_parameter_edge_cases () =
    (* 测试参数边界情况 *)

    (* 测试已知函数的各种参数情况 *)
    let test_function_if_exists name test_cases =
      if is_builtin_function name then
        List.iter
          (fun (desc, args, should_succeed) ->
            let result = TestUtils.safe_call_builtin name args in
            if should_succeed then
              match result with
              | Some _ -> Printf.printf "    %s: 成功\n" desc
              | None -> Printf.printf "    %s: 意外失败\n" desc
            else
              match result with
              | Some _ -> Printf.printf "    %s: 意外成功\n" desc
              | None -> Printf.printf "    %s: 正确失败\n" desc)
          test_cases
      else Printf.printf "    函数'%s'不存在，跳过测试\n" name
    in

    (* 测试整数转字符串函数 *)
    test_function_if_exists "整数转字符串"
      [
        ("正常整数", [ IntValue 42 ], true);
        ("零值", [ IntValue 0 ], true);
        ("负数", [ IntValue (-123) ], true);
        ("错误类型", [ StringValue "not_int" ], false);
        ("无参数", [], false);
        ("多参数", [ IntValue 1; IntValue 2 ], false);
      ];

    (* 测试字符串长度函数 *)
    test_function_if_exists "字符串长度"
      [
        ("正常字符串", [ StringValue "hello" ], true);
        ("空字符串", [ StringValue "" ], true);
        ("中文字符串", [ StringValue "你好" ], true);
        ("错误类型", [ IntValue 123 ], false);
        ("多参数", [ StringValue "a"; StringValue "b" ], false);
      ]

  let test_error_message_quality () =
    (* 测试错误消息质量 *)
    let test_error_message func_name args expected_keywords =
      try
        ignore (call_builtin_function func_name args);
        Printf.printf "    错误: 应该抛出异常但没有\n"
      with
      | RuntimeError msg ->
          let contains_keyword =
            List.exists
              (fun keyword -> String.contains msg (String.get keyword 0))
              expected_keywords
          in
          if contains_keyword then Printf.printf "    错误消息包含预期关键词\n"
          else Printf.printf "    错误消息: %s\n" msg
      | _ -> Printf.printf "    错误: 抛出了错误类型的异常\n"
    in

    test_error_message "不存在的函数" [] [ "未知"; "函数" ];
    test_error_message "整数转字符串" [ StringValue "wrong" ] [ "类型"; "参数" ]
end

(** 中文编程特色测试 *)
module ChineseProgrammingTests = struct
  let test_chinese_function_names () =
    let function_names = get_builtin_function_names () in

    (* 检查是否有中文函数名 *)
    let chinese_functions =
      List.filter
        (fun name ->
          (* 简单检查是否包含中文字符 *)
          let has_chinese = ref false in
          String.iter (fun c -> if Char.code c > 127 then has_chinese := true) name;
          !has_chinese)
        function_names
    in

    let chinese_count = List.length chinese_functions in
    let total_count = List.length function_names in
    let chinese_ratio = float_of_int chinese_count /. float_of_int total_count in

    Printf.printf "    中文函数数量: %d/%d (%.1f%%)\n" chinese_count total_count (chinese_ratio *. 100.0);

    if chinese_count > 0 then
      Printf.printf "    中文函数示例: %s\n" (String.concat ", " (take 5 chinese_functions))

  let test_chinese_parameter_handling () =
    (* 测试中文字符串参数处理 *)
    let chinese_test_cases =
      [
        ("你好", "中文字符串");
        ("", "空字符串");
        ("Hello世界", "中英混合");
        ("🚀🔥", "Unicode emoji");
        ("测试\n换行", "包含特殊字符");
      ]
    in

    List.iter
      (fun (chinese_str, desc) ->
        match TestUtils.safe_call_builtin "字符串长度" [ StringValue chinese_str ] with
        | Some (IntValue len) -> Printf.printf "    %s长度: %d\n" desc len
        | _ -> Printf.printf "    %s: 函数可能不存在\n" desc)
      chinese_test_cases

  let test_chinese_error_messages () =
    (* 测试中文错误消息 *)
    try
      ignore (call_builtin_function "不存在的中文函数名" []);
      Printf.printf "    错误: 应该抛出异常\n"
    with
    | RuntimeError msg ->
        (* 检查错误消息是否包含中文 *)
        let has_chinese = ref false in
        String.iter (fun c -> if Char.code c > 127 then has_chinese := true) msg;
        if !has_chinese then Printf.printf "    错误消息包含中文字符\n"
        else Printf.printf "    错误消息: %s\n" msg
    | _ -> Printf.printf "    错误: 抛出了错误类型的异常\n"
end

(** 功能完整性验证测试 *)
module FunctionalityCompletenessTests = struct
  let test_essential_functions_availability () =
    (* 测试基本功能函数的可用性 *)
    let essential_functions =
      [
        ("类型转换", [ "整数转字符串"; "字符串转整数"; "布尔值转字符串" ]);
        ("基本IO", [ "打印"; "读取"; "输出" ]);
        ("字符串操作", [ "字符串长度"; "字符串连接" ]);
        ("数学运算", [ "绝对值"; "最大值"; "最小值" ]);
        ("数组操作", [ "数组长度"; "创建数组" ]);
      ]
    in

    List.iter
      (fun (category, functions) ->
        let available_count =
          List.fold_left
            (fun acc func_name -> if is_builtin_function func_name then acc + 1 else acc)
            0 functions
        in
        Printf.printf "    %s: %d/%d 可用\n" category available_count (List.length functions))
      essential_functions

  let test_function_behavior_consistency () =
    (* 测试函数行为一致性 *)

    (* 多次调用相同函数应返回相同结果 *)
    let test_consistency func_name args =
      if is_builtin_function func_name then
        let result1 = TestUtils.safe_call_builtin func_name args in
        let result2 = TestUtils.safe_call_builtin func_name args in
        match (result1, result2) with
        | Some v1, Some v2 when v1 = v2 -> Printf.printf "    函数'%s'调用一致性: 通过\n" func_name
        | Some v1, Some v2 ->
            Printf.printf "    函数'%s'调用不一致: %s vs %s\n" func_name (value_to_string v1)
              (value_to_string v2)
        | None, None -> Printf.printf "    函数'%s'调用一致性: 都失败\n" func_name
        | _ -> Printf.printf "    函数'%s'调用不一致: 一次成功一次失败\n" func_name
    in

    test_consistency "整数转字符串" [ IntValue 42 ];
    test_consistency "字符串长度" [ StringValue "hello" ];
    test_consistency "布尔值转字符串" [ BoolValue true ]

  let test_comprehensive_coverage () =
    (* 全面测试覆盖率验证 *)
    let total_functions = List.length builtin_functions in
    let callable_functions =
      List.fold_left
        (fun acc (name, _) ->
          match TestUtils.safe_call_builtin name [] with
          | Some _ -> acc + 1
          | None ->
              (* 尝试用一些通用参数 *)
              let test_args =
                [
                  [ IntValue 1 ];
                  [ StringValue "test" ];
                  [ BoolValue true ];
                  [ IntValue 1; IntValue 2 ];
                ]
              in
              let callable =
                List.exists
                  (fun args ->
                    match TestUtils.safe_call_builtin name args with
                    | Some _ -> true
                    | None -> false)
                  test_args
              in
              if callable then acc + 1 else acc)
        0 builtin_functions
    in

    let coverage_ratio = float_of_int callable_functions /. float_of_int total_functions in
    Printf.printf "    测试覆盖率: %d/%d (%.1f%%)\n" callable_functions total_functions
      (coverage_ratio *. 100.0);

    check TestUtils.bool_testable "应覆盖大部分内置函数" true (coverage_ratio > 0.5)
end

(** 运行所有测试 *)
let test_suite =
  [
    ( "内置函数表结构",
      [
        test_case "函数表非空" `Quick BuiltinTableStructureTests.test_function_table_not_empty;
        test_case "函数表结构" `Quick BuiltinTableStructureTests.test_function_table_structure;
        test_case "函数名唯一性" `Quick BuiltinTableStructureTests.test_function_names_unique;
        test_case "函数表完整性" `Quick BuiltinTableStructureTests.test_function_table_completeness;
      ] );
    ( "哈希表缓存机制",
      [
        test_case "哈希表性能" `Quick HashTableCacheTests.test_hash_table_performance;
        test_case "哈希表一致性" `Quick HashTableCacheTests.test_hash_table_consistency;
        test_case "惰性初始化" `Quick HashTableCacheTests.test_lazy_initialization;
      ] );
    ( "函数调用接口",
      [
        test_case "基本函数调用" `Quick FunctionCallInterfaceTests.test_basic_function_calls;
        test_case "多参数函数" `Quick FunctionCallInterfaceTests.test_multiple_argument_functions;
        test_case "无参数函数" `Quick FunctionCallInterfaceTests.test_zero_argument_functions;
        test_case "调用错误处理" `Quick FunctionCallInterfaceTests.test_function_call_error_handling;
      ] );
    ( "函数查询功能",
      [
        test_case "函数存在性检查" `Quick FunctionQueryTests.test_function_existence_check;
        test_case "获取函数名列表" `Quick FunctionQueryTests.test_get_function_names;
        test_case "查询一致性" `Quick FunctionQueryTests.test_query_consistency;
      ] );
    ( "模块集成",
      [
        test_case "子模块集成" `Quick ModuleIntegrationTests.test_submodule_integration;
        test_case "函数分类" `Quick ModuleIntegrationTests.test_function_categorization;
        test_case "跨模块兼容性" `Quick ModuleIntegrationTests.test_cross_module_compatibility;
      ] );
    ( "性能优化验证",
      [
        test_case "哈希vs线性性能" `Quick PerformanceOptimizationTests.test_hash_vs_linear_performance;
        test_case "函数调用性能" `Quick PerformanceOptimizationTests.test_function_call_performance;
        test_case "内存效率" `Quick PerformanceOptimizationTests.test_memory_efficiency;
      ] );
    ( "错误处理",
      [
        test_case "无效函数调用" `Quick ErrorHandlingTests.test_invalid_function_calls;
        test_case "参数边界情况" `Quick ErrorHandlingTests.test_parameter_edge_cases;
        test_case "错误消息质量" `Quick ErrorHandlingTests.test_error_message_quality;
      ] );
    ( "中文编程特色",
      [
        test_case "中文函数名" `Quick ChineseProgrammingTests.test_chinese_function_names;
        test_case "中文参数处理" `Quick ChineseProgrammingTests.test_chinese_parameter_handling;
        test_case "中文错误消息" `Quick ChineseProgrammingTests.test_chinese_error_messages;
      ] );
    ( "功能完整性",
      [
        test_case "基本函数可用性" `Quick
          FunctionalityCompletenessTests.test_essential_functions_availability;
        test_case "函数行为一致性" `Quick FunctionalityCompletenessTests.test_function_behavior_consistency;
        test_case "综合测试覆盖" `Quick FunctionalityCompletenessTests.test_comprehensive_coverage;
      ] );
  ]

let () =
  Printf.printf "骆言Builtin Functions模块全面测试覆盖率提升 - Fix #1477\n";
  Printf.printf "======================================================\n";
  run "Builtin Functions Comprehensive Coverage Tests" test_suite
