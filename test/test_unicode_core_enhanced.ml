(** 骆言Unicode核心增强测试 - Enhanced Unicode Core Tests *)

open Alcotest
open Yyocamlc_lib.Utf8_utils

(** 测试Unicode字符识别 *)
let test_unicode_char_recognition () =
  (* 测试中文字符识别 *)
  check bool "识别中文字符" true (is_chinese_utf8 "骆");
  check bool "识别中文字符" true (is_chinese_utf8 "言");
  check bool "不识别英文字符" false (is_chinese_utf8 "a");
  check bool "不识别数字字符" false (is_chinese_utf8 "1")

(** 测试Unicode字符分类 *)
let test_unicode_char_classification () =
  (* 测试汉字分类 - 使用is_chinese_utf8代替is_hanzi *)
  check bool "检测汉字" true (is_chinese_utf8 "骆");
  check bool "检测汉字" true (is_chinese_utf8 "言");
  (* 测试中文标点符号检测 *)
  check bool "检测中文逗号" true (ChinesePunctuation.is_chinese_comma "，" 0);
  check bool "检测中文句号" true (ChinesePunctuation.is_chinese_period "。" 0);
  (* 测试全角数字检测 *)
  check bool "检测全角数字" true (FullwidthDetection.is_fullwidth_digit_string "０");
  check bool "检测全角数字" true (FullwidthDetection.is_fullwidth_digit_string "１")

(** 测试Unicode字符串处理 *)
let test_unicode_string_processing () =
  (* 测试字符串长度计算 - 使用StringUtils.utf8_length *)
  let test_string = "骆言语言" in
  check int "Unicode字符串长度" 4 (StringUtils.utf8_length test_string);
  
  (* 测试字符串分割 - 使用StringUtils.utf8_to_char_list *)
  let chars = StringUtils.utf8_to_char_list test_string in
  check int "字符分割数量" 4 (List.length chars);
  check string "第一个字符" "骆" (List.nth chars 0);
  check string "第二个字符" "言" (List.nth chars 1)

(** 测试Unicode特殊字符检测 *)
let test_unicode_special_chars () =
  (* 测试中文数字字符检测 *)
  check bool "检测中文数字一" true (is_chinese_digit_char "一");
  check bool "检测中文数字二" true (is_chinese_digit_char "二");
  check bool "检测中文数字十" true (is_chinese_digit_char "十");
  check bool "不检测普通汉字" false (is_chinese_digit_char "骆");
  
  (* 测试全角数字转换 *)
  let digit_val = FullwidthDetection.fullwidth_digit_to_int "５" in
  check bool "全角数字转换成功" true (Option.is_some digit_val);
  match digit_val with
  | Some n -> check int "全角数字5转换结果" 5 n
  | None -> failwith "全角数字转换失败"

(** 测试Unicode编码验证 *)
let test_unicode_encoding_validation () =
  (* 测试UTF-8字符串解析 *)
  let test_string = "骆言编程语言" in
  let first_char_result = next_utf8_char test_string 0 in
  check bool "UTF-8字符解析成功" true (Option.is_some first_char_result);
  
  (* 测试字符串是否全为中文 *)
  check bool "检测字符串全为中文" true (StringUtils.is_all_chinese test_string);
  check bool "检测混合字符串不全为中文" false (StringUtils.is_all_chinese "hello世界")

(** 测试Unicode字符属性 *)
let test_unicode_char_properties () =
  (* 测试基础字符属性 *)
  check bool "字母或中文字符属性" true (is_letter_or_chinese 'a');
  check bool "数字字符属性" true (is_digit '1');
  check bool "空白字符属性" true (is_whitespace ' ');
  (* 测试中文字符字节检测 - 骆的UTF-8第一个字节是0xE9 *)
  check bool "中文字符字节属性" true (is_chinese_char (char_of_int 0xE9));
  check bool "分隔符属性" true (is_separator_char ',')

(** 测试Unicode边界检查 *)
let test_unicode_boundary_checks () =
  (* 测试中文关键字边界检查 *)
  let test_input = "函数 hello" in
  check bool "中文关键字边界检查" true (BoundaryDetection.is_chinese_keyword_boundary test_input 0 "函数");
  
  (* 测试标识符边界检查 *)
  let test_input2 = "hello world" in
  check bool "标识符边界检查" true (BoundaryDetection.is_identifier_boundary test_input2 5)

(** 测试Unicode标识符验证 *)
let test_unicode_identifier_validation () =
  (* 测试有效标识符 *)
  check bool "中文标识符有效性" true (is_valid_identifier "骆言");
  check bool "英文标识符有效性" true (is_valid_identifier "hello");
  check bool "混合标识符有效性" true (is_valid_identifier "hello世界");
  
  (* 测试无效标识符 *)
  check bool "数字开头标识符无效" false (is_valid_identifier "123abc");
  check bool "空字符串无效" false (is_valid_identifier "")

(** 测试Unicode字符串工具 *)
let test_unicode_string_utils () =
  (* 测试字符串转字符列表 *)
  let char_list = string_to_char_list "abc" in
  check int "字符列表长度" 3 (List.length char_list);
  
  (* 测试字符列表转字符串 *)
  let reconstructed = char_list_to_string char_list in
  check string "字符串重构" "abc" reconstructed;
  
  (* 测试过滤中文字符 - 注意：此函数只保留中文UTF-8的首字节 *)
  let filtered = filter_chinese_chars "hello骆言world" in
  (* 期望结果是中文字符的首字节：骆(\233) 和 言(\232) 的首字节 *)
  check string "过滤中文字符" "\233\232" filtered

(** 测试Unicode数字处理 *)
let test_unicode_digit_processing () =
  (* 测试数字字符串检测 *)
  check bool "检测纯数字字符串" true (is_all_digits "12345");
  check bool "检测非纯数字字符串" false (is_all_digits "123a45");
  
  (* 测试中文长度计算 *)
  let mixed_text = "hello骆言world" in
  check int "中文字符数量" 2 (chinese_length mixed_text)

(** 测试Unicode全角字符检测 *)
let test_unicode_fullwidth_detection () =
  (* 测试全角数字检测 *)
  check bool "检测全角数字" true (FullwidthDetection.is_fullwidth_digit_string "０");
  check bool "检测全角数字" true (FullwidthDetection.is_fullwidth_digit_string "９");
  check bool "非全角数字" false (FullwidthDetection.is_fullwidth_digit_string "1");
  
  (* 测试全角符号检测 *)
  check bool "检测全角符号" true (FullwidthDetection.is_fullwidth_symbol "０" 0)

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
          test_case "Unicode标识符验证" `Quick test_unicode_identifier_validation;
        ] );
      ( "特殊字符和工具",
        [
          test_case "Unicode特殊字符检测" `Quick test_unicode_special_chars;
          test_case "Unicode字符串工具" `Quick test_unicode_string_utils;
          test_case "Unicode数字处理" `Quick test_unicode_digit_processing;
        ] );
      ( "高级功能",
        [
          test_case "Unicode边界检查" `Quick test_unicode_boundary_checks;
          test_case "Unicode全角字符检测" `Quick test_unicode_fullwidth_detection;
        ] );
    ]