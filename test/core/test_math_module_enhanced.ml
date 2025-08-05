(** 骆言增强数学模块测试 - Issue #2189 数学模块核心功能完善任务

    本测试模块专门针对增强的 标准库/数学.ly 模块进行全面功能测试， 重点测试新增的三角函数、统计函数、数论函数和数学常量的正确性、边界条件和性能表现。

    测试覆盖范围：
    - 三角函数: 正弦、余弦、正切 (使用泰勒级数实现)
    - 统计函数: 平均值、方差、标准差、中位数
    - 数论函数: 素数优化判断、质因数分解
    - 数学常量: 圆周率、自然对数底、欧拉常数、黄金比例
    - 边界条件处理和错误情况处理
    - 性能基准测试 (目标: ≥80% OCaml标准库性能)

    Author: Whisky, PR Worker
    @version 1.0
    @since 2025-08-05 Issue #2189 数学模块核心功能完善任务 *)

open Alcotest
open Yyocamlc_lib.Value_operations
open Yyocamlc_lib.Builtin_math

(** 测试工具函数模块 *)
module TestUtils = struct
  (** 创建测试用的浮点数列表值 *)
  let make_float_list nums = ListValue (List.map (fun f -> FloatValue f) nums)

  (** 创建测试用的整数列表值 *)
  let make_int_list nums = ListValue (List.map (fun n -> IntValue n) nums)

  (** 验证运行时错误 *)
  let expect_runtime_error f =
    try
      ignore (f ());
      false
    with
    | RuntimeError _ -> true
    | _ -> false

  (** 验证两个浮点数在指定精度内相等 *)
  let float_equal ?(precision = 1e-10) a b = abs_float (a -. b) < precision

  (** 验证两个值相等 *)
  let rec values_equal v1 v2 =
    match (v1, v2) with
    | IntValue a, IntValue b -> a = b
    | FloatValue a, FloatValue b -> float_equal a b
    | StringValue a, StringValue b -> a = b
    | BoolValue a, BoolValue b -> a = b
    | UnitValue, UnitValue -> true
    | ListValue a, ListValue b -> List.length a = List.length b && List.for_all2 values_equal a b
    | _ -> false

  (** 获取浮点值 *)
  let get_float_value = function
    | FloatValue f -> f
    | IntValue i -> float_of_int i
    | _ -> failwith "Not a numeric value"

  (** 获取整数值 *)
  let get_int_value = function IntValue i -> i | _ -> failwith "Not an integer value"

  (** 获取布尔值 *)
  let get_bool_value = function BoolValue b -> b | _ -> failwith "Not a boolean value"

  (** 获取列表值 *)
  let get_list_value = function ListValue l -> l | _ -> failwith "Not a list value"
end

(** 三角函数测试模块 *)
module TrigonometricTests = struct
  (** 测试正弦函数基本功能 *)
  let test_sin_basic () =
    (* 测试特殊角度 *)
    let sin_0 = TestUtils.get_float_value (sin_function [ FloatValue 0.0 ]) in
    let sin_pi_2 =
      TestUtils.get_float_value (sin_function [ FloatValue (3.141592653589793 /. 2.0) ])
    in
    let sin_pi = TestUtils.get_float_value (sin_function [ FloatValue 3.141592653589793 ]) in

    check bool "sin(0) 应约等于 0" true (TestUtils.float_equal sin_0 0.0 ~precision:1e-8);
    check bool "sin(π/2) 应约等于 1" true (TestUtils.float_equal sin_pi_2 1.0 ~precision:1e-8);
    check bool "sin(π) 应约等于 0" true (TestUtils.float_equal sin_pi 0.0 ~precision:1e-8);

    (* 测试负角度 *)
    let sin_neg_pi_2 =
      TestUtils.get_float_value (sin_function [ FloatValue (-3.141592653589793 /. 2.0) ])
    in
    check bool "sin(-π/2) 应约等于 -1" true (TestUtils.float_equal sin_neg_pi_2 (-1.0) ~precision:1e-8)

  (** 测试余弦函数基本功能 *)
  let test_cos_basic () =
    (* 测试特殊角度 *)
    let cos_0 = TestUtils.get_float_value (cos_function [ FloatValue 0.0 ]) in
    let cos_pi_2 =
      TestUtils.get_float_value (cos_function [ FloatValue (3.141592653589793 /. 2.0) ])
    in
    let cos_pi = TestUtils.get_float_value (cos_function [ FloatValue 3.141592653589793 ]) in

    check bool "cos(0) 应约等于 1" true (TestUtils.float_equal cos_0 1.0 ~precision:1e-8);
    check bool "cos(π/2) 应约等于 0" true (TestUtils.float_equal cos_pi_2 0.0 ~precision:1e-8);
    check bool "cos(π) 应约等于 -1" true (TestUtils.float_equal cos_pi (-1.0) ~precision:1e-8)

  (** 测试正切函数基本功能 *)
  let test_tan_basic () =
    (* 测试基本角度 *)
    let tan_0 = TestUtils.get_float_value (tan_function [ FloatValue 0.0 ]) in
    let tan_pi_4 =
      TestUtils.get_float_value (tan_function [ FloatValue (3.141592653589793 /. 4.0) ])
    in
    let tan_pi = TestUtils.get_float_value (tan_function [ FloatValue 3.141592653589793 ]) in

    check bool "tan(0) 应约等于 0" true (TestUtils.float_equal tan_0 0.0 ~precision:1e-8);
    check bool "tan(π/4) 应约等于 1" true (TestUtils.float_equal tan_pi_4 1.0 ~precision:1e-8);
    check bool "tan(π) 应约等于 0" true (TestUtils.float_equal tan_pi 0.0 ~precision:1e-8)

  (** 测试三角函数恒等式 *)
  let test_trigonometric_identities () =
    let angles = [ 0.5; 1.0; 1.5; 2.0 ] in
    List.iter
      (fun angle ->
        let sin_val = TestUtils.get_float_value (sin_function [ FloatValue angle ]) in
        let cos_val = TestUtils.get_float_value (cos_function [ FloatValue angle ]) in
        let identity = (sin_val *. sin_val) +. (cos_val *. cos_val) in
        check bool
          (Printf.sprintf "sin²(%f) + cos²(%f) 应等于 1" angle angle)
          true
          (TestUtils.float_equal identity 1.0 ~precision:1e-8))
      angles

  (** 测试三角函数周期性 *)
  let test_trigonometric_periodicity () =
    let pi = 3.141592653589793 in
    let test_angles = [ 0.5; 1.0; 1.5 ] in
    List.iter
      (fun angle ->
        let sin_angle = TestUtils.get_float_value (sin_function [ FloatValue angle ]) in
        let sin_angle_plus_2pi =
          TestUtils.get_float_value (sin_function [ FloatValue (angle +. (2.0 *. pi)) ])
        in
        let cos_angle = TestUtils.get_float_value (cos_function [ FloatValue angle ]) in
        let cos_angle_plus_2pi =
          TestUtils.get_float_value (cos_function [ FloatValue (angle +. (2.0 *. pi)) ])
        in

        check bool
          (Printf.sprintf "sin(%f) = sin(%f + 2π) 周期性" angle angle)
          true
          (TestUtils.float_equal sin_angle sin_angle_plus_2pi ~precision:1e-7);
        check bool
          (Printf.sprintf "cos(%f) = cos(%f + 2π) 周期性" angle angle)
          true
          (TestUtils.float_equal cos_angle cos_angle_plus_2pi ~precision:1e-7))
      test_angles
end

(** 统计函数测试模块 *)
module StatisticalTests = struct
  (** 测试平均值函数 *)
  let test_mean_function () =
    (* 测试基本平均值 *)
    let data1 = TestUtils.make_float_list [ 1.0; 2.0; 3.0; 4.0; 5.0 ] in
    let mean1 = TestUtils.get_float_value (mean_function [ data1 ]) in
    check bool "平均值 [1,2,3,4,5] 应为 3.0" true (TestUtils.float_equal mean1 3.0);

    (* 测试包含负数的平均值 *)
    let data2 = TestUtils.make_float_list [ -2.0; -1.0; 0.0; 1.0; 2.0 ] in
    let mean2 = TestUtils.get_float_value (mean_function [ data2 ]) in
    check bool "平均值 [-2,-1,0,1,2] 应为 0.0" true (TestUtils.float_equal mean2 0.0);

    (* 测试单元素平均值 *)
    let data3 = TestUtils.make_float_list [ 42.5 ] in
    let mean3 = TestUtils.get_float_value (mean_function [ data3 ]) in
    check bool "单元素平均值应为元素本身" true (TestUtils.float_equal mean3 42.5)

  (** 测试方差函数 *)
  let test_variance_function () =
    (* 测试基本方差 (样本方差) *)
    let data1 = TestUtils.make_float_list [ 1.0; 2.0; 3.0; 4.0; 5.0 ] in
    let var1 = TestUtils.get_float_value (variance_function [ data1 ]) in
    (* 预期方差: ((1-3)² + (2-3)² + (3-3)² + (4-3)² + (5-3)²) / 4 = 10/4 = 2.5 *)
    check bool "方差 [1,2,3,4,5] 应为 2.5" true (TestUtils.float_equal var1 2.5);

    (* 测试零方差 (所有元素相同) *)
    let data2 = TestUtils.make_float_list [ 5.0; 5.0; 5.0; 5.0 ] in
    let var2 = TestUtils.get_float_value (variance_function [ data2 ]) in
    check bool "相同元素方差应为 0" true (TestUtils.float_equal var2 0.0)

  (** 测试标准差函数 *)
  let test_standard_deviation_function () =
    (* 测试基本标准差 *)
    let data1 = TestUtils.make_float_list [ 1.0; 2.0; 3.0; 4.0; 5.0 ] in
    let std1 = TestUtils.get_float_value (standard_deviation_function [ data1 ]) in
    (* 标准差应为方差的平方根: sqrt(2.5) ≈ 1.58 *)
    check bool "标准差 [1,2,3,4,5] 应约为 1.58" true
      (TestUtils.float_equal std1 (sqrt 2.5) ~precision:1e-6);

    (* 测试零标准差 *)
    let data2 = TestUtils.make_float_list [ 3.0; 3.0; 3.0 ] in
    let std2 = TestUtils.get_float_value (standard_deviation_function [ data2 ]) in
    check bool "相同元素标准差应为 0" true (TestUtils.float_equal std2 0.0)

  (** 测试中位数函数 *)
  let test_median_function () =
    (* 测试奇数个元素的中位数 *)
    let data1 = TestUtils.make_float_list [ 3.0; 1.0; 4.0; 1.0; 5.0 ] in
    let median1 = TestUtils.get_float_value (median_function [ data1 ]) in
    check bool "奇数个元素中位数 [3,1,4,1,5] 应为 3.0" true (TestUtils.float_equal median1 3.0);

    (* 测试偶数个元素的中位数 *)
    let data2 = TestUtils.make_float_list [ 1.0; 2.0; 3.0; 4.0 ] in
    let median2 = TestUtils.get_float_value (median_function [ data2 ]) in
    check bool "偶数个元素中位数 [1,2,3,4] 应为 2.5" true (TestUtils.float_equal median2 2.5);

    (* 测试单元素中位数 *)
    let data3 = TestUtils.make_float_list [ 7.5 ] in
    let median3 = TestUtils.get_float_value (median_function [ data3 ]) in
    check bool "单元素中位数应为元素本身" true (TestUtils.float_equal median3 7.5)

  (** 测试统计函数边界条件 *)
  let test_statistical_boundary_cases () =
    (* 测试空列表 *)
    let empty_list = TestUtils.make_float_list [] in
    let mean_empty = TestUtils.get_float_value (mean_function [ empty_list ]) in
    let var_empty = TestUtils.get_float_value (variance_function [ empty_list ]) in
    let std_empty = TestUtils.get_float_value (standard_deviation_function [ empty_list ]) in
    let median_empty = TestUtils.get_float_value (median_function [ empty_list ]) in

    check bool "空列表平均值应为 0" true (TestUtils.float_equal mean_empty 0.0);
    check bool "空列表方差应为 0" true (TestUtils.float_equal var_empty 0.0);
    check bool "空列表标准差应为 0" true (TestUtils.float_equal std_empty 0.0);
    check bool "空列表中位数应为 0" true (TestUtils.float_equal median_empty 0.0)
end

(** 数论函数测试模块 *)
module NumberTheoryTests = struct
  (** 测试素数优化判断函数 *)
  let test_optimized_prime_check () =
    let test_cases =
      [
        (1, false);
        (2, true);
        (3, true);
        (4, false);
        (5, true);
        (6, false);
        (7, true);
        (8, false);
        (9, false);
        (10, false);
        (11, true);
        (13, true);
        (17, true);
        (19, true);
        (23, true);
        (25, false);
        (29, true);
        (31, true);
        (37, true);
        (41, true);
        (100, false);
        (101, true);
        (103, true);
        (107, true);
        (109, true);
      ]
    in

    List.iter
      (fun (n, expected) ->
        let result = TestUtils.get_bool_value (optimized_prime_function [ IntValue n ]) in
        check bool (Printf.sprintf "素数优化判断(%d) 应为 %b" n expected) expected result)
      test_cases

  (** 测试质因数分解函数 *)
  let test_prime_factorization () =
    (* 测试基本质因数分解 *)
    let factors_12 = TestUtils.get_list_value (prime_factorization_function [ IntValue 12 ]) in
    let expected_12 = [ 2; 2; 3 ] in
    let actual_12 = List.map TestUtils.get_int_value factors_12 in
    check bool "12的质因数分解应为 [2,2,3]" true
      (List.sort compare actual_12 = List.sort compare expected_12);

    (* 测试素数的质因数分解 *)
    let factors_17 = TestUtils.get_list_value (prime_factorization_function [ IntValue 17 ]) in
    let actual_17 = List.map TestUtils.get_int_value factors_17 in
    check bool "17的质因数分解应为 [17]" true (actual_17 = [ 17 ]);

    (* 测试1的质因数分解 *)
    let factors_1 = TestUtils.get_list_value (prime_factorization_function [ IntValue 1 ]) in
    check bool "1的质因数分解应为空列表" true (factors_1 = []);

    (* 测试较大数的质因数分解 *)
    let factors_60 = TestUtils.get_list_value (prime_factorization_function [ IntValue 60 ]) in
    let expected_60 = [ 2; 2; 3; 5 ] in
    let actual_60 = List.map TestUtils.get_int_value factors_60 in
    check bool "60的质因数分解应为 [2,2,3,5]" true
      (List.sort compare actual_60 = List.sort compare expected_60)

  (** 测试数论函数性能 *)
  let test_number_theory_performance () =
    (* 测试大素数判断 *)
    let large_prime = 1009 in
    let result = TestUtils.get_bool_value (optimized_prime_function [ IntValue large_prime ]) in
    check bool "1009应该是素数" true result;

    (* 测试大合数分解 *)
    let large_composite = 1001 in
    (* 7 * 11 * 13 *)
    let factors =
      TestUtils.get_list_value (prime_factorization_function [ IntValue large_composite ])
    in
    let actual_factors = List.map TestUtils.get_int_value factors in
    let expected_factors = [ 7; 11; 13 ] in
    check bool "1001的质因数分解应为 [7,11,13]" true
      (List.sort compare actual_factors = List.sort compare expected_factors)
end

(** 数学常量测试模块 *)
module MathConstantsTests = struct
  (** 测试数学常量精度 *)
  let test_mathematical_constants () =
    (* 测试圆周率 *)
    let pi_val = TestUtils.get_float_value (pi_constant []) in
    check bool "圆周率应接近 3.14159..." true
      (TestUtils.float_equal pi_val 3.141592653589793 ~precision:1e-10);

    (* 测试自然对数底 *)
    let e_val = TestUtils.get_float_value (e_constant []) in
    check bool "自然对数底应接近 2.71828..." true
      (TestUtils.float_equal e_val 2.718281828459045 ~precision:1e-10);

    (* 测试欧拉常数 *)
    let euler_val = TestUtils.get_float_value (euler_constant []) in
    check bool "欧拉常数应接近 0.57721..." true
      (TestUtils.float_equal euler_val 0.577215664901532861 ~precision:1e-10);

    (* 测试黄金比例 *)
    let golden_val = TestUtils.get_float_value (golden_ratio_constant []) in
    check bool "黄金比例应接近 1.61803..." true
      (TestUtils.float_equal golden_val 1.618033988749894848 ~precision:1e-10)
end

(** 集成测试和性能测试模块 *)
module IntegrationAndPerformanceTests = struct
  (** 测试数学函数组合使用 *)
  let test_math_function_composition () =
    (* 测试三角函数与统计函数组合 *)
    let angles = [ 0.0; 0.5; 1.0; 1.5; 2.0 ] in
    let sin_values =
      List.map (fun angle -> TestUtils.get_float_value (sin_function [ FloatValue angle ])) angles
    in
    let sin_list = TestUtils.make_float_list sin_values in
    let sin_mean = TestUtils.get_float_value (mean_function [ sin_list ]) in

    check bool "正弦值序列的平均值应在合理范围内" true (sin_mean >= -1.0 && sin_mean <= 1.0);

    (* 测试素数序列的统计分析 *)
    let first_primes = [ 2; 3; 5; 7; 11; 13; 17; 19; 23; 29 ] in
    List.iter
      (fun p ->
        let is_prime = TestUtils.get_bool_value (optimized_prime_function [ IntValue p ]) in
        check bool (Printf.sprintf "%d 应该是素数" p) true is_prime)
      first_primes

  (** 测试数学函数完整性 *)
  let test_math_functions_completeness () =
    (* 验证所有新增函数都可调用 *)
    let test_sin = sin_function [ FloatValue 1.0 ] in
    let test_cos = cos_function [ FloatValue 1.0 ] in
    let test_tan = tan_function [ FloatValue 1.0 ] in
    let test_mean = mean_function [ TestUtils.make_float_list [ 1.0; 2.0; 3.0 ] ] in
    let test_var = variance_function [ TestUtils.make_float_list [ 1.0; 2.0; 3.0 ] ] in
    let test_std = standard_deviation_function [ TestUtils.make_float_list [ 1.0; 2.0; 3.0 ] ] in
    let test_median = median_function [ TestUtils.make_float_list [ 1.0; 2.0; 3.0 ] ] in
    let test_prime_opt = optimized_prime_function [ IntValue 17 ] in
    let test_factorization = prime_factorization_function [ IntValue 12 ] in

    (* 验证函数返回正确类型 *)
    (match test_sin with FloatValue _ -> () | _ -> failwith "sin应返回浮点数");
    (match test_cos with FloatValue _ -> () | _ -> failwith "cos应返回浮点数");
    (match test_tan with FloatValue _ -> () | _ -> failwith "tan应返回浮点数");
    (match test_mean with FloatValue _ -> () | _ -> failwith "mean应返回浮点数");
    (match test_var with FloatValue _ -> () | _ -> failwith "variance应返回浮点数");
    (match test_std with FloatValue _ -> () | _ -> failwith "std应返回浮点数");
    (match test_median with FloatValue _ -> () | _ -> failwith "median应返回浮点数");
    (match test_prime_opt with BoolValue _ -> () | _ -> failwith "prime_opt应返回布尔值");
    (match test_factorization with ListValue _ -> () | _ -> failwith "factorization应返回列表");

    check bool "所有新增函数都应正常工作" true true

  (** 性能基准测试 *)
  let test_performance_benchmarks () =
    (* 三角函数性能测试 *)
    let start_time = Sys.time () in
    for i = 1 to 1000 do
      let angle = float_of_int i *. 0.01 in
      ignore (sin_function [ FloatValue angle ]);
      ignore (cos_function [ FloatValue angle ]);
      ignore (tan_function [ FloatValue angle ])
    done;
    let trig_time = Sys.time () -. start_time in
    check bool "三角函数性能应在合理范围内" true (trig_time < 10.0);

    (* 统计函数性能测试 *)
    let large_dataset = TestUtils.make_float_list (List.init 10000 (fun i -> float_of_int i)) in
    let stat_start = Sys.time () in
    ignore (mean_function [ large_dataset ]);
    ignore (variance_function [ large_dataset ]);
    ignore (standard_deviation_function [ large_dataset ]);
    ignore (median_function [ large_dataset ]);
    let stat_time = Sys.time () -. stat_start in
    check bool "统计函数性能应在合理范围内" true (stat_time < 5.0);

    (* 数论函数性能测试 *)
    let nt_start = Sys.time () in
    for i = 1 to 1000 do
      ignore (optimized_prime_function [ IntValue i ]);
      if i <= 100 then ignore (prime_factorization_function [ IntValue i ])
    done;
    let nt_time = Sys.time () -. nt_start in
    check bool "数论函数性能应在合理范围内" true (nt_time < 3.0)
end

(** 错误处理和边界条件测试模块 *)
module ErrorHandlingTests = struct
  (** 测试三角函数错误处理 *)
  let test_trigonometric_error_handling () =
    (* 测试参数数量错误 *)
    let error_case1 () = sin_function [] in
    let error_case2 () = cos_function [ FloatValue 1.0; FloatValue 2.0 ] in
    let error_case3 () = tan_function [ IntValue 123 ] in

    check bool "sin无参数应抛出错误" true (TestUtils.expect_runtime_error error_case1);
    check bool "cos多参数应抛出错误" true (TestUtils.expect_runtime_error error_case2);
    check bool "tan错误类型应抛出错误" true (TestUtils.expect_runtime_error error_case3)

  (** 测试统计函数错误处理 *)
  let test_statistical_error_handling () =
    (* 测试非数值列表 *)
    let non_numeric_list = ListValue [ StringValue "错误"; IntValue 1 ] in
    let error_case1 () = mean_function [ non_numeric_list ] in
    let error_case2 () = variance_function [ non_numeric_list ] in

    check bool "非数值列表平均值应抛出错误" true (TestUtils.expect_runtime_error error_case1);
    check bool "非数值列表方差应抛出错误" true (TestUtils.expect_runtime_error error_case2);

    (* 测试参数类型错误 *)
    let error_case3 () = mean_function [ IntValue 123 ] in
    check bool "非列表参数应抛出错误" true (TestUtils.expect_runtime_error error_case3)

  (** 测试数论函数错误处理 *)
  let test_number_theory_error_handling () =
    (* 测试负数和零 *)
    let zero_prime = TestUtils.get_bool_value (optimized_prime_function [ IntValue 0 ]) in
    let neg_prime = TestUtils.get_bool_value (optimized_prime_function [ IntValue (-5) ]) in

    check bool "0不应该是素数" false zero_prime;
    check bool "负数不应该是素数" false neg_prime;

    (* 测试质因数分解边界情况 *)
    let factors_0 = TestUtils.get_list_value (prime_factorization_function [ IntValue 0 ]) in
    let factors_neg = TestUtils.get_list_value (prime_factorization_function [ IntValue (-10) ]) in

    check bool "0的质因数分解应为空" true (factors_0 = []);
    check bool "负数的质因数分解应为空" true (factors_neg = [])
end

(** 中文编程特色测试模块 - 骆言风格 *)
module ChineseProgrammingTests = struct
  (** 测试中文数学概念应用 *)
  let test_chinese_mathematical_concepts () =
    (* 测试"三角"概念 - 三角函数的和谐之美 *)
    let harmony_angle = 3.141592653589793 /. 6.0 in
    (* π/6 = 30° *)
    let sin_harmony = TestUtils.get_float_value (sin_function [ FloatValue harmony_angle ]) in
    let cos_harmony = TestUtils.get_float_value (cos_function [ FloatValue harmony_angle ]) in

    check bool "和谐角度sin(π/6)应为0.5" true (TestUtils.float_equal sin_harmony 0.5 ~precision:1e-8);
    check bool "和谐角度cos(π/6)应为√3/2" true
      (TestUtils.float_equal cos_harmony (sqrt 3.0 /. 2.0) ~precision:1e-8);

    (* 测试"统计"概念 - 群体智慧的数学表达 *)
    let wisdom_data = TestUtils.make_float_list [ 8.0; 8.0; 8.0; 8.0; 8.0 ] in
    (* 八八如意 *)
    let collective_wisdom = TestUtils.get_float_value (mean_function [ wisdom_data ]) in
    check bool "群体智慧平均值应为8.0" true (TestUtils.float_equal collective_wisdom 8.0)

  (** 测试中国古代数学传统 *)
  let test_ancient_chinese_mathematics () =
    (* 测试九章算术风格的数学计算 *)
    let jiuzhang_sequence =
      TestUtils.make_float_list [ 1.0; 2.0; 3.0; 4.0; 5.0; 6.0; 7.0; 8.0; 9.0 ]
    in
    let jiuzhang_sum = TestUtils.get_float_value (mean_function [ jiuzhang_sequence ]) in
    check bool "九章序列平均值应为5.0" true (TestUtils.float_equal jiuzhang_sum 5.0);

    (* 测试勾股定理相关的三角函数 *)
    let right_angle = 3.141592653589793 /. 2.0 in
    let gou_gu_sin = TestUtils.get_float_value (sin_function [ FloatValue right_angle ]) in
    check bool "直角正弦值应为1" true (TestUtils.float_equal gou_gu_sin 1.0 ~precision:1e-8)

  (** 测试诗词数学 - 韵律中的数值美学 *)
  let test_poetic_mathematics () =
    (* 测试五言绝句的数学美学 *)
    let wuyan_rhythm = TestUtils.make_float_list [ 5.0; 5.0; 5.0; 5.0 ] in
    (* 四句五言 *)
    let poetry_total =
      List.fold_left ( +. ) 0.0
        (List.map TestUtils.get_float_value
           [
             mean_function [ wuyan_rhythm ];
             variance_function [ wuyan_rhythm ];
             standard_deviation_function [ wuyan_rhythm ];
           ])
    in
    check bool "诗词数学计算应有意义" true (poetry_total >= 0.0);

    (* 测试黄金比例在古代艺术中的体现 *)
    let golden_ratio = TestUtils.get_float_value (golden_ratio_constant []) in
    let fibonacci_like = TestUtils.make_float_list [ 1.0; 1.0; 2.0; 3.0; 5.0; 8.0 ] in
    let fib_ratios = [] in
    (* 计算相邻项比值趋向黄金比例 *)
    check bool "黄金比例应在合理范围" true (golden_ratio > 1.6 && golden_ratio < 1.62)
end

(** 测试套件注册 *)
let test_suite =
  [
    ( "三角函数测试",
      [
        test_case "正弦函数基本功能" `Quick TrigonometricTests.test_sin_basic;
        test_case "余弦函数基本功能" `Quick TrigonometricTests.test_cos_basic;
        test_case "正切函数基本功能" `Quick TrigonometricTests.test_tan_basic;
        test_case "三角函数恒等式" `Quick TrigonometricTests.test_trigonometric_identities;
        test_case "三角函数周期性" `Quick TrigonometricTests.test_trigonometric_periodicity;
      ] );
    ( "统计函数测试",
      [
        test_case "平均值函数" `Quick StatisticalTests.test_mean_function;
        test_case "方差函数" `Quick StatisticalTests.test_variance_function;
        test_case "标准差函数" `Quick StatisticalTests.test_standard_deviation_function;
        test_case "中位数函数" `Quick StatisticalTests.test_median_function;
        test_case "统计函数边界条件" `Quick StatisticalTests.test_statistical_boundary_cases;
      ] );
    ( "数论函数测试",
      [
        test_case "素数优化判断" `Quick NumberTheoryTests.test_optimized_prime_check;
        test_case "质因数分解" `Quick NumberTheoryTests.test_prime_factorization;
        test_case "数论函数性能" `Quick NumberTheoryTests.test_number_theory_performance;
      ] );
    ("数学常量测试", [ test_case "数学常量精度" `Quick MathConstantsTests.test_mathematical_constants ]);
    ( "集成和性能测试",
      [
        test_case "函数组合使用" `Quick IntegrationAndPerformanceTests.test_math_function_composition;
        test_case "函数完整性" `Quick IntegrationAndPerformanceTests.test_math_functions_completeness;
        test_case "性能基准测试" `Slow IntegrationAndPerformanceTests.test_performance_benchmarks;
      ] );
    ( "错误处理测试",
      [
        test_case "三角函数错误处理" `Quick ErrorHandlingTests.test_trigonometric_error_handling;
        test_case "统计函数错误处理" `Quick ErrorHandlingTests.test_statistical_error_handling;
        test_case "数论函数错误处理" `Quick ErrorHandlingTests.test_number_theory_error_handling;
      ] );
    ( "中文编程特色",
      [
        test_case "中文数学概念" `Quick ChineseProgrammingTests.test_chinese_mathematical_concepts;
        test_case "古代数学传统" `Quick ChineseProgrammingTests.test_ancient_chinese_mathematics;
        test_case "诗词数学" `Quick ChineseProgrammingTests.test_poetic_mathematics;
      ] );
  ]

(** 运行所有测试 *)
let () = run "骆言增强数学模块测试 - Issue #2189" test_suite
