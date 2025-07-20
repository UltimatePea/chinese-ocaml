(** 骆言词法分析器 - 工具函数模块接口 (模块化重构版本)
    
    本模块提供词法分析器所需的各种实用工具函数，
    包括字符处理、字符串解析、数字解析等功能。
    这是模块化重构版本，提高了代码的可维护性。
    
    @author 骆言团队
    @since 2025-07-20 *)

(** 字符处理函数 *)

(** 检查字符是否为中文字符 *)
val is_chinese_char : char -> bool

(** 检查字符是否为字母或中文字符 *)
val is_letter_or_chinese : char -> bool

(** 检查字符是否为数字 *)
val is_digit : char -> bool

(** 检查字符是否为空白字符 *)
val is_whitespace : char -> bool

(** 检查字符是否为分隔符 *)
val is_separator_char : char -> bool

(** 检查UTF-8字符串是否为中文字符 *)
val is_chinese_utf8 : string -> bool

(** 获取下一个UTF-8字符及其结束位置 *)
val next_utf8_char : string -> int -> string * int

(** 检查字符是否为中文数字字符 *)
val is_chinese_digit_char : string -> bool

(** 检查字符串是否全为数字 *)
val is_all_digits : string -> bool

(** 检查字符串是否为有效标识符 *)
val is_valid_identifier : string -> bool

(** 获取当前位置的字符 *)
val get_current_char : Lexer_state.state -> char option

(** 检查UTF-8字符 *)
val check_utf8_char : string -> int -> string * int

(** 创建新的词法分析器状态 *)
val make_new_state : Lexer_state.state -> int -> Lexer_state.state

(** 创建不支持字符错误 *)
val create_unsupported_char_error : string -> Lexer_tokens.position -> Compiler_errors.compiler_error

(** 字符串处理函数 *)

(** 从指定位置开始读取字符串，直到满足停止条件
    @param state 词法分析器状态
    @param start_pos 开始位置
    @param stop_condition 停止条件函数
    @return (读取的字符串, 结束位置) *)
val read_string_until : Lexer_state.state -> int -> (string -> bool) -> string * int

(** 数字解析函数 *)

(** 解析整数
    @param str 要解析的字符串
    @return 解析结果，成功时返回Some整数，失败时返回None *)
val parse_integer : string -> int option

(** 解析浮点数
    @param str 要解析的字符串
    @return 解析结果，成功时返回Some浮点数，失败时返回None *)
val parse_float : string -> float option

(** 中文数字转换函数 *)

(** 转换中文数字为阿拉伯数字
    @param chinese_num 中文数字字符串
    @return 转换结果，成功时返回Some整数，失败时返回None *)
val chinese_to_arabic : string -> int option