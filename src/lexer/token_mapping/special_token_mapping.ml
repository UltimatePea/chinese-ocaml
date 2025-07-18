(** 特殊Token映射模块 *)

open Token_definitions

(** 映射特殊关键字变体到Token *)
let map_special_variant = function
  (* Special keywords *)
  | `IdentifierTokenSpecial -> IdentifierTokenSpecial "数值"
  | _ -> failwith "Unknown special keyword variant"