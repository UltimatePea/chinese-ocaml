(** 骆言词法分析器 - 系统关键字转换模块接口

    本模块提供系统级关键字的转换功能，包括异常处理、模块系统和宏系统相关的关键字转换。 支持从符号化关键字到Token类型的安全转换。

    @author 骆言团队
    @since 2025-07-20 *)

val convert_exception_keywords :
  Compiler_errors_types.position ->
  [> `ExceptionKeyword | `RaiseKeyword | `TryKeyword | `CatchKeyword | `FinallyKeyword ] ->
  Lexer_tokens.token Compiler_errors_types.error_result
(** 异常处理关键字转换 将异常处理相关的关键字多态变体转换为对应的Token类型

    @param pos 位置信息，用于错误报告
    @param keyword 要转换的异常处理关键字多态变体
    @return 转换结果，成功时返回对应Token，失败时返回错误 *)

val convert_module_keywords :
  Compiler_errors_types.position ->
  [> `ModuleKeyword
  | `ModuleTypeKeyword
  | `RefKeyword
  | `IncludeKeyword
  | `FunctorKeyword
  | `SigKeyword
  | `EndKeyword ] ->
  Lexer_tokens.token Compiler_errors_types.error_result
(** 模块系统关键字转换 将模块系统相关的关键字多态变体转换为对应的Token类型

    @param pos 位置信息，用于错误报告
    @param keyword 要转换的模块系统关键字多态变体
    @return 转换结果，成功时返回对应Token，失败时返回错误 *)

val convert_macro_keywords :
  Compiler_errors_types.position ->
  [> `MacroKeyword | `ExpandKeyword ] ->
  Lexer_tokens.token Compiler_errors_types.error_result
(** 宏系统关键字转换 将宏系统相关的关键字多态变体转换为对应的Token类型

    @param pos 位置信息，用于错误报告
    @param keyword 要转换的宏系统关键字多态变体
    @return 转换结果，成功时返回对应Token，失败时返回错误 *)
