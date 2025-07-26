(** 骆言Token系统整合重构 - 字面量映射管理接口 *)

open Yyocamlc_lib.Token_types

(** 字面量映射模块 *)
module LiteralMapping : sig
  val try_parse_int : string -> int option
  (** 尝试解析整数 *)

  val try_parse_float : string -> float option
  (** 尝试解析浮点数 *)

  val is_string_literal : string -> bool
  (** 检查是否为字符串字面量 *)

  val extract_string_content : string -> string
  (** 提取字符串内容 *)

  val lookup_chinese_digit : string -> int option
  (** 查找中文数字 *)

  val lookup_chinese_unit : string -> int option
  (** 查找中文单位 *)

  val parse_simple_chinese_number : string -> int option
  (** 简化版中文数字解析 *)

  val is_chinese_number : string -> bool
  (** 检查是否为中文数字 *)

  val lookup_chinese_bool : string -> bool option
  (** 查找中文布尔值 *)

  val lookup_english_bool : string -> bool option
  (** 查找英文布尔值 *)

  val lookup_bool : string -> bool option
  (** 通用布尔值查找 *)

  val parse_literal : string -> Literals.literal_token option
  (** 字面量识别和解析 *)

  val literal_to_string : Literals.literal_token -> string
  (** 字面量转换为字符串 *)

  val literal_to_english_string : Literals.literal_token -> string
  (** 字面量转换为英文字符串 *)

  val is_numeric_literal : Literals.literal_token -> bool
  (** 检查字面量类型 *)

  val is_string_literal_token : Literals.literal_token -> bool
  val is_boolean_literal : Literals.literal_token -> bool

  val get_literal_value :
    Literals.literal_token -> [ `Int of int | `Float of float | `String of string | `Bool of bool | `Unit | `Null | `Char of char ]
  (** 获取字面量值 *)

  val compare_literals : Literals.literal_token -> Literals.literal_token -> int
  (** 字面量比较 *)

  val get_all_chinese_digits : unit -> string list
  (** 获取所有支持的中文数字 *)

  val get_all_chinese_units : unit -> string list
  (** 获取所有支持的中文单位 *)

  val get_literal_stats : unit -> string
  (** 字面量统计信息 *)
end

(** 字面量验证器 *)
module LiteralValidator : sig
  val validate_int_range : int -> min_val:int -> max_val:int -> bool
  (** 验证整数范围 *)

  val validate_float_range : float -> min_val:float -> max_val:float -> bool
  (** 验证浮点数范围 *)

  val validate_string_length : string -> max_length:int -> bool
  (** 验证字符串长度 *)

  val validate_string_charset : string -> allowed_chars:string -> bool
  (** 验证字符串字符集 *)

  val validate_literal : Literals.literal_token -> bool
  (** 全面验证字面量 *)
end
