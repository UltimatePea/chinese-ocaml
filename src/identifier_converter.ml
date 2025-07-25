(** 标识符Token转换模块
 *
 *  从token_conversion_core.ml重构而来，专门处理标识符相关的Token转换
 *  
 *  @author 骆言技术债务清理团队 Issue #1276
 *  @version 2.0
 *  @since 2025-07-25 *)

open Lexer_tokens

(** 异常定义 *)
exception Unknown_identifier_token of string

(** 转换标识符tokens *)
let convert_identifier_token = function
  | Token_mapping.Token_definitions_unified.QuotedIdentifierToken s -> QuotedIdentifierToken s
  | Token_mapping.Token_definitions_unified.IdentifierTokenSpecial s -> IdentifierTokenSpecial s
  | token -> 
      let error_msg = "不是标识符token: " ^ (Obj.tag (Obj.repr token) |> string_of_int) in
      raise (Unknown_identifier_token error_msg)