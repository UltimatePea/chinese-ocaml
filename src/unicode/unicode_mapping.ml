(** Unicode字符映射和查找功能 *)

open Unicode_types

(** 字符映射表管理模块 *)
module CharMap = struct
  let name_to_char_map =
    List.fold_left (fun acc def -> (def.name, def.char) :: acc) [] char_definitions

  let name_to_triple_map =
    List.fold_left (fun acc def -> (def.name, def.triple) :: acc) [] char_definitions

  let char_to_triple_map =
    List.fold_left (fun acc def -> (def.char, def.triple) :: acc) [] char_definitions
end

(** Legacy兼容性查找模块 *)
module Legacy = struct
  (** 过滤指定类别的字符 *)
  let filter_by_category category =
    List.filter (fun def -> def.category = category) char_definitions

  (** 获取指定类别的字符列表 *)
  let get_chars_by_category category = List.map (fun def -> def.char) (filter_by_category category)

  (** 获取指定类别的字符名称列表 *)
  let get_names_by_category category = List.map (fun def -> def.name) (filter_by_category category)

  (** 查找字符对应的UTF-8三元组 *)
  let find_triple_by_char char_str =
    try Some (List.assoc char_str CharMap.char_to_triple_map) with Not_found -> None

  (** 查找名称对应的字符 *)
  let find_char_by_name name =
    try Some (List.assoc name CharMap.name_to_char_map) with Not_found -> None

  (** 获取字符的字节组合 - 向后兼容函数 *)
  let get_char_bytes char_name =
    match find_char_by_name char_name with
    | Some char_str -> (
        match find_triple_by_char char_str with
        | Some triple -> (triple.byte1, triple.byte2, triple.byte3)
        | None -> (0, 0, 0))
    | None -> (0, 0, 0)

  (** 检查字符是否属于指定类别 - 向后兼容函数 *)
  let is_char_category char_str category =
    try
      let def = List.find (fun d -> d.char = char_str) char_definitions in
      def.category = category
    with Not_found -> false
end
