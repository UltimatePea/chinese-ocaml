(** 古典诗词解析器测试 - Classical Poetry Parser Tests *)

open Yyocamlc_lib
open Ast
open Lexer
open Parser
open Parser_poetry

let test_count_chinese_chars () =
  (* 测试中文字符计数功能 *)
  let count1 = count_chinese_chars "快排算法" in
  print_endline ("快排算法 = " ^ string_of_int count1);
  assert (count1 = 4);
  let count2 = count_chinese_chars "快排" in
  print_endline ("快排 = " ^ string_of_int count2);
  assert (count2 = 2);
  print_endline "✓ 中文字符计数测试通过"

let test_four_char_parallel () =
  (* 测试四言骈体解析 *)
  let source = "骈体 四言 {\n「快排算法」\n「受列表参」\n「若小则返」\n「大则分割」\n}" in
  let tokens = tokenize "test.ly" source in
  let state = create_parser_state tokens in
  
  try
    let (expr, _final_state) = parse_poetry_expression state in
    match expr with
    | PoetryAnnotatedExpr (LitExpr (StringLit content), ParallelProse) ->
      assert (String.length content > 0);
      print_endline "✓ 四言骈体解析测试通过"
    | _ -> failwith "四言骈体解析结果类型错误"
  with
  | PoetryParseError msg -> failwith ("四言骈体解析失败: " ^ msg)
  | SyntaxError (msg, _pos) -> failwith ("语法错误: " ^ msg)

let test_five_char_verse () =
  (* 测试五言律诗解析 *)
  let source = "五言 律诗 {\n「定义排序法」\n「接受数组参」\n「遍历比较值」\n「交换位置定」\n}" in
  let tokens = tokenize "test.ly" source in
  let state = create_parser_state tokens in
  
  try
    let (expr, _final_state) = parse_poetry_expression state in
    match expr with
    | PoetryAnnotatedExpr (LitExpr (StringLit content), RegulatedVerse) ->
      assert (String.length content > 0);
      print_endline "✓ 五言律诗解析测试通过"
    | _ -> failwith "五言律诗解析结果类型错误"
  with
  | PoetryParseError msg -> failwith ("五言律诗解析失败: " ^ msg)
  | SyntaxError (msg, _pos) -> failwith ("语法错误: " ^ msg)

let test_seven_char_quatrain () =
  (* 测试七言绝句解析 *)
  let source = "七言 绝句 {\n「夫快排者受列表焉」\n「观其长短若小则返」\n\"大则分之递归合并\"\n\"是谓快排排序算法\"\n}" in
  let tokens = tokenize "test.ly" source in
  let state = create_parser_state tokens in
  
  try
    let (expr, _final_state) = parse_poetry_expression state in
    match expr with
    | PoetryAnnotatedExpr (LitExpr (StringLit content), Quatrain) ->
      assert (String.length content > 0);
      print_endline "✓ 七言绝句解析测试通过"
    | _ -> failwith "七言绝句解析结果类型错误"
  with
  | PoetryParseError msg -> failwith ("七言绝句解析失败: " ^ msg)
  | SyntaxError (msg, _pos) -> failwith ("语法错误: " ^ msg)

let test_parallel_structure () =
  (* 测试对偶结构解析 *)
  let source = "骈体 (左联: 「夫加法者受二数焉」, 右联: 「夫减法者受二数焉」)" in
  let tokens = tokenize "test.ly" source in
  let state = create_parser_state tokens in
  
  try
    let (expr, _final_state) = parse_poetry_expression state in
    match expr with
    | PoetryAnnotatedExpr (LitExpr (StringLit content), Couplet) ->
      assert (String.length content > 0);
      print_endline "✓ 对偶结构解析测试通过"
    | _ -> failwith "对偶结构解析结果类型错误"
  with
  | PoetryParseError msg -> failwith ("对偶结构解析失败: " ^ msg)
  | SyntaxError (msg, _pos) -> failwith ("语法错误: " ^ msg)

let test_char_count_validation () =
  (* 测试字符数验证 - 正确情况 *)
  (try
    validate_char_count 4 "快排算法";
    print_endline "✓ 字符数验证（正确）测试通过"
  with
  | PoetryParseError _ -> failwith "字符数验证（正确）测试失败");
  
  (* 测试字符数验证 - 错误情况 *)
  (try
    validate_char_count 4 "快排算法实现";
    failwith "字符数验证（错误）测试失败：应该抛出异常"
  with
  | PoetryParseError _ -> print_endline "✓ 字符数验证（错误）测试通过")

let run_tests () =
  print_endline "开始古典诗词解析器测试...\n";
  
  test_count_chinese_chars ();
  test_char_count_validation ();
  test_four_char_parallel ();
  test_five_char_verse ();
  test_seven_char_quatrain ();
  test_parallel_structure ();
  
  print_endline "\n✅ 所有古典诗词解析器测试通过！"

let () = run_tests ()