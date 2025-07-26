(** Token调度核心模块
 *
 *  从token_conversion_core.ml重构而来，提供向后兼容性和统一的调度接口
 *  
 *  @author 骆言技术债务清理团队 Issue #1276
 *  @version 2.0
 *  @since 2025-07-25 *)

open Token_system_unified_core.Token_types

(** 向后兼容性保证 - 重新导出原有接口 *)

(** 标识符转换模块向后兼容接口 *)
module Identifiers = struct
  (* Simplified wrapper for backward compatibility *)
  let convert_identifier_token token =
    match token with IdentifierToken _ -> Some token | _ -> None
end

(** 字面量转换模块向后兼容接口 *)
module Literals = struct
  let convert_literal_token = Yyocamlc_lib.Literal_converter.convert_literal_token
end

(** 基础关键字转换模块向后兼容接口 *)
module BasicKeywords = struct
  let convert_basic_keyword_token token =
    let token_str =
      match token with Yyocamlc_lib.Unified_token_core.IdentifierToken s -> s | _ -> ""
    in
    Yyocamlc_lib.Token_compatibility_unified.map_basic_keywords token_str
end

(** 类型关键字转换模块向后兼容接口 *)
module TypeKeywords = struct
  let convert_type_keyword_token token =
    let token_str =
      match token with Yyocamlc_lib.Unified_token_core.IdentifierToken s -> s | _ -> ""
    in
    Yyocamlc_lib.Token_compatibility_unified.map_type_keywords token_str
end

(** 古典语言转换模块向后兼容接口 *)
module Classical = struct
  let convert_wenyan_token token =
    let token_str =
      match token with Yyocamlc_lib.Unified_token_core.IdentifierToken s -> s | _ -> ""
    in
    Yyocamlc_lib.Token_compatibility_unified.map_wenyan_keywords token_str

  let convert_natural_language_token token =
    let token_str =
      match token with Yyocamlc_lib.Unified_token_core.IdentifierToken s -> s | _ -> ""
    in
    Yyocamlc_lib.Token_compatibility_unified.map_natural_language_keywords token_str

  let convert_ancient_token token =
    let token_str =
      match token with Yyocamlc_lib.Unified_token_core.IdentifierToken s -> s | _ -> ""
    in
    Yyocamlc_lib.Token_compatibility_unified.map_classical_keywords token_str

  let convert_classical_token token =
    let token_str =
      match token with Yyocamlc_lib.Unified_token_core.IdentifierToken s -> s | _ -> ""
    in
    Yyocamlc_lib.Token_compatibility_unified.map_classical_keywords token_str
end

(** 主要转换接口 - 通过注册器提供 *)
let convert_token = fun _token -> failwith "Conversion_registry access needs to be fixed"

let convert_token_list = fun _tokens -> failwith "Conversion_registry access needs to be fixed"
let get_conversion_stats = fun () -> failwith "Conversion_registry access needs to be fixed"

exception Unknown_identifier_token of string
(** 向后兼容的异常导出 *)

exception Unknown_literal_token of string
exception Unknown_basic_keyword_token of string
exception Unknown_type_keyword_token of string
exception Unknown_classical_token of string
