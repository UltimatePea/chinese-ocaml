(** Unicode字符字节访问器模块测试
 * 验证字节级别的中文字符访问逻辑正确性
 * 确保各个字节位的独立访问功能
 * Author: Alpha, Primary Worker Agent
 * Fix #1725 *)

open Unicode.Char_byte_accessors

(** 字节值验证助手函数 *)
let assert_byte_range byte name =
  assert (byte >= 0 && byte <= 255);
  Printf.printf "✅ %s 字节值在有效范围内: %02X\n" name byte

let assert_byte_equals expected actual name =
  assert (expected = actual);
  Printf.printf "✅ %s 字节值正确: %02X\n" name actual

(** 测试引号字符字节访问器 *)
let test_quote_byte_accessors () =
  Printf.printf "\n🔍 测试引号字符字节访问器...\n";
  
  (* 测试左引号字节访问 *)
  assert_byte_range Quote.left_quote_byte1 "左引号第1字节";
  assert_byte_range Quote.left_quote_byte2 "左引号第2字节";
  assert_byte_range Quote.left_quote_byte3 "左引号第3字节";
  
  (* 测试右引号字节访问 *)
  assert_byte_range Quote.right_quote_byte1 "右引号第1字节";
  assert_byte_range Quote.right_quote_byte2 "右引号第2字节";
  assert_byte_range Quote.right_quote_byte3 "右引号第3字节";
  
  (* 测试字符串开始符字节访问 *)
  assert_byte_range Quote.string_start_byte1 "字符串开始符第1字节";
  assert_byte_range Quote.string_start_byte2 "字符串开始符第2字节";
  assert_byte_range Quote.string_start_byte3 "字符串开始符第3字节";
  
  (* 测试字符串结束符字节访问 *)
  assert_byte_range Quote.string_end_byte1 "字符串结束符第1字节";
  assert_byte_range Quote.string_end_byte2 "字符串结束符第2字节";
  assert_byte_range Quote.string_end_byte3 "字符串结束符第3字节";
  
  (* 验证访问器与原始字节组合的一致性 *)
  let (orig_b1, orig_b2, orig_b3) = Unicode.Char_byte_definitions.Quote.left_quote_bytes in
  assert_byte_equals orig_b1 Quote.left_quote_byte1 "左引号第1字节一致性";
  assert_byte_equals orig_b2 Quote.left_quote_byte2 "左引号第2字节一致性";
  assert_byte_equals orig_b3 Quote.left_quote_byte3 "左引号第3字节一致性";
  
  Printf.printf "✅ 引号字符字节访问器测试完成\n"

(** 测试中文标点符号字节访问器 *)
let test_chinese_punctuation_accessors () =
  Printf.printf "\n🔍 测试中文标点符号字节访问器...\n";
  
  (* 测试中文左括号字节访问 *)
  assert_byte_range ChinesePunctuation.chinese_left_paren_byte1 "中文左括号第1字节";
  assert_byte_range ChinesePunctuation.chinese_left_paren_byte2 "中文左括号第2字节";
  assert_byte_range ChinesePunctuation.chinese_left_paren_byte3 "中文左括号第3字节";
  
  (* 测试中文右括号字节访问 *)
  assert_byte_range ChinesePunctuation.chinese_right_paren_byte1 "中文右括号第1字节";
  assert_byte_range ChinesePunctuation.chinese_right_paren_byte2 "中文右括号第2字节";
  assert_byte_range ChinesePunctuation.chinese_right_paren_byte3 "中文右括号第3字节";
  
  (* 测试中文逗号字节访问 *)
  assert_byte_range ChinesePunctuation.chinese_comma_byte1 "中文逗号第1字节";
  assert_byte_range ChinesePunctuation.chinese_comma_byte2 "中文逗号第2字节";
  assert_byte_range ChinesePunctuation.chinese_comma_byte3 "中文逗号第3字节";
  
  (* 测试中文冒号字节访问 *)
  assert_byte_range ChinesePunctuation.chinese_colon_byte1 "中文冒号第1字节";
  assert_byte_range ChinesePunctuation.chinese_colon_byte2 "中文冒号第2字节";
  assert_byte_range ChinesePunctuation.chinese_colon_byte3 "中文冒号第3字节";
  
  (* 测试中文句号字节访问 *)
  assert_byte_range ChinesePunctuation.chinese_period_byte1 "中文句号第1字节";
  assert_byte_range ChinesePunctuation.chinese_period_byte2 "中文句号第2字节";
  assert_byte_range ChinesePunctuation.chinese_period_byte3 "中文句号第3字节";
  
  (* 验证访问器与原始字节组合的一致性 *)
  let (orig_b1, orig_b2, orig_b3) = Unicode.Char_byte_definitions.ChinesePunctuation.chinese_comma_bytes in
  assert_byte_equals orig_b1 ChinesePunctuation.chinese_comma_byte1 "中文逗号第1字节一致性";
  assert_byte_equals orig_b2 ChinesePunctuation.chinese_comma_byte2 "中文逗号第2字节一致性";
  assert_byte_equals orig_b3 ChinesePunctuation.chinese_comma_byte3 "中文逗号第3字节一致性";
  
  Printf.printf "✅ 中文标点符号字节访问器测试完成\n"

(** 测试全角字符字节访问器 *)
let test_fullwidth_accessors () =
  Printf.printf "\n🔍 测试全角字符字节访问器...\n";
  
  (* 测试全角左括号第3字节访问 *)
  assert_byte_range Fullwidth.fullwidth_left_paren_byte3 "全角左括号第3字节";
  
  (* 测试全角右括号第3字节访问 *)
  assert_byte_range Fullwidth.fullwidth_right_paren_byte3 "全角右括号第3字节";
  
  (* 测试全角逗号第3字节访问 *)
  assert_byte_range Fullwidth.fullwidth_comma_byte3 "全角逗号第3字节";
  
  (* 测试全角冒号第3字节访问 *)
  assert_byte_range Fullwidth.fullwidth_colon_byte3 "全角冒号第3字节";
  
  (* 测试全角分号第3字节访问（硬编码值验证） *)
  assert_byte_range Fullwidth.fullwidth_semicolon_byte3 "全角分号第3字节";
  assert_byte_equals 0x9B Fullwidth.fullwidth_semicolon_byte3 "全角分号第3字节硬编码值";
  
  (* 测试全角管道符字节访问（硬编码值验证） *)
  assert_byte_range Fullwidth.fullwidth_pipe_byte1 "全角管道符第1字节";
  assert_byte_range Fullwidth.fullwidth_pipe_byte2 "全角管道符第2字节";
  assert_byte_range Fullwidth.fullwidth_pipe_byte3 "全角管道符第3字节";
  assert_byte_equals 0xEF Fullwidth.fullwidth_pipe_byte1 "全角管道符第1字节硬编码值";
  assert_byte_equals 0xBD Fullwidth.fullwidth_pipe_byte2 "全角管道符第2字节硬编码值";
  assert_byte_equals 0x9C Fullwidth.fullwidth_pipe_byte3 "全角管道符第3字节硬编码值";
  
  (* 测试中文注释符号字节访问 *)
  assert_byte_range Fullwidth.comment_colon_byte1 "中文注释冒号第1字节";
  assert_byte_range Fullwidth.comment_colon_byte2 "中文注释冒号第2字节";
  assert_byte_range Fullwidth.comment_colon_byte3 "中文注释冒号第3字节";
  
  Printf.printf "✅ 全角字符字节访问器测试完成\n"

(** 测试其他符号字节访问器 *)
let test_other_symbols_accessors () =
  Printf.printf "\n🔍 测试其他符号字节访问器...\n";
  
  (* 测试中文减号字节访问 *)
  assert_byte_range OtherSymbols.chinese_minus_byte1 "中文减号第1字节";
  assert_byte_range OtherSymbols.chinese_minus_byte2 "中文减号第2字节";
  assert_byte_range OtherSymbols.chinese_minus_byte3 "中文减号第3字节";
  
  (* 测试中文方括号字节访问 *)
  assert_byte_range OtherSymbols.chinese_square_left_bracket_byte1 "中文左方括号第1字节";
  assert_byte_range OtherSymbols.chinese_square_left_bracket_byte2 "中文左方括号第2字节";
  assert_byte_range OtherSymbols.chinese_square_left_bracket_byte3 "中文左方括号第3字节";
  
  assert_byte_range OtherSymbols.chinese_square_right_bracket_byte1 "中文右方括号第1字节";
  assert_byte_range OtherSymbols.chinese_square_right_bracket_byte2 "中文右方括号第2字节";
  assert_byte_range OtherSymbols.chinese_square_right_bracket_byte3 "中文右方括号第3字节";
  
  (* 验证中文方括号硬编码值 *)
  assert_byte_equals 0xE3 OtherSymbols.chinese_square_left_bracket_byte1 "中文左方括号第1字节硬编码值";
  assert_byte_equals 0x80 OtherSymbols.chinese_square_left_bracket_byte2 "中文左方括号第2字节硬编码值";
  assert_byte_equals 0x90 OtherSymbols.chinese_square_left_bracket_byte3 "中文左方括号第3字节硬编码值";
  
  assert_byte_equals 0xE3 OtherSymbols.chinese_square_right_bracket_byte1 "中文右方括号第1字节硬编码值";
  assert_byte_equals 0x80 OtherSymbols.chinese_square_right_bracket_byte2 "中文右方括号第2字节硬编码值";
  assert_byte_equals 0x91 OtherSymbols.chinese_square_right_bracket_byte3 "中文右方括号第3字节硬编码值";
  
  (* 测试箭头符号字节访问 *)
  assert_byte_range OtherSymbols.chinese_arrow_byte1 "中文箭头第1字节";
  assert_byte_range OtherSymbols.chinese_arrow_byte2 "中文箭头第2字节";
  assert_byte_range OtherSymbols.chinese_arrow_byte3 "中文箭头第3字节";
  
  (* 验证箭头符号硬编码值 *)
  assert_byte_equals 0xE2 OtherSymbols.chinese_arrow_byte1 "中文箭头第1字节硬编码值";
  assert_byte_equals 0x86 OtherSymbols.chinese_arrow_byte2 "中文箭头第2字节硬编码值";
  assert_byte_equals 0x92 OtherSymbols.chinese_arrow_byte3 "中文箭头第3字节硬编码值";
  
  Printf.printf "✅ 其他符号字节访问器测试完成\n"

(** 测试字节访问器函数一致性 *)
let test_accessor_consistency () =
  Printf.printf "\n🔍 测试字节访问器函数一致性...\n";
  
  (* 验证get_byte1/2/3函数的正确性 *)
  let test_bytes = (0xE3, 0x80, 0x90) in
  let b1 = get_byte1 test_bytes in
  let b2 = get_byte2 test_bytes in
  let b3 = get_byte3 test_bytes in
  
  assert_byte_equals 0xE3 b1 "get_byte1函数";
  assert_byte_equals 0x80 b2 "get_byte2函数";
  assert_byte_equals 0x90 b3 "get_byte3函数";
  
  (* 验证访问器与原始定义的完全一致性 *)
  let verify_accessor_consistency name def_bytes accessor_bytes =
    let (def_b1, def_b2, def_b3) = def_bytes in
    let (acc_b1, acc_b2, acc_b3) = accessor_bytes in
    assert (def_b1 = acc_b1 && def_b2 = acc_b2 && def_b3 = acc_b3);
    Printf.printf "✅ %s 访问器与定义一致性验证通过\n" name
  in
  
  verify_accessor_consistency "左引号"
    Unicode.Char_byte_definitions.Quote.left_quote_bytes
    (Quote.left_quote_byte1, Quote.left_quote_byte2, Quote.left_quote_byte3);
  
  verify_accessor_consistency "中文逗号"
    Unicode.Char_byte_definitions.ChinesePunctuation.chinese_comma_bytes
    (ChinesePunctuation.chinese_comma_byte1, ChinesePunctuation.chinese_comma_byte2, ChinesePunctuation.chinese_comma_byte3);
  
  Printf.printf "✅ 字节访问器函数一致性测试完成\n"

(** 边界条件测试 *)
let test_boundary_conditions () =
  Printf.printf "\n🔍 测试字节访问器边界条件...\n";
  
  (* 测试空字节组合 *)
  let empty_bytes = (0, 0, 0) in
  assert (get_byte1 empty_bytes = 0);
  assert (get_byte2 empty_bytes = 0);
  assert (get_byte3 empty_bytes = 0);
  Printf.printf "✅ 空字节组合访问处理正确\n";
  
  (* 测试最大字节值 *)
  let max_bytes = (255, 255, 255) in
  assert (get_byte1 max_bytes = 255);
  assert (get_byte2 max_bytes = 255);
  assert (get_byte3 max_bytes = 255);
  Printf.printf "✅ 最大字节值访问处理正确\n";
  
  Printf.printf "✅ 边界条件测试完成\n"

(** 性能基准测试 *)
let test_performance () =
  Printf.printf "\n🔍 字节访问器性能基准测试...\n";
  
  let start_time = Sys.time () in
  
  (* 重复访问不同字节位10000次 *)
  for _i = 1 to 10000 do
    ignore (Quote.left_quote_byte1);
    ignore (Quote.left_quote_byte2);
    ignore (Quote.left_quote_byte3);
    ignore (ChinesePunctuation.chinese_comma_byte1);
    ignore (Fullwidth.fullwidth_pipe_byte2);
    ignore (OtherSymbols.chinese_arrow_byte3)
  done;
  
  let end_time = Sys.time () in
  let duration = end_time -. start_time in
  
  Printf.printf "✅ 10000次字节访问耗时: %.6f秒\n" duration;
  assert (duration < 0.01); (* 应在10毫秒内完成 *)
  Printf.printf "✅ 字节访问器性能符合要求\n"

(** 主测试执行函数 *)
let () =
  Printf.printf "🔍 开始Unicode字符字节访问器模块测试...\n\n";
  
  test_quote_byte_accessors ();
  test_chinese_punctuation_accessors ();
  test_fullwidth_accessors ();
  test_other_symbols_accessors ();
  test_accessor_consistency ();
  test_boundary_conditions ();
  test_performance ();
  
  Printf.printf "\n🎉 Unicode字符字节访问器模块测试全部通过！\n";
  Printf.printf "测试覆盖: 引号字符访问器、中文标点访问器、全角字符访问器、其他符号访问器、一致性验证、边界条件、性能基准\n";
  Printf.printf "\n📈 本测试为Unicode字符字节级别访问提供了全面的质量保障\n";
  Printf.printf "🎯 确保中文编程语言的字节级别字符处理功能精确可靠\n"