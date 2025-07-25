(** Token转换 - 字面量专门模块
    
    从token_conversion_core.ml中提取的字面量转换逻辑，
    提升代码模块化和可维护性。
    
    @author 骆言技术债务清理团队 Issue #1256
    @version 1.0
    @since 2025-07-25 *)

open Lexer_tokens

(** 异常定义 *)
exception Unknown_literal_token of string

(** 转换字面量tokens *)
let convert_literal_token = function
  | Token_mapping.Token_definitions_unified.IntToken i -> IntToken i
  | Token_mapping.Token_definitions_unified.FloatToken f -> FloatToken f
  | Token_mapping.Token_definitions_unified.ChineseNumberToken s -> ChineseNumberToken s
  | Token_mapping.Token_definitions_unified.StringToken s -> StringToken s
  | Token_mapping.Token_definitions_unified.BoolToken b -> BoolToken b
  | token -> 
      let error_msg = "不是字面量token: " ^ (Obj.tag (Obj.repr token) |> string_of_int) in
      raise (Unknown_literal_token error_msg)

(** 检查是否为字面量token *)
let is_literal_token = function
  | Token_mapping.Token_definitions_unified.IntToken _
  | Token_mapping.Token_definitions_unified.FloatToken _
  | Token_mapping.Token_definitions_unified.ChineseNumberToken _
  | Token_mapping.Token_definitions_unified.StringToken _
  | Token_mapping.Token_definitions_unified.BoolToken _ -> true
  | _ -> false

(** 安全转换字面量token（返回Option类型） *)
let convert_literal_token_safe token =
  try Some (convert_literal_token token)
  with Unknown_literal_token _ -> None