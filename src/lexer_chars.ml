(** 词法分析器字符处理模块 *)

open Lexer_state
open Lexer_tokens
open Lexer_utils
open Lexer_keywords

(** 检查UTF-8字符匹配 *)
let check_utf8_char state _byte1 byte2 byte3 =
  state.position + 2 < state.length
  && Char.code state.input.[state.position + 1] = byte2
  && Char.code state.input.[state.position + 2] = byte3

(** 检查关键字边界 - 重构：提取独立函数 *)
let is_valid_keyword_boundary state next_pos =
  if next_pos >= state.length then true (* 文件结尾 *)
  else
    let next_utf8_char, _ = next_utf8_char state.input next_pos in
    if String.length next_utf8_char = 1 then
      let next_char = next_utf8_char.[0] in
      (* 检查是否为分隔符或允许的字符 *)
      is_separator_char next_char || next_char = ' ' || next_char = '\t' || next_char = '\n'
      || is_digit next_char (* 允许关键字后面跟数字 *)
      || not ((next_char >= 'a' && next_char <= 'z') || (next_char >= 'A' && next_char <= 'Z'))
    else
      (* 对于UTF-8字符，允许中文关键字匹配 *)
      true

(** 检查关键字匹配并更新最佳匹配 - 重构：减少嵌套 *)
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

(** 尝试匹配关键字 - 重构：消除深度嵌套 *)
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

(* 计算UTF-8字符串中的字符数量 *)
let count_utf8_chars sequence =
  let sequence_len = String.length sequence in
  let char_count = ref 0 in
  let pos_ref = ref 0 in
  while !pos_ref < sequence_len do
    let _, char_len = next_utf8_char sequence !pos_ref in
    incr char_count;
    pos_ref := !pos_ref + char_len
  done;
  !char_count

(* 创建关键字匹配后的新状态 *)
let create_keyword_state state keyword_len =
  {
    state with
    position = state.position + keyword_len;
    current_column = state.current_column + keyword_len;
  }

(* 处理非关键字字符，检查是否为ASCII字母并抛出错误 *)
let handle_non_keyword_char state pos =
  let utf8_char, _ = next_utf8_char state.input state.position in
  if String.length utf8_char = 1 then
    let cur_char = utf8_char.[0] in
    if (cur_char >= 'a' && cur_char <= 'z') || (cur_char >= 'A' && cur_char <= 'Z') then
      raise (LexError ("ASCII字母已禁用，请使用中文标识符。禁用字母: " ^ String.make 1 cur_char, pos))
    else raise (LexError ("意外的字符: " ^ utf8_char, pos))
  else raise (LexError ("意外的字符: " ^ utf8_char, pos))

(* 尝试匹配关键字或处理未知字符 *)
let try_keyword_or_error state pos =
  match try_match_keyword state with
  | Some (_, token, keyword_len) ->
      let new_state = create_keyword_state state keyword_len in
      (token, pos, new_state)
  | None -> handle_non_keyword_char state pos

(* 处理中文数字序列 *)
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

(** 处理字母或中文字符 *)
let handle_letter_or_chinese_char state pos =
  let ch, _ = next_utf8_char state.input state.position in
  if is_chinese_digit_char ch then
    let sequence, temp_state = read_chinese_number_sequence state in
    if sequence <> "" then handle_chinese_number_sequence state pos sequence temp_state
    else try_keyword_or_error state pos
  else try_keyword_or_error state pos
