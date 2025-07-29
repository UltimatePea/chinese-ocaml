(** 骆言标准化错误处理模块 - 减少异常类型碎片化 *)

exception StandardRuntimeError of string
(** 核心标准化异常类型 - 从56种减少到5种核心类型 *)

exception StandardSyntaxError of string * Compiler_errors.position option
exception StandardTypeError of string * Compiler_errors.position option
exception StandardLexError of string * Compiler_errors.position option
exception StandardSystemError of string

(** 错误映射函数 - 将现有的各种异常类型映射到标准类型 *)
let standardize_exception = function
  (* 运行时错误族 *)
  | Failure msg -> StandardRuntimeError msg
  | Invalid_argument msg -> StandardRuntimeError ("参数错误: " ^ msg)
  | Not_found -> StandardRuntimeError "未找到所需资源"
  | Sys_error msg -> StandardSystemError ("系统错误: " ^ msg)
  (* 编译器相关错误 *)
  | Compiler_errors.CompilerError err -> (
      match err.error with
      | Compiler_errors.ParseError (msg, pos) -> StandardSyntaxError (msg, Some pos)
      | Compiler_errors.RuntimeError (msg, _pos) -> StandardRuntimeError msg
      | Compiler_errors.TypeError (msg, pos) -> StandardTypeError (msg, pos)
      | Compiler_errors.LexError (msg, pos) -> StandardLexError (msg, Some pos)
      | Compiler_errors.InternalError msg -> StandardSystemError ("内部错误: " ^ msg)
      | _ -> StandardSystemError ("未分类编译器错误: " ^ Compiler_errors.format_error_message err.error))
  (* 其他异常 *)
  | exn -> StandardSystemError ("未处理异常: " ^ Printexc.to_string exn)

(** 安全执行函数 - 捕获所有异常并标准化 *)
let safe_execute_standardized f =
  try Ok (f ()) with
  | StandardRuntimeError msg -> Error (Error_types.RuntimeError msg)
  | StandardSyntaxError (msg, pos) -> (
      match pos with
      | Some p -> Error (Error_types.ParseError (msg, p.line, p.column))
      | None -> Error (Error_types.ParseError (msg, 0, 0)))
  | StandardTypeError (msg, _pos) -> Error (Error_types.TypeError msg)
  | StandardLexError (msg, pos) -> (
      match pos with
      | Some p -> Error (Error_types.LexError (msg, p))
      | None -> Error (Error_types.LexError (msg, { filename = ""; line = 0; column = 0 })))
  | StandardSystemError msg -> Error (Error_types.SystemError msg)
  | exn -> Error (Error_types.SystemError (Printexc.to_string exn))

(** 统一错误抛出函数 - 替代分散的failwith调用 *)
let fail_runtime msg = raise (StandardRuntimeError msg)

let fail_syntax ?pos msg = raise (StandardSyntaxError (msg, pos))
let fail_type ?pos msg = raise (StandardTypeError (msg, pos))
let fail_lex ?pos msg = raise (StandardLexError (msg, pos))
let fail_system msg = raise (StandardSystemError msg)

(** 向后兼容的异常转换 - 返回错误创建函数 *)
let convert_legacy_exception error_name msg =
  match error_name with
  | "ToneDataError" -> StandardRuntimeError msg
  | "Parser_utils" -> StandardSyntaxError (msg, None)
  | "LexError" -> StandardLexError (msg, None)
  | "CompilerError" -> StandardSystemError msg
  | "Json_parse_error" -> StandardRuntimeError msg
  | "Ru_sheng_data_error" -> StandardRuntimeError msg
  | "Test_config_error" -> StandardSystemError msg
  | "Rhyme_data_not_found" -> StandardRuntimeError msg
  | "RhymeDataEngineError" -> StandardRuntimeError msg
  | "Unknown_classical_token" -> StandardLexError (msg, None)
  | "Lexer_conversion_failed" -> StandardLexError (msg, None)
  | "Unknown_modern_token" -> StandardLexError (msg, None)
  | "Unified_conversion_failed" -> StandardSystemError msg
  | "RhythmAnalyzerError" -> StandardRuntimeError msg
  | "JsonLoaderError" -> StandardRuntimeError msg
  | "Yu_rhyme_data_error" -> StandardRuntimeError msg
  | "UnifiedEngineError" -> StandardSystemError msg
  | "PoetryParseError" -> StandardSyntaxError (msg, None)
  | "TokenMappingError" -> StandardLexError (msg, None)
  | "ArtisticEvaluatorError" -> StandardRuntimeError msg
  | "RhymeDataLoadError" -> StandardRuntimeError msg
  | "FileReadError" -> StandardSystemError msg
  | "SemanticError" -> StandardTypeError (msg, None)
  | "Unknown_identifier_token" -> StandardLexError (msg, None)
  | "Unknown_token" -> StandardLexError (msg, None)
  | "Incompatible_token" -> StandardLexError (msg, None)
  | "Legacy_conversion_failed" -> StandardSystemError msg
  | "Token_conversion_failed" -> StandardLexError (msg, None)
  | "Conversion_failed" -> StandardSystemError msg
  | "RhymeDataError" -> StandardRuntimeError msg
  | "MeterEngineError" -> StandardRuntimeError msg
  | "RhymeException" -> StandardRuntimeError msg
  | "DataLoadError" -> StandardSystemError msg
  | _ -> StandardSystemError msg

(** 批量错误重构助手 - 用于将文件中的多种异常统一化 *)
let refactor_error_calls error_name msg = convert_legacy_exception error_name msg

(** 错误统计助手 - 用于监控标准化进展 *)
let count_standardized_errors () =
  (* 这里可以添加错误计数逻辑 *)
  ()

(** 兼容性包装 - 允许渐进式迁移 *)
module Compatibility = struct
  (** 包装旧的failwith调用 *)
  let failwith msg = fail_runtime msg

  (** 包装旧的invalid_arg调用 *)
  let invalid_arg msg = fail_runtime ("参数错误: " ^ msg)

  (** 包装旧的raise调用 *)
  let raise_with_standardization exn = raise (standardize_exception exn)
end
