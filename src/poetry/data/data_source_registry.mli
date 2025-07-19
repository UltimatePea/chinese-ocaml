(** 诗词数据源注册器 - 自动注册所有可用数据源 *)

(** {1 数据源注册函数} *)

val register_yu_rhyme : unit -> unit
(** 注册鱼韵组数据 *)

val register_hua_rhyme : unit -> unit
(** 注册花韵组数据 *)

val register_other_rhymes : unit -> unit
(** 注册其他韵组数据 *)

(** {1 备份数据源注册} *)

val register_backup_data : unit -> unit
(** 注册备份数据源 *)

(** {1 初始化函数} *)

val register_all_data_sources : unit -> unit
(** 注册所有可用的数据源 *)

(** {1 统计信息} *)

val get_registration_stats : unit -> int * int * bool
(** 获取数据注册统计信息 *)
