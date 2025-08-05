(** 骆言包管理系统工具模块接口 - Package Management Utilities Interface *)

open Package_registry

(** 包信息类型 *)
type package_info = {
  config: Package_registry.package_config;
  path: string;
  installed: bool;
  cache_path: string option;
}

(** 包文件路径常量 *)
val package_config_filename : string
val package_cache_dir_name : string
val package_install_dir_name : string

(** 格式化函数 *)
val format_package_info : package_info -> string
val format_package_list : package_info list -> string
val format_search_results : string -> search_result list -> string

(** 路径工具函数 *)
val get_package_install_path : string -> string
val get_package_cache_path : string -> string

(** 包状态检查 *)
val is_package_installed : string -> bool
val create_package_info : package_config -> string -> package_info