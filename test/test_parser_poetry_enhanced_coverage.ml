(** 骆言Parser古典诗词模块增强测试覆盖 - Fix #1307
    
    本测试模块为 parser_poetry.ml 提供全面的增强测试覆盖，作为提升项目测试覆盖率
    从22%到50%目标的第二阶段实施。专注于古典诗词解析器的工具函数测试。
    
    测试内容涵盖：
    - 中文字符计数工具（各种复杂情况）
    - 格律验证机制（边界情况和错误处理）
    - 异常处理机制
    - UTF-8中文字符处理边界情况
    
    测试策略：边界情况、错误路径、复杂格式组合验证
*)

open Alcotest
open Yyocamlc_lib.Parser_poetry

(** 断言异常被正确抛出 *)
let assert_poetry_parse_error f =
  try
    let _ = f () in
    check bool "应该抛出PoetryParseError异常" false true
  with
  | PoetryParseError _ -> check bool "正确抛出PoetryParseError" true true
  | _ -> check bool "应该抛出PoetryParseError异常，但抛出了其他异常" false true

(** 测试用例：中文字符计数功能测试 *)
let test_count_chinese_chars () =
  (* 测试纯中文字符 *)
  let count1 = count_chinese_chars "春风得意马蹄疾" in
  check int "七个中文字符" 7 count1;
  
  (* 测试四个中文字符 *)
  let count2 = count_chinese_chars "雄关漫道" in
  check int "四个中文字符" 4 count2;
  
  (* 测试五个中文字符 *)
  let count3 = count_chinese_chars "大江东去波" in
  check int "五个中文字符" 5 count3;
  
  (* 测试空字符串 *)
  let count4 = count_chinese_chars "" in
  check int "空字符串" 0 count4;
  
  (* 测试单个字符 *)
  let count5 = count_chinese_chars "山" in
  check int "单个中文字符" 1 count5;
  
  (* 测试复杂诗句 *)
  let count6 = count_chinese_chars "床前明月光" in
  check int "五个中文字符的经典诗句" 5 count6;
  
  (* 测试十字以上长句 *)
  let count7 = count_chinese_chars "两个黄鹂鸣翠柳一行白鹭上青天" in
  check int "十四个中文字符的长句" 14 count7;
  
  (* 测试三字短句 *)
  let count8 = count_chinese_chars "人之初" in
  check int "三个中文字符短句" 3 count8

(** 测试用例：格律字数验证功能测试 *)
let test_validate_char_count () =
  (* 测试正确字数验证（四言） *)
  validate_char_count 4 "雄关漫道";
  check bool "四言字数验证通过" true true;
  
  (* 测试正确字数验证（五言） *)
  validate_char_count 5 "大江东去波";
  check bool "五言字数验证通过" true true;
  
  (* 测试正确字数验证（七言） *)
  validate_char_count 7 "春风得意马蹄疾";
  check bool "七言字数验证通过" true true;
  
  (* 测试三言验证 *)
  validate_char_count 3 "人之初";
  check bool "三言字数验证通过" true true;
  
  (* 测试六言验证 *)
  validate_char_count 6 "明月何时照我";
  check bool "六言字数验证通过" true true;
  
  (* 测试字数不匹配的错误情况 *)
  assert_poetry_parse_error (fun () -> 
    validate_char_count 4 "春风得意马蹄疾");
  
  assert_poetry_parse_error (fun () -> 
    validate_char_count 7 "雄关漫道");
    
  assert_poetry_parse_error (fun () -> 
    validate_char_count 4 "床前明月光");
    
  assert_poetry_parse_error (fun () -> 
    validate_char_count 3 "春风得意马蹄疾一路向前");
    
  (* 测试零字数验证 - 可能不会抛出错误，因为空字符串是0字符 *)
  validate_char_count 0 "";
  check bool "零字数验证通过" true true

(** 测试用例：PoetryParseError异常机制测试 *)
let test_poetry_parse_error_exception () =
  (* 测试异常能正确被创建和抛出 *)
  try
    raise (PoetryParseError "测试异常消息");
    check bool "应该抛出异常" false true
  with
  | PoetryParseError msg -> 
      check string "异常消息正确" "测试异常消息" msg
  | _ -> 
      check bool "应该抛出PoetryParseError" false true;
      
  (* 测试空异常消息 *)
  try
    raise (PoetryParseError "");
    check bool "应该抛出异常" false true
  with
  | PoetryParseError msg -> 
      check string "空异常消息" "" msg
  | _ -> 
      check bool "应该抛出PoetryParseError" false true

(** 测试用例：中文字符计数的边界和特殊情况测试 *)
let test_count_chinese_chars_edge_cases () =
  (* 测试重复字符 *)
  let count1 = count_chinese_chars "山山山山" in
  check int "四个重复字符" 4 count1;
  
  (* 测试传统长诗句 *)
  let count2 = count_chinese_chars "床前明月光疑是地上霜举头望明月低头思故乡" in
  check int "二十字古诗全文" 20 count2;
  
  (* 测试单字重复长句 *)
  let count3 = count_chinese_chars "好好好好好好好好好好" in
  check int "十个重复的好字" 10 count3;
  
  (* 测试一字句 *)
  let count4 = count_chinese_chars "诗" in
  check int "单字诗" 1 count4;
  
  (* 测试两字句 *)
  let count5 = count_chinese_chars "诗词" in
  check int "两字词语" 2 count5

(** 测试用例：格律验证的极端情况测试 *)
let test_validate_char_count_extreme_cases () =
  (* 测试大数值验证 *)
  let long_poem = String.concat "" (Array.to_list (Array.make 100 "诗")) in
  validate_char_count 100 long_poem;
  check bool "百字长诗验证通过" true true;
  
  (* 测试大数值不匹配 *)
  assert_poetry_parse_error (fun () -> 
    validate_char_count 50 long_poem);
    
  (* 测试一字验证成功 *)
  validate_char_count 1 "诗";
  check bool "单字验证通过" true true;
  
  (* 测试一字验证失败 *)
  assert_poetry_parse_error (fun () -> 
    validate_char_count 2 "诗")

(** Alcotest测试套件定义 *)
let enhanced_coverage_tests = [
  "中文字符计数功能测试", `Quick, test_count_chinese_chars;
  "格律字数验证功能测试", `Quick, test_validate_char_count;
  "PoetryParseError异常机制测试", `Quick, test_poetry_parse_error_exception;
  "中文字符计数边界情况测试", `Quick, test_count_chinese_chars_edge_cases;
  "格律验证极端情况测试", `Quick, test_validate_char_count_extreme_cases;
]

(** 主测试运行器 *)
let () = 
  run "骆言Parser古典诗词模块增强测试覆盖 - Fix #1307" [
    ("增强测试覆盖", enhanced_coverage_tests);
  ]