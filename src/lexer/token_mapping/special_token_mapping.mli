(** 特殊Token映射模块 *)

open Token_definitions

val map_special_variant : [> `IdentifierTokenSpecial ] -> token
(** 映射特殊关键字变体到Token
    @param variant 特殊关键字变体
    @return 对应的Token
    @raise Failure 如果遇到未知的特殊关键字变体 *)
