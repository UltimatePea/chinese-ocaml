(** 类型关键字Token映射模块 - 使用统一token定义 *)

open Token_definitions_unified

(** {1 类型关键字映射} *)

val map_type_variant :
  [> `TypeKeyword
  | `PrivateKeyword
  | `InputKeyword
  | `OutputKeyword
  | `IntTypeKeyword
  | `FloatTypeKeyword
  | `StringTypeKeyword
  | `BoolTypeKeyword
  | `UnitTypeKeyword
  | `ListTypeKeyword
  | `ArrayTypeKeyword
  | `VariantKeyword
  | `TagKeyword ] ->
  token
(** 映射类型关键字变体到Token *)
