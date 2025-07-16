(** 骆言词法分析器 - Chinese Programming Language Lexer *)

(* 导入模块化的词法分析器组件 *)
open Lexer_tokens
open Lexer_state  
open Lexer_utils
open Lexer_variants

(* 从原始lexer.ml中保留的必要函数 *)

(** 检查UTF-8字符匹配 *)
let check_utf8_char state _byte1 byte2 byte3 =
  state.position + 2 < state.length
  && Char.code state.input.[state.position + 1] = byte2
  && Char.code state.input.[state.position + 2] = byte3

(** 尝试匹配关键字 *)
let try_match_keyword state =
  let rec try_keywords keywords best_match =
    match keywords with
    | [] -> best_match
    | (keyword, token) :: rest ->
        let keyword_len = String.length keyword in
        if state.position + keyword_len <= state.length then
          let substring = String.sub state.input state.position keyword_len in
          if substring = keyword then
            (* 检查关键字边界 *)
            let next_pos = state.position + keyword_len in
            let is_complete_word =
              if next_pos >= state.length then true (* 文件结尾 *)
              else
                let next_char = state.input.[next_pos] in
                (* 对于中文关键字，检查边界 *)
                if
                  String.for_all
                    (fun c -> Char.code c >= Constants.UTF8.chinese_char_threshold)
                    keyword
                then
                  (* 中文关键字：检查下一个字符是否可能形成更长的关键字 *)
                  let next_is_chinese =
                    Char.code next_char >= Constants.UTF8.chinese_char_threshold
                  in
                  if next_is_chinese then
                    (* 检查是否为引用标识符的引号，如果是则认为关键字完整 *)
                    let is_quote_punctuation =
                      Char.code next_char = Constants.UTF8.left_quote_byte1
                      && next_pos + 2 < state.length
                      && Char.code state.input.[next_pos + 1] = Constants.UTF8.left_quote_byte2
                      && (Char.code state.input.[next_pos + 2] = Constants.UTF8.left_quote_byte3
                         || Char.code state.input.[next_pos + 2] = Constants.UTF8.right_quote_byte3)
                    in
                    if is_quote_punctuation then true (* 引号字符，关键字完整 *)
                    else
                      (* 简化的匹配逻辑 - 假设当前匹配是完整的 *)
                      true
                  else true (* 下一个字符不是中文，当前关键字完整 *)
                else
                  (* 英文关键字：使用简单的分隔符检查 *)
                  is_separator_char next_char
                  || not (is_letter_or_chinese next_char || is_digit next_char)
            in
            if is_complete_word then
              match best_match with
              | None -> try_keywords rest (Some (keyword, token, keyword_len))
              | Some (_, _, best_len) when keyword_len > best_len ->
                  try_keywords rest (Some (keyword, token, keyword_len))
              | Some _ -> try_keywords rest best_match
            else try_keywords rest best_match
          else try_keywords rest best_match
        else try_keywords rest best_match
  in
  try_keywords
    (List.map (fun (str, variant) -> (str, variant_to_token variant)) Keyword_tables.Keywords.all_keywords_list)
    None

(** 读取字符串字面量 *)
let read_string_literal state : (token * lexer_state) =
  let rec read state acc =
    match current_char state with
    | Some c when Char.code c = 0xE3 && check_utf8_char state 0xE3 0x80 0x8F ->
        (* 』 (U+300F) - 结束字符串字面量 *)
        let new_state =
          { state with position = state.position + 3; current_column = state.current_column + 1 }
        in
        (StringToken acc, new_state)
    | Some '\\' -> (
        let state1 = advance state in
        match current_char state1 with
        | Some 'n' -> read (advance state1) (acc ^ "\n")
        | Some 't' -> read (advance state1) (acc ^ "\t")
        | Some 'r' -> read (advance state1) (acc ^ "\r")
        | Some '"' -> read (advance state1) (acc ^ "\"")
        | Some '\\' -> read (advance state1) (acc ^ "\\")
        | Some c -> read (advance state1) (acc ^ String.make 1 c)
        | None ->
            raise (LexError ("Unterminated string", {
                     line = state.current_line;
                     column = state.current_column;
                     filename = state.filename;
                   })))
    | Some c -> read (advance state) (acc ^ String.make 1 c)
    | None ->
        raise (LexError ("Unterminated string", {
                 line = state.current_line;
                 column = state.current_column;
                 filename = state.filename;
               }))
  in
  read state ""

(** 读取阿拉伯数字 - Issue #192: 允许阿拉伯数字 *)
let read_arabic_number state =
  let rec read_digits pos acc =
    if pos >= state.length then (acc, pos)
    else
      let c = state.input.[pos] in
      if is_digit c then read_digits (pos + 1) (acc ^ String.make 1 c) else (acc, pos)
  in
  let digits, end_pos = read_digits state.position "" in
  let new_state =
    {
      state with
      position = end_pos;
      current_column = state.current_column + (end_pos - state.position);
    }
  in

  (* 检查是否有小数点 *)
  if end_pos < state.length && state.input.[end_pos] = '.' then
    (* 有小数点，尝试读取小数部分 *)
    let decimal_digits, final_pos = read_digits (end_pos + 1) "" in
    if decimal_digits = "" then
      (* 小数点后没有数字，只返回整数部分 *)
      (IntToken (int_of_string digits), new_state)
    else
      (* 有小数部分 *)
      let float_str = digits ^ "." ^ decimal_digits in
      let final_state =
        {
          state with
          position = final_pos;
          current_column = state.current_column + (final_pos - state.position);
        }
      in
      (FloatToken (float_of_string float_str), final_state)
  else
    (* 只是整数 *)
    (IntToken (int_of_string digits), new_state)

(** 读取引用标识符 *)
let read_quoted_identifier state =
  let rec loop pos acc =
    if pos >= state.length then
      failwith "未闭合的引用标识符"
    else
      let ch, next_pos = next_utf8_char state.input pos in
      if ch = "」" then (acc, next_pos) (* 找到结束引号，返回内容和新位置 *)
      else if ch = "" then
        failwith "引用标识符中的无效字符"
      else loop next_pos (acc ^ ch)
  in
  let identifier, new_pos = loop state.position "" in
  let new_col = state.current_column + (new_pos - state.position) in
  let token = QuotedIdentifierToken identifier in
  (token, { state with position = new_pos; current_column = new_col })

(** 获取下一个词元 *)
let next_token state : (token * position * lexer_state) =
  let state = skip_whitespace_and_comments state in
  let pos =
    { line = state.current_line; column = state.current_column; filename = state.filename }
  in

  match current_char state with
  | None -> (EOF, pos, state)
  | Some '\n' -> (Newline, pos, advance state)
  | _ -> (
      (* 首先尝试识别中文标点符号 *)
      try
        match recognize_chinese_punctuation state pos with
        | Some result -> result
        | None -> (
            (* 尝试识别｜」组合 *)
            match recognize_pipe_right_bracket state pos with
            | Some result -> result
            | None -> (
              (* ASCII符号现在被禁止使用 - 抛出错误 *)
              match current_char state with
              | None -> (EOF, pos, state)
              | Some '"' ->
                  raise (LexError ("ASCII符号已禁用，请使用中文标点符号。禁用字符: \"", pos))
              | Some (( '+' | '-' | '*' | '/' | '%' | '^' | '=' | '<' | '>' | '.' | '(' | ')' | '['
                       | ']' | '{' | '}' | ',' | ';' | ':' | '!' | '|' | '_' | '@' | '#' | '$' | '&'
                       | '?' | '\'' | '`' | '~' ) as c) ->
                  raise (LexError ("ASCII符号已禁用，请使用中文标点符号。禁用字符: " ^ String.make 1 c, pos))
              | Some c when Char.code c = 0xE3 && check_utf8_char state 0xE3 0x80 0x8E ->
                  (* 『 (U+300E) - 开始字符串字面量 *)
                  let skip_state =
                    {
                      state with
                      position = state.position + 3;
                      current_column = state.current_column + 1;
                    }
                  in
                  let (token, new_state) = read_string_literal skip_state in
                  (token, pos, new_state)
              | Some c when Char.code c = 0xE3 && check_utf8_char state 0xE3 0x80 0x8C ->
                  (* 「 (U+300C) - 开始引用标识符 *)
                  let skip_state =
                    {
                      state with
                      position = state.position + 3;
                      current_column = state.current_column + 1;
                    }
                  in
                  let token, new_state = read_quoted_identifier skip_state in
                  (token, pos, new_state)
              | Some c when is_digit c ->
                  (* 阿拉伯数字 *)
                  let token, new_state = read_arabic_number state in
                  (token, pos, new_state)
              | Some c when is_letter_or_chinese c ->
                  (* 尝试匹配关键字 *)
                  match try_match_keyword state with
                  | Some (keyword, token, keyword_len) ->
                      let new_state =
                        {
                          state with
                          position = state.position + keyword_len;
                          current_column = state.current_column + keyword_len;
                        }
                      in
                      (token, pos, new_state)
                  | None ->
                      (* 尝试处理中文数字 *)
                      let ch, _ = next_utf8_char state.input state.position in
                      if is_chinese_digit_char ch then
                        let sequence, temp_state = read_chinese_number_sequence state in
                        if sequence <> "" then
                          let token = convert_chinese_number_sequence sequence in
                          (token, pos, temp_state)
                        else
                          (* 不是中文数字，尝试关键字匹配 *)
                          match try_match_keyword state with
                          | Some (keyword, token, keyword_len) ->
                              let new_state =
                                {
                                  state with
                                  position = state.position + keyword_len;
                                  current_column = state.current_column + keyword_len;
                                }
                              in
                              (token, pos, new_state)
                          | None ->
                              (* 不是关键字，报错 *)
                              raise (LexError ("意外的字符: " ^ String.make 1 c, pos))
                      else
                        (* 不是中文数字，尝试关键字匹配 *)
                        match try_match_keyword state with
                        | Some (keyword, token, keyword_len) ->
                            let new_state =
                              {
                                state with
                                position = state.position + keyword_len;
                                current_column = state.current_column + keyword_len;
                              }
                            in
                            (token, pos, new_state)
                        | None ->
                            (* 不是关键字，报错 *)
                            raise (LexError ("意外的字符: " ^ String.make 1 c, pos))
              | Some c ->
                  (* 其他字符，报错 *)
                  raise (LexError ("意外的字符: " ^ String.make 1 c, pos))
              ))
      with
      | LexError (msg, pos) -> raise (LexError (msg, pos))
  )

(** 词法分析主函数 *)
let tokenize input filename : positioned_token list =
  let rec analyze state acc =
    let (token, pos, new_state) = next_token state in
    let positioned_token = (token, pos) in
    (match token with
     | EOF -> List.rev (positioned_token :: acc)
     | Newline -> analyze new_state (positioned_token :: acc)
     | _ -> analyze new_state (positioned_token :: acc))
  in
  let initial_state = create_lexer_state input filename in
  analyze initial_state []