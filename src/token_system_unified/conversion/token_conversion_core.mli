(** Token转换核心模块接口 - Issue #1066 技术债务改进

    此模块整合了原先分散在多个文件中的Token转换逻辑，提供统一的转换接口。

    @author 骆言技术债务清理团队 Issue #1066
    @version 1.0
    @since 2025-07-24 *)

exception Unknown_identifier_token of string
(** 异常定义 *)

exception Unknown_literal_token of string
exception Unknown_basic_keyword_token of string
exception Unknown_type_keyword_token of string
exception Unknown_classical_token of string

val convert_identifier_token : Token_mapping.Token_definitions_unified.token -> Yyocamlc_lib.Lexer_tokens.token
(** 转换标识符tokens *)

val convert_literal_token : Token_mapping.Token_definitions_unified.token -> Yyocamlc_lib.Lexer_tokens.token
(** 转换字面量tokens *)

val convert_basic_keyword_token :
  Token_mapping.Token_definitions_unified.token -> Yyocamlc_lib.Lexer_tokens.token
(** 转换基础关键字tokens *)

val convert_type_keyword_token : Token_mapping.Token_definitions_unified.token -> Yyocamlc_lib.Lexer_tokens.token
(** 转换类型关键字tokens *)

val convert_wenyan_token : Token_mapping.Token_definitions_unified.token -> Yyocamlc_lib.Lexer_tokens.token
(** 转换文言文关键字tokens *)

val convert_natural_language_token :
  Token_mapping.Token_definitions_unified.token -> Yyocamlc_lib.Lexer_tokens.token
(** 转换自然语言关键字tokens *)

val convert_ancient_token : Token_mapping.Token_definitions_unified.token -> Yyocamlc_lib.Lexer_tokens.token
(** 转换古雅体关键字tokens *)

val convert_classical_token : Token_mapping.Token_definitions_unified.token -> Yyocamlc_lib.Lexer_tokens.token
(** 转换古典语言tokens - 主入口函数 *)

val convert_token : Token_mapping.Token_definitions_unified.token -> Yyocamlc_lib.Lexer_tokens.token option
(** 统一的Token转换接口 - 尝试所有转换类型 *)

val convert_token_list :
  Token_mapping.Token_definitions_unified.token list -> Yyocamlc_lib.Lexer_tokens.token list
(** 批量转换Token列表 *)

(** 向后兼容性保证 - 重新导出原有接口 *)
module Identifiers : sig
  val convert_identifier_token : Token_mapping.Token_definitions_unified.token -> Yyocamlc_lib.Lexer_tokens.token
end

module Literals : sig
  val convert_literal_token : Token_mapping.Token_definitions_unified.token -> Yyocamlc_lib.Lexer_tokens.token
end

module BasicKeywords : sig
  val convert_basic_keyword_token :
    Token_mapping.Token_definitions_unified.token -> Yyocamlc_lib.Lexer_tokens.token
end

module TypeKeywords : sig
  val convert_type_keyword_token :
    Token_mapping.Token_definitions_unified.token -> Yyocamlc_lib.Lexer_tokens.token
end

module Classical : sig
  val convert_wenyan_token : Token_mapping.Token_definitions_unified.token -> Yyocamlc_lib.Lexer_tokens.token

  val convert_natural_language_token :
    Token_mapping.Token_definitions_unified.token -> Yyocamlc_lib.Lexer_tokens.token

  val convert_ancient_token : Token_mapping.Token_definitions_unified.token -> Yyocamlc_lib.Lexer_tokens.token
  val convert_classical_token : Token_mapping.Token_definitions_unified.token -> Yyocamlc_lib.Lexer_tokens.token
end

val get_conversion_stats : unit -> string
(** 转换统计信息 *)
