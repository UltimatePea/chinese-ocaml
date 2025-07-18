(** 类型关键字Token转换模块 *)

open Lexer_tokens

(** 转换类型关键字tokens *)
let convert_type_keyword_token = function
  (* 类型关键字 *)
  | Token_mapping.Token_definitions.TypeKeyword -> TypeKeyword
  | Token_mapping.Token_definitions.PrivateKeyword -> PrivateKeyword
  | Token_mapping.Token_definitions.InputKeyword -> InputKeyword
  | Token_mapping.Token_definitions.OutputKeyword -> OutputKeyword
  | Token_mapping.Token_definitions.IntTypeKeyword -> IntTypeKeyword
  | Token_mapping.Token_definitions.FloatTypeKeyword -> FloatTypeKeyword
  | Token_mapping.Token_definitions.StringTypeKeyword -> StringTypeKeyword
  | Token_mapping.Token_definitions.BoolTypeKeyword -> BoolTypeKeyword
  | Token_mapping.Token_definitions.UnitTypeKeyword -> UnitTypeKeyword
  | Token_mapping.Token_definitions.ListTypeKeyword -> ListTypeKeyword
  | Token_mapping.Token_definitions.ArrayTypeKeyword -> ArrayTypeKeyword
  | Token_mapping.Token_definitions.VariantKeyword -> VariantKeyword
  | Token_mapping.Token_definitions.TagKeyword -> TagKeyword
  | _ -> failwith "Not a type keyword token"
