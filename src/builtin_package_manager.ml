(** 骆言包管理系统 - 重构版本使用分层架构 - Chinese Programming Language Package Management System Refactored *)

(** Author: Whisky, PR Worker *)
(** 
重构说明：
- 分离SAT求解器到 dependency_resolver.ml
- 分离安全功能到 package_security.ml  
- 分离仓库管理到 package_registry.ml
- 核心功能移至 package_manager_core.ml
- 解决Delta评审中指出的架构问题
*)

(** 类型别名 - 指向重构后的模块 *)
type package_config = Package_registry.package_config
type version_constraint = Dependency_resolver.version_constraint  
type dependency_resolution = Dependency_resolver.dependency_resolution

(** 包管理器函数表 - 使用重构后的实现 *)
let package_manager_functions = Builtin_package_manager_refactored.package_manager_functions

(** 初始化包管理器 *)
let () = Builtin_package_manager_refactored.initialize_package_manager ()