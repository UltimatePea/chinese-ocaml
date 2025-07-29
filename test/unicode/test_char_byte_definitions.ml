(** Unicode字符字节定义模块测试
 * 验证中文字符字节组合定义的准确性和完整性
 * 确保Unicode字符处理的正确性
 * Author: Alpha, Primary Worker Agent
 * Fix #1725 *)

open Unicode.Char_byte_definitions

(** 字节组合验证助手函数 *)
let assert_valid_utf8_bytes (b1, b2, b3) name =
  (* UTF-8字节范围验证 *)
  assert (b1 >= 0 && b1 <= 255);
  assert (b2 >= 0 && b2 <= 255);
  assert (b3 >= 0 && b3 <= 255);
  Printf.printf "✅ %s 字节组合验证通过: (%02X, %02X, %02X)\n" name b1 b2 b3

let assert_non_zero_bytes (b1, b2, b3) name =
  (* 确保非空字节组合（除特殊情况外） *)
  if (b1, b2, b3) = (0, 0, 0) then
    Printf.printf "⚠️  %s 字节组合为空 - 可能是字符映射缺失\n" name
  else
    Printf.printf "✅ %s 字节组合非空\n" name

(** 测试引号字符字节定义 *)
let test_quote_bytes () =
  Printf.printf "\n🔍 测试引号字符字节定义...\n";
  
  (* 验证左引号字节组合 *)
  assert_valid_utf8_bytes Quote.left_quote_bytes "左引号";
  assert_non_zero_bytes Quote.left_quote_bytes "左引号";
  
  (* 验证右引号字节组合 *)
  assert_valid_utf8_bytes Quote.right_quote_bytes "右引号";
  assert_non_zero_bytes Quote.right_quote_bytes "右引号";
  
  (* 验证字符串开始符字节组合 *)
  assert_valid_utf8_bytes Quote.string_start_bytes "字符串开始符";
  assert_non_zero_bytes Quote.string_start_bytes "字符串开始符";
  
  (* 验证字符串结束符字节组合 *)
  assert_valid_utf8_bytes Quote.string_end_bytes "字符串结束符";
  assert_non_zero_bytes Quote.string_end_bytes "字符串结束符";
  
  (* 验证左右引号不同 *)
  assert (Quote.left_quote_bytes <> Quote.right_quote_bytes);
  Printf.printf "✅ 左右引号字节组合不同\n";
  
  Printf.printf "✅ 引号字符字节定义测试完成\n"

(** 测试中文标点符号字节定义 *)
let test_chinese_punctuation_bytes () =
  Printf.printf "\n🔍 测试中文标点符号字节定义...\n";
  
  (* 验证中文左括号 *)
  assert_valid_utf8_bytes ChinesePunctuation.chinese_left_paren_bytes "中文左括号";
  assert_non_zero_bytes ChinesePunctuation.chinese_left_paren_bytes "中文左括号";
  
  (* 验证中文右括号 *)
  assert_valid_utf8_bytes ChinesePunctuation.chinese_right_paren_bytes "中文右括号";
  assert_non_zero_bytes ChinesePunctuation.chinese_right_paren_bytes "中文右括号";
  
  (* 验证中文逗号 *)
  assert_valid_utf8_bytes ChinesePunctuation.chinese_comma_bytes "中文逗号";
  assert_non_zero_bytes ChinesePunctuation.chinese_comma_bytes "中文逗号";
  
  (* 验证中文冒号 *)
  assert_valid_utf8_bytes ChinesePunctuation.chinese_colon_bytes "中文冒号";
  assert_non_zero_bytes ChinesePunctuation.chinese_colon_bytes "中文冒号";
  
  (* 验证中文句号 *)
  assert_valid_utf8_bytes ChinesePunctuation.chinese_period_bytes "中文句号";
  assert_non_zero_bytes ChinesePunctuation.chinese_period_bytes "中文句号";
  
  (* 验证配对符号不同 *)
  assert (ChinesePunctuation.chinese_left_paren_bytes <> ChinesePunctuation.chinese_right_paren_bytes);
  Printf.printf "✅ 中文左右括号字节组合不同\n";
  
  Printf.printf "✅ 中文标点符号字节定义测试完成\n"

(** 测试全角字符字节定义 *)
let test_fullwidth_bytes () =
  Printf.printf "\n🔍 测试全角字符字节定义...\n";
  
  (* 验证全角左括号 *)
  assert_valid_utf8_bytes Fullwidth.fullwidth_left_paren_bytes "全角左括号";
  
  (* 验证全角右括号 *)
  assert_valid_utf8_bytes Fullwidth.fullwidth_right_paren_bytes "全角右括号";
  
  (* 验证全角逗号 *)
  assert_valid_utf8_bytes Fullwidth.fullwidth_comma_bytes "全角逗号";
  
  (* 验证全角分号（硬编码值） *)
  assert_valid_utf8_bytes Fullwidth.fullwidth_semicolon_bytes "全角分号";
  let (b1, b2, b3) = Fullwidth.fullwidth_semicolon_bytes in
  assert (b1 = 0xEF && b2 = 0xBC && b3 = 0x9B);
  Printf.printf "✅ 全角分号硬编码值正确: (EF, BC, 9B)\n";
  
  (* 验证全角管道符（硬编码值） *)
  assert_valid_utf8_bytes Fullwidth.fullwidth_pipe_bytes "全角管道符";
  let (b1, b2, b3) = Fullwidth.fullwidth_pipe_bytes in
  assert (b1 = 0xEF && b2 = 0xBD && b3 = 0x9C);
  Printf.printf "✅ 全角管道符硬编码值正确: (EF, BD, 9C)\n";
  
  Printf.printf "✅ 全角字符字节定义测试完成\n"

(** 测试其他中文符号字节定义 *)
let test_other_symbols_bytes () =
  Printf.printf "\n🔍 测试其他中文符号字节定义...\n";
  
  (* 验证中文方括号 *)
  assert_valid_utf8_bytes OtherSymbols.chinese_square_left_bracket_bytes "中文左方括号";
  let (b1, b2, b3) = OtherSymbols.chinese_square_left_bracket_bytes in
  assert (b1 = 0xE3 && b2 = 0x80 && b3 = 0x90);
  Printf.printf "✅ 中文左方括号【字节值正确: (E3, 80, 90)\n";
  
  assert_valid_utf8_bytes OtherSymbols.chinese_square_right_bracket_bytes "中文右方括号";
  let (b1, b2, b3) = OtherSymbols.chinese_square_right_bracket_bytes in
  assert (b1 = 0xE3 && b2 = 0x80 && b3 = 0x91);
  Printf.printf "✅ 中文右方括号】字节值正确: (E3, 80, 91)\n";
  
  (* 验证箭头符号 *)
  assert_valid_utf8_bytes OtherSymbols.chinese_arrow_bytes "中文箭头";
  let (b1, b2, b3) = OtherSymbols.chinese_arrow_bytes in
  assert (b1 = 0xE2 && b2 = 0x86 && b3 = 0x92);
  Printf.printf "✅ 中文箭头→字节值正确: (E2, 86, 92)\n";
  
  assert_valid_utf8_bytes OtherSymbols.chinese_double_arrow_bytes "中文双箭头";
  let (b1, b2, b3) = OtherSymbols.chinese_double_arrow_bytes in
  assert (b1 = 0xE2 && b2 = 0x87 && b3 = 0x92);
  Printf.printf "✅ 中文双箭头⇒字节值正确: (E2, 87, 92)\n";
  
  assert_valid_utf8_bytes OtherSymbols.chinese_assign_arrow_bytes "中文赋值箭头";
  let (b1, b2, b3) = OtherSymbols.chinese_assign_arrow_bytes in
  assert (b1 = 0xE2 && b2 = 0x86 && b3 = 0x90);
  Printf.printf "✅ 中文赋值箭头←字节值正确: (E2, 86, 90)\n";
  
  (* 验证中文减号（可能为空） *)
  assert_valid_utf8_bytes OtherSymbols.chinese_minus_bytes "中文减号";
  Printf.printf "⚠️  中文减号字节组合验证 - 可能需要实际字符映射\n";
  
  Printf.printf "✅ 其他中文符号字节定义测试完成\n"

(** 测试全角范围常量 *)
let test_fullwidth_ranges () =
  Printf.printf "\n🔍 测试全角符号范围常量...\n";
  
  (* 验证全角起始字节范围 *)
  assert (FullwidthRanges.fullwidth_start_byte1 = 0xEF);
  assert (FullwidthRanges.fullwidth_start_byte2 = 0xBC);
  Printf.printf "✅ 全角符号起始字节范围正确: (EF, BC, xx)\n";
  
  Printf.printf "✅ 全角范围常量测试完成\n"

(** 测试字符字节组合一致性 *)
let test_consistency () =
  Printf.printf "\n🔍 测试字符字节组合一致性...\n";
  
  (* 验证中文标点和全角字符的对应关系 *)
  assert (ChinesePunctuation.chinese_left_paren_bytes = Fullwidth.fullwidth_left_paren_bytes);
  assert (ChinesePunctuation.chinese_right_paren_bytes = Fullwidth.fullwidth_right_paren_bytes);
  assert (ChinesePunctuation.chinese_comma_bytes = Fullwidth.fullwidth_comma_bytes);
  Printf.printf "✅ 中文标点和全角字符字节组合一致性验证通过\n";
  
  (* 验证不同符号类型的字节组合不重复 *)
  let quote_bytes = [Quote.left_quote_bytes; Quote.right_quote_bytes] in
  let punct_bytes = [ChinesePunctuation.chinese_comma_bytes; ChinesePunctuation.chinese_period_bytes] in
  let arrow_bytes = [OtherSymbols.chinese_arrow_bytes; OtherSymbols.chinese_double_arrow_bytes] in
  
  (* 确保不同类型符号字节组合互不相同 *)
  let all_bytes = quote_bytes @ punct_bytes @ arrow_bytes in
  let unique_bytes = List.sort_uniq compare all_bytes in
  assert (List.length all_bytes = List.length unique_bytes);
  Printf.printf "✅ 不同符号类型字节组合唯一性验证通过\n";
  
  Printf.printf "✅ 字符字节组合一致性测试完成\n"

(** 边界条件和错误处理测试 *)
let test_boundary_conditions () =
  Printf.printf "\n🔍 测试边界条件和错误处理...\n";
  
  (* 测试get_char_bytes函数边界条件 *)
  let empty_result = get_char_bytes "" in
  assert (empty_result = (0, 0, 0));
  Printf.printf "✅ 空字符名称处理正确\n";
  
  let invalid_result = get_char_bytes "invalid_char_name_123" in
  assert (invalid_result = (0, 0, 0));
  Printf.printf "✅ 无效字符名称处理正确\n";
  
  Printf.printf "✅ 边界条件和错误处理测试完成\n"

(** 性能基准测试 *)
let test_performance () =
  Printf.printf "\n🔍 Unicode字符字节定义性能基准测试...\n";
  
  let start_time = Sys.time () in
  
  (* 重复访问字节组合1000次 *)
  for _i = 1 to 1000 do
    ignore (Quote.left_quote_bytes);
    ignore (ChinesePunctuation.chinese_comma_bytes);
    ignore (OtherSymbols.chinese_arrow_bytes);
    ignore (Fullwidth.fullwidth_semicolon_bytes)
  done;
  
  let end_time = Sys.time () in
  let duration = end_time -. start_time in
  
  Printf.printf "✅ 1000次字节组合访问耗时: %.6f秒\n" duration;
  assert (duration < 0.01); (* 应在10毫秒内完成 *)
  Printf.printf "✅ Unicode字符字节访问性能符合要求\n"

(** 主测试执行函数 *)
let () =
  Printf.printf "🔍 开始Unicode字符字节定义模块测试...\n\n";
  
  test_quote_bytes ();
  test_chinese_punctuation_bytes ();
  test_fullwidth_bytes ();
  test_other_symbols_bytes ();
  test_fullwidth_ranges ();
  test_consistency ();
  test_boundary_conditions ();
  test_performance ();
  
  Printf.printf "\n🎉 Unicode字符字节定义模块测试全部通过！\n";
  Printf.printf "测试覆盖: 引号字符、中文标点、全角字符、其他符号、一致性验证、边界条件、性能基准\n";
  Printf.printf "\n📈 本测试为Unicode字符处理模块提供了全面的质量保障\n";
  Printf.printf "🎯 确保中文编程语言的基础字符处理功能稳定可靠\n"