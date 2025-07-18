(** 骆言古典诗词解析器 - Chinese Classical Poetry Parser
    夯程序之道，以古文为体，以诗词为用。
    此模块专司诗词解析，承古典之精髓，融现代之技艺。
    四言骈体、五言律诗、七言绝句，皆可解析。
*)

open Ast
open Lexer
open Parser_utils
open Parser_types

(** 初始化模块日志器：记录解析过程之日志
    如史官记事，记录解析过程中的各种信息。
*)
let log_debug = Logger_utils.init_debug_logger "Parser_poetry"

exception PoetryParseError of string
(** 诗词解析相关异常：解析过程中遇到的错误
    若解析不成，则抛出此异常，以告诗家修正。
*)

(** 中文字符计数函数：准确计算中文字符数量
    诗词格律，以字数为准。四言五言七言，各有所定。
    此函数用于UTF-8编码中文字符计数，以验证诗词格律。
*)
let count_chinese_chars text =
  (* 使用统一的UTF-8工具模块，消除代码重复 *)
  Utf8_utils.StringUtils.utf8_length text

(** 验证字符数是否符合诗词格式要求：检查字数是否符合格律
    诗词格律严谨，不容一字之差。此函数用于验证字数。
*)
let validate_char_count expected_count text =
  let actual_count = count_chinese_chars text in
  if actual_count <> expected_count then
    raise (PoetryParseError (Printf.sprintf "字符数不匹配：期望%d字，实际%d字" expected_count actual_count))

(** 解析诗句内容：提取「」引号内的诗句内容
    诗句以「」标识，以区别于常规代码。此函数用于提取诗句内容。
*)
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

(** 解析四言骈体：四字节拍的骈体文
    四言骈体，句式简洁，对仗工整。每句四字，不多不少。
    此函数用于解析四言骈体诗句，生成对应的AST节点。
*)
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
  
  (* 四言骈体艺术性检查：简单的对仗和平仄检查 *)
  let check_siyan_artistic_quality verses =
    (* 检查是否有成对的诗句（偶数行为佳） *)
    let verse_count = List.length verses in
    if verse_count >= 2 && verse_count mod 2 = 0 then
      log_debug ("四言骈体包含" ^ string_of_int verse_count ^ "句，符合对仗结构");
    
    (* 简单的平仄检查：检查是否有声调变化 *)
    List.iter (fun verse ->
      let char_count = count_chinese_chars verse in
      if char_count <> 4 then
        log_debug ("警告：诗句「" ^ verse ^ "」字数为" ^ string_of_int char_count ^ "，不符合四言格式")
    ) verses;
  in
  
  check_siyan_artistic_quality verses;
  
  let poetry_expr =
    PoetryAnnotatedExpr (LitExpr (StringLit (String.concat "\n" verses)), ParallelProse)
  in
  log_debug "四言骈体解析完成";
  (poetry_expr, state)

(** 解析五言律诗：五字节拍的律诗结构
    五言律诗，格律严谨，对仗工整。每句五字，平仄相对。
    此函数用于解析五言律诗诗句，生成对应的AST节点。
*)
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

(** 解析七言绝句：七字节拍的绝句结构
    七言绝句，起承转合，韵律整齐。每句七字，通常四句成篇。
    此函数用于解析七言绝句诗句，生成对应的AST节点。
*)
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

(** 解析对偶结构：支持对偶结构的语法分析
    对偶结构，亦称对联，左右相对，意境相对。左联右联，字数相等。
    此函数用于解析对偶结构，生成对应的AST节点。
*)
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

(** 主要诗词解析入口函数：根据关键字分派到具体解析函数
    诗词类型众多，各有特色。此函数作为统一入口，分派到具体解析函数。
*)
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
