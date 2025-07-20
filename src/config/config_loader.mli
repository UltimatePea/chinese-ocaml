(** 骆言编译器配置加载器模块接口 *)

(** 从配置文件加载 *)
val load_from_file : string -> bool

(** 配置初始化 *)
val init_config : ?config_file:string -> unit -> unit

(** 配置验证 *)
val validate_config : unit -> string list