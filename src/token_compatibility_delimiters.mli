(** Token兼容性分隔符映射模块接口 - Token Compatibility Delimiters Module Interface
    
    此模块负责处理各种分隔符的映射转换，包括括号、标点符号、中文标点等。
    这是从 token_compatibility.ml 中提取出来的专门模块，提升代码可维护性。
    
    @author 骆言技术债务清理团队 Issue #646
    @version 1.0
    @since 2025-07-20 *)

(** 分隔符映射函数
    将遗留的分隔符字符串映射到统一token系统中的对应分隔符
    
    支持的分隔符类型：
    - 括号类：LeftParen, RightParen, LeftBracket, RightBracket, LeftBrace, RightBrace
    - 基础标点：Comma, Semicolon, Colon, Dot, QuestionMark, ExclamationMark
    - 中文标点：ChineseComma, ChinesePause, ChineseSemicolon, ChineseColon, ChinesePeriod, ChineseQuestion, ChineseExclamation
    - 特殊符号：Pipe, Underscore, At, Hash
    
    @param legacy_delimiter 遗留系统中的分隔符字符串
    @return 对应的统一token，如果无法映射则返回None *)
val map_legacy_delimiter_to_unified : string -> Unified_token_core.unified_token option