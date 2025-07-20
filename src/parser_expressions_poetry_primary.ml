(** 骆言语法分析器诗词表达式处理模块（Primary层）
    
    本模块专门处理诗词表达式在Primary层的解析，作为现有Parser_poetry模块的补充。
    从parser_expressions_primary.ml中拆分出来。
    
    @author 骆言技术债务清理团队
    @version 1.0
    @since 2025-07-20 Issue #644 重构 *)

open Lexer
open Parser_utils

(** 解析诗词表达式 *)
let parse_poetry_expr state token =
  match token with
  | ParallelStructKeyword | FiveCharKeyword | SevenCharKeyword ->
      Parser_poetry.parse_poetry_expression state
  | _ -> invalid_arg "parse_poetry_expr: 不是诗词关键字"

(** 解析诗词表达式（重构后） *)
let parse_poetry_expressions state =
  let token, _ = current_token state in
  match token with
  | ParallelStructKeyword | FiveCharKeyword | SevenCharKeyword ->
      Some (parse_poetry_expr state token)
  | _ -> None