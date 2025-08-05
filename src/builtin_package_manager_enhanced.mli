(** 骆言包管理系统增强接口 - Chinese Programming Language Package Management System Enhanced Interface *)

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

(** 包完整性信息 *)
type package_integrity = {
  sha256: string;
  size: int;
  signature: string option;
}

(** 包元数据 *)
type package_metadata = {
  config: package_config;
  integrity: package_integrity;
  download_url: string;
  published_at: float;
}

(** 包仓库类型 *)
type package_registry = {
  url: string;
  name: string;
  packages: (string, (string * package_metadata) list) Hashtbl.t;
  index_last_updated: float;
}

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

(** SAT求解器状态 *)
type sat_variable = int
type sat_clause = sat_variable list
type sat_formula = sat_clause list
type sat_assignment = (sat_variable * bool) list

(** 安全验证函数 *)
val sanitize_package_name : string -> (string, string) result
val validate_path_traversal : string -> (string, string) result
val validate_file_size : int -> (unit, string) result

(** 加密和完整性验证函数 *)
val compute_sha256 : string -> string
val verify_package_integrity : string -> package_integrity -> (unit, string) result
val sign_package : string -> string -> string
val verify_package_signature : string -> string -> string -> (unit, string) result

(** 配置文件解析函数 *)
val parse_package_config : string -> (package_config, string) result
val validate_package_config : package_config -> (unit, string) result
val serialize_package_config : package_config -> string

(** 版本管理函数 *)
val parse_version_constraint : string -> (version_constraint, string) result
val version_satisfies : string -> version_constraint -> bool
val compare_versions : string -> string -> int
val is_valid_version : string -> bool

(** 中央仓库管理函数 *)
val create_registry : string -> string -> package_registry
val add_package_to_registry : package_registry -> string -> string -> package_config -> package_integrity -> unit
val search_packages_in_registry : package_registry -> string -> string list
val find_package_in_registry : package_registry -> string -> string option -> (string * package_config) option
val update_registry_index : package_registry -> (unit, string) result
val get_default_registry : unit -> package_registry option

(** SAT求解器函数 *)
val create_sat_variable : string -> sat_variable
val solve_sat_formula : sat_formula -> sat_assignment option
val build_dependency_constraint_formula : package_config list -> (sat_formula * (string * string, sat_variable) Hashtbl.t)
val advanced_dependency_resolution : package_config list -> (dependency_resolution, string) result

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