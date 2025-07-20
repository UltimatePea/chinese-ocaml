(** 骆言词法分析器 - 系统关键字转换模块接口

    本模块提供系统级关键字转换功能，处理高级语言特性如
    异常处理、模块系统和宏系统的关键字转换。
    
    主要功能：
    - 异常处理关键字转换
    - 模块系统关键字转换  
    - 宏系统关键字转换
    - 错误处理和位置信息
*)

(** {2 异常处理关键字转换} *)

val convert_exception_keywords : Compiler_errors_types.position -> [>
  | `ExceptionKeyword
  | `RaiseKeyword
  | `TryKeyword
  | `CatchKeyword
  | `FinallyKeyword
  ] -> Lexer_tokens.token Compiler_errors_types.error_result
(** [convert_exception_keywords pos keyword] 转换异常处理关键字
    @param pos 词法位置信息
    @param keyword 异常处理关键字变体
    @return 转换后的token或错误信息 *)

(** {2 模块系统关键字转换} *)

val convert_module_keywords : Compiler_errors_types.position -> [>
  | `ModuleKeyword
  | `ModuleTypeKeyword
  | `RefKeyword
  | `IncludeKeyword
  | `FunctorKeyword
  | `SigKeyword
  | `EndKeyword
  ] -> Lexer_tokens.token Compiler_errors_types.error_result
(** [convert_module_keywords pos keyword] 转换模块系统关键字
    @param pos 词法位置信息
    @param keyword 模块系统关键字变体
    @return 转换后的token或错误信息 *)

(** {2 宏系统关键字转换} *)

val convert_macro_keywords : Compiler_errors_types.position -> [>
  | `MacroKeyword
  | `ExpandKeyword
  ] -> Lexer_tokens.token Compiler_errors_types.error_result
(** [convert_macro_keywords pos keyword] 转换宏系统关键字
    @param pos 词法位置信息
    @param keyword 宏系统关键字变体
    @return 转换后的token或错误信息 *)