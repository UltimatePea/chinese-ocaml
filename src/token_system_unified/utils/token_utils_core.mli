(** Token工具函数模块接口 *)

open Token_system_unified_core.Token_types

val make_positioned_token : token -> position -> token_metadata option -> positioned_token
(** 创建带位置信息和元数据的Token *)

val make_simple_token : token -> string -> int -> int -> positioned_token
(** 创建简单的Token *)

val get_token_priority : token -> token_priority
(** 获取Token优先级 *)

val default_position : string -> position
(** 创建默认位置信息 *)

val equal_token : unified_token -> unified_token -> bool
(** 比较两个Token是否相等 *)
