(** 骆言编译器统一配置管理模块 - 重构版本 *)

(** 重新导出配置类型 *)
type compiler_config = Config_modules.Compiler_config.t
type runtime_config = Config_modules.Runtime_config.t

(** 向后兼容：默认配置 *)
let default_compiler_config = Config_modules.Compiler_config.default
let default_runtime_config = Config_modules.Runtime_config.default

(** 向后兼容：配置引用 *)
let compiler_config = ref default_compiler_config
let runtime_config = ref default_runtime_config

(** 向后兼容：配置访问函数 *)
let get_compiler_config () = Config_modules.Compiler_config.get ()
let get_runtime_config () = Config_modules.Runtime_config.get ()

let set_compiler_config config = 
  compiler_config := config;
  Config_modules.Compiler_config.set config

let set_runtime_config config = 
  runtime_config := config;
  Config_modules.Runtime_config.set config

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
        Config_modules.Runtime_config.update_debug_mode debug );
    ( "CHINESE_OCAML_VERBOSE",
      fun v ->
        let verbose = parse_boolean_env_var v in
        runtime_config := { !runtime_config with verbose_logging = verbose };
        Config_modules.Runtime_config.update_verbose_logging verbose );
    ( "CHINESE_OCAML_BUFFER_SIZE",
      fun v ->
        match parse_positive_int_env_var v with
        | Some size -> 
            compiler_config := { !compiler_config with buffer_size = size };
            Config_modules.Compiler_config.update_buffer_size size
        | None -> () );
    ( "CHINESE_OCAML_TIMEOUT",
      fun v ->
        match parse_positive_float_env_var v with
        | Some timeout -> 
            compiler_config := { !compiler_config with compilation_timeout = timeout };
            Config_modules.Compiler_config.update_compilation_timeout timeout
        | None -> () );
    ( "CHINESE_OCAML_OUTPUT_DIR",
      fun v ->
        match parse_non_empty_string_env_var v with
        | Some dir -> 
            compiler_config := { !compiler_config with output_directory = dir };
            Config_modules.Compiler_config.update_output_directory dir
        | None -> () );
    ( "CHINESE_OCAML_TEMP_DIR",
      fun v ->
        match parse_non_empty_string_env_var v with
        | Some dir -> 
            compiler_config := { !compiler_config with temp_directory = dir };
            Config_modules.Compiler_config.update_temp_directory dir
        | None -> () );
    ( "CHINESE_OCAML_C_COMPILER",
      fun v ->
        match parse_non_empty_string_env_var v with
        | Some compiler -> 
            compiler_config := { !compiler_config with c_compiler = compiler };
            Config_modules.Compiler_config.update_c_compiler compiler
        | None -> () );
    ( "CHINESE_OCAML_OPT_LEVEL",
      fun v ->
        match parse_int_range_env_var v 0 3 with
        | Some level -> 
            compiler_config := { !compiler_config with optimization_level = level };
            Config_modules.Compiler_config.update_optimization_level level
        | None -> () );
    ( "CHINESE_OCAML_MAX_ERRORS",
      fun v ->
        match parse_positive_int_env_var v with
        | Some max_errors -> 
            runtime_config := { !runtime_config with max_error_count = max_errors };
            Config_modules.Runtime_config.update_max_error_count max_errors
        | None -> () );
    ( "CHINESE_OCAML_LOG_LEVEL",
      fun v ->
        match parse_enum_env_var v [ "debug"; "info"; "warn"; "error" ] with
        | Some level -> 
            runtime_config := { !runtime_config with log_level = level };
            Config_modules.Runtime_config.update_log_level level
        | None -> () );
    ( "CHINESE_OCAML_COLOR",
      fun v ->
        let colored = parse_boolean_env_var v in
        runtime_config := { !runtime_config with colored_output = colored };
        Config_modules.Runtime_config.update_colored_output colored );
  ]

(** 从环境变量加载配置 - 向后兼容 *)
let load_from_env () =
  List.iter
    (fun (env_var, setter) ->
      try
        let value = Sys.getenv env_var in
        setter value
      with Not_found -> ())
    env_var_mappings;
  (* 保持向后兼容的全局状态同步 *)
  compiler_config := Config_modules.Compiler_config.get ();
  runtime_config := Config_modules.Runtime_config.get ()

(** 重新导出配置加载功能 *)
let load_from_file = Config_modules.Config_loader.load_from_file
let init_config = Config_modules.Config_loader.init_config
let validate_config = Config_modules.Config_loader.validate_config

(** 向后兼容：打印当前配置 *)
let print_config () =
  let compiler_cfg = get_compiler_config () in
  let runtime_cfg = get_runtime_config () in
  Unified_logging.Legacy.printf "=== 骆言编译器配置 ===\n";
  Unified_logging.Legacy.printf "缓冲区大小: %d\n" compiler_cfg.buffer_size;
  Unified_logging.Legacy.printf "编译超时: %.1f秒\n" compiler_cfg.compilation_timeout;
  Unified_logging.Legacy.printf "输出目录: %s\n" compiler_cfg.output_directory;
  Unified_logging.Legacy.printf "C编译器: %s\n" compiler_cfg.c_compiler;
  Unified_logging.Legacy.printf "优化级别: %d\n" compiler_cfg.optimization_level;
  Unified_logging.Legacy.printf "调试模式: %b\n" runtime_cfg.debug_mode;
  Unified_logging.Legacy.printf "详细日志: %b\n" runtime_cfg.verbose_logging;
  Unified_logging.Legacy.printf "错误恢复: %b\n" runtime_cfg.error_recovery;
  Unified_logging.Legacy.printf "最大错误数: %d\n" runtime_cfg.max_error_count;
  Unified_logging.Legacy.printf "=======================\n";
  flush stdout

(** 向后兼容：便捷的配置获取函数 *)
module Get = struct
  let buffer_size () = (get_compiler_config ()).buffer_size
  let large_buffer_size () = (get_compiler_config ()).large_buffer_size
  let compilation_timeout () = (get_compiler_config ()).compilation_timeout
  let output_directory () = (get_compiler_config ()).output_directory
  let temp_directory () = (get_compiler_config ()).temp_directory
  let c_compiler () = (get_compiler_config ()).c_compiler
  let c_compiler_flags () = (get_compiler_config ()).c_compiler_flags
  let optimization_level () = (get_compiler_config ()).optimization_level
  let debug_mode () = (get_runtime_config ()).debug_mode
  let verbose_logging () = (get_runtime_config ()).verbose_logging
  let error_recovery () = (get_runtime_config ()).error_recovery
  let max_error_count () = (get_runtime_config ()).max_error_count
  let continue_on_error () = (get_runtime_config ()).continue_on_error
  let show_suggestions () = (get_runtime_config ()).show_suggestions
  let colored_output () = (get_runtime_config ()).colored_output
  let spell_correction () = (get_runtime_config ()).spell_correction
  let hashtable_size () = (get_compiler_config ()).default_hashtable_size
  let large_hashtable_size () = (get_compiler_config ()).large_hashtable_size
end

(** 新增：模块化配置访问接口 *)
module Compiler = Config_modules.Compiler_config
module Runtime = Config_modules.Runtime_config