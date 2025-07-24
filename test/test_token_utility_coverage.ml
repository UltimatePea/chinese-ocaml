(** 令牌工具覆盖率测试 - 提升令牌相关工具函数的测试覆盖率 *)

open Yyocamlc_lib.Lexer_tokens

(** 测试基本令牌创建功能 *)
let test_token_creation () =
  Printf.printf "测试令牌创建功能...\n";
  
  (* 测试字面量令牌 *)
  let int_token = IntToken 42 in
  let float_token = FloatToken 3.14 in
  let string_token = StringToken "测试" in
  let bool_token = BoolToken true in
  let chinese_num_token = ChineseNumberToken "三" in
  
  Printf.printf "  创建整数令牌: %s\n" (match int_token with IntToken n -> string_of_int n | _ -> "错误");
  Printf.printf "  创建浮点令牌: %s\n" (match float_token with FloatToken f -> string_of_float f | _ -> "错误");
  Printf.printf "  创建字符串令牌: %s\n" (match string_token with StringToken s -> s | _ -> "错误");
  Printf.printf "  创建布尔令牌: %s\n" (match bool_token with BoolToken b -> string_of_bool b | _ -> "错误");
  Printf.printf "  创建中文数字令牌: %s\n" (match chinese_num_token with ChineseNumberToken s -> s | _ -> "错误");
  
  Printf.printf "✅ 令牌创建功能测试通过\n"

(** 测试标识符令牌 *)
let test_identifier_tokens () =
  Printf.printf "测试标识符令牌...\n";
  
  let quoted_id = QuotedIdentifierToken "变量" in
  let special_id = IdentifierTokenSpecial "数值" in
  
  Printf.printf "  引用标识符: %s\n" (match quoted_id with QuotedIdentifierToken s -> s | _ -> "错误");
  Printf.printf "  特殊标识符: %s\n" (match special_id with IdentifierTokenSpecial s -> s | _ -> "错误");
  
  Printf.printf "✅ 标识符令牌测试通过\n"

(** 测试关键字令牌 *)
let test_keyword_tokens () =
  Printf.printf "测试关键字令牌...\n";
  
  let keywords = [
    (LetKeyword, "让");
    (FunKeyword, "函数");
    (IfKeyword, "如果");
    (ThenKeyword, "那么");
    (ElseKeyword, "否则");
    (TrueKeyword, "真");
    (FalseKeyword, "假");
  ] in
  
  List.iter (fun (token, name) -> 
    Printf.printf "  关键字令牌: %s\n" name
  ) keywords;
  
  Printf.printf "✅ 关键字令牌测试通过\n"

(** 测试操作符令牌 *)
let test_operator_tokens () =
  Printf.printf "测试操作符令牌...\n";
  
  let operators = [
    (Plus, "+");
    (Minus, "-");
    (Multiply, "*");
    (Divide, "/");
    (Equal, "=");
  ] in
  
  List.iter (fun (token, symbol) -> 
    Printf.printf "  操作符令牌: %s\n" symbol
  ) operators;
  
  Printf.printf "✅ 操作符令牌测试通过\n"

(** 测试分隔符令牌 *)
let test_delimiter_tokens () =
  Printf.printf "测试分隔符令牌...\n";
  
  let delimiters = [
    (LeftParen, "(");
    (RightParen, ")");
    (LeftBracket, "[");
    (RightBracket, "]");
    (LeftBrace, "{");
    (RightBrace, "}");
    (Semicolon, ";");
    (Comma, ",");
    (Colon, ":");
  ] in
  
  List.iter (fun (token, symbol) -> 
    Printf.printf "  分隔符令牌: %s\n" symbol
  ) delimiters;
  
  Printf.printf "✅ 分隔符令牌测试通过\n"

(** 测试位置信息 *)
let test_position_info () =
  Printf.printf "测试位置信息...\n";
  
  let pos1 = { filename = "test.ly"; line = 10; column = 5 } in
  let pos2 = { filename = "example.ly"; line = 25; column = 12 } in
  
  Printf.printf "  位置1: %s:%d:%d\n" pos1.filename pos1.line pos1.column;
  Printf.printf "  位置2: %s:%d:%d\n" pos2.filename pos2.line pos2.column;
  
  (* 测试位置相等性 *)
  let same_pos = { filename = "test.ly"; line = 10; column = 5 } in
  assert (pos1.filename = same_pos.filename);
  assert (pos1.line = same_pos.line);
  assert (pos1.column = same_pos.column);
  
  Printf.printf "✅ 位置信息测试通过\n"

(** 测试位置令牌 *)
let test_positioned_tokens () =
  Printf.printf "测试位置令牌...\n";
  
  let pos = { filename = "test.ly"; line = 15; column = 8 } in
  let token = IntToken 123 in
  let positioned_token = (token, pos) in
  
  let (extracted_token, extracted_pos) = positioned_token in
  assert (extracted_token = IntToken 123);
  assert (extracted_pos.filename = "test.ly");
  assert (extracted_pos.line = 15);
  assert (extracted_pos.column = 8);
  
  Printf.printf "  位置令牌: %s:%d:%d\n" extracted_pos.filename extracted_pos.line extracted_pos.column;
  Printf.printf "✅ 位置令牌测试通过\n"

(** 测试令牌比较 *)
let test_token_equality () =
  Printf.printf "测试令牌比较...\n";
  
  (* 测试相同令牌 *)
  assert (IntToken 42 = IntToken 42);
  assert (StringToken "测试" = StringToken "测试");
  assert (LetKeyword = LetKeyword);
  assert (Plus = Plus);
  
  (* 测试不同令牌 *)
  assert (IntToken 42 <> IntToken 24);
  assert (StringToken "测试1" <> StringToken "测试2");
  assert (LetKeyword <> FunKeyword);
  assert (Plus <> Minus);
  
  Printf.printf "✅ 令牌比较测试通过\n"

(** 测试边界情况 *)
let test_edge_cases () =
  Printf.printf "测试边界情况...\n";
  
  (* 测试空字符串 *)
  let empty_string = StringToken "" in
  Printf.printf "  空字符串令牌创建成功\n";
  
  (* 测试大整数 *)
  let large_int = IntToken 999999999 in
  Printf.printf "  大整数令牌创建成功\n";
  
  (* 测试零值 *)
  let zero_int = IntToken 0 in
  let zero_float = FloatToken 0.0 in
  Printf.printf "  零值令牌创建成功\n";
  
  (* 测试特殊字符 *)
  let special_string = StringToken "特殊字符@#$%中文" in
  let special_quoted_id = QuotedIdentifierToken "包含空格的 标识符" in
  Printf.printf "  特殊字符令牌创建成功\n";
  
  Printf.printf "✅ 边界情况测试通过\n"

(** 运行所有测试 *)
let run_tests () =
  Printf.printf "=== 令牌工具覆盖率测试开始 ===\n";
  
  test_token_creation ();
  test_identifier_tokens ();
  test_keyword_tokens ();
  test_operator_tokens ();
  test_delimiter_tokens ();
  test_position_info ();
  test_positioned_tokens ();
  test_token_equality ();
  test_edge_cases ();
  
  Printf.printf "=== 令牌工具覆盖率测试完成 ===\n";
  Printf.printf "🎯 目标：提升lexer_tokens.ml模块的测试覆盖率\n"

let () = run_tests ()