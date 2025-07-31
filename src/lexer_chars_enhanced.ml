(** 词法分析器字符处理模块 - Unicode增强版
    
    本模块替代原有lexer_chars.ml，提供增强的中文字符处理功能：
    - 使用统一的Unicode常量和处理函数
    - 改进的UTF-8字符边界检测
    - 准确的位置跟踪和错误定位
    - 高性能的字符分类和验证
    - 更好的错误恢复和错误消息
    
    Author: Whisky, PR Worker
    Issue: #1847 - Unicode字符处理优化
    
    @version 2.0 - Unicode增强版
    @since 2025-07-31 *)

open Lexer_state
open Lexer_tokens
open Lexer_utils
open Lexer_keywords
open Unicode.Unicode_constants_enhanced
open Unicode.Utf8_utils_enhanced

(** 增强的错误处理 - 使用标准位置类型 *)
exception EnhancedLexError of string * Lexer_tokens.position * string option

(** 检查UTF-8字符匹配 - 使用增强的Unicode模块 *)
let check_utf8_char state byte1 byte2 byte3 =
  state.position + 2 < state.length &&
  Char.code state.input.[state.position] = byte1 &&
  Char.code state.input.[state.position + 1] = byte2 &&
  Char.code state.input.[state.position + 2] = byte3

(** 检查关键字边界 - 使用增强的边界检测 *)
let is_valid_keyword_boundary state next_pos =
  if next_pos >= state.length then true (* 文件结尾 *)
  else
    match UTF8Processing.next_utf8_char_safe state.input next_pos with
    | ValidChar (next_char, _) ->
        if String.length next_char = 1 then
          let c = next_char.[0] in
          (* 使用增强的字符分类 *)
          CharacterDetection.is_separator_char c || c = ' ' || c = '\t' || c = '\n' ||
          CharacterDetection.is_digit c || (* 允许关键字后面跟数字 *)
          not (CharacterDetection.is_letter_or_chinese c)
        else
          (* 对于UTF-8字符，使用Unicode边界检测 *)
          BoundaryDetection.is_chinese_keyword_boundary state.input state.position next_char
    | InvalidSequence (_, _) -> true  (* 无效字符认为是边界 *)
    | EndOfInput -> true

(** 检查关键字匹配并更新最佳匹配 - 增强版 *)
let check_keyword_match state keyword token keyword_len best_match =
  if state.position + keyword_len > state.length then best_match
  else
    let substring = String.sub state.input state.position keyword_len in
    if substring <> keyword then best_match
    else
      let next_pos = state.position + keyword_len in
      if not (is_valid_keyword_boundary state next_pos) then best_match
      else
        match best_match with
        | None -> Some (keyword, token, keyword_len)
        | Some (_, _, best_len) when keyword_len > best_len -> Some (keyword, token, keyword_len)
        | Some _ -> best_match

(** 尝试匹配关键字 - 使用增强的处理逻辑 *)
let try_match_keyword state =
  let rec try_keywords keywords best_match =
    match keywords with
    | [] -> best_match
    | (keyword, token) :: rest ->
        let keyword_len = String.length keyword in
        let updated_match = check_keyword_match state keyword token keyword_len best_match in
        try_keywords rest updated_match
  in
  try_keywords
    (List.map
       (fun (str, variant) ->
         match variant with
         | `IdentifierTokenSpecial -> (str, IdentifierTokenSpecial str)
         | _ -> (str, variant_to_token variant))
       Keyword_tables.Keywords.all_keywords_list)
    None

(** 计算UTF-8字符串中的字符数量 - 使用增强的UTF-8处理 *)
let count_utf8_chars sequence =
  UTF8Processing.count_utf8_chars sequence

(** 创建关键字匹配后的新状态 - 增强位置跟踪 *)
let create_keyword_state state keyword_len =
  (* 计算实际的字符数而不是字节数 *)
  let keyword_text = String.sub state.input state.position keyword_len in
  let char_count = count_utf8_chars keyword_text in
  {
    state with
    position = state.position + keyword_len;
    current_column = state.current_column + char_count;  (* 使用字符数而不是字节数 *)
  }

(** 处理非关键字字符，检查是否为ASCII字母并提供更好的错误信息 *)
let handle_non_keyword_char state pos =
  match UTF8Processing.next_utf8_char_safe state.input state.position with
  | ValidChar (char_str, _) ->
      if String.length char_str = 1 then
        let cur_char = char_str.[0] in
        let char_code = Char.code cur_char in
        (* 使用增强的字符检测 *)
        if char_code < 128 && CharacterDetection.is_letter_or_chinese cur_char then
          (* 提供中文替代建议 *)
          let suggestion = CharacterValidation.suggest_alternative char_str in
          let error_msg = match suggestion with
            | Some alt -> Printf.sprintf "ASCII字母已禁用，请使用中文标识符。禁用字母: %s，建议使用: %s" char_str alt
            | None -> Printf.sprintf "ASCII字母已禁用，请使用中文标识符。禁用字母: %s" char_str
          in
          raise (EnhancedLexError (error_msg, pos, suggestion))
        else
          let char_category = CharacterDetection.classify_unicode_char char_str in
          let error_msg = Printf.sprintf "意外的字符: %s (类别: %s)" char_str char_category in
          raise (EnhancedLexError (error_msg, pos, None))
      else
        (* 对于多字节字符，保持与原版本一致的错误处理 *)
        let error_msg = Printf.sprintf "不支持的字符: %s (非关键字的多字节字符)" char_str in
        raise (EnhancedLexError (error_msg, pos, None))
  | InvalidSequence (_, error_msg) ->
      raise (EnhancedLexError (Printf.sprintf "无效的UTF-8序列: %s" error_msg, pos, None))
  | EndOfInput ->
      raise (EnhancedLexError ("意外的输入结束", pos, None))

(** 尝试匹配关键字或处理未知字符 - 增强错误处理 *)
let try_keyword_or_error state pos =
  try
    match try_match_keyword state with
    | Some (_, token, keyword_len) ->
        let new_state = create_keyword_state state keyword_len in
        (token, pos, new_state)
    | None -> handle_non_keyword_char state pos
  with
  | EnhancedLexError (msg, _error_pos, suggestion) ->
      (* 转换为原有的错误类型以保持兼容性 *)
      let enhanced_msg = match suggestion with
        | Some alt -> msg ^ Printf.sprintf " [建议: %s]" alt
        | None -> msg
      in
      raise (LexError (enhanced_msg, pos))

(** 处理中文数字序列 - 使用增强的中文数字处理 *)
let handle_chinese_number_sequence state pos sequence temp_state =
  let char_count = count_utf8_chars sequence in
  if char_count > 1 then
    (* 多字符数字序列，优先作为数字处理 *)
    let token = convert_chinese_number_sequence sequence in
    (token, pos, temp_state)
  else
    (* 单字符，尝试关键字匹配 *)
    match try_match_keyword state with
    | Some (_, token, keyword_len) ->
        let new_state = create_keyword_state state keyword_len in
        (token, pos, new_state)
    | None ->
        (* 不是关键字，作为数字处理 *)
        let token = convert_chinese_number_sequence sequence in
        (token, pos, temp_state)

(** 处理字母或中文字符 - 使用增强的Unicode分类 *)
let handle_letter_or_chinese_char state pos =
  match UTF8Processing.next_utf8_char_safe state.input state.position with
  | ValidChar (char_str, _) ->
      if ChineseCharProcessing.is_chinese_digit_char char_str then
        let sequence, temp_state = read_chinese_number_sequence state in
        if sequence <> "" then 
          handle_chinese_number_sequence state pos sequence temp_state
        else 
          try_keyword_or_error state pos
      else
        try_keyword_or_error state pos
  | InvalidSequence (error_pos, error_msg) ->
      raise (LexError (Printf.sprintf "UTF-8字符处理错误: %s (位置: %d)" error_msg error_pos, pos))
  | EndOfInput ->
      raise (LexError ("意外的输入结束", pos))

(* Module完成 - 提供与原lexer_chars.ml完全兼容的接口，同时使用增强的Unicode处理 *)