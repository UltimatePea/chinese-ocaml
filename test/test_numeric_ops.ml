(** 骆言数值操作模块综合测试套件 *)

[@@@warning "-32"] (* 关闭未使用值声明警告 *)
[@@@warning "-26"] (* 关闭未使用变量警告 *)
[@@@warning "-27"] (* 关闭未使用严格变量警告 *)

open Yyocamlc_lib.Numeric_ops
open Yyocamlc_lib.Value_operations

(** 测试数据生成和清理模块 *)
module TestDataGenerator = struct
  (** 创建各种数值类型测试数据 *)
  let create_numeric_values () =
    [
      ("整数零", IntValue 0);
      ("正整数", IntValue 42);
      ("负整数", IntValue (-123));
      ("浮点数零", FloatValue 0.0);
      ("正浮点数", FloatValue 3.14);
      ("负浮点数", FloatValue (-2.718));
      ("大整数", IntValue 1000000);
      ("小浮点数", FloatValue 0.001);
    ]

  (** 创建非数值类型测试数据 *)
  let create_non_numeric_values () =
    [
      ("字符串", StringValue "hello");
      ("布尔值真", BoolValue true);
      ("布尔值假", BoolValue false);
      ("单元值", UnitValue);
      ("列表", ListValue [ IntValue 1; IntValue 2 ]);
      ("空字符串", StringValue "");
    ]

  (** 创建混合类型测试数据 *)
  let create_mixed_lists () =
    [
      ("纯整数列表", [ IntValue 1; IntValue 2; IntValue 3 ]);
      ("纯浮点数列表", [ FloatValue 1.0; FloatValue 2.5; FloatValue 3.14 ]);
      ("混合数值列表", [ IntValue 10; FloatValue 2.5; IntValue 5 ]);
      ("空列表", []);
      ("单元素整数", [ IntValue 42 ]);
      ("单元素浮点数", [ FloatValue 3.14 ]);
      ("包含非数值", [ IntValue 1; StringValue "hello"; IntValue 2 ]);
      ("全非数值", [ StringValue "a"; BoolValue true; UnitValue ]);
    ]

  (** 创建数值二元操作测试用例 *)
  let create_binary_op_test_cases () =
    [
      ("两个正整数", IntValue 10, IntValue 5);
      ("两个负整数", IntValue (-3), IntValue (-7));
      ("正负整数", IntValue 8, IntValue (-3));
      ("两个正浮点数", FloatValue 4.5, FloatValue 2.3);
      ("两个负浮点数", FloatValue (-1.5), FloatValue (-2.7));
      ("正负浮点数", FloatValue 6.8, FloatValue (-1.2));
      ("整数与浮点数", IntValue 10, FloatValue 2.5);
      ("浮点数与整数", FloatValue 7.2, IntValue 3);
      ("零值操作", IntValue 0, FloatValue 0.0);
      ("大数值操作", IntValue 1000000, FloatValue 0.000001);
    ]
end

(** 数值类型检查测试模块 *)
module TestNumericTypeChecking = struct
  let test_is_numeric () =
    Printf.printf "测试数值类型检查...\n";

    (* 测试数值类型 *)
    let numeric_cases =
      [
        (IntValue 42, true);
        (IntValue 0, true);
        (IntValue (-123), true);
        (FloatValue 3.14, true);
        (FloatValue 0.0, true);
        (FloatValue (-2.718), true);
      ]
    in

    List.iter
      (fun (value, expected) ->
        let result = is_numeric value in
        Printf.printf "    %s -> %b (期望: %b) %s\n" (value_to_string value) result expected
          (if result = expected then "✓" else "✗");
        assert (result = expected))
      numeric_cases;

    (* 测试非数值类型 *)
    let non_numeric_cases =
      [
        (StringValue "hello", false);
        (BoolValue true, false);
        (BoolValue false, false);
        (UnitValue, false);
        (ListValue [ IntValue 1 ], false);
      ]
    in

    List.iter
      (fun (value, expected) ->
        let result = is_numeric value in
        Printf.printf "    %s -> %b (期望: %b) %s\n" (value_to_string value) result expected
          (if result = expected then "✓" else "✗");
        assert (result = expected))
      non_numeric_cases;

    Printf.printf "  ✅ 数值类型检查测试通过！\n"

  let test_validate_numeric_list () =
    Printf.printf "测试数值列表验证...\n";

    (* 测试有效的数值列表 *)
    let valid_lists =
      [
        ([ IntValue 1; IntValue 2; IntValue 3 ], "纯整数列表");
        ([ FloatValue 1.0; FloatValue 2.5 ], "纯浮点数列表");
        ([ IntValue 10; FloatValue 2.5; IntValue 5 ], "混合数值列表");
        ([], "空列表");
        ([ IntValue 42 ], "单元素列表");
      ]
    in

    List.iter
      (fun (lst, desc) ->
        try
          let result = validate_numeric_list lst "test_function" in
          Printf.printf "    %s: 验证通过 ✓\n" desc;
          assert (result = lst)
        with _ ->
          Printf.printf "    %s: 意外失败 ✗\n" desc;
          assert false)
      valid_lists;

    (* 测试无效的数值列表 *)
    let invalid_lists =
      [
        ([ IntValue 1; StringValue "hello"; IntValue 2 ], "包含字符串");
        ([ BoolValue true; IntValue 1 ], "包含布尔值");
        ([ UnitValue; FloatValue 2.5 ], "包含单元值");
        ([ StringValue "a"; BoolValue true ], "全非数值");
      ]
    in

    List.iter
      (fun (lst, desc) ->
        try
          let _ = validate_numeric_list lst "test_function" in
          Printf.printf "    %s: 应该失败但通过了 ✗\n" desc;
          assert false
        with _ -> Printf.printf "    %s: 正确拒绝 ✓\n" desc)
      invalid_lists;

    Printf.printf "  ✅ 数值列表验证测试通过！\n"

  let run_all () =
    Printf.printf "\n=== 数值类型检查测试 ===\n";
    test_is_numeric ();
    test_validate_numeric_list ()
end

(** 数值二元操作测试模块 *)
module TestNumericBinaryOperations = struct
  let test_add_operation () =
    Printf.printf "测试加法操作...\n";

    let test_cases =
      [
        (IntValue 10, IntValue 5, IntValue 15);
        (FloatValue 3.5, FloatValue 2.1, FloatValue 5.6);
        (IntValue 7, FloatValue 2.3, FloatValue 9.3);
        (FloatValue 4.7, IntValue 3, FloatValue 7.7);
        (IntValue 0, IntValue 0, IntValue 0);
        (FloatValue 0.0, FloatValue 0.0, FloatValue 0.0);
        (IntValue (-5), IntValue 3, IntValue (-2));
        (FloatValue (-2.5), FloatValue 1.5, FloatValue (-1.0));
      ]
    in

    List.iter
      (fun (v1, v2, expected) ->
        let result = apply_numeric_binary_op add_op v1 v2 in
        let matches =
          match (result, expected) with
          | IntValue r, IntValue e -> r = e
          | FloatValue r, FloatValue e -> abs_float (r -. e) < 0.0001
          | _ -> false
        in
        Printf.printf "    %s + %s = %s (期望: %s) %s\n" (value_to_string v1) (value_to_string v2)
          (value_to_string result) (value_to_string expected)
          (if matches then "✓" else "✗");
        assert matches)
      test_cases;

    Printf.printf "  ✅ 加法操作测试通过！\n"

  let test_multiply_operation () =
    Printf.printf "测试乘法操作...\n";

    let test_cases =
      [
        (IntValue 6, IntValue 7, IntValue 42);
        (FloatValue 2.5, FloatValue 4.0, FloatValue 10.0);
        (IntValue 3, FloatValue 2.5, FloatValue 7.5);
        (FloatValue 1.5, IntValue 4, FloatValue 6.0);
        (IntValue 0, IntValue 100, IntValue 0);
        (FloatValue 0.0, FloatValue 3.14, FloatValue 0.0);
        (IntValue (-3), IntValue 4, IntValue (-12));
        (FloatValue (-2.0), FloatValue (-1.5), FloatValue 3.0);
      ]
    in

    List.iter
      (fun (v1, v2, expected) ->
        let result = apply_numeric_binary_op multiply_op v1 v2 in
        let matches =
          match (result, expected) with
          | IntValue r, IntValue e -> r = e
          | FloatValue r, FloatValue e -> abs_float (r -. e) < 0.0001
          | _ -> false
        in
        Printf.printf "    %s * %s = %s (期望: %s) %s\n" (value_to_string v1) (value_to_string v2)
          (value_to_string result) (value_to_string expected)
          (if matches then "✓" else "✗");
        assert matches)
      test_cases;

    Printf.printf "  ✅ 乘法操作测试通过！\n"

  let test_max_operation () =
    Printf.printf "测试最大值操作...\n";

    let test_cases =
      [
        (IntValue 10, IntValue 5, IntValue 10);
        (IntValue 3, IntValue 8, IntValue 8);
        (FloatValue 3.5, FloatValue 2.1, FloatValue 3.5);
        (FloatValue 1.9, FloatValue 4.2, FloatValue 4.2);
        (IntValue 7, FloatValue 2.3, FloatValue 7.0);
        (IntValue 2, FloatValue 5.7, FloatValue 5.7);
        (FloatValue 4.7, IntValue 3, FloatValue 4.7);
        (FloatValue 1.2, IntValue 6, FloatValue 6.0);
        (IntValue (-3), IntValue (-7), IntValue (-3));
        (FloatValue (-2.5), FloatValue (-1.5), FloatValue (-1.5));
      ]
    in

    List.iter
      (fun (v1, v2, expected) ->
        let result = apply_numeric_binary_op max_op v1 v2 in
        let matches =
          match (result, expected) with
          | IntValue r, IntValue e -> r = e
          | FloatValue r, FloatValue e -> abs_float (r -. e) < 0.0001
          | _ -> false
        in
        Printf.printf "    max(%s, %s) = %s (期望: %s) %s\n" (value_to_string v1) (value_to_string v2)
          (value_to_string result) (value_to_string expected)
          (if matches then "✓" else "✗");
        assert matches)
      test_cases;

    Printf.printf "  ✅ 最大值操作测试通过！\n"

  let test_min_operation () =
    Printf.printf "测试最小值操作...\n";

    let test_cases =
      [
        (IntValue 10, IntValue 5, IntValue 5);
        (IntValue 3, IntValue 8, IntValue 3);
        (FloatValue 3.5, FloatValue 2.1, FloatValue 2.1);
        (FloatValue 1.9, FloatValue 4.2, FloatValue 1.9);
        (IntValue 7, FloatValue 2.3, FloatValue 2.3);
        (IntValue 2, FloatValue 5.7, FloatValue 2.0);
        (FloatValue 4.7, IntValue 3, FloatValue 3.0);
        (FloatValue 1.2, IntValue 6, FloatValue 1.2);
        (IntValue (-3), IntValue (-7), IntValue (-7));
        (FloatValue (-2.5), FloatValue (-1.5), FloatValue (-2.5));
      ]
    in

    List.iter
      (fun (v1, v2, expected) ->
        let result = apply_numeric_binary_op min_op v1 v2 in
        let matches =
          match (result, expected) with
          | IntValue r, IntValue e -> r = e
          | FloatValue r, FloatValue e -> abs_float (r -. e) < 0.0001
          | _ -> false
        in
        Printf.printf "    min(%s, %s) = %s (期望: %s) %s\n" (value_to_string v1) (value_to_string v2)
          (value_to_string result) (value_to_string expected)
          (if matches then "✓" else "✗");
        assert matches)
      test_cases;

    Printf.printf "  ✅ 最小值操作测试通过！\n"

  let test_invalid_type_operations () =
    Printf.printf "测试无效类型操作...\n";

    let invalid_cases =
      [
        (StringValue "hello", IntValue 5);
        (IntValue 10, BoolValue true);
        (FloatValue 3.14, UnitValue);
        (BoolValue false, StringValue "world");
      ]
    in

    List.iter
      (fun (v1, v2) ->
        try
          let _ = apply_numeric_binary_op add_op v1 v2 in
          Printf.printf "    %s + %s: 应该失败但成功了 ✗\n" (value_to_string v1) (value_to_string v2);
          assert false
        with
        | Failure msg when msg = "非数值类型" ->
            Printf.printf "    %s + %s: 正确抛出异常 ✓\n" (value_to_string v1) (value_to_string v2)
        | _ ->
            Printf.printf "    %s + %s: 抛出了错误类型的异常 ✗\n" (value_to_string v1) (value_to_string v2);
            assert false)
      invalid_cases;

    Printf.printf "  ✅ 无效类型操作测试通过！\n"

  let run_all () =
    Printf.printf "\n=== 数值二元操作测试 ===\n";
    test_add_operation ();
    test_multiply_operation ();
    test_max_operation ();
    test_min_operation ();
    test_invalid_type_operations ()
end

(** 数值聚合函数测试模块 *)
module TestNumericAggregation = struct
  let test_fold_numeric_list () =
    Printf.printf "测试数值列表折叠...\n";

    (* 测试加法折叠 *)
    let sum_tests =
      [
        ([ IntValue 1; IntValue 2; IntValue 3 ], IntValue 0, IntValue 6);
        ([ FloatValue 1.5; FloatValue 2.3; FloatValue 1.2 ], FloatValue 0.0, FloatValue 5.0);
        ([ IntValue 10; FloatValue 2.5; IntValue 5 ], IntValue 0, FloatValue 17.5);
        ([], IntValue 0, IntValue 0);
        ([ IntValue 42 ], IntValue 0, IntValue 42);
      ]
    in

    List.iter
      (fun (lst, initial, expected) ->
        let result = fold_numeric_list add_op initial lst "加法测试" in
        let matches =
          match (result, expected) with
          | IntValue r, IntValue e -> r = e
          | FloatValue r, FloatValue e -> abs_float (r -. e) < 0.0001
          | _ -> false
        in
        Printf.printf "    fold_add %s = %s (期望: %s) %s\n"
          (String.concat "; " (List.map value_to_string lst))
          (value_to_string result) (value_to_string expected)
          (if matches then "✓" else "✗");
        assert matches)
      sum_tests;

    (* 测试最大值折叠 *)
    let max_tests =
      [
        ([ IntValue 3; IntValue 1; IntValue 4; IntValue 2 ], IntValue 0, IntValue 4);
        ([ FloatValue 2.7; FloatValue 3.14; FloatValue 1.9 ], FloatValue 0.0, FloatValue 3.14);
        ([ IntValue 5; FloatValue 2.5; IntValue 3 ], IntValue 0, FloatValue 5.0);
      ]
    in

    List.iter
      (fun (lst, initial, expected) ->
        let result = fold_numeric_list max_op initial lst "最大值测试" in
        let matches =
          match (result, expected) with
          | IntValue r, IntValue e -> r = e
          | FloatValue r, FloatValue e -> abs_float (r -. e) < 0.0001
          | _ -> false
        in
        Printf.printf "    fold_max %s = %s (期望: %s) %s\n"
          (String.concat "; " (List.map value_to_string lst))
          (value_to_string result) (value_to_string expected)
          (if matches then "✓" else "✗");
        assert matches)
      max_tests;

    Printf.printf "  ✅ 数值列表折叠测试通过！\n"

  let test_process_nonempty_numeric_list () =
    Printf.printf "测试非空数值列表处理...\n";

    (* 测试非空列表 *)
    let non_empty_tests =
      [
        ([ IntValue 10; IntValue 5; IntValue 3 ], add_op, IntValue 18);
        ([ FloatValue 4.0; FloatValue 2.0; FloatValue 1.0 ], multiply_op, FloatValue 8.0);
        ([ IntValue 7; IntValue 2; IntValue 9; IntValue 1 ], max_op, IntValue 9);
        ([ FloatValue 5.5; FloatValue 2.3; FloatValue 8.1 ], min_op, FloatValue 2.3);
        ([ IntValue 42 ], add_op, IntValue 42);
        (* 单元素列表 *)
      ]
    in

    List.iter
      (fun (lst, op, expected) ->
        let result = process_nonempty_numeric_list op lst "非空测试" in
        let matches =
          match (result, expected) with
          | IntValue r, IntValue e -> r = e
          | FloatValue r, FloatValue e -> abs_float (r -. e) < 0.0001
          | _ -> false
        in
        Printf.printf "    process_nonempty %s = %s (期望: %s) %s\n"
          (String.concat "; " (List.map value_to_string lst))
          (value_to_string result) (value_to_string expected)
          (if matches then "✓" else "✗");
        assert matches)
      non_empty_tests;

    (* 测试空列表 *)
    (try
       let _ = process_nonempty_numeric_list add_op [] "空列表测试" in
       Printf.printf "    空列表: 应该失败但成功了 ✗\n";
       assert false
     with _ -> Printf.printf "    空列表: 正确抛出异常 ✓\n");

    Printf.printf "  ✅ 非空数值列表处理测试通过！\n"

  let test_create_numeric_aggregator () =
    Printf.printf "测试数值聚合器创建...\n";

    let sum_aggregator = create_numeric_aggregator add_op (IntValue 0) "求和" in
    let product_aggregator = create_numeric_aggregator multiply_op (IntValue 1) "求积" in

    (* 测试求和聚合器 *)
    let sum_tests =
      [
        ([ IntValue 1; IntValue 2; IntValue 3 ], IntValue 6);
        ([ FloatValue 1.5; FloatValue 2.5 ], FloatValue 4.0);
        ([], IntValue 0);
      ]
    in

    List.iter
      (fun (lst, expected) ->
        let result = sum_aggregator lst in
        let matches =
          match (result, expected) with
          | IntValue r, IntValue e -> r = e
          | FloatValue r, FloatValue e -> abs_float (r -. e) < 0.0001
          | _ -> false
        in
        Printf.printf "    sum_aggregator %s = %s (期望: %s) %s\n"
          (String.concat "; " (List.map value_to_string lst))
          (value_to_string result) (value_to_string expected)
          (if matches then "✓" else "✗");
        assert matches)
      sum_tests;

    (* 测试求积聚合器 *)
    let product_tests =
      [
        ([ IntValue 2; IntValue 3; IntValue 4 ], IntValue 24);
        ([ FloatValue 2.0; FloatValue 2.5 ], FloatValue 5.0);
        ([], IntValue 1);
      ]
    in

    List.iter
      (fun (lst, expected) ->
        let result = product_aggregator lst in
        let matches =
          match (result, expected) with
          | IntValue r, IntValue e -> r = e
          | FloatValue r, FloatValue e -> abs_float (r -. e) < 0.0001
          | _ -> false
        in
        Printf.printf "    product_aggregator %s = %s (期望: %s) %s\n"
          (String.concat "; " (List.map value_to_string lst))
          (value_to_string result) (value_to_string expected)
          (if matches then "✓" else "✗");
        assert matches)
      product_tests;

    Printf.printf "  ✅ 数值聚合器创建测试通过！\n"

  let test_create_nonempty_numeric_aggregator () =
    Printf.printf "测试非空数值聚合器创建...\n";

    let max_aggregator = create_nonempty_numeric_aggregator max_op "求最大值" in
    let min_aggregator = create_nonempty_numeric_aggregator min_op "求最小值" in

    (* 测试最大值聚合器 *)
    let max_tests =
      [
        ([ IntValue 1; IntValue 5; IntValue 3 ], IntValue 5);
        ([ FloatValue 2.7; FloatValue 1.9; FloatValue 3.14 ], FloatValue 3.14);
        ([ IntValue 42 ], IntValue 42);
      ]
    in

    List.iter
      (fun (lst, expected) ->
        let result = max_aggregator lst in
        let matches =
          match (result, expected) with
          | IntValue r, IntValue e -> r = e
          | FloatValue r, FloatValue e -> abs_float (r -. e) < 0.0001
          | _ -> false
        in
        Printf.printf "    max_aggregator %s = %s (期望: %s) %s\n"
          (String.concat "; " (List.map value_to_string lst))
          (value_to_string result) (value_to_string expected)
          (if matches then "✓" else "✗");
        assert matches)
      max_tests;

    (* 测试最小值聚合器 *)
    let min_tests =
      [
        ([ IntValue 7; IntValue 2; IntValue 9 ], IntValue 2);
        ([ FloatValue 4.5; FloatValue 1.2; FloatValue 3.8 ], FloatValue 1.2);
        ([ FloatValue (-1.5) ], FloatValue (-1.5));
      ]
    in

    List.iter
      (fun (lst, expected) ->
        let result = min_aggregator lst in
        let matches =
          match (result, expected) with
          | IntValue r, IntValue e -> r = e
          | FloatValue r, FloatValue e -> abs_float (r -. e) < 0.0001
          | _ -> false
        in
        Printf.printf "    min_aggregator %s = %s (期望: %s) %s\n"
          (String.concat "; " (List.map value_to_string lst))
          (value_to_string result) (value_to_string expected)
          (if matches then "✓" else "✗");
        assert matches)
      min_tests;

    (* 测试空列表处理 *)
    (try
       let _ = max_aggregator [] in
       Printf.printf "    max_aggregator(空列表): 应该失败但成功了 ✗\n";
       assert false
     with _ -> Printf.printf "    max_aggregator(空列表): 正确抛出异常 ✓\n");

    Printf.printf "  ✅ 非空数值聚合器创建测试通过！\n"

  let run_all () =
    Printf.printf "\n=== 数值聚合函数测试 ===\n";
    test_fold_numeric_list ();
    test_process_nonempty_numeric_list ();
    test_create_numeric_aggregator ();
    test_create_nonempty_numeric_aggregator ()
end

(** 自定义数值操作测试模块 *)
module TestCustomNumericOperations = struct
  let test_custom_binary_operations () =
    Printf.printf "测试自定义二元操作...\n";

    (* 创建减法操作 *)
    let subtract_op = { int_op = ( - ); float_op = ( -. ); mixed_op = ( -. ) } in

    let subtract_tests =
      [
        (IntValue 10, IntValue 3, IntValue 7);
        (FloatValue 5.5, FloatValue 2.3, FloatValue 3.2);
        (IntValue 8, FloatValue 2.5, FloatValue 5.5);
        (FloatValue 7.8, IntValue 3, FloatValue 4.8);
      ]
    in

    List.iter
      (fun (v1, v2, expected) ->
        let result = apply_numeric_binary_op subtract_op v1 v2 in
        let matches =
          match (result, expected) with
          | IntValue r, IntValue e -> r = e
          | FloatValue r, FloatValue e -> abs_float (r -. e) < 0.0001
          | _ -> false
        in
        Printf.printf "    %s - %s = %s (期望: %s) %s\n" (value_to_string v1) (value_to_string v2)
          (value_to_string result) (value_to_string expected)
          (if matches then "✓" else "✗");
        assert matches)
      subtract_tests;

    (* 创建除法操作 *)
    let divide_op = { int_op = ( / ); float_op = ( /. ); mixed_op = ( /. ) } in

    let divide_tests =
      [
        (IntValue 15, IntValue 3, IntValue 5);
        (FloatValue 10.0, FloatValue 2.5, FloatValue 4.0);
        (IntValue 21, FloatValue 3.0, FloatValue 7.0);
        (FloatValue 8.4, IntValue 2, FloatValue 4.2);
      ]
    in

    List.iter
      (fun (v1, v2, expected) ->
        let result = apply_numeric_binary_op divide_op v1 v2 in
        let matches =
          match (result, expected) with
          | IntValue r, IntValue e -> r = e
          | FloatValue r, FloatValue e -> abs_float (r -. e) < 0.0001
          | _ -> false
        in
        Printf.printf "    %s / %s = %s (期望: %s) %s\n" (value_to_string v1) (value_to_string v2)
          (value_to_string result) (value_to_string expected)
          (if matches then "✓" else "✗");
        assert matches)
      divide_tests;

    Printf.printf "  ✅ 自定义二元操作测试通过！\n"

  let test_custom_aggregators () =
    Printf.printf "测试自定义聚合器...\n";

    (* 创建平均值聚合器（简化版：总和除以长度的近似） *)
    let difference_op = { int_op = ( - ); float_op = ( -. ); mixed_op = ( -. ) } in

    let difference_aggregator = create_nonempty_numeric_aggregator difference_op "求差值" in

    let difference_tests =
      [
        ([ IntValue 10; IntValue 3; IntValue 2 ], IntValue 5);
        (* 10 - 3 - 2 = 5 *)
        ([ FloatValue 15.0; FloatValue 5.0; FloatValue 2.5 ], FloatValue 7.5);
        (* 15.0 - 5.0 - 2.5 = 7.5 *)
        ([ IntValue 100 ], IntValue 100);
        (* 单元素 *)
      ]
    in

    List.iter
      (fun (lst, expected) ->
        let result = difference_aggregator lst in
        let matches =
          match (result, expected) with
          | IntValue r, IntValue e -> r = e
          | FloatValue r, FloatValue e -> abs_float (r -. e) < 0.0001
          | _ -> false
        in
        Printf.printf "    difference %s = %s (期望: %s) %s\n"
          (String.concat "; " (List.map value_to_string lst))
          (value_to_string result) (value_to_string expected)
          (if matches then "✓" else "✗");
        assert matches)
      difference_tests;

    Printf.printf "  ✅ 自定义聚合器测试通过！\n"

  let run_all () =
    Printf.printf "\n=== 自定义数值操作测试 ===\n";
    test_custom_binary_operations ();
    test_custom_aggregators ()
end

(** 错误处理和边界条件测试模块 *)
module TestErrorHandlingAndEdgeCases = struct
  let test_error_handling () =
    Printf.printf "测试错误处理...\n";

    (* 测试包含非数值的列表验证 *)
    let invalid_lists =
      [
        [ IntValue 1; StringValue "hello"; IntValue 2 ];
        [ BoolValue true; FloatValue 3.14 ];
        [ UnitValue; IntValue 42 ];
      ]
    in

    List.iter
      (fun lst ->
        try
          let _ = validate_numeric_list lst "test_function" in
          Printf.printf "    invalid list: 应该失败但成功了 ✗\n";
          assert false
        with _ -> Printf.printf "    invalid list: 正确抛出异常 ✓\n")
      invalid_lists;

    (* 测试聚合器的错误处理 *)
    let sum_aggregator = create_numeric_aggregator add_op (IntValue 0) "求和测试" in

    (try
       let _ = sum_aggregator [ IntValue 1; StringValue "bad"; IntValue 2 ] in
       Printf.printf "    聚合器错误处理: 应该失败但成功了 ✗\n";
       assert false
     with _ -> Printf.printf "    聚合器错误处理: 正确抛出异常 ✓\n");

    Printf.printf "  ✅ 错误处理测试通过！\n"

  let test_edge_cases () =
    Printf.printf "测试边界条件...\n";

    (* 测试极值运算 *)
    let edge_cases =
      [
        (* 零值运算 *)
        (IntValue 0, IntValue 1000000, add_op, IntValue 1000000);
        (FloatValue 0.0, FloatValue 999.999, multiply_op, FloatValue 0.0);
        (* 大数值运算 *)
        (IntValue 1000000, IntValue 1000000, add_op, IntValue 2000000);
        (FloatValue 1e6, FloatValue 1e-6, multiply_op, FloatValue 1.0);
        (* 负数运算 *)
        (IntValue (-100), IntValue 50, add_op, IntValue (-50));
        (FloatValue (-3.5), FloatValue (-2.5), max_op, FloatValue (-2.5));
      ]
    in

    List.iter
      (fun (v1, v2, op, expected) ->
        let result = apply_numeric_binary_op op v1 v2 in
        let matches =
          match (result, expected) with
          | IntValue r, IntValue e -> r = e
          | FloatValue r, FloatValue e -> abs_float (r -. e) < 0.0001
          | _ -> false
        in
        Printf.printf "    edge case: %s op %s = %s (期望: %s) %s\n" (value_to_string v1)
          (value_to_string v2) (value_to_string result) (value_to_string expected)
          (if matches then "✓" else "✗");
        assert matches)
      edge_cases;

    (* 测试空列表和单元素列表 *)
    let sum_aggregator = create_numeric_aggregator add_op (IntValue 0) "边界测试" in

    (* 空列表 *)
    let empty_result = sum_aggregator [] in
    assert (empty_result = IntValue 0);
    Printf.printf "    空列表聚合: 正确返回初始值 ✓\n";

    (* 单元素列表 *)
    let single_result = sum_aggregator [ IntValue 42 ] in
    assert (single_result = IntValue 42);
    Printf.printf "    单元素列表聚合: 正确计算 ✓\n";

    Printf.printf "  ✅ 边界条件测试通过！\n"

  let test_precision_issues () =
    Printf.printf "测试浮点精度问题...\n";

    let divide_op = { int_op = ( / ); float_op = ( /. ); mixed_op = ( /. ) } in

    (* 测试浮点运算精度 *)
    let precision_tests =
      [
        (FloatValue 0.1, FloatValue 0.2, add_op, 0.3);
        (FloatValue 1.0, FloatValue 3.0, divide_op, 0.33333333);
        (* 需要自定义除法操作 *)
      ]
    in

    (* 只测试一些基本精度情况 *)
    let result = apply_numeric_binary_op add_op (FloatValue 0.1) (FloatValue 0.2) in
    (match result with
    | FloatValue r ->
        let close_to_expected = abs_float (r -. 0.3) < 0.0001 in
        Printf.printf "    0.1 + 0.2 ≈ 0.3: %s\n" (if close_to_expected then "✓" else "✗");
        assert close_to_expected
    | _ ->
        Printf.printf "    0.1 + 0.2: 类型错误 ✗\n";
        assert false);

    Printf.printf "  ✅ 浮点精度问题测试通过！\n"

  let run_all () =
    Printf.printf "\n=== 错误处理和边界条件测试 ===\n";
    test_error_handling ();
    test_edge_cases ();
    test_precision_issues ()
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

  let test_numeric_operations_performance () =
    Printf.printf "测试数值操作性能...\n";

    let large_int_list = List.init 10000 (fun i -> IntValue i) in
    let large_float_list = List.init 10000 (fun i -> FloatValue (float_of_int i *. 0.1)) in

    let sum_aggregator = create_numeric_aggregator add_op (IntValue 0) "性能测试" in
    let max_aggregator = create_nonempty_numeric_aggregator max_op "性能测试" in

    let test_sum_performance () =
      let _ = sum_aggregator large_int_list in
      let _ = sum_aggregator large_float_list in
      ()
    in

    let test_max_performance () =
      let _ = max_aggregator large_int_list in
      let _ = max_aggregator large_float_list in
      ()
    in

    time_function test_sum_performance "求和性能(2万个数值)";
    time_function test_max_performance "求最大值性能(2万个数值)";

    Printf.printf "  ✅ 数值操作性能测试完成！\n"

  let test_type_checking_performance () =
    Printf.printf "测试类型检查性能...\n";

    let mixed_values =
      Array.init 10000 (fun i ->
          if i mod 3 = 0 then IntValue i
          else if i mod 3 = 1 then FloatValue (float_of_int i)
          else StringValue ("item" ^ string_of_int i))
    in

    let test_type_checking () = Array.iter (fun v -> ignore (is_numeric v)) mixed_values in

    time_function test_type_checking "类型检查性能(1万个值)";
    Printf.printf "  ✅ 类型检查性能测试完成！\n"

  let test_validation_performance () =
    Printf.printf "测试验证性能...\n";

    let valid_numeric_list = List.init 5000 (fun i -> IntValue i) in
    let invalid_mixed_list =
      List.init 5000 (fun i ->
          if i mod 10 = 0 then StringValue ("item" ^ string_of_int i) else IntValue i)
    in

    let test_validation () =
      try
        let _ = validate_numeric_list valid_numeric_list "性能测试" in
        ()
      with _ -> (
        ();
        try
          let _ = validate_numeric_list invalid_mixed_list "性能测试" in
          ()
        with _ -> ())
    in

    time_function test_validation "验证性能(1万个值)";
    Printf.printf "  ✅ 验证性能测试完成！\n"

  let run_all () =
    Printf.printf "\n=== 性能基准测试 ===\n";
    test_numeric_operations_performance ();
    test_type_checking_performance ();
    test_validation_performance ()
end

(** 主测试运行器 *)
let run_all_tests () =
  Printf.printf "🚀 骆言数值操作模块综合测试开始\n";
  Printf.printf "======================================\n";

  (* 运行所有测试模块 *)
  TestNumericTypeChecking.run_all ();
  TestNumericBinaryOperations.run_all ();
  TestNumericAggregation.run_all ();
  TestCustomNumericOperations.run_all ();
  TestErrorHandlingAndEdgeCases.run_all ();
  TestPerformance.run_all ();

  Printf.printf "\n======================================\n";
  Printf.printf "✅ 所有测试通过！数值操作模块功能正常。\n";
  Printf.printf "   测试覆盖: 类型检查、二元操作、聚合函数、自定义操作、\n";
  Printf.printf "             错误处理、边界条件、性能测试\n"

(** 程序入口点 *)
let () = run_all_tests ()
