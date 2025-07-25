(** 骆言词法分析器 - 基础数据类型Token *)

(** 基础数据类型token，包括数字、字符串、布尔值等字面量 *)
type basic_token =
  | IntToken of int              (** 整数字面量 *)
  | FloatToken of float          (** 浮点数字面量 *)
  | ChineseNumberToken of string (** 中文数字：一二三四五六七八九点 *)
  | StringToken of string        (** 字符串字面量 *)
  | BoolToken of bool            (** 布尔字面量 *)
[@@deriving show, eq]

(** 将基础token转换为字符串表示 *)
val to_string : basic_token -> string

(** 检查是否为数字类型token *)
val is_numeric : basic_token -> bool

(** 检查是否为字符串类型token *)
val is_string : basic_token -> bool