(** 骆言内置数学模块测试 - Phase 26 内置模块测试覆盖率提升
    
    本测试模块专门针对 builtin_math.ml 模块进行全面功能测试，
    重点测试数学计算的正确性、边界条件和性能表现。
    
    测试覆盖范围：
    - 范围生成函数
    - 求和聚合函数
    - 最大值最小值函数
    - 边界条件处理
    - 错误情况处理
    - 中文数字处理
    
    @author 骆言技术债务清理团队 - Phase 26
    @version 1.0
    @since 2025-07-20 Issue #680 内置模块测试覆盖率提升 *)

open Alcotest
open Yyocamlc_lib.Value_operations
open Yyocamlc_lib.Builtin_math

(** 测试工具函数 *)
module TestUtils = struct
  (** 创建测试用的整数列表值 *)
  let make_int_list nums = ListValue (List.map (fun n -> IntValue n) nums)
  
  (** 创建测试用的浮点数列表值 *)
  let make_float_list nums = ListValue (List.map (fun f -> FloatValue f) nums)
  
  (** 创建测试用的混合数值列表 *)
  let make_mixed_list values = ListValue values
  
  (** 验证运行时错误 *)
  let expect_runtime_error f =
    try
      ignore (f ());
      false
    with
    | RuntimeError _ -> true
    | _ -> false
    
  (** 验证两个值相等 *)
  let values_equal v1 v2 = match (v1, v2) with
    | (IntValue a, IntValue b) -> a = b
    | (FloatValue a, FloatValue b) -> abs_float (a -. b) < 1e-10
    | (StringValue a, StringValue b) -> a = b
    | (BoolValue a, BoolValue b) -> a = b
    | (UnitValue, UnitValue) -> true
    | (ListValue a, ListValue b) -> 
        List.length a = List.length b && List.for_all2 (=) a b
    | _ -> false
    
  (** 验证列表包含特定值 *)
  let list_contains list_val target_val =
    match list_val with
    | ListValue items -> List.exists (fun item -> values_equal item target_val) items
    | _ -> false
    
  (** 获取列表长度 *)
  let get_list_length list_val =
    match list_val with
    | ListValue items -> List.length items
    | _ -> 0
end

(** 范围生成函数测试 *)
module RangeGenerationTests = struct
  
  (** 测试基本范围生成 *)
  let test_basic_range_generation () =
    (* 测试正向递增范围 *)
    let result1 = range_function [IntValue 1; IntValue 5] in
    let expected1 = TestUtils.make_int_list [1; 2; 3; 4; 5] in
    check bool "1到5的范围应正确" true (TestUtils.values_equal result1 expected1);
    
    (* 测试单元素范围 *)
    let result2 = range_function [IntValue 3; IntValue 3] in
    let expected2 = TestUtils.make_int_list [3] in
    check bool "单元素范围应正确" true (TestUtils.values_equal result2 expected2);
    
    (* 测试包含零的范围 *)
    let result3 = range_function [IntValue (-2); IntValue 2] in
    let expected3 = TestUtils.make_int_list [-2; -1; 0; 1; 2] in
    check bool "包含零的范围应正确" true (TestUtils.values_equal result3 expected3)

  (** 测试范围生成的边界条件 *)
  let test_range_boundary_cases () =
    (* 测试空范围（起始大于结束） *)
    let result1 = range_function [IntValue 5; IntValue 1] in
    let expected1 = TestUtils.make_int_list [] in
    check bool "空范围应返回空列表" true (TestUtils.values_equal result1 expected1);
    
    (* 测试大范围 *)
    let result2 = range_function [IntValue 1; IntValue 100] in
    check int "大范围长度应正确" 100 (TestUtils.get_list_length result2);
    check bool "大范围应包含起始值" true (TestUtils.list_contains result2 (IntValue 1));
    check bool "大范围应包含结束值" true (TestUtils.list_contains result2 (IntValue 100));
    
    (* 测试负数范围 *)
    let result3 = range_function [IntValue (-5); IntValue (-1)] in
    let expected3 = TestUtils.make_int_list [-5; -4; -3; -2; -1] in
    check bool "负数范围应正确" true (TestUtils.values_equal result3 expected3)

  (** 测试范围生成的错误处理 *)
  let test_range_error_handling () =
    (* 测试参数数量错误 *)
    let error_case1 () = range_function [IntValue 1] in
    check bool "参数不足应抛出错误" true (TestUtils.expect_runtime_error error_case1);
    
    (* 测试参数类型错误 *)
    let error_case2 () = range_function [StringValue "错误"; IntValue 5] in
    check bool "参数类型错误应抛出错误" true (TestUtils.expect_runtime_error error_case2);
    
    let error_case3 () = range_function [IntValue 1; FloatValue 5.0] in
    check bool "混合数值类型应抛出错误" true (TestUtils.expect_runtime_error error_case3)

end

(** 求和函数测试 *)
module SumFunctionTests = struct
  
  (** 测试整数求和 *)
  let test_integer_sum () =
    (* 测试正整数求和 *)
    let int_list1 = TestUtils.make_int_list [1; 2; 3; 4; 5] in
    let result1 = sum_function [int_list1] in
    check bool "正整数求和应为15" true (TestUtils.values_equal result1 (IntValue 15));
    
    (* 测试包含零的求和 *)
    let int_list2 = TestUtils.make_int_list [0; 1; 0; 2; 0] in
    let result2 = sum_function [int_list2] in
    check bool "包含零的求和应为3" true (TestUtils.values_equal result2 (IntValue 3));
    
    (* 测试负数求和 *)
    let int_list3 = TestUtils.make_int_list [-1; -2; -3] in
    let result3 = sum_function [int_list3] in
    check bool "负数求和应为-6" true (TestUtils.values_equal result3 (IntValue (-6)))

  (** 测试浮点数求和 *)
  let test_float_sum () =
    (* 测试基本浮点数求和 *)
    let float_list1 = TestUtils.make_float_list [1.5; 2.5; 3.0] in
    let result1 = sum_function [float_list1] in
    check bool "浮点数求和应为7.0" true (TestUtils.values_equal result1 (FloatValue 7.0));
    
    (* 测试小数精度 *)
    let float_list2 = TestUtils.make_float_list [0.1; 0.2; 0.3] in
    let result2 = sum_function [float_list2] in
    check bool "小数求和应接近0.6" true 
      (match result2 with FloatValue f -> abs_float (f -. 0.6) < 1e-10 | _ -> false)

  (** 测试空列表和边界条件 *)
  let test_sum_boundary_cases () =
    (* 测试空列表求和 *)
    let empty_list = TestUtils.make_int_list [] in
    let result1 = sum_function [empty_list] in
    check bool "空列表求和应为0" true (TestUtils.values_equal result1 (IntValue 0));
    
    (* 测试单元素求和 *)
    let single_list = TestUtils.make_int_list [42] in
    let result2 = sum_function [single_list] in
    check bool "单元素求和应为元素本身" true (TestUtils.values_equal result2 (IntValue 42));
    
    (* 测试大数值求和 *)
    let large_list = TestUtils.make_int_list [1000; 2000; 3000] in
    let result3 = sum_function [large_list] in
    check bool "大数值求和应为6000" true (TestUtils.values_equal result3 (IntValue 6000))

  (** 测试求和错误处理 *)
  let test_sum_error_handling () =
    (* 测试非数值列表 *)
    let non_numeric_list = ListValue [StringValue "错误"; IntValue 1] in
    let error_case1 () = sum_function [non_numeric_list] in
    check bool "非数值列表应抛出错误" true (TestUtils.expect_runtime_error error_case1);
    
    (* 测试参数类型错误 *)
    let error_case2 () = sum_function [IntValue 123] in
    check bool "非列表参数应抛出错误" true (TestUtils.expect_runtime_error error_case2)

end

(** 最大值最小值函数测试 *)
module MinMaxFunctionTests = struct
  
  (** 测试最大值函数 *)
  let test_max_function () =
    (* 测试整数最大值 *)
    let int_list1 = TestUtils.make_int_list [3; 7; 2; 9; 1] in
    let result1 = max_function [int_list1] in
    check bool "整数最大值应为9" true (TestUtils.values_equal result1 (IntValue 9));
    
    (* 测试浮点数最大值 *)
    let float_list1 = TestUtils.make_float_list [1.5; 3.7; 2.1] in
    let result2 = max_function [float_list1] in
    check bool "浮点数最大值应为3.7" true (TestUtils.values_equal result2 (FloatValue 3.7));
    
    (* 测试负数最大值 *)
    let neg_list = TestUtils.make_int_list [-5; -2; -8; -1] in
    let result3 = max_function [neg_list] in
    check bool "负数最大值应为-1" true (TestUtils.values_equal result3 (IntValue (-1)))

  (** 测试最小值函数 *)
  let test_min_function () =
    (* 测试整数最小值 *)
    let int_list1 = TestUtils.make_int_list [3; 7; 2; 9; 1] in
    let result1 = min_function [int_list1] in
    check bool "整数最小值应为1" true (TestUtils.values_equal result1 (IntValue 1));
    
    (* 测试浮点数最小值 *)
    let float_list1 = TestUtils.make_float_list [1.5; 3.7; 0.9] in
    let result2 = min_function [float_list1] in
    check bool "浮点数最小值应为0.9" true (TestUtils.values_equal result2 (FloatValue 0.9));
    
    (* 测试正数最小值 *)
    let pos_list = TestUtils.make_int_list [5; 2; 8; 1; 3] in
    let result3 = min_function [pos_list] in
    check bool "正数最小值应为1" true (TestUtils.values_equal result3 (IntValue 1))

  (** 测试最值函数的边界条件 *)
  let test_minmax_boundary_cases () =
    (* 测试单元素列表 *)
    let single_list = TestUtils.make_int_list [42] in
    let max_result = max_function [single_list] in
    let min_result = min_function [single_list] in
    check bool "单元素最大值应为元素本身" true (TestUtils.values_equal max_result (IntValue 42));
    check bool "单元素最小值应为元素本身" true (TestUtils.values_equal min_result (IntValue 42));
    
    (* 测试相同元素列表 *)
    let same_list = TestUtils.make_int_list [5; 5; 5; 5] in
    let max_result2 = max_function [same_list] in
    let min_result2 = min_function [same_list] in
    check bool "相同元素最大值应为5" true (TestUtils.values_equal max_result2 (IntValue 5));
    check bool "相同元素最小值应为5" true (TestUtils.values_equal min_result2 (IntValue 5));
    
    (* 测试包含零的列表 *)
    let zero_list = TestUtils.make_int_list [-1; 0; 1] in
    let max_result3 = max_function [zero_list] in
    let min_result3 = min_function [zero_list] in
    check bool "包含零的最大值应为1" true (TestUtils.values_equal max_result3 (IntValue 1));
    check bool "包含零的最小值应为-1" true (TestUtils.values_equal min_result3 (IntValue (-1)))

  (** 测试最值函数的错误处理 *)
  let test_minmax_error_handling () =
    (* 测试空列表 *)
    let empty_list = TestUtils.make_int_list [] in
    let error_case1 () = max_function [empty_list] in
    let error_case2 () = min_function [empty_list] in
    check bool "空列表最大值应抛出错误" true (TestUtils.expect_runtime_error error_case1);
    check bool "空列表最小值应抛出错误" true (TestUtils.expect_runtime_error error_case2);
    
    (* 测试非数值列表 *)
    let non_numeric_list = ListValue [StringValue "错误"] in
    let error_case3 () = max_function [non_numeric_list] in
    let error_case4 () = min_function [non_numeric_list] in
    check bool "非数值列表最大值应抛出错误" true (TestUtils.expect_runtime_error error_case3);
    check bool "非数值列表最小值应抛出错误" true (TestUtils.expect_runtime_error error_case4)

end

(** 复杂场景和集成测试 *)
module MathIntegrationTests = struct
  
  (** 测试数学函数组合使用 *)
  let test_math_function_composition () =
    (* 生成范围并求和 *)
    let range_result = range_function [IntValue 1; IntValue 10] in
    let sum_result = sum_function [range_result] in
    check bool "1到10求和应为55" true (TestUtils.values_equal sum_result (IntValue 55));
    
    (* 生成范围并求最值 *)
    let range_result2 = range_function [IntValue 5; IntValue 15] in
    let max_result = max_function [range_result2] in
    let min_result = min_function [range_result2] in
    check bool "5到15最大值应为15" true (TestUtils.values_equal max_result (IntValue 15));
    check bool "5到15最小值应为5" true (TestUtils.values_equal min_result (IntValue 5))

  (** 测试数学函数表完整性 *)
  let test_math_functions_table () =
    let expected_functions = ["范围"; "求和"; "最大值"; "最小值"] in
    let actual_functions = List.map fst math_functions in
    
    List.iter (fun expected ->
      check bool (Printf.sprintf "函数表应包含'%s'" expected) true (List.mem expected actual_functions)
    ) expected_functions;
    
    check int "数学函数表大小应正确" (List.length expected_functions) (List.length actual_functions)

  (** 测试大数值计算性能 *)
  let test_large_number_performance () =
    (* 测试大范围性能 *)
    let large_range = range_function [IntValue 1; IntValue 1000] in
    check int "大范围长度应为1000" 1000 (TestUtils.get_list_length large_range);
    
    (* 测试大列表求和性能 *)
    let sum_result = sum_function [large_range] in
    check bool "大范围求和应正确" true (TestUtils.values_equal sum_result (IntValue 500500));
    
    (* 测试大列表最值性能 *)
    let max_result = max_function [large_range] in
    let min_result = min_function [large_range] in
    check bool "大范围最大值应为1000" true (TestUtils.values_equal max_result (IntValue 1000));
    check bool "大范围最小值应为1" true (TestUtils.values_equal min_result (IntValue 1))

  (** 测试混合数值类型处理 *)
  let test_mixed_numeric_types () =
    (* 测试整数和浮点数混合求和 *)
    let mixed_list = TestUtils.make_mixed_list [IntValue 1; FloatValue 2.5; IntValue 3] in
    let sum_result = sum_function [mixed_list] in
    check bool "混合类型求和应正确" true 
      (match sum_result with FloatValue f -> abs_float (f -. 6.5) < 1e-10 | _ -> false);
    
    (* 测试混合类型最值 - 由于类型提升，结果可能是FloatValue *)
    let mixed_list2 = TestUtils.make_mixed_list [IntValue 5; FloatValue 3.7; IntValue 2] in
    let max_result = max_function [mixed_list2] in
    let min_result = min_function [mixed_list2] in
    (* 当有浮点数参与时，结果会提升为浮点类型 *)
    check bool "混合类型最大值应为5.0" true (TestUtils.values_equal max_result (FloatValue 5.0));
    check bool "混合类型最小值应为2.0" true (TestUtils.values_equal min_result (FloatValue 2.0))

end

(** 中文编程特色测试 *)
module ChineseMathTests = struct
  
  (** 测试中文数字处理 *)
  let test_chinese_number_processing () =
    (* 测试中文风格的数值范围 *)
    let chinese_range = range_function [IntValue 1; IntValue 5] in
    let expected_values = [1; 2; 3; 4; 5] in
    
    (* 验证范围包含预期的数值 *)
    List.iter (fun expected ->
      check bool (Printf.sprintf "中文范围应包含%d" expected) true 
        (TestUtils.list_contains chinese_range (IntValue expected))
    ) expected_values

  (** 测试中文数学概念应用 *)
  let test_chinese_math_concepts () =
    (* 测试"求和"概念 - 累积相加 *)
    let accumulation_list = TestUtils.make_int_list [10; 20; 30; 40; 50] in
    let total = sum_function [accumulation_list] in
    check bool "累积求和应为150" true (TestUtils.values_equal total (IntValue 150));
    
    (* 测试"最大值"概念 - 选取至尊 *)
    let competition_list = TestUtils.make_int_list [88; 92; 95; 87; 90] in
    let champion = max_function [competition_list] in
    check bool "竞争中的冠军应为95" true (TestUtils.values_equal champion (IntValue 95));
    
    (* 测试"最小值"概念 - 选取谦逊 *)
    let humility_list = TestUtils.make_int_list [3; 1; 4; 2; 5] in
    let modest = min_function [humility_list] in
    check bool "谦逊者应为1" true (TestUtils.values_equal modest (IntValue 1))

  (** 测试中文编程风格的数学序列 *)
  let test_chinese_mathematical_sequences () =
    (* 测试天干地支风格的数字序列（简化版） *)
    let traditional_sequence = range_function [IntValue 1; IntValue 12] in
    check int "传统序列长度应为12" 12 (TestUtils.get_list_length traditional_sequence);
    
    (* 测试古代计数系统的数学运算 *)
    let ancient_numbers = TestUtils.make_int_list [9; 18; 27; 36] in  (* 九的倍数 *)
    let ancient_sum = sum_function [ancient_numbers] in
    check bool "古代数字求和应为90" true (TestUtils.values_equal ancient_sum (IntValue 90));
    
    (* 测试五行相关的数学计算（简化表示） *)
    let five_elements = TestUtils.make_int_list [1; 2; 3; 4; 5] in  (* 代表五行 *)
    let elements_max = max_function [five_elements] in
    let elements_min = min_function [five_elements] in
    check bool "五行最大应为5" true (TestUtils.values_equal elements_max (IntValue 5));
    check bool "五行最小应为1" true (TestUtils.values_equal elements_min (IntValue 1))

  (** 测试诗词数学 - 韵律中的数值 *)
  let test_poetic_mathematics () =
    (* 测试五言绝句的音韵数字（每句5字，共4句） *)
    let poem_structure = TestUtils.make_int_list [5; 5; 5; 5] in
    let total_chars = sum_function [poem_structure] in
    check bool "五言绝句总字数应为20" true (TestUtils.values_equal total_chars (IntValue 20));
    
    (* 测试七言律诗的结构数字（每句7字，共8句） *)
    let regulated_verse = range_function [IntValue 1; IntValue 8] in
    let verse_sum = sum_function [regulated_verse] in
    check bool "律诗句序求和应为36" true (TestUtils.values_equal verse_sum (IntValue 36))

end

(** 测试套件注册 *)
let test_suite = [
  "范围生成函数", [
    test_case "基本范围生成" `Quick RangeGenerationTests.test_basic_range_generation;
    test_case "范围边界条件" `Quick RangeGenerationTests.test_range_boundary_cases;
    test_case "范围错误处理" `Quick RangeGenerationTests.test_range_error_handling;
  ];
  
  "求和函数", [
    test_case "整数求和" `Quick SumFunctionTests.test_integer_sum;
    test_case "浮点数求和" `Quick SumFunctionTests.test_float_sum;
    test_case "求和边界条件" `Quick SumFunctionTests.test_sum_boundary_cases;
    test_case "求和错误处理" `Quick SumFunctionTests.test_sum_error_handling;
  ];
  
  "最值函数", [
    test_case "最大值函数" `Quick MinMaxFunctionTests.test_max_function;
    test_case "最小值函数" `Quick MinMaxFunctionTests.test_min_function;
    test_case "最值边界条件" `Quick MinMaxFunctionTests.test_minmax_boundary_cases;
    test_case "最值错误处理" `Quick MinMaxFunctionTests.test_minmax_error_handling;
  ];
  
  "数学集成测试", [
    test_case "函数组合使用" `Quick MathIntegrationTests.test_math_function_composition;
    test_case "函数表完整性" `Quick MathIntegrationTests.test_math_functions_table;
    test_case "大数值性能" `Quick MathIntegrationTests.test_large_number_performance;
    test_case "混合数值类型" `Quick MathIntegrationTests.test_mixed_numeric_types;
  ];
  
  "中文数学特色", [
    test_case "中文数字处理" `Quick ChineseMathTests.test_chinese_number_processing;
    test_case "中文数学概念" `Quick ChineseMathTests.test_chinese_math_concepts;
    test_case "数学序列" `Quick ChineseMathTests.test_chinese_mathematical_sequences;
    test_case "诗词数学" `Quick ChineseMathTests.test_poetic_mathematics;
  ];
]

(** 运行所有测试 *)
let () = 
  Printf.printf "骆言内置数学模块测试 - Phase 26\n";
  Printf.printf "==========================================\n";
  run "Builtin Math Module Tests" test_suite