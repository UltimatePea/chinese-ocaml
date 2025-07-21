(** 骆言编译器统一配置管理模块 - 向后兼容接口 *)

type compiler_config = Compiler_config.t
(** 重新导出子模块配置类型 *)

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

(** 环境变量映射 - 重构为使用统一模块 
    
    原74行的重复env_var_mappings已迁移到Env_var_config模块，
    消除了代码重复，提升了维护性。
    
    向后兼容性保留，但现在内部使用Env_var_config模块。
    @see Env_var_config 统一的环境变量配置管理 *)

(** 从环境变量加载配置 - 重构为使用统一模块 *)
let load_from_env () =
  (* 使用新的模块化环境变量处理 *)
  Env_var_config.process_all_env_vars runtime_config compiler_config

(** 新增：统一加载所有配置模块 *)
let load_all_from_env () =
  Compiler_config.load_from_env ();
  Runtime_config.load_from_env ();
  (* 保持向后兼容的全局状态同步 *)
  compiler_config := Compiler_config.get ();
  runtime_config := Runtime_config.get ()

(** 配置验证函数 *)
let validate_compiler_config (config : Compiler_config.t) =
  config.buffer_size > 0
  && config.large_buffer_size >= config.buffer_size
  && config.compilation_timeout > 0.0 && config.optimization_level >= 0
  && config.optimization_level <= 3

let validate_runtime_config (config : Runtime_config.t) =
  config.max_error_count > 0 && List.mem config.log_level [ "debug"; "info"; "warn"; "error" ]

(** 配置重置函数 *)
let reset_to_defaults () =
  Compiler_config.set Compiler_config.default;
  Runtime_config.set Runtime_config.default;
  compiler_config := default_compiler_config;
  runtime_config := default_runtime_config
