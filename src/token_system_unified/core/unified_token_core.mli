(** 统一Token核心系统接口 - 桥接和重新导出现有系统 *)

(* 重新导出核心类型 *)
include module type of Yyocamlc_lib.Token_types

(** Token优先级定义 *)
type token_priority =
  | HighPriority  (** 高优先级：关键字、保留字 *)
  | MediumPriority  (** 中优先级：运算符、分隔符 *)
  | LowPriority  (** 低优先级：标识符、字面量 *)

type unified_token = token
(** 统一Token类型 - 重新导出现有的token类型 *)

type extended_positioned_token = {
  token : unified_token;
  position : position;
  metadata : string option;
}
(** 扩展的positioned_token *)

val string_of_token : unified_token -> string
(** Token到字符串的转换 *)

val make_positioned_token : unified_token -> position -> string option -> extended_positioned_token
(** 创建带位置信息的token *)

val make_simple_token : unified_token -> string -> int -> int -> extended_positioned_token
(** 创建简单的positioned token *)

val get_token_category : unified_token -> string
(** 获取token的分类 *)

val get_token_priority : unified_token -> token_priority
(** 获取token的默认优先级 *)

val equal_token : unified_token -> unified_token -> bool
(** Token相等性比较 *)

val equal_positioned_token : extended_positioned_token -> extended_positioned_token -> bool
(** Positioned token相等性比较 *)

val default_position : string -> position
(** 创建默认位置 *)
