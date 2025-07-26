(** Token分类检查模块接口 *)

open Token_types
open Token_errors

val is_literal_token : token -> bool
(** 检查是否为字面量token *)

val is_identifier_token : token -> bool
(** 检查是否为标识符token *)

val is_keyword_token : token -> bool
(** 检查是否为任何类型的关键字token *)

val is_operator_token : token -> bool
(** 检查是否为运算符token *)

val is_delimiter_token : token -> bool
(** 检查是否为分隔符token *)

val is_special_token : token -> bool
(** 检查是否为特殊token *)

val get_token_category_safe : token -> token_category token_result
(** 获取Token分类（安全版本，返回Result类型） *)

val get_token_category : token -> token_category
(** 获取Token分类 *)
