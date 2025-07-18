(** 字面量Token转换模块 *)

open Lexer_tokens

(** 转换字面量tokens *)
let convert_literal_token = function
  | Token_mapping.Token_definitions.IntToken i -> IntToken i
  | Token_mapping.Token_definitions.FloatToken f -> FloatToken f
  | Token_mapping.Token_definitions.ChineseNumberToken s -> ChineseNumberToken s
  | Token_mapping.Token_definitions.StringToken s -> StringToken s
  | Token_mapping.Token_definitions.BoolToken b -> BoolToken b
  | _ -> failwith "Not a literal token"
