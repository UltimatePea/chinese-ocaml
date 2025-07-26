(** Token分类检查模块 - 从unified_token_core.ml重构而来 第五阶段系统一致性优化：统一错误处理系统，替换failwith为统一错误处理。

    @version 2.1 (错误处理统一化版)
    @since 2025-07-20 Issue #718 系统一致性优化 *)

open Token_types
open Token_errors

let is_literal_token = function
  | LiteralToken _ -> true
  | _ -> false

let is_identifier_token = function
  | IdentifierToken _ -> true
  | _ -> false

let is_keyword_token = function
  | KeywordToken _ -> true
  | _ -> false

let is_operator_token = function
  | OperatorToken _ -> true
  | _ -> false

let is_delimiter_token = function
  | DelimiterToken _ -> true
  | _ -> false

let is_special_token = function
  | SpecialToken _ -> true
  | _ -> false

(** 获取Token分类（安全版本，返回Result类型） *)
let get_token_category_safe token =
  if is_literal_token token then ok_result LiteralCategory
  else if is_identifier_token token then ok_result IdentifierCategory
  else if is_keyword_token token then ok_result KeywordCategory
  else if is_operator_token token then ok_result OperatorCategory
  else if is_delimiter_token token then ok_result DelimiterCategory
  else if is_special_token token then ok_result SpecialCategory
  else error_result (UnknownToken ("Unknown token category", None))

(** 获取Token分类（兼容性版本） *)
let get_token_category token =
  match get_token_category_safe token with
  | Ok category -> category
  | Error _ -> (* 默认返回SpecialCategory作为未知类型 *) SpecialCategory
