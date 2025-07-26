(** 骆言Token系统整合重构 - 向后兼容性层接口 *)

open Yyocamlc_lib.Token_types

(** 兼容性别名模块 - 保持旧API可用 *)
module Compatibility : sig
  type legacy_token = token
  (** 旧版Token类型别名 *)

  type legacy_position = position
  type legacy_positioned_token = positioned_token

  val make_int_token : int -> token
  (** 旧版Token创建函数 *)

  val make_float_token : float -> token
  val make_string_token : string -> token
  val make_bool_token : bool -> token
  val make_chinese_number_token : string -> token
  val make_let_keyword : unit -> token
  val make_if_keyword : unit -> token
  val make_then_keyword : unit -> token
  val make_else_keyword : unit -> token
  val make_plus_op : unit -> token
  val make_minus_op : unit -> token
  val make_multiply_op : unit -> token
  val make_divide_op : unit -> token
  val make_assign_op : unit -> token
  val make_equal_op : unit -> token
  val make_left_paren : unit -> token
  val make_right_paren : unit -> token
  val make_left_bracket : unit -> token
  val make_right_bracket : unit -> token
  val make_comma : unit -> token
  val make_semicolon : unit -> token
  val make_quoted_identifier : string -> token
  val make_special_identifier : string -> token

  val make_position : int -> int -> string -> position
  (** 旧版位置和定位Token函数 *)

  val make_positioned_token : token -> position -> positioned_token

  val is_literal : token -> bool
  (** 旧版Token分类函数 *)

  val is_keyword : token -> bool
  val is_operator : token -> bool
  val is_delimiter : token -> bool
  val is_identifier : token -> bool
  val is_wenyan : token -> bool
  val is_natural_language : token -> bool
  val is_poetry : token -> bool
  val is_numeric_token : token -> bool
  val is_string_token : token -> bool
  val is_control_flow_token : token -> bool
  val is_binary_op_token : token -> bool
  val is_unary_op_token : token -> bool
  val is_left_delimiter_token : token -> bool
  val is_right_delimiter_token : token -> bool

  val token_to_string : token -> string
  (** 旧版Token转换函数 *)

  val position_to_string : position -> string
  val positioned_token_to_string : positioned_token -> string

  val equal_token : token -> token -> bool
  (** 旧版Token比较函数 *)

  val equal_position : position -> position -> bool
  val equal_positioned_token : positioned_token -> positioned_token -> bool

  val get_token_precedence : token -> int
  (** 旧版优先级函数 *)

  exception LexError of string * position
  (** 旧版异常 *)
end

(** 原有模块接口的兼容性包装 *)
module LiteralTokensCompat : sig
  type literal_token = Literals.literal_token

  val literal_token_to_string : literal_token -> string
  val is_numeric_literal : literal_token -> bool
  val is_string_literal : literal_token -> bool
end

module KeywordTokensCompat : sig
  type keyword_token = Keywords.keyword_token

  val keyword_token_to_string : keyword_token -> string
  val is_control_flow_keyword : keyword_token -> bool
end

module OperatorTokensCompat : sig
  type operator_token = Operators.operator_token

  val operator_token_to_string : operator_token -> string
  val is_binary_operator : operator_token -> bool
  val is_unary_operator : operator_token -> bool
  val get_operator_precedence : operator_token -> int
end

module DelimiterTokensCompat : sig
  type delimiter_token = Delimiters.delimiter_token

  val delimiter_token_to_string : delimiter_token -> string
  val is_left_delimiter : delimiter_token -> bool
  val is_right_delimiter : delimiter_token -> bool
end

module IdentifierTokensCompat : sig
  type identifier_token = Identifiers.identifier_token

  val identifier_token_to_string : identifier_token -> string
end

module WenyanTokensCompat : sig
  type wenyan_token = token

  val wenyan_token_to_string : wenyan_token -> string
end

module NaturalLanguageTokensCompat : sig
  type natural_language_token = natural_language_type

  val natural_language_token_to_string : natural_language_token -> string
end

module PoetryTokensCompat : sig
  type poetry_token = poetry_type

  val poetry_token_to_string : poetry_token -> string
end
