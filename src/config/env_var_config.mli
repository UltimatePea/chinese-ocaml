(** 环境变量配置模块接口

    统一管理所有环境变量处理逻辑的模块接口定义

    @author 骆言技术债务清理团队
    @version 1.0
    @since 2025-07-20 Issue #706 重构 *)

type env_var_handler = string -> unit
(** 环境变量处理函数类型 *)

type env_var_config = {
  name : string;  (** 环境变量名 *)
  handler : env_var_handler;  (** 处理函数 *)
  description : string;  (** 配置描述 *)
}
(** 环境变量配置定义 *)

(** 配置值类型 *)
type config_value_type =
  | Boolean
  | PositiveInt
  | PositiveFloat
  | NonEmptyString
  | IntRange of int * int
  | Enum of string list

(** 配置目标类型 *)
type config_target = 
  | RuntimeConfig
  | CompilerConfig

(** 配置规格定义 *)
type config_spec = {
  env_name : string;
  value_type : config_value_type;
  target : config_target;
  field_updater : string;
  description : string;
}

val process_all_env_vars : Runtime_config.t ref -> Compiler_config.t ref -> unit
(** 批量处理所有环境变量 - 主要接口函数 *)

val process_env_var : env_var_config -> unit
(** 处理单个环境变量 *)

val get_all_env_var_names : Runtime_config.t ref -> Compiler_config.t ref -> string list
(** 获取所有环境变量名称列表 *)

val get_config_description :
  Runtime_config.t ref -> Compiler_config.t ref -> string -> string option
(** 获取环境变量配置描述 *)

val print_env_var_help : Runtime_config.t ref -> Compiler_config.t ref -> unit
(** 显示所有环境变量配置帮助信息 *)
