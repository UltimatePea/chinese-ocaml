(** 特殊Token映射模块 - 使用统一token定义 *)

open Token_definitions_unified

(** 映射特殊关键字变体到Token - 保持原有逻辑，因为此模块需要特殊处理 *)
let map_special_variant = function
  (* Special keywords *)
  | `IdentifierTokenSpecial -> IdentifierTokenSpecial "数值"
  | _ -> raise (Invalid_argument "Unknown special keyword variant")
