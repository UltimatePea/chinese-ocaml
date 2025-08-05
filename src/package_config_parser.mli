(** 骆言包配置解析模块接口 - Package Configuration Parser Interface *)

(** Author: Whisky, PR Worker *)

(** TOML解析功能 *)
val parse_toml_content : string -> (string * string) list
val parse_toml_array_value : string -> string list

(** 包配置管理 *)
val parse_package_config : string -> (Package_registry.package_config, string) result
val validate_package_config : Package_registry.package_config -> (unit, string) result