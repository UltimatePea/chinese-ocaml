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

open Lexer
open Parser_utils

(** ==================== 字面量表达式解析 ==================== *)

(** 解析字面量表达式（整数、浮点数、字符串、布尔值） - 委派给字面量解析模块 *)
let parse_literal_expr state = Parser_expressions_literals.parse_literal_expr state

(** ==================== 标识符表达式解析 - 重构版本 ==================== *)

(* 标识符表达式解析已迁移到 Parser_expressions_identifiers 模块 *)

(** ==================== 关键字表达式解析 ==================== *)

(** 解析标签表达式 - 委派给运算符模块 *)
let parse_tag_expr = Parser_expressions_operators.parse_tag_expr

(* 类型关键字表达式解析已迁移到 Parser_expressions_identifiers 模块 *)

(** ==================== 复合表达式解析 ==================== *)

(** ==================== 诗词表达式解析 ==================== *)

(** 解析古典诗词表达式 - 委派给运算符模块 *)
let parse_poetry_expr = Parser_expressions_operators.parse_poetry_expr

(** ==================== 古雅体表达式解析 ==================== *)

(** 解析古雅体表达式 - 委派给运算符模块 *)
let parse_ancient_expr = Parser_expressions_operators.parse_ancient_expr

(** ==================== 主解析函数 - 重构版本 ==================== *)

(* 标识符和类型关键字表达式解析辅助函数已迁移到 Parser_expressions_identifiers 模块 *)

(* 解析容器表达式辅助函数 - 委派给运算符模块 *)
let parse_container_exprs = Parser_expressions_operators.parse_container_exprs

(* 解析特殊关键字表达式辅助函数 - 委派给运算符模块 *)
let parse_special_keyword_exprs = Parser_expressions_operators.parse_special_keyword_exprs

(* 处理错误情况和不支持的语法 *)
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

(** 匹配字面量类型tokens - 委派给字面量解析模块 *)
let is_literal_token = Parser_expressions_literals.is_literal_token

(* 标识符和类型关键字token检查函数已迁移到 Parser_expressions_identifiers 模块 *)

(** 匹配容器类型tokens - 委派给运算符模块 *)
let is_container_token = Parser_expressions_operators.is_container_token

(** 匹配特殊关键字tokens - 委派给运算符模块 *)
let is_special_keyword_token = Parser_expressions_operators.is_special_keyword_token

(** 统一的错误处理辅助函数 *)
let raise_parse_error expr_type token exn state =
  let error_msg =
    Unified_formatter.ErrorHandling.parse_failure_with_token expr_type (show_token token)
      (Printexc.to_string exn)
  in
  let _, pos = current_token state in
  raise (Parser_utils.make_unexpected_token_error error_msg pos)

(** 解析单个表达式类型 - 字面量 - 委派给字面量解析模块 *)
let parse_literal_expr_safe token state =
  Parser_expressions_literals.parse_literal_expr_safe token state

(* 安全标识符和类型关键字表达式解析函数已迁移到 Parser_expressions_identifiers 模块 *)

(** 解析单个表达式类型 - 容器 *)
let parse_container_expr_safe parse_expr parse_array_expr parse_record_expr token state =
  try parse_container_exprs parse_expr parse_array_expr parse_record_expr state
  with exn -> raise_parse_error "容器表达式" token exn state

(** 解析单个表达式类型 - 特殊关键字 *)
let parse_special_keyword_expr_safe parse_expr parse_array_expr parse_record_expr token state =
  try parse_special_keyword_exprs parse_expr parse_array_expr parse_record_expr state
  with exn -> raise_parse_error "特殊关键字表达式" token exn state

(** 解析基础表达式 - 重构后的统一入口函数 *)
let rec parse_primary_expr parse_expr parse_array_expr parse_record_expr state =
  let state = Parser_expressions_utils.skip_newlines state in
  let token, pos = current_token state in

  match token with
  | _ when is_literal_token token -> parse_literal_expr_safe token state
  | _ when Parser_expressions_identifiers.is_identifier_token token ->
      Parser_expressions_identifiers.parse_identifier_expr_safe parse_expr token state
  | _ when Parser_expressions_identifiers.is_type_keyword_token token ->
      Parser_expressions_identifiers.parse_type_keyword_expr_safe token state
  | _ when is_container_token token ->
      parse_container_expr_safe parse_expr parse_array_expr parse_record_expr token state
  | TagKeyword -> (
      try parse_tag_expr (parse_primary_expr parse_expr parse_array_expr parse_record_expr) state
      with exn -> raise_parse_error "标签表达式" token exn state)
  | _ when is_special_keyword_token token ->
      parse_special_keyword_expr_safe parse_expr parse_array_expr parse_record_expr token state
  | _ -> handle_unsupported_syntax token pos

(** ==================== 向后兼容性函数 ==================== *)

(** 简化的基本表达式解析器 - 仅用于函数参数 - 委派给字面量解析模块 *)
let parse_basic_argument_expr state = Parser_expressions_literals.parse_basic_argument_expr state

(** 向后兼容：解析函数调用或变量 - 委派给函数调用解析模块 *)
let parse_function_call_or_variable name state =
  Parser_expressions_calls.parse_function_call_or_variable parse_basic_argument_expr name state
