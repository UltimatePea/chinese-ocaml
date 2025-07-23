(** 骆言编译器Token和位置格式化模块接口

    本模块专注于Token格式化和位置信息处理，提供统一的Token格式化接口。
    包含位置信息格式化、Token类型格式化、错误定位和词法分析辅助功能。
    
    从unified_formatter.ml中拆分而来，专注于词法分析和语法分析过程中的格式化需求。
    
    @author 骆言AI代理
    @version 1.0
    @since 2025-07-22 *)

(** 位置信息格式化模块 *)
module Position : sig
  (** 基础位置格式化 *)
  val format_position : string -> int -> int -> string
  val format_error_with_position : string -> string -> string -> string
  val format_optional_position : (string * int * int) option -> string

  (** 扩展位置格式化 *)
  val format_range_position : string -> int -> int -> int -> int -> string
  val format_source_context : string -> int -> int -> string list -> string
  val format_error_indicator : int -> string
end

(** Token格式化模块 *)
module TokenFormatting : sig
  (** 基础Token类型格式化 *)
  val format_int_token : int -> string
  val format_float_token : float -> string
  val format_string_token : string -> string
  val format_identifier_token : string -> string
  val format_quoted_identifier_token : string -> string

  (** Token错误消息 *)
  val token_expectation : string -> string -> string
  val unexpected_token : string -> string

  (** 复合Token格式化 *)
  val format_keyword_token : string -> string
  val format_operator_token : string -> string
  val format_delimiter_token : string -> string
  val format_boolean_token : bool -> string

  (** 特殊Token格式化 *)
  val format_eof_token : unit -> string
  val format_newline_token : unit -> string
  val format_whitespace_token : unit -> string
  val format_comment_token : string -> string

  (** Token位置信息结合格式化 *)
  val format_token_with_position : string -> int -> int -> string

  (** 中文特定Token格式化 *)
  val format_chinese_number_token : string -> string
  val format_ancient_style_token : string -> string
  val format_poetry_token : string -> string

  (** Token序列格式化 *)
  val format_token_sequence : string list -> string
  val format_token_stream : (string * int * int) list -> string
end

(** 增强位置格式化模块 *)
module EnhancedPosition : sig
  (** 基础位置格式化变体 *)
  val simple_line_col : int -> int -> string
  val parenthesized_line_col : int -> int -> string
  
  (** 范围位置格式化 *)
  val range_position : int -> int -> int -> int -> string
  
  (** 错误位置标记 *)
  val error_position_marker : int -> int -> string
  
  (** 兼容性包装函数 *)
  val format_position_enhanced : string -> int -> int -> string
  val format_error_with_enhanced_position : string -> string -> string -> string

  (** 详细位置信息 *)
  val format_detailed_position : string -> int -> int -> int -> string

  (** 相对位置格式化 *)
  val format_relative_position : int -> int -> int -> int -> string

  (** 位置范围格式化 *)
  val format_span_info : (string * int * int) -> (string * int * int) -> string

  (** 源码上下文显示 *)
  val format_source_excerpt : string -> int -> string -> int -> string

  (** 多行错误显示 *)
  val format_multiline_error : string -> int -> int -> string list -> string -> string
end

(** Token工具模块 *)
module TokenUtilities : sig
  (** Token类型分类 *)
  val is_literal_token : string -> bool
  val is_identifier_token : string -> bool
  val is_keyword_token : string -> bool
  val is_operator_token : string -> bool
  val is_delimiter_token : string -> bool

  (** Token验证消息 *)
  val validate_token_type : string -> string -> string
  val validate_token_value : string -> string -> string

  (** Token统计信息 *)
  val format_token_statistics : int -> int -> int -> int -> string

  (** Token转换助手 *)
  val token_to_string : string -> string -> string
  val token_list_to_string : (string * string) list -> string

  (** 词法分析辅助 *)
  val format_lexer_state : int -> string -> string -> string
  val format_tokenization_progress : int -> int -> string -> string
end