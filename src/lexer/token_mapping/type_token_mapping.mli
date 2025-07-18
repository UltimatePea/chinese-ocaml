(** 类型关键字Token映射模块 *)

open Token_definitions

(** 映射类型关键字变体到Token
    @param variant 类型关键字变体
    @return 对应的Token
    @raise Failure 如果遇到未知的类型关键字变体 *)
val map_type_variant : [> `TypeKeyword | `PrivateKeyword | `InputKeyword | `OutputKeyword | `IntTypeKeyword
                       | `FloatTypeKeyword | `StringTypeKeyword | `BoolTypeKeyword | `UnitTypeKeyword
                       | `ListTypeKeyword | `ArrayTypeKeyword | `VariantKeyword | `TagKeyword ] -> token