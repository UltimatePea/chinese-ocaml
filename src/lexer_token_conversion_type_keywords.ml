(** 类型关键字Token转换模块 *)

open Lexer_tokens

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
  | _ -> raise (Failure "Not a type keyword token")
