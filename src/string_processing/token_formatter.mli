(** 骆言编译器Token字符串表示格式化器接口 - 第九阶段代码重复消除 *)

(** Token格式化器 *)
module Token_formatter : sig
  (** 基本Token类型格式化 *)
  val int_token : int -> string
  val float_token : float -> string
  val string_token : string -> string
  val char_token : char -> string
  val bool_token : bool -> string
  
  (** 关键字Token格式化 *)
  val keyword_token : string -> string
  val identifier_token : string -> string
  val operator_token : string -> string
  
  (** 特殊Token格式化 *)
  val eof_token : unit -> string
  val newline_token : unit -> string
  val whitespace_token : unit -> string
  val comment_token : string -> string
  
  (** 中文特定Token格式化 *)
  val chinese_char_token : string -> string
  val chinese_punctuation_token : string -> string
  val chinese_number_token : string -> string
  
  (** 错误Token格式化 *)
  val invalid_token : string -> string
  val unexpected_char_token : char -> string
  
  (** Token位置信息格式化 *)
  val token_with_position : string -> int -> int -> string
  
  (** Token序列格式化 *)
  val token_sequence : string list -> string
  
  (** Token调试信息格式化 *)
  val token_debug_info : string -> string -> string -> string
  
  (** 复合Token格式化 *)
  val function_call_token : string -> string list -> string
  val module_access_token : string -> string -> string
  
  (** 简化Token显示（用于用户友好输出） *)
  val simple_token_display : string -> string
end