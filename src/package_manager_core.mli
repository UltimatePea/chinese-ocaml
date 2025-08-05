(** 骆言包管理系统核心模块接口 - Package Manager Core Module Interface *)

(** Author: Whisky, PR Worker *)


(** 包信息类型 *)
type package_info = Package_utils.package_info

(** 核心异常类型 *)
exception PackageManagerError of string

(** 错误处理辅助函数 *)
val handle_package_error : string -> string -> (unit -> 'a) -> 'a

(** 工具函数 *)
val mkdir_p : string -> unit

(** TOML解析功能 - 已迁移到 Package_config_parser 模块 *)

(** 包配置管理 - 已迁移到 Package_config_parser 模块 *)
val parse_package_config : string -> (Package_registry.package_config, string) result
val validate_package_config : Package_registry.package_config -> (unit, string) result
val serialize_package_config : Package_registry.package_config -> string

(** 包查找和目录管理 *)
val find_package_config : string -> (Package_registry.package_config, string) result
val get_package_cache_dir : unit -> string
val get_package_install_dir : string -> string
val get_installed_packages : unit -> package_info list

(** 依赖解析 *)
val resolve_dependencies : Package_registry.package_config -> (Dependency_resolver.dependency_resolution, string) result

(** 骆言内置函数 *)
val install_package_function : Value_operations.runtime_value list -> Value_operations.runtime_value
val uninstall_package_function : Value_operations.runtime_value list -> Value_operations.runtime_value
val list_packages_function : Value_operations.runtime_value list -> Value_operations.runtime_value
val search_packages_function : Value_operations.runtime_value list -> Value_operations.runtime_value
val package_info_function : Value_operations.runtime_value list -> Value_operations.runtime_value

(** 包管理器函数表 *)
val package_manager_functions : (string * Value_operations.runtime_value) list