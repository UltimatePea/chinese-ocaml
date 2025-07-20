(** 字面量Token转换模块 *)

open Lexer_tokens

(** 转换字面量tokens *)
let convert_literal_token = function
  | Token_mapping.Token_definitions_unified.IntToken i -> IntToken i
  | Token_mapping.Token_definitions_unified.FloatToken f -> FloatToken f
  | Token_mapping.Token_definitions_unified.ChineseNumberToken s -> ChineseNumberToken s
  | Token_mapping.Token_definitions_unified.StringToken s -> StringToken s
  | Token_mapping.Token_definitions_unified.BoolToken b -> BoolToken b
  | _ -> raise (Failure "Not a literal token")
