(** 环境变量配置模块 - 统一管理所有环境变量处理逻辑

    本模块将原本分散在多个文件中的环境变量映射统一管理， 解决了代码重复和维护困难的问题。

    @author 骆言技术债务清理团队
    @version 1.0
    @since 2025-07-20 Issue #706 重构 *)

type env_var_handler = string -> unit
(** 环境变量处理函数类型 *)

type env_var_config = {
  name : string;  (** 环境变量名 *)
  handler : env_var_handler;  (** 处理函数 *)
  description : string;  (** 配置描述 *)
}
(** 环境变量配置定义 *)

(** 配置值类型 *)
type config_value_type =
  | Boolean
  | PositiveInt
  | PositiveFloat
  | NonEmptyString
  | IntRange of int * int
  | Enum of string list

(** 配置目标类型 *)
type config_target = 
  | RuntimeConfig
  | CompilerConfig

(** 配置规格定义 *)
type config_spec = {
  env_name : string;
  value_type : config_value_type;
  target : config_target;
  field_updater : string; (* 用于记录更新函数名，便于调试 *)
  description : string;
}

(** 解析布尔环境变量 *)
let parse_boolean_env_var v =
  match String.lowercase_ascii (String.trim v) with
  | "true" | "1" | "yes" | "on" -> true
  | _ -> false

(** 解析正整数环境变量 *)
let parse_positive_int_env_var v =
  try
    let i = int_of_string (String.trim v) in
    if i > 0 then Some i else None
  with Failure _ -> None

(** 解析正浮点数环境变量 *)
let parse_positive_float_env_var v =
  try
    let f = float_of_string (String.trim v) in
    if f > 0.0 then Some f else None
  with Failure _ -> None

(** 解析非空字符串环境变量 *)
let parse_non_empty_string_env_var v =
  let trimmed = String.trim v in
  if trimmed = "" then None else Some trimmed

(** 解析整数范围环境变量 *)
let parse_int_range_env_var v min_val max_val =
  try
    let i = int_of_string (String.trim v) in
    if i >= min_val && i <= max_val then Some i else None
  with Failure _ -> None

(** 解析枚举环境变量 *)
let parse_enum_env_var v valid_values =
  let normalized = String.lowercase_ascii (String.trim v) in
  if List.mem normalized valid_values then Some normalized else None

(** 配置规格数据 - 数据驱动的配置定义 *)
let config_specifications = [
  {
    env_name = "CHINESE_OCAML_DEBUG";
    value_type = Boolean;
    target = RuntimeConfig;
    field_updater = "debug_mode";
    description = "启用调试模式";
  };
  {
    env_name = "CHINESE_OCAML_VERBOSE";
    value_type = Boolean;
    target = RuntimeConfig;
    field_updater = "verbose_logging";
    description = "启用详细日志记录";
  };
  {
    env_name = "CHINESE_OCAML_BUFFER_SIZE";
    value_type = PositiveInt;
    target = CompilerConfig;
    field_updater = "buffer_size";
    description = "设置缓冲区大小";
  };
  {
    env_name = "CHINESE_OCAML_TIMEOUT";
    value_type = PositiveFloat;
    target = CompilerConfig;
    field_updater = "compilation_timeout";
    description = "设置编译超时时间";
  };
  {
    env_name = "CHINESE_OCAML_OUTPUT_DIR";
    value_type = NonEmptyString;
    target = CompilerConfig;
    field_updater = "output_directory";
    description = "设置输出目录";
  };
  {
    env_name = "CHINESE_OCAML_TEMP_DIR";
    value_type = NonEmptyString;
    target = CompilerConfig;
    field_updater = "temp_directory";
    description = "设置临时目录";
  };
  {
    env_name = "CHINESE_OCAML_C_COMPILER";
    value_type = NonEmptyString;
    target = CompilerConfig;
    field_updater = "c_compiler";
    description = "设置C编译器";
  };
  {
    env_name = "CHINESE_OCAML_OPT_LEVEL";
    value_type = IntRange (0, 3);
    target = CompilerConfig;
    field_updater = "optimization_level";
    description = "设置优化级别 (0-3)";
  };
  {
    env_name = "CHINESE_OCAML_MAX_ERRORS";
    value_type = PositiveInt;
    target = RuntimeConfig;
    field_updater = "max_error_count";
    description = "设置最大错误数量";
  };
  {
    env_name = "CHINESE_OCAML_LOG_LEVEL";
    value_type = Enum ["debug"; "info"; "warn"; "error"];
    target = RuntimeConfig;
    field_updater = "log_level";
    description = "设置日志级别";
  };
  {
    env_name = "CHINESE_OCAML_COLOR";
    value_type = Boolean;
    target = RuntimeConfig;
    field_updater = "colored_output";
    description = "启用彩色输出";
  };
]

(** 从配置规格创建环境变量配置 *)
let create_config_from_spec runtime_config_ref compiler_config_ref spec =
  let create_handler = match spec.value_type, spec.target with
    | Boolean, RuntimeConfig ->
      fun v ->
        let value = parse_boolean_env_var v in
        runtime_config_ref := (match spec.field_updater with
          | "debug_mode" -> 
            Runtime_config.update_debug_mode value;
            { !runtime_config_ref with Runtime_config.debug_mode = value }
          | "verbose_logging" ->
            Runtime_config.update_verbose_logging value;
            { !runtime_config_ref with Runtime_config.verbose_logging = value }
          | "colored_output" ->
            Runtime_config.update_colored_output value;
            { !runtime_config_ref with Runtime_config.colored_output = value }
          | _ -> !runtime_config_ref)
    | PositiveInt, CompilerConfig ->
      fun v ->
        (match parse_positive_int_env_var v with
         | Some value ->
           compiler_config_ref := (match spec.field_updater with
             | "buffer_size" ->
               Compiler_config.update_buffer_size value;
               { !compiler_config_ref with Compiler_config.buffer_size = value }
             | _ -> !compiler_config_ref)
         | None -> ())
    | PositiveInt, RuntimeConfig ->
      fun v ->
        (match parse_positive_int_env_var v with
         | Some value ->
           runtime_config_ref := (match spec.field_updater with
             | "max_error_count" ->
               Runtime_config.update_max_error_count value;
               { !runtime_config_ref with Runtime_config.max_error_count = value }
             | _ -> !runtime_config_ref)
         | None -> ())
    | PositiveFloat, CompilerConfig ->
      fun v ->
        (match parse_positive_float_env_var v with
         | Some value ->
           compiler_config_ref := (match spec.field_updater with
             | "compilation_timeout" ->
               Compiler_config.update_compilation_timeout value;
               { !compiler_config_ref with Compiler_config.compilation_timeout = value }
             | _ -> !compiler_config_ref)
         | None -> ())
    | NonEmptyString, CompilerConfig ->
      fun v ->
        (match parse_non_empty_string_env_var v with
         | Some value ->
           compiler_config_ref := (match spec.field_updater with
             | "output_directory" ->
               Compiler_config.update_output_directory value;
               { !compiler_config_ref with Compiler_config.output_directory = value }
             | "temp_directory" ->
               Compiler_config.update_temp_directory value;
               { !compiler_config_ref with Compiler_config.temp_directory = value }
             | "c_compiler" ->
               Compiler_config.update_c_compiler value;
               { !compiler_config_ref with Compiler_config.c_compiler = value }
             | _ -> !compiler_config_ref)
         | None -> ())
    | IntRange (min_val, max_val), CompilerConfig ->
      fun v ->
        (match parse_int_range_env_var v min_val max_val with
         | Some value ->
           compiler_config_ref := (match spec.field_updater with
             | "optimization_level" ->
               Compiler_config.update_optimization_level value;
               { !compiler_config_ref with Compiler_config.optimization_level = value }
             | _ -> !compiler_config_ref)
         | None -> ())
    | Enum valid_values, RuntimeConfig ->
      fun v ->
        (match parse_enum_env_var v valid_values with
         | Some value ->
           runtime_config_ref := (match spec.field_updater with
             | "log_level" ->
               Runtime_config.update_log_level value;
               { !runtime_config_ref with Runtime_config.log_level = value }
             | _ -> !runtime_config_ref)
         | None -> ())
    | _ -> fun _ -> () (* 未支持的组合，静默忽略 *)
  in
  {
    name = spec.env_name;
    handler = create_handler;
    description = spec.description;
  }

(** 创建环境变量配置处理器 - 数据驱动版本 *)
let create_config_definitions runtime_config_ref compiler_config_ref =
  List.map (create_config_from_spec runtime_config_ref compiler_config_ref) config_specifications

(** 处理单个环境变量 *)
let process_env_var config =
  try
    let value = Sys.getenv config.name in
    config.handler value
  with
  | Not_found -> () (* 环境变量未设置，忽略 *)
  | exn -> Printf.eprintf "警告: 处理环境变量 %s 时出错: %s\n" config.name (Printexc.to_string exn)

(** 批量处理环境变量 - 主要接口函数 *)
let process_all_env_vars runtime_config_ref compiler_config_ref =
  let config_definitions = create_config_definitions runtime_config_ref compiler_config_ref in
  List.iter process_env_var config_definitions

(** 获取所有环境变量名称列表 *)
let get_all_env_var_names runtime_config_ref compiler_config_ref =
  let config_definitions = create_config_definitions runtime_config_ref compiler_config_ref in
  List.map (fun config -> config.name) config_definitions

(** 获取环境变量配置描述 *)
let get_config_description runtime_config_ref compiler_config_ref name =
  let config_definitions = create_config_definitions runtime_config_ref compiler_config_ref in
  try
    let config = List.find (fun c -> c.name = name) config_definitions in
    Some config.description
  with Not_found -> None

(** 显示所有环境变量配置帮助信息 *)
let print_env_var_help runtime_config_ref compiler_config_ref =
  let config_definitions = create_config_definitions runtime_config_ref compiler_config_ref in
  Printf.printf "支持的环境变量配置:\n\n";
  List.iter
    (fun config -> Printf.printf "  %s\n    %s\n\n" config.name config.description)
    config_definitions
