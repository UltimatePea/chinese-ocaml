(** 骆言语法分析器基础表达式解析模块 - 整合版

    本模块将原有的多个细分基础表达式模块整合为一个统一模块：
    - parser_exprs_primary.ml
    - parser_exprs_literals_primary.ml
    - parser_exprs_keywords_primary.ml
    - parser_exprs_compound_primary.ml
    - parser_exprs_poetry_primary.ml
    - parser_exprs_identifiers.ml
    - parser_exprs_basic.ml (部分功能)

    整合目的： 1. 减少模块间的循环依赖 2. 提高代码的可维护性 3. 简化项目结构 4. 保持所有现有功能完整

    技术债务重构 - Fix #796
    @author 骆言AI代理
    @version 3.0 (整合版)
    @since 2025-07-21 *)

open Ast
open Lexer
open Parser_utils


(** ==================== 字面量表达式解析 ==================== *)

(** 解析字面量表达式（整数、浮点数、字符串、布尔值） - 委派给字面量解析模块 *)
let parse_literal_expr state = Parser_expressions_literals.parse_literal_expr state

(** ==================== 标识符表达式解析 - 重构版本 ==================== *)

(* 标识符表达式解析已迁移到 Parser_expressions_identifiers 模块 *)

(** ==================== 关键字表达式解析 ==================== *)

(** 解析标签表达式 *)
let parse_tag_expr parse_primary_expr state =
  (* 多态变体表达式: 标签 「标签名」 [值] *)
  let state1 = advance_parser state in
  let tag_name, state2 = parse_identifier state1 in
  let token, _ = current_token state2 in
  if is_identifier_like token then
    (* 有值的多态变体: 标签 「标签名」 值 *)
    let value_expr, state3 = parse_primary_expr state2 in
    (PolymorphicVariantExpr (tag_name, Some value_expr), state3)
  else
    (* 无值的多态变体: 标签 「标签名」 *)
    (PolymorphicVariantExpr (tag_name, None), state2)

(* 类型关键字表达式解析已迁移到 Parser_expressions_identifiers 模块 *)

(** ==================== 复合表达式解析 ==================== *)

(** 解析括号表达式 *)
let parse_parenthesized_expr parse_expr state =
  let state1 = advance_parser state in
  let token, _ = current_token state1 in
  if is_right_paren token then
    (* 处理单元字面量 () *)
    let state2 = advance_parser state1 in
    Parser_expressions_calls.parse_postfix_expr parse_expr (LitExpr UnitLit) state2
  else
    (* 处理括号表达式 (expr) *)
    let expr, state2 = parse_expr state1 in
    let state3 = expect_token_punctuation state2 is_right_paren "right parenthesis" in
    Parser_expressions_calls.parse_postfix_expr parse_expr expr state3

(** 解析模块表达式 *)
let parse_module_expr state = 
  (* 简单实现：假设模块表达式是一个标识符 *)
  let module_name, state1 = parse_identifier state in
  (VarExpr module_name, state1)

(** ==================== 诗词表达式解析 ==================== *)

(** 解析古典诗词表达式 *)
let parse_poetry_expr state =
  let token, _ = current_token state in
  match token with
  | ParallelStructKeyword | FiveCharKeyword | SevenCharKeyword ->
      Parser_poetry.parse_poetry_expr state
  | _ ->
      raise
        (Parser_utils.make_unexpected_token_error
           ("parse_poetry_expr: " ^ show_token token)
           (snd (current_token state)))

(** ==================== 古雅体表达式解析 ==================== *)

(** 解析古雅体表达式 *)
let parse_ancient_expr parse_expr state =
  let token, _ = current_token state in
  match token with
  | AncientDefineKeyword -> Parser_ancient.parse_ancient_function_definition parse_expr state
  | AncientObserveKeyword ->
      Parser_ancient.parse_ancient_match_expr parse_expr Parser_patterns.parse_pattern
        state
  | AncientListStartKeyword -> Parser_ancient.parse_ancient_list_expr parse_expr state
  | _ ->
      raise
        (Parser_utils.make_unexpected_token_error
           ("parse_ancient_expr: " ^ show_token token)
           (snd (current_token state)))


(** ==================== 主解析函数 - 重构版本 ==================== *)

(* 解析字面量表达式辅助函数 - 委派给字面量解析模块 *)
let parse_literal_exprs state = Parser_expressions_literals.parse_literal_exprs state

(* 标识符和类型关键字表达式解析辅助函数已迁移到 Parser_expressions_identifiers 模块 *)

(* 解析容器表达式辅助函数 *)
let parse_container_exprs parse_expr parse_array_expr parse_record_expr
    state =
  let token, pos = current_token state in
  match token with
  (* 括号表达式 *)
  | LeftParen | ChineseLeftParen ->
      parse_parenthesized_expr parse_expr state
  (* 数组表达式 *)
  | LeftArray | ChineseLeftArray ->
      let array_expr, state1 = parse_array_expr state in
      Parser_expressions_calls.parse_postfix_expr parse_expr array_expr state1
  (* 记录表达式 *)
  | LeftBrace ->
      let record_expr, state1 = parse_record_expr state in
      Parser_expressions_calls.parse_postfix_expr parse_expr record_expr state1
  | _ ->
      raise
        (Parser_utils.make_unexpected_token_error
           ("parse_container_exprs: 不支持的容器token " ^ show_token token)
           pos)

(* 解析特殊关键字表达式辅助函数 *)
and parse_special_keyword_exprs parse_expr _parse_array_expr
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

(* 处理错误情况和不支持的语法 *)
and handle_unsupported_syntax token pos =
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

(** 匹配字面量类型tokens - 委派给字面量解析模块 *)
let is_literal_token = Parser_expressions_literals.is_literal_token

(* 标识符和类型关键字token检查函数已迁移到 Parser_expressions_identifiers 模块 *)

(** 匹配容器类型tokens *)
let is_container_token = function
  | LeftParen | ChineseLeftParen | LeftArray | ChineseLeftArray | LeftBrace -> true
  | _ -> false

(** 匹配特殊关键字tokens *)
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

(** 解析单个表达式类型 - 字面量 - 委派给字面量解析模块 *)
let parse_literal_expr_safe token state = Parser_expressions_literals.parse_literal_expr_safe token state

(* 安全标识符和类型关键字表达式解析函数已迁移到 Parser_expressions_identifiers 模块 *)

(** 解析单个表达式类型 - 容器 *)
let parse_container_expr_safe parse_expr parse_array_expr parse_record_expr token
    state =
  try
    parse_container_exprs parse_expr parse_array_expr parse_record_expr
      state
  with exn -> raise_parse_error "容器表达式" token exn state

(** 解析单个表达式类型 - 特殊关键字 *)
let parse_special_keyword_expr_safe parse_expr parse_array_expr parse_record_expr
    token state =
  try
    parse_special_keyword_exprs parse_expr parse_array_expr
      parse_record_expr state
  with exn -> raise_parse_error "特殊关键字表达式" token exn state

(** 解析基础表达式 - 重构后的统一入口函数 *)
let rec parse_primary_expr parse_expr parse_array_expr parse_record_expr state =
  let state = Parser_expressions_utils.skip_newlines state in
  let token, pos = current_token state in

  match token with
  | _ when is_literal_token token -> parse_literal_expr_safe token state
  | _ when Parser_expressions_identifiers.is_identifier_token token -> Parser_expressions_identifiers.parse_identifier_expr_safe parse_expr token state
  | _ when Parser_expressions_identifiers.is_type_keyword_token token -> Parser_expressions_identifiers.parse_type_keyword_expr_safe token state
  | _ when is_container_token token ->
      parse_container_expr_safe parse_expr parse_array_expr parse_record_expr
        token state
  | TagKeyword -> (
      try
        parse_tag_expr
          (parse_primary_expr parse_expr parse_array_expr parse_record_expr)
          state
      with exn -> raise_parse_error "标签表达式" token exn state)
  | _ when is_special_keyword_token token ->
      parse_special_keyword_expr_safe parse_expr parse_array_expr
        parse_record_expr token state
  | _ -> handle_unsupported_syntax token pos

(** ==================== 向后兼容性函数 ==================== *)

(** 简化的基本表达式解析器 - 仅用于函数参数 - 委派给字面量解析模块 *)
let parse_basic_argument_expr state = Parser_expressions_literals.parse_basic_argument_expr state

(** 向后兼容：解析函数调用或变量 - 委派给函数调用解析模块 *)
let parse_function_call_or_variable name state =
  Parser_expressions_calls.parse_function_call_or_variable parse_basic_argument_expr name state
