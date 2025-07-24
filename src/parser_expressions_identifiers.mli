(** 骆言语法分析器标识符和函数调用解析模块接口
    
    本模块专门处理标识符表达式和函数调用的解析：
    - 带引号标识符解析
    - 特殊标识符处理
    - 复合标识符解析
    - 函数调用检测和参数收集
    - 变量引用处理
    
    技术债务重构 - Fix #1050
    @author 骆言AI代理
    @version 1.0
    @since 2025-07-24 *)

open Ast

(** 解析标识符表达式（变量引用和函数调用）
    @param parse_expression 表达式解析器函数
    @param state 当前解析器状态
    @return (表达式, 新的解析器状态) *)
val parse_identifier_expr : (Parser_utils.parser_state -> expression * Parser_utils.parser_state) -> Parser_utils.parser_state -> expression * Parser_utils.parser_state

(** 解析函数参数列表
    @param parse_expression 表达式解析器函数
    @param state 当前解析器状态
    @return (参数表达式列表, 新的解析器状态) *)
val parse_function_arguments : (Parser_utils.parser_state -> expression * Parser_utils.parser_state) -> Parser_utils.parser_state -> expression list * Parser_utils.parser_state

(** 解析函数调用或变量引用（根据后续token决定）
    @param parse_expression 表达式解析器函数
    @param name 标识符名称
    @param state 当前解析器状态
    @return (表达式, 新的解析器状态) *)
val parse_function_call_or_variable : (Parser_utils.parser_state -> expression * Parser_utils.parser_state) -> string -> Parser_utils.parser_state -> expression * Parser_utils.parser_state

(** 判断token是否为标识符类型
    @param token 要判断的token
    @return 如果是标识符token则返回true *)
val is_identifier_token : Lexer.token -> bool

(** 向后兼容：解析函数调用或变量（使用基础参数解析器）
    @param name 标识符名称
    @param state 当前解析器状态  
    @return (表达式, 新的解析器状态) *)
val parse_function_call_or_variable_basic : string -> Parser_utils.parser_state -> expression * Parser_utils.parser_state