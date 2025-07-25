(** 错误消息常量模块接口 *)

val undefined_variable : string -> string
(** 变量和模块相关错误 *)

val module_not_found : string -> string
val member_not_found : string -> string -> string
val empty_scope_stack : string
val empty_variable_name : string

val unterminated_comment : string
(** 词法分析器错误 *)

val unterminated_chinese_comment : string
val unterminated_string : string
val unterminated_quoted_identifier : string
val invalid_char_in_quoted_identifier : string

val ascii_symbols_disabled : string
(** 符号和数字相关错误 *)

val fullwidth_numbers_disabled : string
val arabic_numbers_disabled : string
val unsupported_chinese_symbol : string
val identifiers_must_be_quoted : string
val ascii_letters_as_keywords_only : string

val type_mismatch : string -> string -> string
(** 类型相关错误 *)

val unknown_type : string -> string
val invalid_type_operation : string -> string

val function_not_found : string -> string
(** 函数相关错误 *)

val invalid_argument_count : int -> int -> string
val invalid_argument_type : string -> string -> string

val unexpected_token : string -> string
(** 解析器错误 *)

val expected_token : string -> string -> string
val syntax_error : string -> string

val ancient_list_syntax_error : string
(** 古雅体语法相关错误 *)

val division_by_zero : string
(** 运行时错误 *)

val stack_overflow : string
val out_of_memory : string
val invalid_operation : string -> string

val file_not_found : string -> string
(** 文件I/O错误 *)

val file_read_error : string -> string
val file_write_error : string -> string

val config_parse_error : string -> string
(** 配置错误 *)

val invalid_config_value : string -> string -> string

val unsupported_char_error : string -> string
(** 通用错误模板 *)
