(** Token工具函数模块接口 *)

open Token_types_core

(** 创建带位置信息和元数据的Token *)
val make_positioned_token : unified_token -> position -> token_metadata option -> positioned_token

(** 创建简单的Token *)
val make_simple_token : unified_token -> string -> int -> int -> positioned_token

(** 获取Token优先级 *)
val get_token_priority : unified_token -> token_priority

(** 创建默认位置信息 *)
val default_position : string -> position

(** 比较两个Token是否相等 *)
val equal_token : unified_token -> unified_token -> bool