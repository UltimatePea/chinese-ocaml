(** 骆言编译器运行时配置模块 *)

(** 运行时配置类型定义 *)
type t = {
  (* 调试配置 *)
  debug_mode : bool;  (** 调试模式 *)
  verbose_logging : bool;  (** 详细日志 *)
  log_level : string;  (** 日志级别: debug, info, warn, error *)
  
  (* 错误处理配置 *)
  error_recovery : bool;  (** 错误恢复机制 *)
  max_error_count : int;  (** 最大错误数量 *)
  continue_on_error : bool;  (** 遇到错误时是否继续 *)
  show_suggestions : bool;  (** 是否显示建议 *)
  colored_output : bool;  (** 彩色输出 *)
  
  (* 智能功能配置 *)
  spell_correction : bool;  (** 拼写纠正 *)
  type_inference : bool;  (** 类型推断 *)
  auto_completion : bool;  (** 自动补全 *)
  code_formatting : bool;  (** 代码格式化 *)
}

(** 默认运行时配置 *)
let default = {
  (* 调试配置 *)
  debug_mode = false;
  verbose_logging = false;
  log_level = "info";
  
  (* 错误处理配置 *)
  error_recovery = true;
  max_error_count = 10;
  continue_on_error = true;
  show_suggestions = true;
  colored_output = false;
  
  (* 智能功能配置 *)
  spell_correction = true;
  type_inference = true;
  auto_completion = false;
  code_formatting = true;
}

(** 当前运行时配置 *)
let current = ref default

(** 获取当前运行时配置 *)
let get () = !current

(** 设置运行时配置 *)
let set config = current := config

(** 更新运行时配置字段 *)
let update_debug_mode debug = 
  current := { !current with debug_mode = debug }

let update_verbose_logging verbose = 
  current := { !current with verbose_logging = verbose }

let update_log_level level = 
  current := { !current with log_level = level }

let update_max_error_count count = 
  current := { !current with max_error_count = count }

let update_colored_output colored = 
  current := { !current with colored_output = colored }

(** 环境变量解析辅助函数 *)
let parse_boolean_env_var v = 
  String.lowercase_ascii v = "true" || v = "1"

let parse_positive_int_env_var v =
  try
    let i = int_of_string v in
    if i > 0 then Some i else None
  with Failure _ -> None

let parse_enum_env_var v valid_values =
  let normalized = String.lowercase_ascii v in
  if List.mem normalized valid_values then Some normalized else None

(** 运行时配置环境变量映射 *)
let env_var_mappings = [
  ("CHINESE_OCAML_DEBUG", fun v ->
    let debug = parse_boolean_env_var v in
    update_debug_mode debug);
    
  ("CHINESE_OCAML_VERBOSE", fun v ->
    let verbose = parse_boolean_env_var v in
    update_verbose_logging verbose);
    
  ("CHINESE_OCAML_MAX_ERRORS", fun v ->
    match parse_positive_int_env_var v with
    | Some max_errors -> update_max_error_count max_errors
    | None -> ());
    
  ("CHINESE_OCAML_LOG_LEVEL", fun v ->
    match parse_enum_env_var v ["debug"; "info"; "warn"; "error"] with
    | Some level -> update_log_level level
    | None -> ());
    
  ("CHINESE_OCAML_COLOR", fun v ->
    let colored = parse_boolean_env_var v in
    update_colored_output colored);
]

(** 从环境变量加载运行时配置 *)
let load_from_env () =
  List.iter (fun (env_var, setter) ->
    try
      let value = Sys.getenv env_var in
      setter value
    with Not_found -> ()
  ) env_var_mappings