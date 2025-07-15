(** 骆言语法分析器接口 - Chinese Programming Language Parser Interface *)

open Ast
open Lexer

(** 语法错误异常 *)
exception SyntaxError of string * position

(** 解析器状态类型 *)
type parser_state = Parser_utils.parser_state

(** 主解析函数 - 将词元列表解析为程序AST 
    @param tokens 带位置信息的词元列表
    @return 解析后的程序AST *)
val parse_program : positioned_token list -> program

(** 创建解析器状态 - 用于单元测试和增量解析
    @param tokens 带位置信息的词元列表  
    @return 解析器状态 *)
val create_parser_state : positioned_token list -> parser_state

(** 解析表达式 - 用于单元测试和REPL
    @param state 解析器状态
    @return 解析后的表达式和更新的解析器状态 *)
val parse_expression : parser_state -> expr * parser_state

(** 解析语句 - 用于单元测试和增量解析
    @param state 解析器状态
    @return 解析后的语句和更新的解析器状态 *)
val parse_statement : parser_state -> stmt * parser_state