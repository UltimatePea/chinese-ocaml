(** 环境变量配置模块 - 第六阶段优化重构版本

    从319行优化为紧凑结构，消除重复解析逻辑，统一配置处理 第六阶段技术债务清理：模式匹配优化，配置表驱动

    @author 骆言技术债务清理团队
    @version 2.0 (第六阶段优化版)
    @since 2025-07-21 Issue #788 超长文件重构优化 *)

type env_var_handler = string -> unit
type env_var_config = { name : string; handler : env_var_handler; description : string }

type config_value_type =
  | Boolean
  | PositiveInt
  | PositiveFloat
  | NonEmptyString
  | IntRange of int * int
  | Enum of string list

type config_target = RuntimeConfig | CompilerConfig

type config_spec = {
  env_name : string;
  value_type : config_value_type;
  target : config_target;
  field_updater : string;
  description : string;
}

(** 通用值解析器 *)
module ValueParser = struct
  let parse_boolean v =
    match String.lowercase_ascii (String.trim v) with
    | "true" | "1" | "yes" | "on" -> true
    | _ -> false

  let parse_positive_int v =
    try
      let i = int_of_string (String.trim v) in
      if i > 0 then i else 1
    with Failure _ -> 1

  let parse_positive_float v =
    try
      let f = float_of_string (String.trim v) in
      if f > 0.0 then f else 1.0
    with Failure _ -> 1.0

  let parse_non_empty_string v =
    let trimmed = String.trim v in
    if String.length trimmed > 0 then trimmed else ""

  let parse_int_range v min_val max_val =
    try
      let i = int_of_string (String.trim v) in
      max min_val (min max_val i)
    with Failure _ -> min_val

  let parse_enum v valid_values =
    let normalized = String.lowercase_ascii (String.trim v) in
    if List.mem normalized valid_values then normalized else List.hd valid_values
end

(** 配置规格构建器 *)
module ConfigSpecBuilder = struct
  let create_spec env_prefix field_name value_type target description =
    let env_name = env_prefix ^ String.uppercase_ascii field_name in
    { env_name; value_type; target; field_updater = field_name; description }

  let runtime_spec = create_spec "CHINESE_OCAML_"
  let compiler_spec = create_spec "CHINESE_OCAML_COMPILER_"
end

(** 配置表定义 - 仅包含支持的字段 *)
let config_definitions =
  [
    (* Runtime配置 - 只包含有update函数的字段 *)
    ("debug", Boolean, RuntimeConfig, "启用调试输出");
    ("verbose", Boolean, RuntimeConfig, "启用详细输出");
    ("max_iterations", PositiveInt, RuntimeConfig, "设置最大错误次数");
    ("log_level", Enum [ "debug"; "info"; "warning"; "error" ], RuntimeConfig, "设置日志级别");
    ("output_format", Boolean, RuntimeConfig, "启用彩色输出");
    (* Compiler配置 - 只包含有update函数的字段 *)
    ("optimization_level", IntRange (0, 3), CompilerConfig, "设置优化级别");
    ("buffer_size", PositiveInt, CompilerConfig, "设置缓冲区大小");
    ("timeout", PositiveFloat, CompilerConfig, "设置编译超时时间");
    ("output_directory", NonEmptyString, CompilerConfig, "设置输出目录");
    ("temp_directory", NonEmptyString, CompilerConfig, "设置临时目录");
    ("c_compiler", NonEmptyString, CompilerConfig, "设置C编译器路径");
  ]

(** 配置规格生成器 *)
let generate_config_specs () =
  List.map
    (fun (field_name, value_type, target, description) ->
      match target with
      | RuntimeConfig -> ConfigSpecBuilder.runtime_spec field_name value_type target description
      | CompilerConfig -> ConfigSpecBuilder.compiler_spec field_name value_type target description)
    config_definitions

(** 值解析和应用器 *)
module ConfigApplier = struct
  let apply_runtime_config _runtime_config_ref spec env_value =
    match (spec.field_updater, spec.value_type) with
    | "debug", Boolean ->
        let value = ValueParser.parse_boolean env_value in
        Runtime_config.update_debug_mode value
    | "verbose", Boolean ->
        let value = ValueParser.parse_boolean env_value in
        Runtime_config.update_verbose_logging value
    | "max_iterations", PositiveInt ->
        let value = ValueParser.parse_positive_int env_value in
        Runtime_config.update_max_error_count value
    | "log_level", Enum [ "debug"; "info"; "warning"; "error" ] ->
        let value = ValueParser.parse_enum env_value [ "debug"; "info"; "warning"; "error" ] in
        Runtime_config.update_log_level value
    | "output_format", Boolean ->
        let value = ValueParser.parse_boolean env_value in
        Runtime_config.update_colored_output value
    | _ -> () (* 未知字段或不支持的字段，忽略 *)

  let apply_compiler_config _compiler_config_ref spec env_value =
    match (spec.field_updater, spec.value_type) with
    | "optimization_level", IntRange (0, 3) ->
        let value = ValueParser.parse_int_range env_value 0 3 in
        Compiler_config.update_optimization_level value
    | "buffer_size", PositiveInt ->
        let value = ValueParser.parse_positive_int env_value in
        Compiler_config.update_buffer_size value
    | "timeout", PositiveFloat ->
        let value = ValueParser.parse_positive_float env_value in
        Compiler_config.update_compilation_timeout value
    | "output_directory", NonEmptyString ->
        let value = ValueParser.parse_non_empty_string env_value in
        Compiler_config.update_output_directory value
    | "temp_directory", NonEmptyString ->
        let value = ValueParser.parse_non_empty_string env_value in
        Compiler_config.update_temp_directory value
    | "c_compiler", NonEmptyString ->
        let value = ValueParser.parse_non_empty_string env_value in
        Compiler_config.update_c_compiler value
    | _ -> () (* 未知字段或不支持的字段，忽略 *)
end

(** 环境变量配置实例创建 *)
let create_env_var_config runtime_config_ref compiler_config_ref spec =
  let handler =
   fun env_value ->
    try
      match spec.target with
      | RuntimeConfig -> ConfigApplier.apply_runtime_config runtime_config_ref spec env_value
      | CompilerConfig -> ConfigApplier.apply_compiler_config compiler_config_ref spec env_value
    with exn -> Printf.eprintf "警告: 处理环境变量 %s 时出错: %s\n" spec.env_name (Printexc.to_string exn)
  in
  { name = spec.env_name; handler; description = spec.description }

(** 接口实现函数 *)
let process_all_env_vars runtime_config_ref compiler_config_ref =
  let all_specs = generate_config_specs () in
  let configs = List.map (create_env_var_config runtime_config_ref compiler_config_ref) all_specs in
  List.iter
    (fun config ->
      try
        let value = Sys.getenv config.name in
        config.handler value
      with Not_found -> () (* 环境变量未设置，忽略 *))
    configs

let process_env_var config =
  try
    let value = Sys.getenv config.name in
    config.handler value
  with Not_found -> () (* 环境变量未设置，忽略 *)

let get_all_env_var_names _runtime_config_ref _compiler_config_ref =
  let all_specs = generate_config_specs () in
  List.map (fun spec -> spec.env_name) all_specs

let get_config_description _runtime_config_ref _compiler_config_ref env_name =
  let all_specs = generate_config_specs () in
  try
    let spec = List.find (fun s -> s.env_name = env_name) all_specs in
    Some spec.description
  with Not_found -> None

let print_env_var_help _runtime_config_ref _compiler_config_ref =
  let all_specs = generate_config_specs () in
  Printf.printf "支持的环境变量配置:\n\n";
  List.iter (fun spec -> Printf.printf "  %s\n    %s\n\n" spec.env_name spec.description) all_specs
