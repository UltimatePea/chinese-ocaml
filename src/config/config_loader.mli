(** 骆言编译器配置加载器模块接口 *)

val load_from_file : string -> bool
(** 从配置文件加载 *)

val init_config : ?config_file:string -> unit -> unit
(** 配置初始化 *)

val validate_config : unit -> string list
(** 配置验证 *)
