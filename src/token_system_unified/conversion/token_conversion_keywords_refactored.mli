(** Token转换 - 关键字专门模块 - 重构版本接口
    
    将124行长函数分解为多个小函数，按语言特性分组
    重构目标：改善代码可读性和维护性
    
    @author Alpha, 主要工作代理
    @version 2.0
    @since 2025-07-25 
    @refactors Issue #1333 *)

exception Unknown_keyword_token of string
(** 未知关键字token异常 *)

val convert_basic_language_keywords :
  Token_mapping.Token_definitions_unified.token -> Yyocamlc_lib.Lexer_tokens.token
(** 转换基础语言关键字 (let, fun, if等)
    @param token 统一token类型
    @return 词法分析器token类型
    @raise Unknown_keyword_token 如果token不是基础语言关键字 *)

val convert_semantic_keywords : Token_mapping.Token_definitions_unified.token -> Yyocamlc_lib.Lexer_tokens.token
(** 转换语义关键字 (as, combine等)
    @param token 统一token类型
    @return 词法分析器token类型
    @raise Unknown_keyword_token 如果token不是语义关键字 *)

val convert_error_recovery_keywords :
  Token_mapping.Token_definitions_unified.token -> Yyocamlc_lib.Lexer_tokens.token
(** 转换错误恢复关键字 (try, catch等)
    @param token 统一token类型
    @return 词法分析器token类型
    @raise Unknown_keyword_token 如果token不是错误恢复关键字 *)

val convert_module_keywords : Token_mapping.Token_definitions_unified.token -> Yyocamlc_lib.Lexer_tokens.token
(** 转换模块系统关键字 (module, include等)
    @param token 统一token类型
    @return 词法分析器token类型
    @raise Unknown_keyword_token 如果token不是模块系统关键字 *)

val convert_natural_language_keywords :
  Token_mapping.Token_definitions_unified.token -> Yyocamlc_lib.Lexer_tokens.token
(** 转换自然语言关键字
    @param token 统一token类型
    @return 词法分析器token类型
    @raise Unknown_keyword_token 如果token不是自然语言关键字 *)

val convert_wenyan_keywords : Token_mapping.Token_definitions_unified.token -> Yyocamlc_lib.Lexer_tokens.token
(** 转换文言文关键字
    @param token 统一token类型
    @return 词法分析器token类型
    @raise Unknown_keyword_token 如果token不是文言文关键字 *)

val convert_ancient_keywords : Token_mapping.Token_definitions_unified.token -> Yyocamlc_lib.Lexer_tokens.token
(** 转换古雅体关键字
    @param token 统一token类型
    @return 词法分析器token类型
    @raise Unknown_keyword_token 如果token不是古雅体关键字 *)

(** 转换策略类型定义 *)
type conversion_strategy =
  | Readable  (** 可读性优先：使用分类函数，便于维护和调试 *)
  | Fast  (** 性能优先：使用直接模式匹配，避免异常开销 *)

val convert_with_strategy :
  conversion_strategy -> Token_mapping.Token_definitions_unified.token -> Yyocamlc_lib.Lexer_tokens.token
(** 统一的转换函数 - 使用策略模式消除代码重复

    @param strategy 转换策略（Readable 或 Fast）
    @param token 统一token类型
    @return 词法分析器token类型
    @raise Unknown_keyword_token 如果token无法被识别

    策略说明：
    - Readable: 使用分类函数，代码结构清晰，便于调试和维护
    - Fast: 使用直接模式匹配，性能更好，适合生产环境 *)

val convert_basic_keyword_token :
  Token_mapping.Token_definitions_unified.token -> Yyocamlc_lib.Lexer_tokens.token
(** 向后兼容的主转换函数 - 使用可读性策略 按优先级依次尝试不同的转换器，直到找到匹配的token类型

    @param token 统一token类型
    @return 词法分析器token类型
    @raise Unknown_keyword_token 如果token无法被任何转换器识别

    优先级顺序： 1. 基础语言关键字 (最常用) 2. 语义关键字 3. 错误恢复关键字 4. 模块系统关键字 5. 自然语言关键字 6. 文言文关键字 7. 古雅体关键字 (最少用) *)

val convert_basic_keyword_token_optimized :
  Token_mapping.Token_definitions_unified.token -> Yyocamlc_lib.Lexer_tokens.token
(** 性能优化版本 - 使用性能策略 使用直接模式匹配而不是异常处理，性能更好

    @param token 统一token类型
    @return 词法分析器token类型
    @raise Unknown_keyword_token 如果token无法被识别 *)
