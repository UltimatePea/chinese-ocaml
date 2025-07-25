(** Token转换核心模块 - 重构版本接口 *)

open Lexer_tokens

(** 统一的token转换入口 - 使用Option类型优化性能 *)
val convert_token : Token_mapping.Token_definitions_unified.token -> Lexer_tokens.token option

(** 批量转换Token列表 *)
val convert_token_list : Token_mapping.Token_definitions_unified.token list -> Lexer_tokens.token list

(** 检查token类型 *)
val get_token_type : Token_mapping.Token_definitions_unified.token -> string

(** 转换统计信息 *)
module Statistics : sig
  val get_conversion_stats : unit -> string
end

(** 向后兼容性模块 - 保持原有接口 *)
module BackwardCompatibility : sig
  module Identifiers : sig
    val convert_identifier_token : Token_mapping.Token_definitions_unified.token -> Lexer_tokens.token
  end
  
  module Literals : sig
    val convert_literal_token : Token_mapping.Token_definitions_unified.token -> Lexer_tokens.token
  end
  
  module BasicKeywords : sig
    val convert_basic_keyword_token : Token_mapping.Token_definitions_unified.token -> Lexer_tokens.token
  end
  
  module TypeKeywords : sig
    val convert_type_keyword_token : Token_mapping.Token_definitions_unified.token -> Lexer_tokens.token
  end
  
  module Classical : sig
    val convert_wenyan_token : Token_mapping.Token_definitions_unified.token -> Lexer_tokens.token
    val convert_natural_language_token : Token_mapping.Token_definitions_unified.token -> Lexer_tokens.token
    val convert_ancient_token : Token_mapping.Token_definitions_unified.token -> Lexer_tokens.token
    val convert_classical_token : Token_mapping.Token_definitions_unified.token -> Lexer_tokens.token
  end
  
  val convert_token : Token_mapping.Token_definitions_unified.token -> Lexer_tokens.token option
  val convert_token_list : Token_mapping.Token_definitions_unified.token list -> Lexer_tokens.token list
end

(** 性能优化的快速路径转换 *)
module FastPath : sig
  val convert_identifier_fast : Token_mapping.Token_definitions_unified.token -> Lexer_tokens.token
  val convert_literal_fast : Token_mapping.Token_definitions_unified.token -> Lexer_tokens.token
  val convert_keyword_fast : Token_mapping.Token_definitions_unified.token -> Lexer_tokens.token
  val convert_type_fast : Token_mapping.Token_definitions_unified.token -> Lexer_tokens.token
  val convert_classical_fast : Token_mapping.Token_definitions_unified.token -> Lexer_tokens.token
end