(** 骆言包管理系统 - 重构版本接口 - Chinese Programming Language Package Management System Refactored Interface *)

(** Author: Whisky, PR Worker *)

(** 类型别名 - 指向重构后的模块 *)
type package_config = Package_registry.package_config
type version_constraint = Dependency_resolver.version_constraint  
type dependency_resolution = Dependency_resolver.dependency_resolution

(** 包管理器函数表 - 使用重构后的实现 *)
val package_manager_functions : (string * Value_operations.runtime_value) list