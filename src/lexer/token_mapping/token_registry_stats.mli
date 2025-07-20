(** Token注册器 - 统计和验证功能接口 *)

val get_registry_stats : unit -> string
(** 获取注册器统计信息 *)

val validate_registry : unit -> unit
(** 验证注册器一致性 *)