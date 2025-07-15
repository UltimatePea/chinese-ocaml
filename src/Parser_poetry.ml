(** 骆言古典诗词解析器 - Chinese Classical Poetry Parser *)

open Ast
open Lexer
open Parser_utils
open Parser_types

(** 初始化模块日志器 *)
let log_debug, _log_info, _log_warn, _log_error = Logger.init_module_logger "Parser_poetry"

exception PoetryParseError of string
(** 诗词解析相关异常 *)

(** 中文字符计数函数 - 准确计算中文字符数（忽略标点符号和空格） *)
let count_chinese_chars text =
  (* 简化实现：计算UTF-8中文字符数量 *)
  let len = String.length text in
  let rec count_chars i acc =
    if i >= len then acc
    else
      let c = String.get text i in
      let byte_val = Char.code c in
      if byte_val >= 0xE0 && byte_val <= 0xEF then
        (* UTF-8 3字节字符（中文字符） *)
        count_chars (i + 3) (acc + 1)
      else if byte_val >= 0xC0 && byte_val <= 0xDF then
        (* UTF-8 2字节字符 *)
        count_chars (i + 2) acc
      else if byte_val >= 0xF0 && byte_val <= 0xF7 then
        (* UTF-8 4字节字符 *)
        count_chars (i + 4) acc
      else
        (* ASCII字符 *)
        count_chars (i + 1) acc
  in
  count_chars 0 0

(** 验证字符数是否符合诗词格式要求 *)
let validate_char_count expected_count text =
  let actual_count = count_chinese_chars text in
  if actual_count <> expected_count then
    raise (PoetryParseError (Printf.sprintf "字符数不匹配：期望%d字，实际%d字" expected_count actual_count))

(** 解析诗句内容 - 提取「」引号内的内容 *)
let parse_poetry_content state =
  let token, pos = current_token state in
  match token with
  | QuotedIdentifierToken name ->
      (* 引用标识符，直接使用内容 *)
      (name, advance_parser state)
  | IdentifierTokenSpecial name ->
      (* 特殊标识符，直接使用 *)
      (name, advance_parser state)
  | StringToken content ->
      (* 字符串字面量 *)
      (content, advance_parser state)
  | _ -> raise (SyntaxError ("期望诗句内容", pos))

(** 解析四言骈体 - 四字节拍的骈体文 *)
let parse_four_char_parallel state =
  log_debug "开始解析四言骈体";

  (* 期望 四言骈体 关键字 *)
  let state = expect_token state ParallelStructKeyword in
  let state = expect_token state FourCharKeyword in
  let state = expect_token state LeftBrace in
  let state = skip_newlines state in

  let rec parse_verses state verses =
    let token, _pos = current_token state in
    match token with
    | RightBrace -> (List.rev verses, advance_parser state)
    | _ ->
        (* 解析一行诗句 *)
        let content, state' = parse_poetry_content state in
        (* 验证四字格式 *)
        validate_char_count 4 content;
        let state' = skip_newlines state' in
        parse_verses state' (content :: verses)
  in

  let verses, state = parse_verses state [] in
  let poetry_expr =
    PoetryAnnotatedExpr (LitExpr (StringLit (String.concat "\n" verses)), ParallelProse)
  in
  log_debug "四言骈体解析完成";
  (poetry_expr, state)

(** 解析五言律诗 - 五字节拍的律诗结构 *)
let parse_five_char_verse state =
  log_debug "开始解析五言律诗";

  (* 期望 五言律诗 关键字 *)
  let state = expect_token state FiveCharKeyword in
  let state = expect_token state RegulatedVerseKeyword in
  let state = expect_token state LeftBrace in
  let state = skip_newlines state in

  let rec parse_verses state verses =
    let token, _pos = current_token state in
    match token with
    | RightBrace -> (List.rev verses, advance_parser state)
    | _ ->
        (* 解析一行诗句 *)
        let content, state' = parse_poetry_content state in
        (* 验证五字格式 *)
        validate_char_count 5 content;
        let state' = skip_newlines state' in
        parse_verses state' (content :: verses)
  in

  let verses, state = parse_verses state [] in
  let poetry_expr =
    PoetryAnnotatedExpr (LitExpr (StringLit (String.concat "\n" verses)), RegulatedVerse)
  in
  log_debug "五言律诗解析完成";
  (poetry_expr, state)

(** 解析七言绝句 - 七字节拍的绝句结构 *)
let parse_seven_char_quatrain state =
  log_debug "开始解析七言绝句";

  (* 期望 七言绝句 关键字 *)
  let state = expect_token state SevenCharKeyword in
  let state = expect_token state QuatrainKeyword in
  let state = expect_token state LeftBrace in
  let state = skip_newlines state in

  let rec parse_verses state verses verse_count =
    let token, _pos = current_token state in
    match token with
    | RightBrace ->
        (* 绝句通常有4句 *)
        if verse_count <> 4 then log_debug (Printf.sprintf "绝句包含%d句，通常为4句" verse_count);
        (List.rev verses, advance_parser state)
    | _ ->
        (* 解析一行诗句 *)
        let content, state' = parse_poetry_content state in
        (* 验证七字格式 *)
        validate_char_count 7 content;
        let state' = skip_newlines state' in
        parse_verses state' (content :: verses) (verse_count + 1)
  in

  let verses, state = parse_verses state [] 0 in
  let poetry_expr =
    PoetryAnnotatedExpr (LitExpr (StringLit (String.concat "\n" verses)), Quatrain)
  in
  log_debug "七言绝句解析完成";
  (poetry_expr, state)

(** 解析对偶结构 - 支持对偶结构的语法分析 *)
let parse_parallel_structure state =
  log_debug "开始解析对偶结构";

  (* 期望 对偶结构 关键字后跟括号 *)
  let state = expect_token state ParallelStructKeyword in
  let state = expect_token state LeftParen in
  let state = skip_newlines state in

  (* 解析左联 *)
  let state =
    let token, pos = current_token state in
    match token with
    | QuotedIdentifierToken "左联" -> advance_parser state
    | IdentifierTokenSpecial "左联" -> advance_parser state
    | _ -> raise (SyntaxError ("期望 '左联' 关键字", pos))
  in
  let state = expect_token state Colon in
  let left_content, state = parse_poetry_content state in
  let state = expect_token state Comma in
  let state = skip_newlines state in

  (* 解析右联 *)
  let state =
    let token, pos = current_token state in
    match token with
    | QuotedIdentifierToken "右联" -> advance_parser state
    | IdentifierTokenSpecial "右联" -> advance_parser state
    | _ -> raise (SyntaxError ("期望 '右联' 关键字", pos))
  in
  let state = expect_token state Colon in
  let right_content, state = parse_poetry_content state in
  let state = skip_newlines state in
  let state = expect_token state RightParen in

  (* 验证对偶字数相等 *)
  let left_count = count_chinese_chars left_content in
  let right_count = count_chinese_chars right_content in
  if left_count <> right_count then
    raise (PoetryParseError (Printf.sprintf "对偶字数不匹配：左联%d字，右联%d字" left_count right_count));

  let couplet_content = left_content ^ "\n" ^ right_content in
  let poetry_expr = PoetryAnnotatedExpr (LitExpr (StringLit couplet_content), Couplet) in
  log_debug "对偶结构解析完成";
  (poetry_expr, state)

(** 主要诗词解析入口函数 *)
let parse_poetry_expression state =
  let token, pos = current_token state in
  match token with
  | ParallelStructKeyword -> (
      (* 检查下一个token来决定是四言骈体还是对偶结构 *)
      let next_token, _next_pos = peek_token state in
      match next_token with
      | FourCharKeyword -> parse_four_char_parallel state
      | LeftParen -> parse_parallel_structure state
      | _ -> raise (SyntaxError ("骈体后期望 '四言' 或 '(' ", pos)))
  | FiveCharKeyword -> parse_five_char_verse state
  | SevenCharKeyword -> parse_seven_char_quatrain state
  | _ -> raise (SyntaxError ("期望诗词关键字", pos))
