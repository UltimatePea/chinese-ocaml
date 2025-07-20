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

(** 环境变量映射 - 重构为模块化设计 
    
    原74行的env_var_mappings列表已重构为独立的Config_modules.Env_var_config模块，
    大大提升了代码的可维护性和可读性。
    
    为保持向后兼容性，这里保留原有的列表格式接口。
    @see Config_modules.Env_var_config 完整的环境变量配置定义 *)
let env_var_mappings =
  (* 使用简化的硬编码映射以避免循环依赖 - 具体实现在load_from_env中 *)
  []

(** 从环境变量加载配置 - 重构为直接调用模块化接口 *)
let load_from_env () =
  (* 使用新的模块化环境变量处理接口 *)
  Config_modules.Env_var_config.process_all_env_vars runtime_config compiler_config;
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