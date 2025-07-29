(** 常量模块基础覆盖测试套件 - Fix #1690 测试覆盖率提升计划第一阶段
    
    Author: Echo, 测试工程师代理

    本测试套件为constants模块提供基础测试覆盖，验证主要常量的正确性。

    @version 1.0 - Phase 1 测试覆盖率提升
    @since 2025-07-29 Fix #1690 *)

open Alcotest
open Yyocamlc_lib

(** 测试数值常量模块 *)
module NumbersTests = struct
  (** 测试基础整数常量 *)
  let test_basic_integers () =
    check int "zero 应该等于 0" 0 Constants.Numbers.zero;
    check int "one 应该等于 1" 1 Constants.Numbers.one;
    check int "two 应该等于 2" 2 Constants.Numbers.two;
    check int "ten 应该等于 10" 10 Constants.Numbers.ten;
    check int "hundred 应该等于 100" 100 Constants.Numbers.hundred;
    check int "thousand 应该等于 1000" 1000 Constants.Numbers.thousand

  (** 测试浮点数常量 *)
  let test_float_constants () =
    check (float 0.001) "zero_float 应该等于 0.0" 0.0 Constants.Numbers.zero_float;
    check (float 0.001) "one_float 应该等于 1.0" 1.0 Constants.Numbers.one_float;
    check (float 0.001) "half_float 应该等于 0.5" 0.5 Constants.Numbers.half_float;
    check (float 0.0001) "pi 应该接近 3.14159" 3.14159265359 Constants.Numbers.pi
end

(** 测试缓冲区配置模块 *)
module BufferTests = struct
  (** 测试缓冲区大小函数 *)
  let test_buffer_sizes () =
    check int "default_buffer 应该等于 1024" 1024 (Constants.BufferSizes.default_buffer ());
    check int "large_buffer 应该等于 4096" 4096 (Constants.BufferSizes.large_buffer ());
    check int "report_buffer 应该等于 16384" 16384 (Constants.BufferSizes.report_buffer ());
    check int "utf8_char_buffer 应该等于 8" 8 (Constants.BufferSizes.utf8_char_buffer ())
end

(** 测试度量指标常量 *)
module MetricsTests = struct
  (** 测试度量常量 *)
  let test_metrics_constants () =
    check (float 0.001) "confidence_multiplier 应该等于 100.0" 100.0 Constants.Metrics.confidence_multiplier;
    check (float 0.001) "full_confidence 应该等于 1.0" 1.0 Constants.Metrics.full_confidence;
    check (float 0.001) "zero_confidence 应该等于 0.0" 0.0 Constants.Metrics.zero_confidence;
    check (float 0.001) "confidence_threshold 应该等于 0.5" 0.5 (Constants.Metrics.confidence_threshold ())
end

(** 测试颜色常量模块 *)
module ColorsTests = struct
  (** 测试ANSI颜色代码 *)
  let test_ansi_colors () =
    check string "red 应该是正确的ANSI代码" "\027[31m" Constants.Colors.red;
    check string "green 应该是正确的ANSI代码" "\027[32m" Constants.Colors.green;
    check string "reset 应该是正确的ANSI代码" "\027[0m" Constants.Colors.reset;
    check string "bold 应该是正确的ANSI代码" "\027[1m" Constants.Colors.bold

  (** 测试颜色文本函数 *)
  let test_color_text_functions () =
    let test_message = "测试" in
    let red_result = Constants.Colors.red_text test_message in
    let expected_red = Constants.Colors.red ^ test_message ^ Constants.Colors.reset in
    check string "red_text 应该正确包装文本" expected_red red_result;
    
    let green_result = Constants.Colors.green_text test_message in
    let expected_green = Constants.Colors.green ^ test_message ^ Constants.Colors.reset in
    check string "green_text 应该正确包装文本" expected_green green_result
end

(** 测试系统配置常量 *)
module SystemConfigTests = struct
  (** 测试系统配置常量 *)
  let test_system_config () =
    check int "default_hash_table_size 应该等于 256" 256 Constants.SystemConfig.default_hash_table_size;
    check int "default_cache_size 应该等于 128" 128 Constants.SystemConfig.default_cache_size;
    check int "utf8_char_max_bytes 应该等于 4" 4 Constants.SystemConfig.utf8_char_max_bytes;
    check int "max_recursion_depth 应该等于 1000" 1000 Constants.SystemConfig.max_recursion_depth
end

(** 测试测试数据常量 *)
module TestDataTests = struct
  (** 测试测试数据常量 *)
  let test_test_data_constants () =
    check int "small_test_number 应该等于 100" 100 Constants.TestData.small_test_number;
    check int "factorial_test_input 应该等于 5" 5 Constants.TestData.factorial_test_input;
    check int "factorial_expected_result 应该等于 120" 120 Constants.TestData.factorial_expected_result;
    check int "sum_1_to_100 应该等于 5050" 5050 Constants.TestData.sum_1_to_100
end

(** 测试运行时函数名称常量 *)
module RuntimeFunctionTests = struct
  (** 测试运行时函数名称 *)
  let test_runtime_function_names () =
    check string "add 函数名应该正确" "luoyan_add" Constants.RuntimeFunctions.add;
    check string "subtract 函数名应该正确" "luoyan_subtract" Constants.RuntimeFunctions.subtract;
    check string "multiply 函数名应该正确" "luoyan_multiply" Constants.RuntimeFunctions.multiply;
    check string "divide 函数名应该正确" "luoyan_divide" Constants.RuntimeFunctions.divide;
    check string "equal 函数名应该正确" "luoyan_equal" Constants.RuntimeFunctions.equal
end

(** 运行所有测试的主函数 *)
let () =
  run "Constants Basic Coverage Tests" [
    ("数值常量", [
      test_case "基础整数常量" `Quick NumbersTests.test_basic_integers;
      test_case "浮点数常量" `Quick NumbersTests.test_float_constants;
    ]);
    ("缓冲区配置", [
      test_case "缓冲区大小" `Quick BufferTests.test_buffer_sizes;
    ]);
    ("度量指标", [
      test_case "度量常量" `Quick MetricsTests.test_metrics_constants;
    ]);
    ("颜色常量", [
      test_case "ANSI颜色代码" `Quick ColorsTests.test_ansi_colors;
      test_case "颜色文本函数" `Quick ColorsTests.test_color_text_functions;
    ]);
    ("系统配置", [
      test_case "系统配置常量" `Quick SystemConfigTests.test_system_config;
    ]);
    ("测试数据", [
      test_case "测试数据常量" `Quick TestDataTests.test_test_data_constants;
    ]);
    ("运行时函数", [
      test_case "运行时函数名称" `Quick RuntimeFunctionTests.test_runtime_function_names;
    ]);
  ]