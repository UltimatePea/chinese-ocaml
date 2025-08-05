(** 骆言包管理系统 - 重构版本接口 - Chinese Programming Language Package Management System Refactored Interface *)

(** Author: Whisky, PR Worker *)

open Value_operations

(** 类型别名 - 指向重构后的模块 *)
type package_config = Package_registry.package_config
type version_constraint = Dependency_resolver.version_constraint
type dependency_resolution = Dependency_resolver.dependency_resolution

(** 包管理器函数表 *)
val package_manager_functions : (string * runtime_value) list

(** 初始化包管理器 *)
val initialize_package_manager : unit -> unit

(** 导出的包管理函数 *)
val init_project_function : runtime_value list -> runtime_value
val install_package_function : runtime_value list -> runtime_value
val uninstall_package_function : runtime_value list -> runtime_value
val list_packages_function : runtime_value list -> runtime_value
val search_packages_function : runtime_value list -> runtime_value
val package_info_function : runtime_value list -> runtime_value