(** 骆言编译器Token字符串表示格式化器接口 - 第九阶段代码重复消除 *)

(** Token格式化器 *)
module Token_formatter : sig
  val int_token : int -> string
  (** 基本Token类型格式化 *)

  val float_token : float -> string
  val string_token : string -> string
  val char_token : char -> string
  val bool_token : bool -> string

  val keyword_token : string -> string
  (** 关键字Token格式化 *)

  val identifier_token : string -> string
  val operator_token : string -> string

  val eof_token : unit -> string
  (** 特殊Token格式化 *)

  val newline_token : unit -> string
  val whitespace_token : unit -> string
  val comment_token : string -> string

  val chinese_char_token : string -> string
  (** 中文特定Token格式化 *)

  val chinese_punctuation_token : string -> string
  val chinese_number_token : string -> string

  val invalid_token : string -> string
  (** 错误Token格式化 *)

  val unexpected_char_token : char -> string

  val token_with_position : string -> int -> int -> string
  (** Token位置信息格式化 *)

  val token_sequence : string list -> string
  (** Token序列格式化 *)

  val token_debug_info : string -> string -> string -> string
  (** Token调试信息格式化 *)

  val function_call_token : string -> string list -> string
  (** 复合Token格式化 *)

  val module_access_token : string -> string -> string

  val simple_token_display : string -> string
  (** 简化Token显示（用于用户友好输出） *)
end
