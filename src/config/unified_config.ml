(** 骆言编译器统一配置管理模块 - 向后兼容接口 *)

(** 重新导出子模块配置类型 *)
type compiler_config = Compiler_config.t
type runtime_config = Runtime_config.t

(** 向后兼容：默认配置 *)
let default_compiler_config = Compiler_config.default
let default_runtime_config = Runtime_config.default

(** 向后兼容：配置引用 *)
let compiler_config = ref default_compiler_config
let runtime_config = ref default_runtime_config

(** 向后兼容：配置访问函数 *)
let get_compiler_config () = Compiler_config.get ()
let get_runtime_config () = Runtime_config.get ()

let set_compiler_config config = 
  compiler_config := config;
  Compiler_config.set config

let set_runtime_config config = 
  runtime_config := config;
  Runtime_config.set config

(** 环境变量解析辅助函数 - 向后兼容 *)
let parse_boolean_env_var v = String.lowercase_ascii v = "true" || v = "1"

let parse_positive_int_env_var v =
  try
    let i = int_of_string v in
    if i > 0 then Some i else None
  with Failure _ -> None

let parse_positive_float_env_var v =
  try
    let f = float_of_string v in
    if f > 0.0 then Some f else None
  with Failure _ -> None

let parse_non_empty_string_env_var v = if String.length v > 0 then Some v else None

let parse_int_range_env_var v min_val max_val =
  try
    let i = int_of_string v in
    if i >= min_val && i <= max_val then Some i else None
  with Failure _ -> None

let parse_enum_env_var v valid_values =
  let normalized = String.lowercase_ascii v in
  if List.mem normalized valid_values then Some normalized else None

(** 统一环境变量映射 - 向后兼容 *)
let env_var_mappings =
  [
    ( "CHINESE_OCAML_DEBUG",
      fun v ->
        let debug = parse_boolean_env_var v in
        runtime_config := { !runtime_config with debug_mode = debug };
        Runtime_config.update_debug_mode debug );
    ( "CHINESE_OCAML_VERBOSE",
      fun v ->
        let verbose = parse_boolean_env_var v in
        runtime_config := { !runtime_config with verbose_logging = verbose };
        Runtime_config.update_verbose_logging verbose );
    ( "CHINESE_OCAML_BUFFER_SIZE",
      fun v ->
        match parse_positive_int_env_var v with
        | Some size -> 
            compiler_config := { !compiler_config with buffer_size = size };
            Compiler_config.update_buffer_size size
        | None -> () );
    ( "CHINESE_OCAML_TIMEOUT",
      fun v ->
        match parse_positive_float_env_var v with
        | Some timeout -> 
            compiler_config := { !compiler_config with compilation_timeout = timeout };
            Compiler_config.update_compilation_timeout timeout
        | None -> () );
    ( "CHINESE_OCAML_OUTPUT_DIR",
      fun v ->
        match parse_non_empty_string_env_var v with
        | Some dir -> 
            compiler_config := { !compiler_config with output_directory = dir };
            Compiler_config.update_output_directory dir
        | None -> () );
    ( "CHINESE_OCAML_TEMP_DIR",
      fun v ->
        match parse_non_empty_string_env_var v with
        | Some dir -> 
            compiler_config := { !compiler_config with temp_directory = dir };
            Compiler_config.update_temp_directory dir
        | None -> () );
    ( "CHINESE_OCAML_C_COMPILER",
      fun v ->
        match parse_non_empty_string_env_var v with
        | Some compiler -> 
            compiler_config := { !compiler_config with c_compiler = compiler };
            Compiler_config.update_c_compiler compiler
        | None -> () );
    ( "CHINESE_OCAML_OPT_LEVEL",
      fun v ->
        match parse_int_range_env_var v 0 3 with
        | Some level -> 
            compiler_config := { !compiler_config with optimization_level = level };
            Compiler_config.update_optimization_level level
        | None -> () );
    ( "CHINESE_OCAML_MAX_ERRORS",
      fun v ->
        match parse_positive_int_env_var v with
        | Some max_errors -> 
            runtime_config := { !runtime_config with max_error_count = max_errors };
            Runtime_config.update_max_error_count max_errors
        | None -> () );
    ( "CHINESE_OCAML_LOG_LEVEL",
      fun v ->
        match parse_enum_env_var v [ "debug"; "info"; "warn"; "error" ] with
        | Some level -> 
            runtime_config := { !runtime_config with log_level = level };
            Runtime_config.update_log_level level
        | None -> () );
    ( "CHINESE_OCAML_COLOR",
      fun v ->
        let colored = parse_boolean_env_var v in
        runtime_config := { !runtime_config with colored_output = colored };
        Runtime_config.update_colored_output colored );
  ]

(** 从环境变量加载配置 - 向后兼容 *)
let load_from_env () =
  List.iter
    (fun (env_var, setter) ->
      try
        let value = Sys.getenv env_var in
        setter value
      with Not_found -> ())
    env_var_mappings

(** 新增：统一加载所有配置模块 *)
let load_all_from_env () =
  Compiler_config.load_from_env ();
  Runtime_config.load_from_env ();
  (* 保持向后兼容的全局状态同步 *)
  compiler_config := Compiler_config.get ();
  runtime_config := Runtime_config.get ()

(** 配置验证函数 *)
let validate_compiler_config (config : Compiler_config.t) =
  config.buffer_size > 0 &&
  config.large_buffer_size >= config.buffer_size &&
  config.compilation_timeout > 0.0 &&
  config.optimization_level >= 0 && config.optimization_level <= 3

let validate_runtime_config (config : Runtime_config.t) =
  config.max_error_count > 0 &&
  List.mem config.log_level ["debug"; "info"; "warn"; "error"]

(** 配置重置函数 *)
let reset_to_defaults () =
  Compiler_config.set Compiler_config.default;
  Runtime_config.set Runtime_config.default;
  compiler_config := default_compiler_config;
  runtime_config := default_runtime_config