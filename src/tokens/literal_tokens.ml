(** 骆言词法分析器 - 字面量令牌类型定义 *)

(** 字面量词元类型 *)
type literal_token =
  | IntToken of int
  | FloatToken of float
  | ChineseNumberToken of string (* 中文数字：一二三四五六七八九点 *)
  | StringToken of string
  | BoolToken of bool
[@@deriving show, eq]

(** 字面量词元转换为字符串 *)
let literal_token_to_string = function
  | IntToken i -> string_of_int i
  | FloatToken f -> string_of_float f
  | ChineseNumberToken s -> s
  | StringToken s -> "\"" ^ s ^ "\""
  | BoolToken b -> string_of_bool b

(** 判断是否为数值类型字面量 *)
let is_numeric_literal = function
  | IntToken _ | FloatToken _ | ChineseNumberToken _ -> true
  | _ -> false

(** 判断是否为字符串类型字面量 *)
let is_string_literal = function
  | StringToken _ -> true
  | _ -> false

(** 判断是否为布尔类型字面量 *)
let is_bool_literal = function
  | BoolToken _ -> true
  | _ -> false