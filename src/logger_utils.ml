(** 统一日志器初始化工具模块 *)

type logger_func = string -> unit
(** 日志器函数类型 *)

(** * 本模块提供统一的日志器初始化接口，解决项目中日志器初始化代码重复问题 * * 使用方法： * 1. 对于需要所有日志级别的模块： * let log_debug, log_info,
    log_warn, log_error = Logger_utils.init_all_loggers "ModuleName" * * 2. 对于只需要特定日志级别的模块： * let
    log_info, log_error = Logger_utils.init_info_error_loggers "ModuleName" * * 3. 对于只需要调试和错误的模块： *
    let log_debug, log_error = Logger_utils.init_debug_error_loggers "ModuleName" * * 4.
    对于只需要信息级别的模块： * let log_info = Logger_utils.init_info_logger "ModuleName" *)

(** 初始化所有级别的日志器 (debug, info, warn, error) *)
let init_all_loggers module_name =
  let debug, info, warn, error = Logger.init_module_logger module_name in
  (debug, info, warn, error)

(** 初始化信息和错误级别的日志器 *)
let init_info_error_loggers module_name =
  let _, info, _, error = Logger.init_module_logger module_name in
  (info, error)

(** 初始化调试和错误级别的日志器 *)
let init_debug_error_loggers module_name =
  let debug, _, _, error = Logger.init_module_logger module_name in
  (debug, error)

(** 初始化信息、警告和错误级别的日志器 *)
let init_info_warn_error_loggers module_name =
  let _, info, warn, error = Logger.init_module_logger module_name in
  (info, warn, error)

(** 初始化调试、信息和错误级别的日志器 *)
let init_debug_info_error_loggers module_name =
  let debug, info, _, error = Logger.init_module_logger module_name in
  (debug, info, error)

(** 初始化调试和信息级别的日志器 *)
let init_debug_info_loggers module_name =
  let debug, info, _, _ = Logger.init_module_logger module_name in
  (debug, info)

(** 只初始化信息级别的日志器 *)
let init_info_logger module_name =
  let _, info, _, _ = Logger.init_module_logger module_name in
  info

(** 只初始化错误级别的日志器 *)
let init_error_logger module_name =
  let _, _, _, error = Logger.init_module_logger module_name in
  error

(** 只初始化调试级别的日志器 *)
let init_debug_logger module_name =
  let debug, _, _, _ = Logger.init_module_logger module_name in
  debug

(** 不保存任何日志器引用，仅进行初始化 *)
let init_no_logger module_name =
  let _ = Logger.init_module_logger module_name in
  ()

(** 兼容性函数 - 保持与现有代码的兼容性 *)
let init_module_logger = Logger.init_module_logger

(** * 自动模块名推断函数 * 根据OCaml文件名自动推断模块名 * 注意：这个函数需要在编译时调用，不能在运行时获取文件信息 *)
let infer_module_name filename =
  let basename = Filename.basename filename in
  let name_without_ext = Filename.remove_extension basename in
  let capitalized = String.capitalize_ascii name_without_ext in
  (* 将下划线转换为驼峰命名 *)
  let convert_underscores str =
    let len = String.length str in
    let buffer = Buffer.create len in
    let rec loop i capitalize_next =
      if i >= len then Buffer.contents buffer
      else
        let c = str.[i] in
        if c = '_' then loop (i + 1) true
        else if capitalize_next then (
          Buffer.add_char buffer (Char.uppercase_ascii c);
          loop (i + 1) false)
        else (
          Buffer.add_char buffer c;
          loop (i + 1) false)
    in
    loop 0 false
  in
  convert_underscores capitalized

(** * 智能初始化函数 * 根据模块的常用日志级别自动选择合适的初始化函数 *)
let smart_init module_name =
  match module_name with
  | "Main" | "Compiler" -> init_info_error_loggers module_name
  | "Parser" | "ParserPoetry" -> init_debug_error_loggers module_name
  | "Semantic" | "TypesInfer" -> init_info_error_loggers module_name
  | "Codegen" | "CCodegen" -> init_debug_error_loggers module_name
  | "ErrorRecovery" ->
      let _, info, error = init_debug_info_error_loggers module_name in
      (info, error)
  | _ -> init_info_error_loggers module_name (* 默认使用info和error *)
