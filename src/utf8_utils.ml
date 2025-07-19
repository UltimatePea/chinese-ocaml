(** 骆言词法分析器UTF-8字符处理工具模块 *)

open Constants

(** UTF-8字符检测和处理 *)

(** 检查字符是否为中文字符 *)
let is_chinese_char c =
  let code = Char.code c in
  (* CJK Unified Ideographs range: U+4E00-U+9FFF *)
  (* But for UTF-8 bytes, we need to check differently *)
  code >= UTF8.chinese_char_start
  || (code >= UTF8.chinese_char_mid_start && code <= UTF8.chinese_char_mid_end)

(** 检查字符是否为字母或中文 *)
let is_letter_or_chinese c = (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || is_chinese_char c

(** 检查字符是否为数字 *)
let is_digit c = c >= '0' && c <= '9'

(** 检查字符是否为空白字符 *)
let is_whitespace c = c = ' ' || c = '\t' || c = '\r'

(** 检查字符是否为分隔符 *)
let is_separator_char c = c = '\t' || c = '\r' || c = '\n'

(** 检查UTF-8字符序列 *)
let check_utf8_char input pos byte1 byte2 byte3 =
  pos + 2 < String.length input
  && Char.code input.[pos] = byte1
  && Char.code input.[pos + 1] = byte2
  && Char.code input.[pos + 2] = byte3

(** 检查是否为中文UTF-8字符串 *)
let is_chinese_utf8 s =
  String.length s >= 3
  &&
  let c1 = Char.code s.[0] in
  let c2 = Char.code s.[1] in
  let c3 = Char.code s.[2] in
  c1 >= 0xE0 && c1 <= 0xEF && c2 >= 0x80 && c2 <= 0xBF && c3 >= 0x80 && c3 <= 0xBF

(** 读取下一个UTF-8字符，提供两种实现以保持兼容性 *)
let next_utf8_char input pos =
  if pos >= String.length input then None
  else
    let c = input.[pos] in
    let code = Char.code c in
    if code < 0x80 then
      (* ASCII字符 *)
      Some (String.make 1 c, pos + 1)
    else if code < 0xC0 then
      (* 无效的UTF-8起始字节 *)
      None
    else if code < 0xE0 then
      (* 2字节UTF-8字符 *)
      if pos + 1 < String.length input then Some (String.sub input pos 2, pos + 2) else None
    else if code < 0xF0 then
      (* 3字节UTF-8字符 (大多数中文字符) *)
      if pos + 2 < String.length input then Some (String.sub input pos 3, pos + 3) else None
    else if
      (* 4字节UTF-8字符 *)
      pos + 3 < String.length input
    then Some (String.sub input pos 4, pos + 4)
    else None

(** 读取下一个UTF-8字符（使用Uutf库，与lexer_utils兼容） *)
let next_utf8_char_uutf input pos =
  if pos >= String.length input then ("", pos)
  else
    try
      let dec = Uutf.decoder (`String (String.sub input pos (String.length input - pos))) in
      match Uutf.decode dec with
      | `Uchar u ->
          let buf = Buffer.create 8 in
          Uutf.Buffer.add_utf_8 buf u;
          let s = Buffer.contents buf in
          let len = Bytes.length (Bytes.of_string s) in
          (s, pos + len)
      | _ -> ("", pos)
    with
    | _ -> ("", pos)

(** 检查是否为中文数字字符 *)
let is_chinese_digit_char ch =
  match ch with
  | "一" | "二" | "三" | "四" | "五" | "六" | "七" | "八" | "九" | "零" | "十" | "百" | "千" | "万" | "亿" | "点" ->
      true
  | _ -> false

(** 中文标点符号检测 *)
module ChinesePunctuation = struct
  (** 检查是否为左引号「 *)
  let is_left_quote input pos =
    check_utf8_char input pos UTF8.left_quote_byte1 UTF8.left_quote_byte2 UTF8.left_quote_byte3

  (** 检查是否为右引号」 *)
  let is_right_quote input pos =
    check_utf8_char input pos UTF8.right_quote_byte1 UTF8.right_quote_byte2 UTF8.right_quote_byte3

  (** 检查是否为字符串开始符『 *)
  let is_string_start input pos =
    check_utf8_char input pos UTF8.string_start_byte1 UTF8.string_start_byte2
      UTF8.string_start_byte3

  (** 检查是否为字符串结束符』 *)
  let is_string_end input pos =
    check_utf8_char input pos UTF8.string_end_byte1 UTF8.string_end_byte2 UTF8.string_end_byte3

  (** 检查是否为中文句号。 *)
  let is_chinese_period input pos =
    check_utf8_char input pos UTF8.chinese_period_byte1 UTF8.chinese_period_byte2
      UTF8.chinese_period_byte3

  (** 检查是否为中文左括号（ *)
  let is_chinese_left_paren input pos = check_utf8_char input pos 0xEF 0xBC 0x88

  (** 检查是否为中文右括号） *)
  let is_chinese_right_paren input pos = check_utf8_char input pos 0xEF 0xBC 0x89

  (** 检查是否为中文逗号， *)
  let is_chinese_comma input pos = check_utf8_char input pos 0xEF 0xBC 0x8C

  (** 检查是否为中文冒号： *)
  let is_chinese_colon input pos = check_utf8_char input pos 0xEF 0xBC 0x9A

  (** 检查是否为中文分号； *)
  let is_chinese_semicolon input pos = check_utf8_char input pos 0xEF 0xBC 0x9B

  (** 检查是否为中文管道符｜ *)
  let is_chinese_pipe input pos = check_utf8_char input pos 0xEF 0xBD 0x9C
end

(** 全角字符检测 *)
module FullwidthDetection = struct
  (** 检查是否为全角数字 *)
  let is_fullwidth_digit c =
    let code = Char.code c in
    code >= 0xFF10 && code <= 0xFF19

  (** 检查是否为全角字母 *)
  let is_fullwidth_letter c =
    let code = Char.code c in
    (code >= 0xFF21 && code <= 0xFF3A) || (code >= 0xFF41 && code <= 0xFF5A)

  (** 检查是否为全角符号 *)
  let is_fullwidth_symbol input pos =
    pos + 2 < String.length input
    && Char.code input.[pos] = UTF8.fullwidth_start_byte1
    && Char.code input.[pos + 1] = UTF8.fullwidth_start_byte2

  (** 检查UTF-8字符串是否为全角数字 *)
  let is_fullwidth_digit_string s =
    if
      String.length s = 3
      && Char.code s.[0] = UTF8.fullwidth_start_byte1
      && Char.code s.[1] = UTF8.fullwidth_start_byte2
    then
      let third_byte = Char.code s.[2] in
      third_byte >= UTF8.fullwidth_digit_start && third_byte <= UTF8.fullwidth_digit_end (* ０到９ *)
    else false

  (** 将全角数字字符串转换为对应的数字值 *)
  let fullwidth_digit_to_int s =
    if is_fullwidth_digit_string s then Some (Char.code s.[2] - UTF8.fullwidth_digit_start)
    else None
end

(** 辅助函数：检查字符串是否只包含数字 *)
let is_all_digits str =
  let len = String.length str in
  let rec check i = if i >= len then true else if is_digit str.[i] then check (i + 1) else false in
  len > 0 && check 0

(** 辅助函数：检查字符串是否只包含字母、数字和下划线 *)
let is_valid_identifier str =
  let len = String.length str in
  let rec check i =
    if i >= len then true
    else
      let c = str.[i] in
      if is_letter_or_chinese c || is_digit c || c = '_' then check (i + 1) else false
  in
  len > 0 && check 0

(** 简单的字符列表操作（与poetry模块兼容） *)
let string_to_char_list s =
  let rec aux acc i = if i >= String.length s then List.rev acc else aux (s.[i] :: acc) (i + 1) in
  aux [] 0

let char_list_to_string chars =
  let buf = Buffer.create (List.length chars) in
  List.iter (Buffer.add_char buf) chars;
  Buffer.contents buf

(** 过滤出中文字符 *)
let filter_chinese_chars s =
  let chars = string_to_char_list s in
  let chinese_chars = List.filter is_chinese_char chars in
  char_list_to_string chinese_chars

(** 计算字符串长度（中文字符数） *)
let chinese_length s =
  let chars = string_to_char_list s in
  List.length (List.filter is_chinese_char chars)

(** UTF-8字符串处理工具 *)
module StringUtils = struct
  (** 获取UTF-8字符串的字符数（不是字节数） *)
  let utf8_length s =
    let rec count pos acc =
      if pos >= String.length s then acc
      else
        match next_utf8_char s pos with
        | None -> acc
        | Some (_, next_pos) -> count next_pos (acc + 1)
    in
    count 0 0

  (** 检查UTF-8字符串是否全部为中文字符 *)
  let is_all_chinese s =
    let rec check pos =
      if pos >= String.length s then true
      else
        match next_utf8_char s pos with
        | None -> false
        | Some (char, next_pos) ->
            if String.length char = 3 && is_chinese_utf8 char then check next_pos else false
    in
    check 0

  (** 将UTF-8字符串拆分为字符列表 *)
  let utf8_to_char_list s =
    let rec collect pos acc =
      if pos >= String.length s then List.rev acc
      else
        match next_utf8_char s pos with
        | None -> List.rev acc
        | Some (char, next_pos) -> collect next_pos (char :: acc)
    in
    collect 0 []
end

(** 关键字边界检测 *)
module BoundaryDetection = struct
  (** 检查中文关键字边界 *)
  let is_chinese_keyword_boundary input pos keyword =
    let keyword_len = String.length keyword in
    let next_pos = pos + keyword_len in
    if next_pos >= String.length input then true (* 文件结尾 *)
    else
      let next_char = input.[next_pos] in
      (* 对于中文关键字，检查边界 *)
      if String.for_all (fun c -> Char.code c >= Constants.UTF8.chinese_char_threshold) keyword then
        (* 中文关键字：检查下一个字符是否可能形成更长的关键字 *)
        let next_is_chinese = Char.code next_char >= Constants.UTF8.chinese_char_threshold in
        if next_is_chinese then
          (* 检查是否为引用标识符的引号，如果是则认为关键字完整 *)
          ChinesePunctuation.is_left_quote input next_pos
          || ChinesePunctuation.is_right_quote input next_pos
          || ChinesePunctuation.is_string_start input next_pos
          || ChinesePunctuation.is_string_end input next_pos
          || is_whitespace next_char || is_separator_char next_char
        else
          (* 下一个字符不是中文，关键字完整 *)
          true
      else
        (* ASCII关键字：检查下一个字符是否为字母数字 *)
        not (is_letter_or_chinese next_char || is_digit next_char)

  (** 检查标识符边界 *)
  let is_identifier_boundary input pos =
    if pos >= String.length input then true
    else
      let c = input.[pos] in
      not (is_letter_or_chinese c || is_digit c || c = '_')
end
