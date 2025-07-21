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

(** 创建环境变量配置处理器 *)
let create_config_definitions runtime_config_ref compiler_config_ref =
  let create_boolean_handler update_runtime update_module =
   fun v ->
    let value = parse_boolean_env_var v in
    runtime_config_ref := update_runtime !runtime_config_ref value;
    update_module value
  in

  let create_positive_int_handler update_compiler update_module =
   fun v ->
    match parse_positive_int_env_var v with
    | Some value ->
        compiler_config_ref := update_compiler !compiler_config_ref value;
        update_module value
    | None -> ()
  in

  let create_runtime_positive_int_handler update_runtime update_module =
   fun v ->
    match parse_positive_int_env_var v with
    | Some value ->
        runtime_config_ref := update_runtime !runtime_config_ref value;
        update_module value
    | None -> ()
  in

  let create_positive_float_handler update_compiler update_module =
   fun v ->
    match parse_positive_float_env_var v with
    | Some value ->
        compiler_config_ref := update_compiler !compiler_config_ref value;
        update_module value
    | None -> ()
  in

  let create_string_handler update_compiler update_module =
   fun v ->
    match parse_non_empty_string_env_var v with
    | Some value ->
        compiler_config_ref := update_compiler !compiler_config_ref value;
        update_module value
    | None -> ()
  in

  let create_int_range_handler min_val max_val update_compiler update_module =
   fun v ->
    match parse_int_range_env_var v min_val max_val with
    | Some value ->
        compiler_config_ref := update_compiler !compiler_config_ref value;
        update_module value
    | None -> ()
  in

  let create_enum_handler valid_values update_runtime update_module =
   fun v ->
    match parse_enum_env_var v valid_values with
    | Some value ->
        runtime_config_ref := update_runtime !runtime_config_ref value;
        update_module value
    | None -> ()
  in

  [
    {
      name = "CHINESE_OCAML_DEBUG";
      handler =
        create_boolean_handler
          (fun config debug -> { config with Runtime_config.debug_mode = debug })
          Runtime_config.update_debug_mode;
      description = "启用调试模式";
    };
    {
      name = "CHINESE_OCAML_VERBOSE";
      handler =
        create_boolean_handler
          (fun config verbose -> { config with Runtime_config.verbose_logging = verbose })
          Runtime_config.update_verbose_logging;
      description = "启用详细日志记录";
    };
    {
      name = "CHINESE_OCAML_BUFFER_SIZE";
      handler =
        create_positive_int_handler
          (fun config size -> { config with Compiler_config.buffer_size = size })
          Compiler_config.update_buffer_size;
      description = "设置缓冲区大小";
    };
    {
      name = "CHINESE_OCAML_TIMEOUT";
      handler =
        create_positive_float_handler
          (fun config timeout -> { config with Compiler_config.compilation_timeout = timeout })
          Compiler_config.update_compilation_timeout;
      description = "设置编译超时时间";
    };
    {
      name = "CHINESE_OCAML_OUTPUT_DIR";
      handler =
        create_string_handler
          (fun config dir -> { config with Compiler_config.output_directory = dir })
          Compiler_config.update_output_directory;
      description = "设置输出目录";
    };
    {
      name = "CHINESE_OCAML_TEMP_DIR";
      handler =
        create_string_handler
          (fun config dir -> { config with Compiler_config.temp_directory = dir })
          Compiler_config.update_temp_directory;
      description = "设置临时目录";
    };
    {
      name = "CHINESE_OCAML_C_COMPILER";
      handler =
        create_string_handler
          (fun config compiler -> { config with Compiler_config.c_compiler = compiler })
          Compiler_config.update_c_compiler;
      description = "设置C编译器";
    };
    {
      name = "CHINESE_OCAML_OPT_LEVEL";
      handler =
        create_int_range_handler 0 3
          (fun config level -> { config with Compiler_config.optimization_level = level })
          Compiler_config.update_optimization_level;
      description = "设置优化级别 (0-3)";
    };
    {
      name = "CHINESE_OCAML_MAX_ERRORS";
      handler =
        create_runtime_positive_int_handler
          (fun config max_errors -> { config with Runtime_config.max_error_count = max_errors })
          Runtime_config.update_max_error_count;
      description = "设置最大错误数量";
    };
    {
      name = "CHINESE_OCAML_LOG_LEVEL";
      handler =
        create_enum_handler
          [ "debug"; "info"; "warn"; "error" ]
          (fun config level -> { config with Runtime_config.log_level = level })
          Runtime_config.update_log_level;
      description = "设置日志级别";
    };
    {
      name = "CHINESE_OCAML_COLOR";
      handler =
        create_boolean_handler
          (fun config colored -> { config with Runtime_config.colored_output = colored })
          Runtime_config.update_colored_output;
      description = "启用彩色输出";
    };
  ]

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
