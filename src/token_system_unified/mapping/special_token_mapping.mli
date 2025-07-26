(** 特殊Token映射模块 - 使用统一token定义 *)

open Token_definitions_unified

(** {1 特殊关键字映射} *)

val map_special_variant : [> `IdentifierTokenSpecial ] -> token
(** 映射特殊关键字变体到Token *)
