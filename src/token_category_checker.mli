(** Token分类检查模块接口 *)

open Token_types_core

(** 检查是否为字面量token *)
val is_literal_token : unified_token -> bool

(** 检查是否为标识符token *)
val is_identifier_token : unified_token -> bool

(** 检查是否为基础关键字token *)
val is_basic_keyword_token : unified_token -> bool

(** 检查是否为数字关键字token *)
val is_number_keyword_token : unified_token -> bool

(** 检查是否为类型关键字token *)
val is_type_keyword_token : unified_token -> bool

(** 检查是否为文言文关键字token *)
val is_wenyan_keyword_token : unified_token -> bool

(** 检查是否为古雅体关键字token *)
val is_classical_keyword_token : unified_token -> bool

(** 检查是否为任何类型的关键字token *)
val is_keyword_token : unified_token -> bool

(** 检查是否为运算符token *)
val is_operator_token : unified_token -> bool

(** 检查是否为分隔符token *)
val is_delimiter_token : unified_token -> bool

(** 检查是否为特殊token *)
val is_special_token : unified_token -> bool

(** 获取Token分类 *)
val get_token_category : unified_token -> token_category