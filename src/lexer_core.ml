(** 骆言词法分析器核心模块 - 词法分析核心处理 *)

open Lexer_tokens
open Lexer_state
open Lexer_utils

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
                  (* 简单方法：如果下一个字符也是中文字符，检查是否有更长的匹配 *)
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
                         ||
                         (* 「 *)
                         Char.code state.input.[next_pos + 2] = Constants.UTF8.right_quote_byte3)
                      (* 」 *)
                    in
                    if is_quote_punctuation then true (* 引号字符，关键字完整 *)
                    else
                      (* 检查是否存在以当前关键字为前缀且与当前输入匹配的更长关键字 *)
                      let has_longer_actual_match =
                        List.exists
                          (fun (kw, _) ->
                            let kw_len = String.length kw in
                            kw_len > keyword_len
                            && String.sub kw 0 keyword_len = keyword
                            && state.position + kw_len <= state.length
                            && String.sub state.input state.position kw_len = kw)
                          (List.map
                             (fun (str, variant) -> (str, Lexer_variants.variant_to_token variant))
                             Keyword_tables.Keywords.all_keywords_list)
                      in
                      not has_longer_actual_match
                  else true (* 下一个字符不是中文，当前关键字完整 *)
                else
                  (* 英文关键字：减少对空格边界的依赖，使用更简单的分隔符检查 *)
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
    (List.map
       (fun (str, variant) -> (str, Lexer_variants.variant_to_token variant))
       Keyword_tables.Keywords.all_keywords_list)
    None

(** 读取字符串字面量 *)
let read_string_literal state : token * lexer_state =
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
            raise
              (LexError
                 ( "Unterminated string",
                   {
                     line = state.current_line;
                     column = state.current_column;
                     filename = state.filename;
                   } )))
    | Some c -> read (advance state) (acc ^ String.make 1 c)
    | None ->
        raise
          (LexError
             ( "Unterminated string",
               {
                 line = state.current_line;
                 column = state.current_column;
                 filename = state.filename;
               } ))
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
    if pos >= state.length then failwith "未闭合的引用标识符"
    else
      let ch, next_pos = next_utf8_char state.input pos in
      if ch = "」" then (acc, next_pos) (* 找到结束引号，返回内容和新位置 *)
      else if ch = "" then failwith "引用标识符中的无效字符"
      else loop next_pos (acc ^ ch)
    (* 继续累积字符 *)
  in
  let identifier, new_pos = loop state.position "" in
  let new_col = state.current_column + (new_pos - state.position) in
  (* 根据Issue #176：所有用「」引用的都是标识符，不管内容是什么 *)
  let token = QuotedIdentifierToken identifier in
  (token, { state with position = new_pos; current_column = new_col })
