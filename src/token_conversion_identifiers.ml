(** Token转换 - 标识符专门模块
    
    从token_conversion_core.ml中提取的标识符转换逻辑，
    提升代码模块化和可维护性。
    
    @author 骆言技术债务清理团队 Issue #1256
    @version 1.0
    @since 2025-07-25 *)

open Lexer_tokens

(** 异常定义 *)
exception Unknown_identifier_token of string

(** 转换标识符tokens *)
let convert_identifier_token = function
  | Token_mapping.Token_definitions_unified.QuotedIdentifierToken s -> QuotedIdentifierToken s
  | Token_mapping.Token_definitions_unified.IdentifierTokenSpecial s -> IdentifierTokenSpecial s
  | _token -> 
      raise (Unknown_identifier_token "不是标识符token")

(** 检查是否为标识符token *)
let is_identifier_token = function
  | Token_mapping.Token_definitions_unified.QuotedIdentifierToken _
  | Token_mapping.Token_definitions_unified.IdentifierTokenSpecial _ -> true
  | _ -> false

(** 安全转换标识符token（返回Option类型） *)
let convert_identifier_token_safe token =
  try Some (convert_identifier_token token)
  with Unknown_identifier_token _ -> None