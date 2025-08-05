(** 骆言包管理系统仓库管理模块接口 - Package Registry Module Interface *)

(** Author: Whisky, PR Worker *)

(** 包配置类型定义 *)
type package_config = {
  name: string;
  version: string;
  description: string option;
  authors: string list;
  license: string option;
  homepage: string option;
  dependencies: (string * string) list;
  dev_dependencies: (string * string) list;
  build_script: string option;
  test_script: string option;
}

(** 包元数据 *)
type package_metadata = {
  config: package_config;
  integrity: Package_security.package_integrity;
  download_url: string;
  published_at: float;
}

(** 包仓库类型 *)
type package_registry

(** 包搜索结果 *)
type search_result = {
  package_name: string;
  version: string;
  description: string option;
  download_count: int;
  last_updated: float;
  relevance_score: float;
}

(** 仓库操作错误类型 *)
type registry_error =
  | NetworkError of string
  | IndexUpdateFailed of string
  | PackageNotFound of string
  | RegistryNotAvailable of string
  | ConnectionPoolExhausted
  | InvalidRegistryResponse of string

exception RegistryError of registry_error

(** 仓库统计信息 *)
type registry_stats = {
  total_packages: int;
  total_versions: int;
  index_last_updated: float;
  connection_pool_active: int;
  connection_pool_idle: int;
  cache_hit_rate: float;
}

(** 仓库创建和管理 *)
val create_registry : string -> string -> package_registry
val reinitialize_connection_pool : package_registry -> unit
val add_global_registry : package_registry -> unit
val get_global_registries : unit -> package_registry list
val clear_global_registries : unit -> unit
val get_default_registry : unit -> package_registry option

(** 包管理操作 *)
val add_package_to_registry : package_registry -> string -> string -> package_config -> string -> string option -> (unit, registry_error) result
val find_package_in_registry : package_registry -> string -> string option -> (string * package_config) option
val search_packages_in_registry : package_registry -> string -> int -> search_result list

(** 仓库索引和健康检查 *)
val update_registry_index : package_registry -> (unit, registry_error) result
val health_check_registry : package_registry -> (unit, registry_error) result

(** 批量操作 *)
val batch_package_lookup : package_registry -> string list -> (string, (string * package_config) option) Hashtbl.t

(** 缓存管理 *)
val get_cached_metadata : string -> string -> (package_metadata * float) option
val cache_metadata : string -> string -> package_metadata -> unit
val clear_metadata_cache : unit -> unit

(** 统计信息 *)
val get_registry_stats : package_registry -> registry_stats