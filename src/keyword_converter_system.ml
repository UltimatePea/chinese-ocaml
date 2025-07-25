(** 骆言词法分析器 - 系统关键字转换模块 *)

open Lexer_tokens
open Compiler_errors

(** 异常处理关键字转换 *)
let convert_exception_keywords pos keyword =
  match keyword with
  | `ExceptionKeyword -> Ok ExceptionKeyword
  | `RaiseKeyword -> Ok RaiseKeyword
  | `TryKeyword -> Ok TryKeyword
  | `CatchKeyword -> Ok CatchKeyword
  | `FinallyKeyword -> Ok FinallyKeyword
  | _ -> unsupported_keyword_error "未知的异常处理关键字" pos

(** 模块系统关键字转换 *)
let convert_module_keywords pos keyword =
  match keyword with
  | `ModuleKeyword -> Ok ModuleKeyword
  | `ModuleTypeKeyword -> Ok ModuleTypeKeyword
  | `RefKeyword -> Ok RefKeyword
  | `IncludeKeyword -> Ok IncludeKeyword
  | `FunctorKeyword -> Ok FunctorKeyword
  | `SigKeyword -> Ok SigKeyword
  | `EndKeyword -> Ok EndKeyword
  | _ -> unsupported_keyword_error "未知的模块系统关键字" pos

(** 宏系统关键字转换 *)
let convert_macro_keywords pos keyword =
  match keyword with
  | `MacroKeyword -> Ok MacroKeyword
  | `ExpandKeyword -> Ok ExpandKeyword
  | _ -> unsupported_keyword_error "未知的宏系统关键字" pos
