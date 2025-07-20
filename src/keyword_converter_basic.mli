(** 骆言词法分析器 - 基础关键字转换模块接口 *)

(** 基础关键字转换
    将基础关键字的多态变体转换为统一的token类型
    @param pos 位置信息，用于错误报告
    @param keyword 要转换的基础关键字多态变体
    @return 转换结果，成功时返回Ok token，失败时返回Error *)
val convert_basic_keywords : 
  Compiler_errors.position -> 
  [> `LetKeyword | `RecKeyword | `InKeyword | `FunKeyword | `IfKeyword 
   | `ThenKeyword | `ElseKeyword | `MatchKeyword | `WithKeyword 
   | `OtherKeyword | `TypeKeyword | `PrivateKeyword | `TrueKeyword 
   | `FalseKeyword | `AndKeyword | `OrKeyword | `NotKeyword | `OfKeyword ] ->
  Lexer_tokens.token Compiler_errors.error_result

(** 语义关键字转换
    将语义关键字的多态变体转换为统一的token类型
    @param pos 位置信息，用于错误报告
    @param keyword 要转换的语义关键字多态变体
    @return 转换结果，成功时返回Ok token，失败时返回Error *)
val convert_semantic_keywords : 
  Compiler_errors.position -> 
  [> `AsKeyword | `CombineKeyword | `WithOpKeyword | `WhenKeyword | `WithDefaultKeyword ] ->
  Lexer_tokens.token Compiler_errors.error_result