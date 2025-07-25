(** 骆言词法分析器 - 向后兼容层 *)

(** 此模块提供与原始lexer_tokens.ml完全兼容的接口， 允许现有代码在不修改的情况下使用新的模块化token结构 *)

type token = Token_unified.token
(** 兼容的token类型定义，映射到新的统一token结构 *)

type position = Token_unified.position = { line : int; column : int; filename : string }
(** 兼容的位置信息类型 *)

type positioned_token = Token_unified.positioned_token
(** 兼容的带位置token类型 *)

exception LexError of string * position
(** 兼容的词法错误异常 *)

(** 原始lexer_tokens.ml中所有242个token的构造函数 *)

(* 字面量构造函数 *)
val int_token : int -> token
val float_token : float -> token
val chinese_number_token : string -> token
val string_token : string -> token
val bool_token : bool -> token

(* 标识符构造函数 *)
val quoted_identifier_token : string -> token
val identifier_token_special : string -> token

(* 核心关键字构造函数 *)
val let_keyword : token
val rec_keyword : token
val in_keyword : token
val fun_keyword : token
val param_keyword : token
val if_keyword : token
val then_keyword : token
val else_keyword : token
val match_keyword : token
val with_keyword : token
val other_keyword : token
val type_keyword : token
val private_keyword : token
val true_keyword : token
val false_keyword : token
val and_keyword : token
val or_keyword : token
val not_keyword : token
val as_keyword : token
val combine_keyword : token
val with_op_keyword : token
val when_keyword : token
val or_else_keyword : token
val with_default_keyword : token
val exception_keyword : token
val raise_keyword : token
val try_keyword : token
val catch_keyword : token
val finally_keyword : token
val of_keyword : token
val module_keyword : token
val module_type_keyword : token
val sig_keyword : token
val end_keyword : token
val functor_keyword : token
val ref_keyword : token
val include_keyword : token
val macro_keyword : token
val expand_keyword : token

(* 运算符构造函数 *)
val plus : token
val minus : token
val multiply : token
val star : token
val divide : token
val slash : token
val modulo : token
val concat : token
val assign : token
val equal : token
val not_equal : token
val less : token
val less_equal : token
val greater : token
val greater_equal : token
val arrow : token
val double_arrow : token
val dot : token
val double_dot : token
val triple_dot : token
val bang : token
val ref_assign : token

(* 分隔符构造函数 *)
val left_paren : token
val right_paren : token
val left_bracket : token
val right_bracket : token
val left_brace : token
val right_brace : token
val comma : token
val semicolon : token
val colon : token
val question_mark : token
val tilde : token
val pipe : token
val underscore : token
val left_array : token
val right_array : token
val assign_arrow : token
val left_quote : token
val right_quote : token
val newline : token
val eof : token

(* 中文标点构造函数 *)
val chinese_left_paren : token
val chinese_right_paren : token
val chinese_left_bracket : token
val chinese_right_bracket : token
val chinese_square_left_bracket : token
val chinese_square_right_bracket : token
val chinese_comma : token
val chinese_semicolon : token
val chinese_colon : token
val chinese_double_colon : token
val chinese_pipe : token
val chinese_left_array : token
val chinese_right_array : token
val chinese_arrow : token
val chinese_double_arrow : token
val chinese_assign_arrow : token

val to_legacy_string : token -> string
(** 转换函数：从新token结构转换为兼容表示 *)

val is_literal_token : token -> bool
(** 检查token类型的兼容函数 *)

val is_keyword_token : token -> bool
val is_operator_token : token -> bool
val is_delimiter_token : token -> bool

val show_token : token -> string
(** 向后兼容的show函数 *)

val show_position : position -> string
val show_positioned_token : positioned_token -> string
