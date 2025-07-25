(** 骆言词法分析器 - 工具函数模块 (模块化重构版本) *)

open Lexer_state

(** 字符处理函数 - 从 Lexer_char_processing 模块导入 *)
let is_chinese_char = Lexer_char_processing.is_chinese_char

let is_letter_or_chinese = Lexer_char_processing.is_letter_or_chinese
let is_digit = Lexer_char_processing.is_digit
let is_whitespace = Lexer_char_processing.is_whitespace
let is_separator_char = Lexer_char_processing.is_separator_char
let is_chinese_utf8 = Lexer_char_processing.is_chinese_utf8
let next_utf8_char = Lexer_char_processing.next_utf8_char
let is_chinese_digit_char = Lexer_char_processing.is_chinese_digit_char
let is_all_digits = Lexer_char_processing.is_all_digits
let is_valid_identifier = Lexer_char_processing.is_valid_identifier

(** 从指定位置开始读取字符串，直到满足停止条件 *)
let read_string_until state start_pos stop_condition =
  let rec loop pos acc =
    if pos >= String.length state.input then (String.concat "" (List.rev acc), pos)
    else
      let ch, next_pos = next_utf8_char state.input pos in
      if stop_condition ch then (String.concat "" (List.rev acc), pos) else loop next_pos (ch :: acc)
  in
  loop start_pos []

(** 解析整数 *)
let parse_integer str = try Some (int_of_string str) with Failure _ -> None

(** 解析浮点数 *)
let parse_float str = try Some (float_of_string str) with Failure _ -> None

(** 解析十六进制数 *)
let parse_hex_int str = try Some (int_of_string ("0x" ^ str)) with Failure _ -> None

(** 解析八进制数 *)
let parse_oct_int str = try Some (int_of_string ("0o" ^ str)) with Failure _ -> None

(** 解析二进制数 *)
let parse_bin_int str = try Some (int_of_string ("0b" ^ str)) with Failure _ -> None

(** 转义字符处理 *)
let process_escape_sequences str =
  let len = String.length str in
  let buf = Buffer.create len in
  let rec loop i =
    if i >= len then Buffer.contents buf
    else if str.[i] = '\\' && i + 1 < len then (
      match str.[i + 1] with
      | 'n' ->
          Buffer.add_char buf '\n';
          loop (i + 2)
      | 't' ->
          Buffer.add_char buf '\t';
          loop (i + 2)
      | 'r' ->
          Buffer.add_char buf '\r';
          loop (i + 2)
      | '\\' ->
          Buffer.add_char buf '\\';
          loop (i + 2)
      | '"' ->
          Buffer.add_char buf '"';
          loop (i + 2)
      | '\'' ->
          Buffer.add_char buf '\'';
          loop (i + 2)
      | c ->
          Buffer.add_char buf '\\';
          Buffer.add_char buf c;
          loop (i + 2))
    else (
      Buffer.add_char buf str.[i];
      loop (i + 1))
  in
  loop 0

module ChineseNumberConverter = Lexer_chinese_numbers.ChineseNumberConverter
(** 中文数字处理函数 - 从 Lexer_chinese_numbers 模块导入 *)

let read_chinese_number_sequence = Lexer_chinese_numbers.read_chinese_number_sequence
let convert_chinese_number_sequence = Lexer_chinese_numbers.convert_chinese_number_sequence

(** 读取全角数字序列 *)
let read_fullwidth_number_sequence state =
  let input = state.input in
  let length = state.length in
  let rec loop pos acc =
    if pos >= length then (acc, pos)
    else
      let ch, next_pos = next_utf8_char input pos in
      if Utf8_utils.FullwidthDetection.is_fullwidth_digit_string ch then loop next_pos (acc ^ ch)
      else (acc, pos)
  in
  let sequence, new_pos = loop state.position "" in
  let new_col = state.current_column + ((new_pos - state.position) / 3) in
  (* 每个全角字符3字节但占1列 *)
  (sequence, { state with position = new_pos; current_column = new_col })

(** 转换全角数字序列为数值 *)
let convert_fullwidth_number_sequence sequence =
  let rec loop pos acc =
    if pos >= String.length sequence then acc
    else if pos + 2 < String.length sequence then
      let ch = String.sub sequence pos 3 in
      match Utf8_utils.FullwidthDetection.fullwidth_digit_to_int ch with
      | Some digit -> loop (pos + 3) ((acc * 10) + digit)
      | None -> acc
    else acc
  in
  let int_val = loop 0 0 in
  Lexer_tokens.IntToken int_val

(** 中文标点符号识别函数 - 从 Lexer_punctuation_recognition 模块导入 *)
let recognize_chinese_punctuation = Lexer_punctuation_recognition.recognize_chinese_punctuation

let recognize_pipe_right_bracket = Lexer_punctuation_recognition.recognize_pipe_right_bracket
