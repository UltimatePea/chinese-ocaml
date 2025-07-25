(** 字面量Token转换模块
 *
 *  从token_conversion_core.ml重构而来，专门处理字面量相关的Token转换
 *  
 *  @author 骆言技术债务清理团队 Issue #1276
 *  @version 2.0
 *  @since 2025-07-25 *)

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