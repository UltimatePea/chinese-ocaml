(** 类型关键字Token映射模块 *)

open Token_definitions

(** 映射类型关键字变体到Token *)
let map_type_variant = function
  | `TypeKeyword -> TypeKeyword
  | `PrivateKeyword -> PrivateKeyword
  (* Type annotation keywords *)
  | `InputKeyword -> InputKeyword
  | `OutputKeyword -> OutputKeyword
  | `IntTypeKeyword -> IntTypeKeyword
  | `FloatTypeKeyword -> FloatTypeKeyword
  | `StringTypeKeyword -> StringTypeKeyword
  | `BoolTypeKeyword -> BoolTypeKeyword
  | `UnitTypeKeyword -> UnitTypeKeyword
  | `ListTypeKeyword -> ListTypeKeyword
  | `ArrayTypeKeyword -> ArrayTypeKeyword
  (* Variant keywords *)
  | `VariantKeyword -> VariantKeyword
  | `TagKeyword -> TagKeyword
  | _ -> failwith "Unknown type keyword variant"
