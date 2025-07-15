(** 骆言语法分析器模式匹配解析模块接口 - Chinese Programming Language Parser Patterns Interface *)

open Ast
open Parser_utils

(** 模式解析函数 *)

(** 解析模式匹配
    @param state 解析器状态
    @return (模式, 新的解析器状态)
*)
val parse_pattern : parser_state -> pattern * parser_state

(** 解析列表模式
    @param state 解析器状态  
    @return (列表模式, 新的解析器状态)
*)
val parse_list_pattern : parser_state -> pattern * parser_state

(** 匹配表达式解析函数 *)

(** 解析现代匹配表达式
    @param state 解析器状态
    @param parse_expression_fn 表达式解析函数回调
    @return (匹配表达式, 新的解析器状态)
*)
val parse_match_expression : parser_state -> (parser_state -> expr * parser_state) -> expr * parser_state

(** 解析古雅体匹配表达式
    @param state 解析器状态
    @param parse_expression_fn 表达式解析函数回调
    @return (古雅体匹配表达式, 新的解析器状态)
*)
val parse_ancient_match_expression : parser_state -> (parser_state -> expr * parser_state) -> expr * parser_state

(** 辅助函数 *)

(** 解析匹配分支
    @param state 解析器状态
    @param parse_expression_fn 表达式解析函数回调
    @return (匹配分支列表, 新的解析器状态)
*)
val parse_match_cases : parser_state -> (parser_state -> expr * parser_state) -> match_branch list * parser_state

(** 构建cons模式
    @param patterns 模式列表
    @return 构建的cons模式
*)
val build_cons_pattern : pattern list -> pattern