(** 骆言语法分析器古雅体模块 - Chinese Programming Language Parser Ancient Module *)

open Ast
open Parser_utils

type 'a parser = parser_state -> 'a * parser_state
(** 解析函数类型，用于高阶函数 *)

type expr_parser = expr parser
(** 表达式解析器类型 *)

type pattern_parser = pattern parser
(** 模式解析器类型 *)

(** 古雅体语法解析函数 *)

val parse_ancient_function_definition : expr_parser -> parser_state -> expr * parser_state
(** 解析古雅体函数定义 语法：夫 函数名 者 受 参数 焉 算法为 表达式 也 例如：夫 阶乘 者 受 数 焉 算法为 数 乘 数减一 之 阶乘 也 *)

val parse_ancient_match_expression :
  expr_parser -> pattern_parser -> parser_state -> expr * parser_state
(** 解析古雅体匹配表达式 语法：观 标识符 之 性 若 模式 则 表达式 余者 则 表达式 观毕 例如：观 数 之 性 若 零 则 一 余者 则 数 乘 数减一 之 阶乘 观毕 *)

val parse_ancient_list_expression : expr_parser -> parser_state -> expr * parser_state
(** 解析古雅体列表表达式 语法：列开始 元素1 其一 元素2 其二 元素3 其三 列结束 例如：列开始 一 其一 二 其二 三 其三 列结束 *)

val parse_ancient_conditional_expression : expr_parser -> parser_state -> expr * parser_state
(** 解析古雅体条件表达式 语法：若 条件 则 表达式 否则 表达式 例如：若 数 等于 零 则 一 否则 数 乘 数减一 之 阶乘 *)

(** 文言（wenyan）语法解析函数 *)

val parse_wenyan_let_expression : expr_parser -> parser_state -> expr * parser_state
(** 解析文言风格变量声明 语法：吾有一数，名曰「数值」，其值四十二也。 例如：吾有一数，名曰「计数器」，其值零也。 *)

val parse_wenyan_simple_let_expression : expr_parser -> parser_state -> expr * parser_state
(** 解析简化文言风格变量声明 语法：设变量名为表达式 例如：设数值为四十二 *)

(** 辅助函数 *)

val skip_newlines : parser_state -> parser_state
(** 跳过换行符 *)

val parse_natural_arithmetic_continuation : expr -> string -> parser_state -> expr * parser_state
(** 解析自然语言算术延续表达式 处理类似「数减一」之「阶乘」的表达式 *)
