(** 骆言Token系统整合重构 - Token公共工具函数接口 *)

open Yyocamlc_lib.Token_types

(** Token创建工具 *)
module TokenCreator : sig
  val make_position : int -> int -> string -> position
  (** 创建位置信息 *)

  val make_positioned_token : token -> position -> positioned_token
  (** 创建带位置的Token *)

  val make_extended_token : token -> position -> string -> positioned_token * string
  (** 创建扩展Token（包含元数据） *)

  val make_int_token : int -> token
  (** 便利函数：创建字面量Token *)

  val make_float_token : float -> token
  val make_string_token : string -> token
  val make_bool_token : bool -> token
  val make_chinese_number_token : string -> token

  val make_let_keyword : unit -> token
  (** 便利函数：创建关键字Token *)

  val make_if_keyword : unit -> token
  val make_then_keyword : unit -> token
  val make_else_keyword : unit -> token

  val make_plus_op : unit -> token
  (** 便利函数：创建操作符Token *)

  val make_minus_op : unit -> token
  val make_multiply_op : unit -> token
  val make_divide_op : unit -> token
  val make_assign_op : unit -> token
  val make_equal_op : unit -> token

  val make_left_paren : unit -> token
  (** 便利函数：创建分隔符Token *)

  val make_right_paren : unit -> token
  val make_left_bracket : unit -> token
  val make_right_bracket : unit -> token
  val make_comma : unit -> token
  val make_semicolon : unit -> token

  val make_quoted_identifier : string -> token
  (** 便利函数：创建标识符Token *)

  val make_special_identifier : string -> token
end

(** Token分类工具 *)
module TokenClassifier : sig
  val is_keyword : token -> bool
  (** 检查Token是否为特定类型 *)

  val is_literal : token -> bool
  val is_operator : token -> bool
  val is_delimiter : token -> bool
  val is_identifier : token -> bool
  val is_special : token -> bool

  val get_token_category : token -> string
  (** 获取Token分类 *)

  val get_category_name : string -> string
  (** 获取Token分类名称 *)

  val is_numeric_token : token -> bool
  (** 特定类型判断函数 *)

  val is_string_token : token -> bool
  val is_control_flow_token : token -> bool
  val is_binary_op_token : token -> bool
  val is_unary_op_token : token -> bool
  val is_left_delimiter_token : token -> bool
  val is_right_delimiter_token : token -> bool
end

(** Token转换工具 *)
module TokenConverter : sig
  val token_to_string : token -> string
  (** Token转换为字符串 *)

  val position_to_string : position -> string
  (** 位置信息转换为字符串 *)

  val positioned_token_to_string : positioned_token -> string
  (** 带位置Token转换为字符串 *)
end

(** Token比较工具 *)
module TokenComparator : sig
  val equal_token : token -> token -> bool
  (** Token相等性比较 *)

  val equal_position : position -> position -> bool
  (** 位置相等性比较 *)

  val equal_positioned_token : positioned_token -> positioned_token -> bool
  (** 带位置Token相等性比较 *)

  val compare_precedence : token -> token -> int
  (** Token优先级比较 *)

  val compare_by_category : token -> token -> int
  (** 按类型比较Token *)
end

(** Token验证工具 *)
module TokenValidator : sig
  val is_valid_token : token -> bool
  (** 验证Token是否有效 *)

  val is_valid_position : position -> bool
  (** 验证位置信息是否有效 *)

  val is_valid_positioned_token : positioned_token -> bool
  (** 验证带位置Token是否有效 *)

  val validate_token_list : token list -> bool
  (** 验证Token列表是否有效 *)
end
