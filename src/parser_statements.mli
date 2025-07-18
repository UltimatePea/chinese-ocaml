(** 骆言语法分析器语句解析模块接口 - Chinese Programming Language Parser Statements Interface *)

open Ast
open Lexer
open Parser_utils

(** 宏定义解析 *)

val parse_macro_params : macro_param list -> parser_state -> macro_param list * parser_state
(** 解析宏参数列表
    @param acc 累积的参数列表
    @param state 解析器状态
    @return (宏参数列表, 新的解析器状态) *)

(** 语句解析 *)

val parse_statement : parser_state -> stmt * parser_state
(** 解析单个语句
    @param state 解析器状态
    @return (语句, 新的解析器状态) *)

val skip_optional_statement_terminator : parser_state -> parser_state
(** 跳过可选的语句终结符
    @param state 解析器状态
    @return 新的解析器状态 *)

(** 程序解析 *)

val parse_program : positioned_token list -> stmt list
(** 解析整个程序
    @param token_list 词元列表
    @return 语句列表（程序） *)
