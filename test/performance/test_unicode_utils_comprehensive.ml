(** Unicode工具函数全面测试套件

    测试目标: unicode/unicode_utils.ml 覆盖范围:
    - FullwidthDigit模块的全角数字处理
    - Checks模块的Unicode字符检查
    - 字节前缀检查功能
    - 边界条件和错误情况

    @version 1.0
    @since 2025-07-23 *)

open Unicode.Unicode_utils
open Unicode.Unicode_types

(** FullwidthDigit模块测试 *)
let test_fullwidth_digit_basic () =
  (* 测试全角数字范围的定义 *)
  assert (FullwidthDigit.start_byte3 = 0x90);
  (* ０ *)
  assert (FullwidthDigit.end_byte3 = 0x99);

  (* ９ *)

  (* 验证范围的合理性 *)
  assert (FullwidthDigit.start_byte3 <= FullwidthDigit.end_byte3);
  assert (FullwidthDigit.end_byte3 - FullwidthDigit.start_byte3 = 9);

  (* 0-9共10个数字 *)
  print_endline "✅ FullwidthDigit基础定义测试通过"

let test_fullwidth_digit_detection () =
  (* 测试全角数字的检测 *)

  (* 测试范围内的字节 - 应该被识别为全角数字 *)
  assert (FullwidthDigit.is_fullwidth_digit 0x90);
  (* ０ *)
  assert (FullwidthDigit.is_fullwidth_digit 0x91);
  (* １ *)
  assert (FullwidthDigit.is_fullwidth_digit 0x92);
  (* ２ *)
  assert (FullwidthDigit.is_fullwidth_digit 0x93);
  (* ３ *)
  assert (FullwidthDigit.is_fullwidth_digit 0x94);
  (* ４ *)
  assert (FullwidthDigit.is_fullwidth_digit 0x95);
  (* ５ *)
  assert (FullwidthDigit.is_fullwidth_digit 0x96);
  (* ６ *)
  assert (FullwidthDigit.is_fullwidth_digit 0x97);
  (* ７ *)
  assert (FullwidthDigit.is_fullwidth_digit 0x98);
  (* ８ *)
  assert (FullwidthDigit.is_fullwidth_digit 0x99);

  (* ９ *)
  print_endline "✅ FullwidthDigit数字检测测试通过"

let test_fullwidth_digit_boundaries () =
  (* 测试边界条件 *)

  (* 范围边界的测试 *)
  assert (FullwidthDigit.is_fullwidth_digit 0x90);
  (* 下边界，应该为真 *)
  assert (FullwidthDigit.is_fullwidth_digit 0x99);

  (* 上边界，应该为真 *)

  (* 超出范围的测试 *)
  assert (not (FullwidthDigit.is_fullwidth_digit 0x8F));
  (* 下边界-1，应该为假 *)
  assert (not (FullwidthDigit.is_fullwidth_digit 0x9A));

  (* 上边界+1，应该为假 *)

  (* 更远范围的测试 *)
  assert (not (FullwidthDigit.is_fullwidth_digit 0x00));
  (* 最小值 *)
  assert (not (FullwidthDigit.is_fullwidth_digit 0xFF));
  (* 最大值 *)
  assert (not (FullwidthDigit.is_fullwidth_digit 0x30));
  (* ASCII '0' *)
  assert (not (FullwidthDigit.is_fullwidth_digit 0x39));

  (* ASCII '9' *)
  print_endline "✅ FullwidthDigit边界条件测试通过"

(** Checks模块测试 *)
let test_checks_basic_functionality () =
  (* 测试中文标点符号前缀检查 *)
  let chinese_punct_result = Checks.is_chinese_punctuation_prefix Prefix.chinese_punctuation in
  assert chinese_punct_result;

  (* 测试中文运算符前缀检查 *)
  let chinese_op_result = Checks.is_chinese_operator_prefix Prefix.chinese_operator in
  assert chinese_op_result;

  (* 测试箭头符号前缀检查 *)
  let arrow_result = Checks.is_arrow_symbol_prefix Prefix.arrow_symbol in
  assert arrow_result;

  (* 测试全角前缀检查 *)
  let fullwidth_result = Checks.is_fullwidth_prefix Prefix.fullwidth in
  assert fullwidth_result;

  print_endline "✅ Checks基础功能测试通过"

let test_checks_negative_cases () =
  (* 测试错误的前缀不会被误识别 *)

  (* 使用错误的字节值测试中文标点符号检查 *)
  assert (not (Checks.is_chinese_punctuation_prefix 0x00));
  assert (not (Checks.is_chinese_punctuation_prefix 0xFF));

  (* 使用错误的字节值测试中文运算符检查 *)
  assert (not (Checks.is_chinese_operator_prefix 0x00));
  assert (not (Checks.is_chinese_operator_prefix 0xFF));

  (* 使用错误的字节值测试箭头符号检查 *)
  assert (not (Checks.is_arrow_symbol_prefix 0x00));
  assert (not (Checks.is_arrow_symbol_prefix 0xFF));

  (* 使用错误的字节值测试全角前缀检查 *)
  assert (not (Checks.is_fullwidth_prefix 0x00));
  assert (not (Checks.is_fullwidth_prefix 0xFF));

  print_endline "✅ Checks负面情况测试通过"

let test_checks_cross_validation () =
  (* 交叉验证：确保不同前缀互不干扰 *)

  (* 中文标点符号前缀不应该被其他检查函数识别 *)
  assert (not (Checks.is_chinese_operator_prefix Prefix.chinese_punctuation));
  assert (not (Checks.is_arrow_symbol_prefix Prefix.chinese_punctuation));
  assert (not (Checks.is_fullwidth_prefix Prefix.chinese_punctuation));

  (* 中文运算符前缀不应该被其他检查函数识别 *)
  assert (not (Checks.is_chinese_punctuation_prefix Prefix.chinese_operator));
  assert (not (Checks.is_arrow_symbol_prefix Prefix.chinese_operator));
  assert (not (Checks.is_fullwidth_prefix Prefix.chinese_operator));

  (* 箭头符号前缀不应该被其他检查函数识别 *)
  assert (not (Checks.is_chinese_punctuation_prefix Prefix.arrow_symbol));
  assert (not (Checks.is_chinese_operator_prefix Prefix.arrow_symbol));
  assert (not (Checks.is_fullwidth_prefix Prefix.arrow_symbol));

  (* 全角前缀不应该被其他检查函数识别 *)
  assert (not (Checks.is_chinese_punctuation_prefix Prefix.fullwidth));
  assert (not (Checks.is_chinese_operator_prefix Prefix.fullwidth));
  assert (not (Checks.is_arrow_symbol_prefix Prefix.fullwidth));

  print_endline "✅ Checks交叉验证测试通过"

(** 前缀值一致性测试 *)
let test_prefix_consistency () =
  (* 验证前缀值在合理的Unicode范围内 *)
  let validate_prefix prefix name =
    (* Unicode字节值应该在0-255范围内 *)
    assert (prefix >= 0 && prefix <= 255);
    (* 打印前缀值用于调试（可选） *)
    Printf.printf "   %s前缀值: 0x%02X\n" name prefix
  in

  validate_prefix Prefix.chinese_punctuation "中文标点符号";
  validate_prefix Prefix.chinese_operator "中文运算符";
  validate_prefix Prefix.arrow_symbol "箭头符号";
  validate_prefix Prefix.fullwidth "全角字符";

  print_endline "✅ 前缀值一致性测试通过"

(** 性能测试 *)
let test_performance () =
  (* 测试FullwidthDigit.is_fullwidth_digit的性能 *)
  for _ = 1 to 10000 do
    for byte3 = 0x80 to 0xBF do
      ignore (FullwidthDigit.is_fullwidth_digit byte3)
    done
  done;

  (* 测试Checks模块各函数的性能 *)
  for _ = 1 to 10000 do
    for byte = 0x80 to 0xBF do
      ignore (Checks.is_chinese_punctuation_prefix byte);
      ignore (Checks.is_chinese_operator_prefix byte);
      ignore (Checks.is_arrow_symbol_prefix byte);
      ignore (Checks.is_fullwidth_prefix byte)
    done
  done;

  print_endline "✅ 性能压力测试通过"

(** 边界条件综合测试 *)
let test_comprehensive_edge_cases () =
  (* 测试所有可能的字节值 *)
  for byte = 0 to 255 do
    (* FullwidthDigit检查不应该导致崩溃 *)
    ignore (FullwidthDigit.is_fullwidth_digit byte);

    (* Checks模块的所有函数都不应该导致崩溃 *)
    ignore (Checks.is_chinese_punctuation_prefix byte);
    ignore (Checks.is_chinese_operator_prefix byte);
    ignore (Checks.is_arrow_symbol_prefix byte);
    ignore (Checks.is_fullwidth_prefix byte)
  done;

  print_endline "✅ 综合边界条件测试通过"

(** 功能正确性验证 *)
let test_correctness_validation () =
  (* 验证全角数字检测的正确性 *)
  let fullwidth_digit_count =
    List.fold_left
      (fun acc byte3 -> if FullwidthDigit.is_fullwidth_digit byte3 then acc + 1 else acc)
      0
      (List.init 256 (fun i -> i))
  in
  (* 应该恰好检测到10个全角数字 (0x90-0x99) *)
  assert (fullwidth_digit_count = 10);

  (* 验证前缀检查的唯一性 *)
  let prefix_values =
    [ Prefix.chinese_punctuation; Prefix.chinese_operator; Prefix.arrow_symbol; Prefix.fullwidth ]
  in

  (* 确保前缀值互不相同（如果定义正确的话） *)
  let rec check_uniqueness = function
    | [] | [ _ ] -> ()
    | x :: xs ->
        assert (not (List.mem x xs));
        check_uniqueness xs
  in
  check_uniqueness prefix_values;

  print_endline "✅ 功能正确性验证测试通过"

(** 主测试运行器 *)
let run_all_tests () =
  print_endline "🧪 开始Unicode工具函数全面测试...";
  print_endline "";

  (* FullwidthDigit模块测试 *)
  test_fullwidth_digit_basic ();
  test_fullwidth_digit_detection ();
  test_fullwidth_digit_boundaries ();

  (* Checks模块测试 *)
  test_checks_basic_functionality ();
  test_checks_negative_cases ();
  test_checks_cross_validation ();

  (* 一致性和正确性测试 *)
  test_prefix_consistency ();
  test_correctness_validation ();

  (* 边界条件和性能测试 *)
  test_comprehensive_edge_cases ();
  test_performance ();

  print_endline "";
  print_endline "🎉 所有Unicode工具函数测试完成！";
  print_endline "📊 测试覆盖范围：";
  print_endline "   - FullwidthDigit全角数字检测: ✅";
  print_endline "   - FullwidthDigit边界条件: ✅";
  print_endline "   - Checks字符前缀检查: ✅";
  print_endline "   - Checks负面情况处理: ✅";
  print_endline "   - Checks交叉验证: ✅";
  print_endline "   - 前缀值一致性: ✅";
  print_endline "   - 功能正确性验证: ✅";
  print_endline "   - 综合边界条件: ✅";
  print_endline "   - 性能压力测试: ✅"

(* 如果直接运行此文件，执行所有测试 *)
let () = run_all_tests ()
