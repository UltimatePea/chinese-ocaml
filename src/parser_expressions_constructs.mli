(** 骆言语法分析器构造表达式解析模块接口
    
    本模块专门处理构造表达式的解析：
    - 括号表达式处理
    - 标签表达式(多态变体)
    - 类型关键字表达式
    - 后缀操作(字段访问、数组索引)
    
    技术债务重构 - Fix #1050
    @author 骆言AI代理
    @version 1.0
    @since 2025-07-24 *)


(** 解析括号表达式
    @param parse_expression 表达式解析器函数
    @param parse_postfix_expression 后缀表达式解析器函数
    @param state 当前解析器状态
    @return (表达式, 新的解析器状态) *)
val parse_parenthesized_expr : (Parser_utils.parser_state -> Ast.expr * Parser_utils.parser_state) -> (Ast.expr -> Parser_utils.parser_state -> Ast.expr * Parser_utils.parser_state) -> Parser_utils.parser_state -> Ast.expr * Parser_utils.parser_state

(** 解析标签表达式（多态变体）
    @param parse_primary_expression 基础表达式解析器函数
    @param state 当前解析器状态
    @return (表达式, 新的解析器状态) *)
val parse_tag_expr : (Parser_utils.parser_state -> Ast.expr * Parser_utils.parser_state) -> Parser_utils.parser_state -> Ast.expr * Parser_utils.parser_state

(** 解析类型关键字表达式
    @param state 当前解析器状态
    @return (表达式, 新的解析器状态) *)
val parse_type_keyword_expr : Parser_utils.parser_state -> Ast.expr * Parser_utils.parser_state

(** 解析后缀表达式（字段访问、数组索引等）
    @param parse_expression 表达式解析器函数
    @param expr 基础表达式
    @param state 当前解析器状态
    @return (表达式, 新的解析器状态) *)
val parse_postfix_expr : (Parser_utils.parser_state -> Ast.expr * Parser_utils.parser_state) -> Ast.expr -> Parser_utils.parser_state -> Ast.expr * Parser_utils.parser_state

(** 解析容器表达式（括号、数组、记录）
    @param parse_expression 表达式解析器函数
    @param parse_array_expression 数组表达式解析器函数
    @param parse_record_expression 记录表达式解析器函数
    @param state 当前解析器状态
    @return (表达式, 新的解析器状态) *)
val parse_container_expressions : (Parser_utils.parser_state -> Ast.expr * Parser_utils.parser_state) -> (Parser_utils.parser_state -> Ast.expr * Parser_utils.parser_state) -> (Parser_utils.parser_state -> Ast.expr * Parser_utils.parser_state) -> Parser_utils.parser_state -> Ast.expr * Parser_utils.parser_state

(** 判断token是否为类型关键字 *)
val is_type_keyword_token : Lexer.token -> bool

(** 判断token是否为容器类型 *)
val is_container_token : Lexer.token -> bool