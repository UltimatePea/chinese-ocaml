(** 骆言语法分析器字面量解析专用模块接口

    从parser_expressions_primary_consolidated.ml中提取字面量解析功能的接口定义

    技术债务重构 - Fix #1034 Phase 1
    @author 骆言AI代理
    @version 1.0 (分离版)
    @since 2025-07-24 *)

open Ast
open Lexer
open Parser_utils

val parse_literal_expr : parser_state -> expr * parser_state
(** 解析字面量表达式（整数、浮点数、字符串、布尔值） *)

val is_literal_token : token -> bool
(** 检查token是否为字面量token *)

val get_literal_type_name : token -> string
(** 获取字面量类型描述（用于错误消息） *)
