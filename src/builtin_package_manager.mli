(** 骆言包管理系统接口 - Chinese Programming Language Package Management System Interface *)

(** Author: Whisky, PR Worker *)

open Value_operations

(** 包配置类型定义 *)
type package_config = {
  name: string;                     (* 名称 *)
  version: string;                  (* 版本 *)
  description: string option;       (* 描述 *)
  authors: string list;             (* 作者 *)
  license: string option;           (* 许可证 *)
  homepage: string option;          (* 主页 *)
  dependencies: (string * string) list;  (* 依赖: 包名 * 版本约束 *)
  dev_dependencies: (string * string) list; (* 开发依赖 *)
  build_script: string option;      (* 构建脚本 *)
  test_script: string option;       (* 测试脚本 *)
}

(** 版本约束类型 *)
type version_constraint = 
  | Exact of string                 (* =1.0.0 *)
  | GreaterThan of string          (* >1.0.0 *)
  | GreaterThanOrEqual of string   (* >=1.0.0 *)
  | LessThan of string             (* <2.0.0 *)
  | LessThanOrEqual of string      (* <=2.0.0 *)
  | Compatible of string           (* ^1.0.0 *)
  | Range of string * string       (* 1.0.0 - 2.0.0 *)

(** 包信息类型 *)
type package_info = {
  config: package_config;
  path: string;                     (* 路径 *)
  installed: bool;                  (* 已安装 *)
  cache_path: string option;        (* 缓存路径 *)
}

(** 依赖解析结果 *)
type dependency_resolution = {
  resolved_packages: (string * string) list;  (* 已解析包: 包名 * 确定版本 *)
  conflicts: (string * string list) list;     (* 冲突: 包名 * 冲突版本列表 *)
  missing: string list;                       (* 缺失: 无法找到的包 *)
}

(** 配置文件解析函数 *)
val parse_package_config : string -> (package_config, string) result
val validate_package_config : package_config -> (unit, string) result
val serialize_package_config : package_config -> string

(** 版本管理函数 *)
val parse_version_constraint : string -> (version_constraint, string) result
val version_satisfies : string -> version_constraint -> bool
val compare_versions : string -> string -> int
val is_valid_version : string -> bool

(** 依赖解析函数 *)
val resolve_dependencies : package_config -> (dependency_resolution, string) result
val detect_circular_dependencies : (string * string list) list -> string list option
val build_dependency_graph : package_config list -> (string * string list) list

(** 包查找和管理函数 *)
val find_package_config : string -> (package_config, string) result
val get_installed_packages : unit -> package_info list
val get_package_cache_dir : unit -> string
val get_package_install_dir : string -> string

(** 包安装和卸载函数 *)
val install_package_function : runtime_value list -> runtime_value
val uninstall_package_function : runtime_value list -> runtime_value
val update_package_function : runtime_value list -> runtime_value
val list_packages_function : runtime_value list -> runtime_value

(** 包搜索和信息函数 *)
val search_packages_function : runtime_value list -> runtime_value
val package_info_function : runtime_value list -> runtime_value
val check_updates_function : runtime_value list -> runtime_value

(** 项目初始化函数 *)
val init_project_function : runtime_value list -> runtime_value
val create_package_config_function : runtime_value list -> runtime_value

(** 包发布函数 *)
val package_project_function : runtime_value list -> runtime_value
val publish_package_function : runtime_value list -> runtime_value
val validate_package_function : runtime_value list -> runtime_value

(** 构建和测试集成函数 *)
val build_project_function : runtime_value list -> runtime_value
val test_project_function : runtime_value list -> runtime_value
val clean_project_function : runtime_value list -> runtime_value

(** 配置文件操作函数 *)
val read_package_config_function : runtime_value list -> runtime_value
val write_package_config_function : runtime_value list -> runtime_value
val update_package_config_function : runtime_value list -> runtime_value

(** 缓存管理函数 *)
val clear_cache_function : runtime_value list -> runtime_value
val rebuild_cache_function : runtime_value list -> runtime_value
val cache_status_function : runtime_value list -> runtime_value

(** 包管理器函数表 *)
val package_manager_functions : (string * runtime_value) list