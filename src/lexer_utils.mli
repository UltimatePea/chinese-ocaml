(** 骆言词法分析器 - 工具函数模块接口 *)

val is_chinese_char : char -> bool
(** 是否为中文字符 *)

val is_letter_or_chinese : char -> bool
(** 是否为字母或中文 *)

val is_digit : char -> bool
(** 是否为数字 *)

val is_whitespace : char -> bool
(** 是否为空白字符 - 空格仍需跳过，但不用于关键字消歧 *)

val is_separator_char : char -> bool
(** 是否为分隔符字符 - 用于关键字边界检查（不包括空格） *)

val is_chinese_utf8 : string -> bool
(** 判断一个UTF-8字符串是否为中文字符（CJK Unified Ideographs） *)

val next_utf8_char : string -> int -> string * int
(** 读取下一个UTF-8字符，返回字符和新位置 *)

val is_chinese_digit_char : string -> bool
(** 是否为中文数字字符 *)

val read_string_until : Lexer_state.lexer_state -> int -> (string -> bool) -> string * int
(** 从指定位置开始读取字符串，直到满足停止条件 *)

val parse_integer : string -> int option
(** 解析整数 *)

val parse_float : string -> float option
(** 解析浮点数 *)

val parse_hex_int : string -> int option
(** 解析十六进制数 *)

val parse_oct_int : string -> int option
(** 解析八进制数 *)

val parse_bin_int : string -> int option
(** 解析二进制数 *)

val process_escape_sequences : string -> string
(** 转义字符处理 *)

val is_all_digits : string -> bool
(** 检查字符串是否只包含数字 *)

val is_valid_identifier : string -> bool
(** 检查字符串是否只包含字母、数字和下划线 *)

val recognize_chinese_punctuation :
  Lexer_state.lexer_state ->
  Lexer_tokens.position ->
  (Lexer_tokens.token * Lexer_tokens.position * Lexer_state.lexer_state) option
(** 识别中文标点符号 *)

val recognize_pipe_right_bracket :
  Lexer_state.lexer_state ->
  Lexer_tokens.position ->
  (Lexer_tokens.token * Lexer_tokens.position * Lexer_state.lexer_state) option
(** 识别pipe right bracket (已禁用) *)

val read_chinese_number_sequence : Lexer_state.lexer_state -> string * Lexer_state.lexer_state
(** 读取中文数字序列 *)

val convert_chinese_number_sequence : string -> Lexer_tokens.token
(** 转换中文数字序列为Token *)

val read_fullwidth_number_sequence : Lexer_state.lexer_state -> string * Lexer_state.lexer_state
(** 读取全角数字序列 *)

val convert_fullwidth_number_sequence : string -> Lexer_tokens.token
(** 转换全角数字序列为Token *)
