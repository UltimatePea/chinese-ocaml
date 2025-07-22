(** 骆言统一错误处理系统 - 工具函数模块 *)

open Error_types

(** 简化错误处理辅助函数 - 保持与现有系统兼容 *)

(** 将Result转换为值，在出错时抛出异常 *)
let result_to_value = function Result.Ok value -> value | Result.Error exn -> raise exn

(** 创建位置信息 *)
let create_eval_position line_hint : Compiler_errors.position =
  { filename = "<expression_evaluator>"; line = line_hint; column = 0 }

(** 安全执行函数，返回Result而不是抛出异常 *)
let safe_execute f =
  try Ok (f ()) with
  | Compiler_errors.CompilerError err -> (
      match err.error with
      | Compiler_errors.ParseError (msg, pos) -> Error (ParseError (msg, pos.line, pos.column))
      | Compiler_errors.RuntimeError (msg, _) -> Error (RuntimeError msg)
      | Compiler_errors.TypeError (msg, _) -> Error (TypeError msg)
      | Compiler_errors.LexError (msg, pos) -> Error (LexError (msg, pos))
      | Compiler_errors.InternalError msg -> Error (CompilerError msg)
      | _ -> Error (SystemError ("编译器错误: " ^ Compiler_errors.format_error_message err.error)))
  | Failure msg -> Error (SystemError msg)
  | e -> Error (SystemError (Printexc.to_string e))

(** 将Result转换为统一错误Result *)
let result_to_unified_result = function
  | Ok value -> Ok value
  | Error exn -> Error (SystemError (Printexc.to_string exn))

(** 链式错误处理 - monadic bind *)
let ( >>= ) result f = match result with Ok value -> f value | Error err -> Error err

(** 错误映射 *)
let map_error f = function Ok value -> Ok value | Error err -> Error (f err)

(** 默认值处理 *)
let with_default default = function Ok value -> value | Error _ -> default

(** 记录错误到日志（如果启用） *)
let log_error error =
  let current_level = Logger.get_level () in
  if current_level = Logger.DEBUG then
    Logger.debug "unified_errors" ("统一错误处理: " ^ Error_conversion.unified_error_to_string error)

(** 第二阶段：便捷错误创建函数 *)

(** 创建词法错误 *)
let create_lexical_error ?pos error_type = LexicalError (error_type, pos)

(** 创建解析错误 *)
let create_parse_error ?pos error_type = ParseError2 (error_type, pos)

(** 创建运行时错误 *)
let create_runtime_error ?pos error_type = RuntimeError2 (error_type, pos)

(** 创建诗词错误 *)
let create_poetry_error ?pos error_type = PoetryError (error_type, pos)

(** 创建系统错误 *)
let create_system_error ?pos error_type = SystemError2 (error_type, pos)

(** 便捷函数：创建无效字符错误 *)
let invalid_character_error ?pos char = create_lexical_error ?pos (InvalidCharacter char)

(** 便捷函数：创建未闭合引用标识符错误 *)
let unterminated_quoted_identifier_error ?pos () =
  create_lexical_error ?pos UnterminatedQuotedIdentifier

(** 便捷函数：创建无效类型关键字错误 *)
let invalid_type_keyword_error ?pos keyword = create_parse_error ?pos (InvalidTypeKeyword keyword)

(** 便捷函数：创建算术错误 *)
let arithmetic_error ?pos msg = create_runtime_error ?pos (ArithmeticError msg)

(** 便捷函数：创建韵律数据错误 *)
let rhyme_data_error ?pos msg = create_poetry_error ?pos (RhymeDataError msg)

(** 便捷函数：创建JSON解析错误 *)
let json_parse_error ?pos msg = create_poetry_error ?pos (JsonParseError msg)

(** 便捷函数：创建文件加载错误 *)
let file_load_error ?pos msg = create_poetry_error ?pos (FileLoadError msg)

(** 便捷函数：创建对偶错误 *)
let parallelism_error ?pos msg = create_poetry_error ?pos (ParallelismError msg)

(** 将新错误类型转换为Result.Error *)
let error_to_result error = Error error

(** 安全执行函数，将failwith替换为统一错误 *)
let safe_failwith_to_error error_creator msg = error_to_result (error_creator msg)
