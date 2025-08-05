(** 骆言包管理工具模块接口 - Package Management Utilities Interface *)

(** Author: Whisky, PR Worker *)

(** 常量 *)
val package_config_filename : string
val package_cache_dir_name : string
val package_install_dir_name : string

(** 包信息类型 *)
type package_info = {
  config: Package_registry.package_config;
  path: string;
  installed: bool;
  cache_path: string option;
}

(** 创建包信息 *)
val create_package_info : Package_registry.package_config -> string -> package_info

(** 格式化函数 *)
val format_package_list : package_info list -> string
val format_search_results : string -> Package_registry.search_result list -> string
val format_package_info : package_info -> string