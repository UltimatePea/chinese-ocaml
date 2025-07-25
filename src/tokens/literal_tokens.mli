(** 骆言词法分析器 - 字面量令牌类型定义接口 *)

(** 字面量词元类型 *)
type literal_token =
  | IntToken of int
  | FloatToken of float
  | ChineseNumberToken of string (* 中文数字：一二三四五六七八九点 *)
  | StringToken of string
  | BoolToken of bool
[@@deriving show, eq]

(** 字面量词元转换为字符串 *)
val literal_token_to_string : literal_token -> string

(** 判断是否为数值类型字面量 *)
val is_numeric_literal : literal_token -> bool

(** 判断是否为字符串类型字面量 *)
val is_string_literal : literal_token -> bool

(** 判断是否为布尔类型字面量 *)
val is_bool_literal : literal_token -> bool