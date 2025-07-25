(** Token转换器注册和调度模块
 *
 *  从token_conversion_core.ml重构而来，提供统一的Token转换调度服务
 *  
 *  @author 骆言技术债务清理团队 Issue #1276
 *  @version 2.0
 *  @since 2025-07-25 *)

open Lexer_tokens

(** 聚合所有转换器的异常 *)
exception Token_conversion_failed of string

(** 统一的Token转换接口 - 尝试所有转换类型 *)
let convert_token token =
  try Some (Identifier_converter.convert_identifier_token token)
  with Identifier_converter.Unknown_identifier_token _ -> (
    try Some (Literal_converter.convert_literal_token token) 
    with Literal_converter.Unknown_literal_token _ -> (
      try Some (Keyword_converter.convert_basic_keyword_token token)
      with Keyword_converter.Unknown_basic_keyword_token _ -> (
        try Some (Keyword_converter.convert_type_keyword_token token)
        with Keyword_converter.Unknown_type_keyword_token _ -> (
          try Some (Classical_converter.convert_classical_token token)
          with Classical_converter.Unknown_classical_token _ -> None))))

(** 批量转换Token列表 *)
let convert_token_list tokens =
  List.map (fun token ->
    match convert_token token with
    | Some converted -> converted
    | None -> 
        let error_msg = "无法转换token: " ^ (Obj.tag (Obj.repr token) |> string_of_int) in
        raise (Token_conversion_failed error_msg)
  ) tokens

(** 转换统计信息 *)
let get_conversion_stats () =
  let identifiers_count = 2 in
  let literals_count = 5 in  
  let basic_keywords_count = 122 in
  let type_keywords_count = 13 in
  let classical_count = 95 in
  let total_count = identifiers_count + literals_count + basic_keywords_count + type_keywords_count + classical_count in
  Printf.sprintf "Token转换模块化统计: 标识符(%d) + 字面量(%d) + 基础关键字(%d) + 类型关键字(%d) + 古典语言(%d) = 总计(%d)个转换规则"
    identifiers_count literals_count basic_keywords_count type_keywords_count classical_count total_count