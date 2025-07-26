(** Token转换 - 类型关键字专门模块

    从token_conversion_core.ml中提取的类型关键字转换逻辑， 提升代码模块化和可维护性。

    @author 骆言技术债务清理团队 Issue #1256
    @version 1.0
    @since 2025-07-25 *)

open Lexer_tokens

exception Unknown_type_keyword_token of string
(** 异常定义 *)

(** 转换类型关键字tokens *)
let convert_type_keyword_token = function
  (* 类型关键字 *)
  | Token_mapping.Token_definitions_unified.TypeKeyword -> TypeKeyword
  | Token_mapping.Token_definitions_unified.PrivateKeyword -> PrivateKeyword
  | Token_mapping.Token_definitions_unified.InputKeyword -> InputKeyword
  | Token_mapping.Token_definitions_unified.OutputKeyword -> OutputKeyword
  | Token_mapping.Token_definitions_unified.IntTypeKeyword -> IntTypeKeyword
  | Token_mapping.Token_definitions_unified.FloatTypeKeyword -> FloatTypeKeyword
  | Token_mapping.Token_definitions_unified.StringTypeKeyword -> StringTypeKeyword
  | Token_mapping.Token_definitions_unified.BoolTypeKeyword -> BoolTypeKeyword
  | Token_mapping.Token_definitions_unified.UnitTypeKeyword -> UnitTypeKeyword
  | Token_mapping.Token_definitions_unified.ListTypeKeyword -> ListTypeKeyword
  | Token_mapping.Token_definitions_unified.ArrayTypeKeyword -> ArrayTypeKeyword
  | Token_mapping.Token_definitions_unified.VariantKeyword -> VariantKeyword
  | Token_mapping.Token_definitions_unified.TagKeyword -> TagKeyword
  | _token -> raise (Unknown_type_keyword_token "不是类型关键字token")

(** 检查是否为类型关键字token *)
let is_type_keyword_token token =
  try
    let _ = convert_type_keyword_token token in
    true
  with Unknown_type_keyword_token _ -> false

(** 安全转换类型关键字token（返回Option类型） *)
let convert_type_keyword_token_safe token =
  try Some (convert_type_keyword_token token) with Unknown_type_keyword_token _ -> None
