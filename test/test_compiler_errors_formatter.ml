(** 编译器错误格式化测试 - 骆言编译器 *)

open Yyocamlc_lib.Compiler_errors_types
open Yyocamlc_lib.Compiler_errors_formatter

(** 辅助函数：检查字符串是否包含子串 *)
let contains_substring str substr =
  try
    let _ = Str.search_forward (Str.regexp (Str.quote substr)) str 0 in
    true
  with Not_found -> false

(** 测试位置格式化 *)
let test_format_position () =
  let pos1 = { filename = "test.ly"; line = 5; column = 10 } in
  let formatted1 = format_position pos1 in
  assert (String.contains formatted1 '5');
  assert (String.contains formatted1 '1');
  
  let pos2 = { filename = ""; line = 1; column = 1 } in
  let formatted2 = format_position pos2 in
  assert (String.length formatted2 > 0);
  print_endline "✓ 位置格式化测试通过"

(** 测试词法错误格式化 *)
let test_format_lex_error () =
  let pos = { filename = "test.ly"; line = 3; column = 8 } in
  let error = LexError ("非法字符 'α'", pos) in
  let formatted = format_error_message error in
  assert (contains_substring formatted "词");
  assert (contains_substring formatted "法");
  assert (contains_substring formatted "非");
  print_endline "✓ 词法错误格式化测试通过"

(** 测试语法错误格式化 *)
let test_format_parse_error () =
  let pos = { filename = "parse.ly"; line = 7; column = 15 } in
  let error = ParseError ("缺少分号", pos) in
  let formatted = format_error_message error in
  assert (contains_substring formatted "语");
  assert (contains_substring formatted "法");
  assert (contains_substring formatted "缺");
  print_endline "✓ 语法错误格式化测试通过"

(** 测试语法结构错误格式化 *)
let test_format_syntax_error () =
  let pos = { filename = "syntax.ly"; line = 12; column = 20 } in
  let error = SyntaxError ("括号不匹配", pos) in
  let formatted = format_error_message error in
  assert (contains_substring formatted "语");
  assert (contains_substring formatted "法");
  assert (contains_substring formatted "括");
  print_endline "✓ 语法结构错误格式化测试通过"

(** 测试诗词解析错误格式化 *)
let test_format_poetry_parse_error () =
  let pos = Some { filename = "poem.ly"; line = 4; column = 6 } in
  let error = PoetryParseError ("平仄不符", pos) in
  let formatted = format_error_message error in
  assert (contains_substring formatted "诗");
  assert (contains_substring formatted "词");
  assert (contains_substring formatted "平");
  print_endline "✓ 诗词解析错误格式化测试通过"

(** 测试诗词解析错误格式化（无位置） *)
let test_format_poetry_parse_error_no_pos () =
  let error = PoetryParseError ("韵律错误", None) in
  let formatted = format_error_message error in
  assert (contains_substring formatted "诗");
  assert (contains_substring formatted "词");
  assert (contains_substring formatted "韵");
  print_endline "✓ 诗词解析错误格式化（无位置）测试通过"

(** 测试类型错误格式化 *)
let test_format_type_error () =
  let pos = Some { filename = "type.ly"; line = 9; column = 12 } in
  let error = TypeError ("类型不匹配: 期望整数，得到字符串", pos) in
  let formatted = format_error_message error in
  assert (contains_substring formatted "类");
  assert (contains_substring formatted "型");
  assert (contains_substring formatted "期");
  print_endline "✓ 类型错误格式化测试通过"

(** 测试语义错误格式化 *)
let test_format_semantic_error () =
  let pos = Some { filename = "semantic.ly"; line = 15; column = 25 } in
  let error = SemanticError ("变量 'x' 未定义", pos) in
  let formatted = format_error_message error in
  assert (contains_substring formatted "语");
  assert (contains_substring formatted "义");
  assert (contains_substring formatted "变");
  print_endline "✓ 语义错误格式化测试通过"

(** 测试代码生成错误格式化 *)
let test_format_codegen_error () =
  let error = CodegenError ("无法生成函数调用代码", "函数生成") in
  let formatted = format_error_message error in
  assert (contains_substring formatted "代");
  assert (contains_substring formatted "码");
  assert (contains_substring formatted "生");
  print_endline "✓ 代码生成错误格式化测试通过"

(** 测试未实现功能错误格式化 *)
let test_format_unimplemented_feature () =
  let error = UnimplementedFeature ("模式匹配", "C后端") in
  let formatted = format_error_message error in
  assert (contains_substring formatted "未");
  assert (contains_substring formatted "实");
  assert (contains_substring formatted "现");
  print_endline "✓ 未实现功能错误格式化测试通过"

(** 测试内部错误格式化 *)
let test_format_internal_error () =
  let error = InternalError "编译器内部断言失败" in
  let formatted = format_error_message error in
  assert (contains_substring formatted "内");
  assert (contains_substring formatted "部");
  assert (contains_substring formatted "编");
  print_endline "✓ 内部错误格式化测试通过"

(** 运行所有测试 *)
let () =
  print_endline "开始运行编译器错误格式化测试...";
  test_format_position ();
  test_format_lex_error ();
  test_format_parse_error ();
  test_format_syntax_error ();
  test_format_poetry_parse_error ();
  test_format_poetry_parse_error_no_pos ();
  test_format_type_error ();
  test_format_semantic_error ();
  test_format_codegen_error ();
  test_format_unimplemented_feature ();
  test_format_internal_error ();
  print_endline "🎉 所有编译器错误格式化测试通过！"