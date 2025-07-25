(** 骆言语法分析器字面量表达式解析模块接口
    
    本模块专门处理各种字面量表达式的解析：
    - 整数字面量（包括中文数字）
    - 浮点数字面量
    - 字符串字面量
    - 布尔值字面量
    - 特殊字面量（如"一"关键字）
    
    技术债务重构 - Fix #1050
    @author 骆言AI代理
    @version 1.0
    @since 2025-07-24 *)

(** 解析字面量表达式 
    @param state 当前解析器状态
    @return (表达式, 新的解析器状态) *)
val parse_literal_expr : Parser_utils.parser_state -> Ast.expr * Parser_utils.parser_state

(** 解析单个字面量参数（用于函数参数解析）
    @param token 当前token
    @param state 当前解析器状态
    @return (表达式, 新的解析器状态) *)
val parse_literal_argument : Lexer.token -> Parser_utils.parser_state -> Ast.expr * Parser_utils.parser_state

(** 判断token是否为字面量类型
    @param token 要判断的token
    @return 如果是字面量token则返回true *)
val is_literal_token : Lexer.token -> bool

(** 解析基础字面量参数表达式（用于向后兼容）
    @param state 当前解析器状态
    @return (表达式, 新的解析器状态) *)
val parse_basic_literal_argument : Parser_utils.parser_state -> Ast.expr * Parser_utils.parser_state

(** ==================== 辅助解析函数 ==================== *)

(** 解析字面量表达式辅助函数 - 向后兼容性
    @param state 当前解析器状态
    @return (表达式, 新的解析器状态) *)
val parse_literal_exprs : Parser_utils.parser_state -> Ast.expr * Parser_utils.parser_state

(** 字面量表达式安全解析函数 - 带错误处理
    @param token 当前token
    @param state 当前解析器状态
    @return (表达式, 新的解析器状态) *)
val parse_literal_expr_safe : Lexer.token -> Parser_utils.parser_state -> Ast.expr * Parser_utils.parser_state

(** 简化的基本表达式解析器 - 仅用于函数参数中的字面量和变量
    @param state 当前解析器状态
    @return (表达式, 新的解析器状态) *)
val parse_basic_argument_expr : Parser_utils.parser_state -> Ast.expr * Parser_utils.parser_state

(** ==================== 字面量处理辅助函数 ==================== *)

(** 检查token是否适合作为字面量使用
    @param token 要判断的token
    @return 如果可以解析为字面量则返回true *)
val can_parse_as_literal : Lexer.token -> bool

(** 从token直接提取字面量值（不消费parser状态）
    @param token 字面量token
    @return 对应的字面量值
    @raise failwith 如果token不是字面量类型 *)
(** 从token直接提取字面量值 - 安全版本返回Result *)
val extract_literal_from_token : Lexer.token -> (Ast.literal, string) result

(** 从token直接提取字面量值 - 向后兼容版本 *)
val extract_literal_from_token_unsafe : Lexer.token -> Ast.literal