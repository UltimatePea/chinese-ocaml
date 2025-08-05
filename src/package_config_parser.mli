(** 骆言包配置解析模块接口 - Package Configuration Parser Interface *)

open Package_registry

(** TOML解析函数 *)
val parse_toml_line : string -> (string * string) option
val parse_nested_toml_section : string -> string list
val parse_toml_content : string -> (string * string) list

(** 包配置解析 *)
val parse_package_config : string -> (package_config, string) result

(** 包配置验证 *)
val validate_package_config : package_config -> (unit, string) result