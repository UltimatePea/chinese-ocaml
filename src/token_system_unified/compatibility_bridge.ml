(** 兼容性桥接模块 - 为统一Token系统提供向后兼容的模块别名 *)

(* 重新导出核心模块以提供兼容性 *)
module Tokens_core = struct
  module Token_types = Token_types
end

module Token_system_core = struct
  module Token_types = Token_types
end

module Token_mapping = struct
  (* 使用 lexer/token_mapping 下的模块 *)
  include Lexer.Token_mapping.Token_definitions_unified
  module Token_definitions_unified = Lexer.Token_mapping.Token_definitions_unified
end

module Lexer_tokens = Lexer_tokens

module Utils = struct
  include Utils.Base_formatter
  module Base_formatter = Utils.Base_formatter
end

module Unified_formatter = Unified_formatter