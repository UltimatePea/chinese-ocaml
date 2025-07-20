(** 标识符Token转换模块 *)

open Lexer_tokens

(** 转换标识符tokens *)
let convert_identifier_token = function
  | Token_mapping.Token_definitions_unified.QuotedIdentifierToken s -> QuotedIdentifierToken s
  | Token_mapping.Token_definitions_unified.IdentifierTokenSpecial s -> IdentifierTokenSpecial s
  | _ -> raise (Failure "Not an identifier token")
