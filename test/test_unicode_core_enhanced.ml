(** 骆言Unicode核心增强测试 - Enhanced Unicode Core Tests *)

open Alcotest
open Yyocamlc_lib.Unicode.Unicode_utils
open Yyocamlc_lib.Unicode.Unicode_chars
open Yyocamlc_lib.Unicode.Unicode_mapping

(** 测试Unicode字符识别 *)
let test_unicode_char_recognition () =
  (* 测试中文字符识别 *)
  check bool "识别中文字符" true (is_chinese_char '骆');
  check bool "识别中文字符" true (is_chinese_char '言');
  check bool "不识别英文字符" false (is_chinese_char 'a');
  check bool "不识别数字字符" false (is_chinese_char '1')

(** 测试Unicode字符分类 *)
let test_unicode_char_classification () =
  (* 测试汉字分类 *)
  check bool "检测汉字" true (is_hanzi '骆');
  check bool "检测汉字" true (is_hanzi '言');
  check bool "检测标点符号" true (is_chinese_punctuation '，');
  check bool "检测标点符号" true (is_chinese_punctuation '。');
  check bool "检测全角字符" true (is_fullwidth_char '０');
  check bool "检测全角字符" true (is_fullwidth_char '１')

(** 测试Unicode字符串处理 *)
let test_unicode_string_processing () =
  (* 测试字符串长度计算 *)
  let test_string = "骆言语言" in
  check int "Unicode字符串长度" 4 (utf8_length test_string);
  
  (* 测试字符串分割 *)
  let chars = utf8_to_chars test_string in
  check int "字符分割数量" 4 (List.length chars);
  check string "第一个字符" "骆" (List.nth chars 0);
  check string "第二个字符" "言" (List.nth chars 1)

(** 测试Unicode映射功能 *)
let test_unicode_mapping () =
  (* 测试简繁体转换映射 *)
  let simplified = get_simplified_char '繁' in
  check bool "简繁体映射存在" true (Option.is_some simplified);
  
  (* 测试大小写映射 *)
  let lower = get_lowercase_mapping 'Ａ' in
  check bool "大小写映射存在" true (Option.is_some lower)

(** 测试Unicode编码验证 *)
let test_unicode_encoding_validation () =
  (* 测试有效UTF-8序列 *)
  let valid_utf8 = "骆言编程语言" in
  check bool "有效UTF-8字符串" true (is_valid_utf8 valid_utf8);
  
  (* 测试字符编码 *)
  let encoded = encode_char '骆' in
  check bool "字符编码成功" true (String.length encoded > 0)

(** 测试Unicode字符属性 *)
let test_unicode_char_properties () =
  (* 测试字符属性查询 *)
  check bool "字母字符属性" true (is_letter_char 'a');
  check bool "数字字符属性" true (is_digit_char '1');
  check bool "空白字符属性" true (is_whitespace_char ' ');
  check bool "控制字符属性" true (is_control_char '\n')

(** 测试Unicode范围检查 *)
let test_unicode_range_checks () =
  (* 测试CJK字符范围 *)
  check bool "CJK统一汉字范围" true (is_in_cjk_range '骆');
  check bool "CJK扩展A范围" true (is_in_cjk_ext_a_range '㐀');
  check bool "CJK符号范围" true (is_in_cjk_symbols_range '〇');
  
  (* 测试不在范围内的字符 *)
  check bool "ASCII字符不在CJK范围" false (is_in_cjk_range 'a')

(** 测试Unicode标准化 *)
let test_unicode_normalization () =
  (* 测试字符串标准化 *)
  let test_string = "骆言" in
  let normalized = normalize_string test_string in
  check bool "字符串标准化" true (String.length normalized > 0);
  
  (* 测试组合字符处理 *)
  let composed = compose_chars ['骆'; '言'] in
  check bool "字符组合" true (String.length composed > 0)

(** 测试Unicode比较 *)
let test_unicode_comparison () =
  (* 测试Unicode字符比较 *)
  check bool "字符相等比较" true (unicode_char_equal '骆' '骆');
  check bool "字符不等比较" false (unicode_char_equal '骆' '言');
  
  (* 测试字符串比较 *)
  check bool "字符串相等比较" true (unicode_string_equal "骆言" "骆言");
  check bool "字符串不等比较" false (unicode_string_equal "骆言" "编程")

(** 测试Unicode搜索 *)
let test_unicode_search () =
  let text = "骆言编程语言很强大" in
  let pattern = "编程" in
  
  (* 测试子字符串查找 *)
  let position = find_substring text pattern in
  check bool "子字符串查找成功" true (Option.is_some position);
  
  (* 测试字符查找 *)
  let char_pos = find_char text '语' in
  check bool "字符查找成功" true (Option.is_some char_pos)

(** 测试Unicode转换 *)
let test_unicode_conversion () =
  (* 测试全角半角转换 *)
  let fullwidth = "０１２３" in
  let halfwidth = convert_to_halfwidth fullwidth in
  check string "全角转半角" "0123" halfwidth;
  
  (* 测试大小写转换 *)
  let uppercase = convert_to_uppercase "ａｂｃ" in
  check bool "大小写转换成功" true (String.length uppercase > 0)

(** 主测试套件 *)
let () =
  run "骆言Unicode核心增强测试"
    [
      ( "字符识别和分类",
        [
          test_case "Unicode字符识别" `Quick test_unicode_char_recognition;
          test_case "Unicode字符分类" `Quick test_unicode_char_classification;
          test_case "Unicode字符属性" `Quick test_unicode_char_properties;
        ] );
      ( "字符串处理",
        [
          test_case "Unicode字符串处理" `Quick test_unicode_string_processing;
          test_case "Unicode编码验证" `Quick test_unicode_encoding_validation;
          test_case "Unicode标准化" `Quick test_unicode_normalization;
        ] );
      ( "映射和转换",
        [
          test_case "Unicode映射功能" `Quick test_unicode_mapping;
          test_case "Unicode转换" `Quick test_unicode_conversion;
        ] );
      ( "高级功能",
        [
          test_case "Unicode范围检查" `Quick test_unicode_range_checks;
          test_case "Unicode比较" `Quick test_unicode_comparison;
          test_case "Unicode搜索" `Quick test_unicode_search;
        ] );
    ]