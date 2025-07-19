(** 骆言统一错误处理系统 - Chinese Programming Language Unified Error Handling System 
    Phase 17 统一化扩展版本 *)

(** 统一错误类型 - 用于替代分散的异常处理 *)
type unified_error =
  | ParseError of string * int * int  (* 解析错误：消息，行，列 *)
  | RuntimeError of string            (* 运行时错误：消息 *)
  | TypeError of string               (* 类型错误：消息 *)
  | LexError of string * Compiler_errors.position (* 词法错误：消息，位置 *)
  | CompilerError of string           (* 编译器错误：消息 *)
  | SystemError of string             (* 系统错误：消息 *)

(** 统一错误结果类型 *)
type 'a unified_result = ('a, unified_error) result

(** 简化错误处理辅助函数 - 保持与现有系统兼容 *)

(** 将Result转换为值，在出错时抛出异常 *)
let result_to_value = function Result.Ok value -> value | Result.Error exn -> raise exn

(** 创建位置信息 *)
let create_eval_position line_hint : Compiler_errors.position =
  { filename = "<expression_evaluator>"; line = line_hint; column = 0 }

(** Phase 17 新增：统一错误处理函数 *)

(** 将统一错误转换为字符串 *)
let unified_error_to_string = function
  | ParseError (msg, line, col) -> Printf.sprintf "解析错误 (%d:%d): %s" line col msg
  | RuntimeError msg -> Printf.sprintf "运行时错误: %s" msg
  | TypeError msg -> Printf.sprintf "类型错误: %s" msg
  | LexError (msg, pos) -> Printf.sprintf "词法错误 (%s:%d): %s" pos.filename pos.line msg
  | CompilerError msg -> Printf.sprintf "编译器错误: %s" msg
  | SystemError msg -> Printf.sprintf "系统错误: %s" msg

(** 将统一错误转换为传统异常（向后兼容） *)
let unified_error_to_exception = function
  | ParseError (msg, line, col) -> 
      let pos = { Compiler_errors.filename = ""; line; column = col } in
      Compiler_errors.CompilerError { 
        error = Compiler_errors.ParseError (msg, pos);
        severity = Compiler_errors.Error;
        context = None;
        suggestions = [];
      }
  | RuntimeError msg -> 
      Compiler_errors.CompilerError { 
        error = Compiler_errors.RuntimeError (msg, None);
        severity = Compiler_errors.Error;
        context = None;
        suggestions = [];
      }
  | TypeError msg -> 
      Compiler_errors.CompilerError { 
        error = Compiler_errors.TypeError (msg, None);
        severity = Compiler_errors.Error;
        context = None;
        suggestions = [];
      }
  | LexError (msg, pos) -> 
      Compiler_errors.CompilerError { 
        error = Compiler_errors.LexError (msg, pos);
        severity = Compiler_errors.Error;
        context = None;
        suggestions = [];
      }
  | CompilerError msg -> 
      Compiler_errors.CompilerError { 
        error = Compiler_errors.InternalError msg;
        severity = Compiler_errors.Error;
        context = None;
        suggestions = [];
      }
  | SystemError msg -> Failure msg

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
      | _ -> Error (SystemError ("编译器错误: " ^ (Compiler_errors.format_error_message err.error)))
    )
  | Failure msg -> Error (SystemError msg)
  | e -> Error (SystemError (Printexc.to_string e))

(** 将Result转换为统一错误Result *)
let result_to_unified_result = function
  | Ok value -> Ok value
  | Error exn -> Error (SystemError (Printexc.to_string exn))

(** 链式错误处理 - monadic bind *)
let (>>=) result f =
  match result with
  | Ok value -> f value
  | Error err -> Error err

(** 错误映射 *)
let map_error f = function
  | Ok value -> Ok value
  | Error err -> Error (f err)

(** 默认值处理 *)
let with_default default = function
  | Ok value -> value
  | Error _ -> default

(** 记录错误到日志（如果启用） *)
let log_error error =
  let current_level = Logger.get_level () in
  if current_level = Logger.DEBUG then
    Logger.debug "unified_errors" ("统一错误处理: " ^ unified_error_to_string error)
