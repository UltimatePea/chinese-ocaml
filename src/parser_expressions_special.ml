(** 骆言语法分析器特殊表达式解析模块
    
    本模块专门处理特殊表达式的解析：
    - 模块表达式解析
    - 诗词表达式处理
    - 古雅体表达式处理
    - 统一错误处理逻辑
    
    技术债务重构 - Fix #1050
    @author 骆言AI代理
    @version 1.0
    @since 2025-07-24 *)

open Ast
open Lexer
open Parser_utils

(** 判断token是否为特殊关键字 *)
let is_special_keyword_token = function
  | ModuleKeyword | CombineKeyword | ParallelStructKeyword | FiveCharKeyword | SevenCharKeyword
  | AncientDefineKeyword | AncientObserveKeyword | AncientListStartKeyword ->
      true
  | _ -> false

(** 统一的错误处理辅助函数 *)
let raise_parse_error expr_type token exn state =
  let error_msg =
    Unified_formatter.ErrorHandling.parse_failure_with_token expr_type (show_token token)
      (Printexc.to_string exn)
  in
  let _, pos = current_token state in
  raise (Parser_utils.make_unexpected_token_error error_msg pos)

(** 解析模块表达式 *)
let parse_module_expr state = Parser_expressions_utils.parse_module_expression state

(** 解析古典诗词表达式 *)
let parse_poetry_expr state =
  let token, _ = current_token state in
  match token with
  | ParallelStructKeyword | FiveCharKeyword | SevenCharKeyword ->
      Parser_poetry.parse_poetry_expression state
  | _ ->
      raise
        (Parser_utils.make_unexpected_token_error
           ("parse_poetry_expression: " ^ show_token token)
           (snd (current_token state)))

(** 解析古雅体表达式 *)
let parse_ancient_expr parse_expr state =
  let token, _ = current_token state in
  match token with
  | AncientDefineKeyword -> Parser_ancient.parse_ancient_function_definition parse_expr state
  | AncientObserveKeyword ->
      Parser_ancient.parse_ancient_match_expression parse_expr Parser_patterns.parse_pattern
        state
  | AncientListStartKeyword -> Parser_ancient.parse_ancient_list_expression parse_expr state
  | _ ->
      raise
        (Parser_utils.make_unexpected_token_error
           ("parse_ancient_expr: " ^ show_token token)
           (snd (current_token state)))

(** 解析特殊关键字表达式 *)
let parse_special_keyword_expressions parse_expr _parse_array_expr
    _parse_record_expr state =
  let token, pos = current_token state in
  match token with
  (* 标签表达式 - 需要特殊处理递归调用 *)
  | TagKeyword ->
      (* 暂时跳过标签表达式的递归调用，留待后续处理 *)
      raise (Parser_utils.make_unexpected_token_error "TagKeyword递归调用需要在主函数中处理" pos)
  (* 模块表达式 *)
  | ModuleKeyword -> parse_module_expr state
  (* 组合表达式 - 委派给结构化表达式模块 *)
  | CombineKeyword ->
      raise (Parser_utils.make_unexpected_token_error "CombineKeyword应由主表达式解析器处理" pos)
  (* 诗词表达式 *)
  | ParallelStructKeyword | FiveCharKeyword | SevenCharKeyword -> parse_poetry_expr state
  (* 古雅体表达式 *)
  | AncientDefineKeyword | AncientObserveKeyword | AncientListStartKeyword ->
      parse_ancient_expr parse_expr state
  | _ ->
      raise
        (Parser_utils.make_unexpected_token_error
           ("parse_special_keyword_exprs: 不支持的特殊token " ^ show_token token)
           pos)

(** 处理错误情况和不支持的语法 *)
let handle_unsupported_syntax token pos =
  match token with
  (* 现代列表语法禁用提示 *)
  | LeftBracket | ChineseLeftBracket ->
      let ancient_list_error_msg =
        "请使用古雅体列表语法替代 [...]。\n\
         空列表：空空如也\n\
         有元素的列表：列开始 元素1 其一 元素2 其二 元素3 其三 列结束\n\
         模式匹配：有首有尾 首名为「变量名」尾名为「尾部变量名」"
      in
      raise (SyntaxError (ancient_list_error_msg, pos))
  (* DefineKeyword特殊处理 *)
  | DefineKeyword -> raise (Types.ParseError ("DefineKeyword应由主解析器处理", pos.line, pos.column))
  (* 其他不支持的token *)
  | _ ->
      raise
        (Parser_utils.make_unexpected_token_error
           ("parse_primary_expr: 不支持的token " ^ show_token token)
           pos)