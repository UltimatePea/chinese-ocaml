(** 骆言语法分析器特殊表达式解析模块接口
    
    本模块专门处理特殊表达式的解析：
    - 模块表达式解析
    - 诗词表达式处理
    - 古雅体表达式处理
    - 统一错误处理逻辑
    
    技术债务重构 - Fix #1050
    @author 骆言AI代理
    @version 1.0
    @since 2025-07-24 *)


(** 解析模块表达式
    @param state 当前解析器状态
    @return (表达式, 新的解析器状态) *)
val parse_module_expr : Parser_utils.parser_state -> Ast.expr * Parser_utils.parser_state

(** 解析古典诗词表达式
    @param state 当前解析器状态
    @return (表达式, 新的解析器状态) *)
val parse_poetry_expr : Parser_utils.parser_state -> Ast.expr * Parser_utils.parser_state

(** 解析古雅体表达式
    @param parse_expression 表达式解析器函数
    @param state 当前解析器状态
    @return (表达式, 新的解析器状态) *)
val parse_ancient_expr : (Parser_utils.parser_state -> Ast.expr * Parser_utils.parser_state) -> Parser_utils.parser_state -> Ast.expr * Parser_utils.parser_state

(** 解析特殊关键字表达式
    @param parse_expression 表达式解析器函数
    @param parse_array_expression 数组表达式解析器函数
    @param parse_record_expression 记录表达式解析器函数
    @param state 当前解析器状态
    @return (表达式, 新的解析器状态) *)
val parse_special_keyword_expressions : (Parser_utils.parser_state -> Ast.expr * Parser_utils.parser_state) -> (Parser_utils.parser_state -> Ast.expr * Parser_utils.parser_state) -> (Parser_utils.parser_state -> Ast.expr * Parser_utils.parser_state) -> Parser_utils.parser_state -> Ast.expr * Parser_utils.parser_state

(** 处理不支持的语法错误
    @param token 出错的token
    @param pos token位置
    @raise SyntaxError 或 ParseError *)
val handle_unsupported_syntax : Lexer.token -> Lexer.position -> 'a

(** 判断token是否为特殊关键字 *)
val is_special_keyword_token : Lexer.token -> bool

(** 统一的错误处理辅助函数
    @param expr_type 表达式类型描述
    @param token 出错的token
    @param exn 异常信息
    @param state 当前解析器状态
    @raise Parser_utils.UnexpectedTokenError *)
val raise_parse_error : string -> Lexer.token -> exn -> Parser_utils.parser_state -> 'a