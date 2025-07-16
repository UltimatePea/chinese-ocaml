(** 骆言词法分析器 - 工具函数模块 *)

(** 是否为中文字符 *)
let is_chinese_char c =
  let code = Char.code c in
  (* CJK Unified Ideographs range: U+4E00-U+9FFF *)
  (* But for UTF-8 bytes, we need to check differently *)
  code >= Constants.UTF8.chinese_char_start
  || (code >= Constants.UTF8.chinese_char_mid_start && code <= Constants.UTF8.chinese_char_mid_end)

(** 是否为字母或中文 *)
let is_letter_or_chinese c = (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || is_chinese_char c

(** 是否为数字 *)
let is_digit c = c >= '0' && c <= '9'

(** 是否为空白字符 - 空格仍需跳过，但不用于关键字消歧 *)
let is_whitespace c = c = ' ' || c = '\t' || c = '\r'

(** 是否为分隔符字符 - 用于关键字边界检查（不包括空格） *)
let is_separator_char c = c = '\t' || c = '\r' || c = '\n'

(** 判断一个UTF-8字符串是否为中文字符（CJK Unified Ideographs） *)
let is_chinese_utf8 s =
  match Uutf.decode (Uutf.decoder (`String s)) with
  | `Uchar u ->
      let code = Uchar.to_int u in
      code >= 0x4E00 && code <= 0x9FFF
  | _ -> false

(** 读取下一个UTF-8字符，返回字符和新位置 *)
let next_utf8_char input pos =
  let dec = Uutf.decoder (`String (String.sub input pos (String.length input - pos))) in
  match Uutf.decode dec with
  | `Uchar u ->
      let buf = Buffer.create 8 in
      Uutf.Buffer.add_utf_8 buf u;
      let s = Buffer.contents buf in
      let len = Bytes.length (Bytes.of_string s) in
      (s, pos + len)
  | _ -> ("", pos)

(** 是否为中文数字字符 *)
let is_chinese_digit_char ch =
  match ch with
  | "一" | "二" | "三" | "四" | "五" | "六" | "七" | "八" | "九" | "十" | "零" | "点" -> true
  | _ -> false

(** 从指定位置开始读取字符串，直到满足停止条件 *)
let read_string_until state start_pos stop_condition =
  let rec loop pos acc =
    if pos >= String.length state.Lexer_state.input then
      (String.concat "" (List.rev acc), pos)
    else
      let ch, next_pos = next_utf8_char state.Lexer_state.input pos in
      if stop_condition ch then
        (String.concat "" (List.rev acc), pos)
      else
        loop next_pos (ch :: acc)
  in
  loop start_pos []

(** 解析整数 *)
let parse_integer str =
  try Some (int_of_string str) with Failure _ -> None

(** 解析浮点数 *)
let parse_float str =
  try Some (float_of_string str) with Failure _ -> None

(** 解析十六进制数 *)
let parse_hex_int str =
  try Some (int_of_string ("0x" ^ str)) with Failure _ -> None

(** 解析八进制数 *)
let parse_oct_int str =
  try Some (int_of_string ("0o" ^ str)) with Failure _ -> None

(** 解析二进制数 *)
let parse_bin_int str =
  try Some (int_of_string ("0b" ^ str)) with Failure _ -> None

(** 转义字符处理 *)
let process_escape_sequences str =
  let len = String.length str in
  let buf = Buffer.create len in
  let rec loop i =
    if i >= len then Buffer.contents buf
    else if str.[i] = '\\' && i + 1 < len then
      match str.[i + 1] with
      | 'n' -> Buffer.add_char buf '\n'; loop (i + 2)
      | 't' -> Buffer.add_char buf '\t'; loop (i + 2)
      | 'r' -> Buffer.add_char buf '\r'; loop (i + 2)
      | '\\' -> Buffer.add_char buf '\\'; loop (i + 2)
      | '"' -> Buffer.add_char buf '"'; loop (i + 2)
      | '\'' -> Buffer.add_char buf '\''; loop (i + 2)
      | c -> Buffer.add_char buf '\\'; Buffer.add_char buf c; loop (i + 2)
    else (
      Buffer.add_char buf str.[i]; 
      loop (i + 1)
    )
  in
  loop 0

(** 检查字符串是否只包含数字 *)
let is_all_digits str =
  let len = String.length str in
  let rec check i =
    if i >= len then true
    else if is_digit str.[i] then check (i + 1)
    else false
  in
  len > 0 && check 0

(** 检查字符串是否只包含字母、数字和下划线 *)
let is_valid_identifier str =
  let len = String.length str in
  let rec check i =
    if i >= len then true
    else
      let c = str.[i] in
      if is_letter_or_chinese c || is_digit c || c = '_' then check (i + 1)
      else false
  in
  len > 0 && check 0