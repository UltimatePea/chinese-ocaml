(** 骆言编译器Unicode字符处理常量模块 - 性能优化版本
    
    本模块在统一版本基础上增加了性能优化：
    - 使用哈希表进行O(1)字符查找
    - 缓存JSON数据加载
    - 优化字符检查函数
    
    @version 1.1 - Phase 2: 性能优化（哈希表查找）
    @since 2025-07-25
*)

include Unicode_constants_unified

(** 性能优化模块 - 使用哈希表提升查找效率 *)
module OptimizedLookup = struct
  (** 字符名称到字符的哈希表 *)
  let name_to_char_table = 
    let tbl = Hashtbl.create 64 in
    List.iter (fun def -> 
      Hashtbl.add tbl def.name def.char
    ) UnifiedCharDefinitions.all_char_definitions;
    tbl
  
  (** 字符到字节三元组的哈希表 *)
  let char_to_bytes_table =
    let tbl = Hashtbl.create 64 in  
    List.iter (fun def ->
      Hashtbl.add tbl def.char def.bytes
    ) UnifiedCharDefinitions.all_char_definitions;
    tbl
  
  (** 字符名称到字节三元组的哈希表 *)
  let name_to_bytes_table = 
    let tbl = Hashtbl.create 64 in
    List.iter (fun def ->
      Hashtbl.add tbl def.name def.bytes
    ) UnifiedCharDefinitions.all_char_definitions;
    tbl
  
  (** 类别到字符定义列表的哈希表 *)
  let category_to_definitions_table =
    let tbl = Hashtbl.create 16 in
    let categories = ["punctuation"; "symbol"; "poetry"; "quote"] in
    List.iter (fun category ->
      let defs = List.filter (fun def -> def.category = category) 
                             UnifiedCharDefinitions.all_char_definitions in
      Hashtbl.add tbl category defs
    ) categories;
    tbl
  
  (** O(1)查找：根据字符名称查找字符 *)
  let find_char_by_name_fast name = 
    try Some (Hashtbl.find name_to_char_table name)
    with Not_found -> None
  
  (** O(1)查找：根据字符查找字节三元组 *)
  let find_bytes_by_char_fast char_str =
    try Some (Hashtbl.find char_to_bytes_table char_str) 
    with Not_found -> None
  
  (** O(1)查找：根据字符名称查找字节三元组 *)
  let find_bytes_by_name_fast name =
    try Some (Hashtbl.find name_to_bytes_table name)
    with Not_found -> None
  
  (** O(1)查找：根据类别查找字符定义列表 *)
  let find_definitions_by_category_fast category =
    try Some (Hashtbl.find category_to_definitions_table category)
    with Not_found -> None
  
  (** 获取所有已知字符名称 *)
  let get_all_char_names () =
    Hashtbl.fold (fun name _ acc -> name :: acc) name_to_char_table []
  
  (** 获取所有已知字符 *)
  let get_all_chars () =
    Hashtbl.fold (fun _ char acc -> char :: acc) name_to_char_table []
  
  (** 获取所有类别 *)
  let get_all_categories () =
    Hashtbl.fold (fun category _ acc -> category :: acc) category_to_definitions_table []
end

(** 缓存数据加载模块 *)
module CachedData = struct
  (** 延迟加载的字符定义数据 *)
  let cached_char_definitions = lazy UnifiedCharDefinitions.all_char_definitions
  
  (** 延迟加载的优化查找表 *)
  let cached_lookup_tables = lazy (
    OptimizedLookup.name_to_char_table,
    OptimizedLookup.char_to_bytes_table,
    OptimizedLookup.name_to_bytes_table,
    OptimizedLookup.category_to_definitions_table
  )
  
  (** 获取缓存的字符定义 *)
  let get_char_definitions () = Lazy.force cached_char_definitions
  
  (** 获取缓存的查找表 *)
  let get_lookup_tables () = Lazy.force cached_lookup_tables
  
  (** 预热缓存 - 强制初始化所有懒惰值 *)
  let warm_cache () =
    ignore (get_char_definitions ());
    ignore (get_lookup_tables ());
    ()
end

(** 快速字符检查函数 *)
module FastChecks = struct
  (** 字符字节的第一个字节集合 - 用于快速过滤 *)
  let chinese_punctuation_first_bytes = [0xE3; 0xEF; 0xE2]
  
  (** 快速检查是否可能是中文标点符号（基于第一个字节） *)
  let is_likely_chinese_punctuation first_byte =
    List.mem first_byte chinese_punctuation_first_bytes
  
  (** 快速检查字节三元组是否为已知的中文字符 *)
  let is_known_chinese_char_bytes (b1, b2, b3) =
    let char_found = ref false in
    Hashtbl.iter (fun _ bytes ->
      if bytes = (b1, b2, b3) then char_found := true
    ) OptimizedLookup.char_to_bytes_table;
    !char_found
  
  (** 快速检查字符串是否为已知的中文字符 *)
  let is_known_chinese_char char_str =
    Hashtbl.mem OptimizedLookup.char_to_bytes_table char_str
  
  (** 快速批量检查字符列表 *)
  let check_char_list chars =
    List.map (fun char_str -> 
      (char_str, is_known_chinese_char char_str)
    ) chars
end

(** 统计和分析模块 *)
module Statistics = struct
  (** 获取字符定义统计信息 *)
  let get_char_statistics () =
    let total = List.length UnifiedCharDefinitions.all_char_definitions in
    let by_category = Hashtbl.create 8 in
    List.iter (fun def ->
      let count = try Hashtbl.find by_category def.category with Not_found -> 0 in
      Hashtbl.replace by_category def.category (count + 1)
    ) UnifiedCharDefinitions.all_char_definitions;
    (total, by_category)
  
  (** 打印统计信息 *)
  let print_statistics () =
    let (total, by_category) = get_char_statistics () in
    Printf.printf "=== Unicode字符定义统计 ===\n";
    Printf.printf "总字符数: %d\n" total;
    Printf.printf "按类别分布:\n";
    Hashtbl.iter (fun category count ->
      Printf.printf "  %s: %d个字符\n" category count
    ) by_category;
    Printf.printf "========================\n"
  
  (** 获取查找表性能信息 *)
  let get_lookup_performance_info () =
    let name_to_char_size = Hashtbl.length OptimizedLookup.name_to_char_table in
    let char_to_bytes_size = Hashtbl.length OptimizedLookup.char_to_bytes_table in
    let name_to_bytes_size = Hashtbl.length OptimizedLookup.name_to_bytes_table in
    let category_to_defs_size = Hashtbl.length OptimizedLookup.category_to_definitions_table in
    (name_to_char_size, char_to_bytes_size, name_to_bytes_size, category_to_defs_size)
end

(** 高级API模块 - 提供更便捷的接口 *)
module AdvancedAPI = struct
  
  type exported_char_info = {
    name: string;
    char: string; 
    bytes: byte_triple;
    category: string;
    bytes_hex: string;
  }
  
  type smart_find_result = 
    [ `FoundByName of string * byte_triple option
    | `FoundByChar of string * byte_triple option ]
  
  (** 智能字符查找 - 自动判断输入类型 *)
  let smart_find input =
    (* 首先尝试作为字符名称查找 *)
    match OptimizedLookup.find_char_by_name_fast input with
    | Some char_str -> 
        let bytes = OptimizedLookup.find_bytes_by_char_fast char_str in
        Some (`FoundByName (char_str, bytes))
    | None ->
        (* 然后尝试作为字符查找 *)
        match OptimizedLookup.find_bytes_by_char_fast input with
        | Some bytes -> Some (`FoundByChar (input, Some bytes))
        | None -> None
  
  (** 批量字符查找 *)
  let batch_find inputs =
    List.map (fun input ->
      (input, smart_find input)
    ) inputs
  
  (** 按类别获取所有字符信息 *)
  let get_category_info category =
    match OptimizedLookup.find_definitions_by_category_fast category with
    | Some defs -> 
        let chars = List.map (fun (def : char_definition) -> def.char) defs in
        let names = List.map (fun (def : char_definition) -> def.name) defs in
        Some (chars, names, List.length defs)
    | None -> None
  
  (** 导出完整的字符映射表 *)
  let export_char_mapping () =
    let mapping = Hashtbl.create 64 in
    List.iter (fun (def : char_definition) ->
      let (b1, b2, b3) = def.bytes in
      let bytes_str = Printf.sprintf "0x%02X, 0x%02X, 0x%02X" b1 b2 b3 in
      Hashtbl.add mapping def.char {
        name = def.name;
        char = def.char;
        bytes = def.bytes;
        category = def.category;
        bytes_hex = bytes_str;
      }
    ) UnifiedCharDefinitions.all_char_definitions;
    mapping
end

(** 向后兼容的优化接口 *)
module OptimizedLegacyAPI = struct
  (** 替代原来的get_char_bytes_by_name，使用哈希表优化 *)
  let get_char_bytes_by_name name =
    match OptimizedLookup.find_bytes_by_name_fast name with
    | Some bytes -> bytes
    | None -> (0, 0, 0)
  
  (** 替代原来的get_char_bytes_by_char，使用哈希表优化 *)
  let get_char_bytes_by_char char_str =
    match OptimizedLookup.find_bytes_by_char_fast char_str with
    | Some bytes -> bytes  
    | None -> (0, 0, 0)
  
  (** 优化版的字符定义查找 *)
  let find_definition_by_char char_str =
    UnifiedCharDefinitions.find_by_char char_str
  
  (** 优化版的字符定义查找 *)
  let find_definition_by_name name =
    UnifiedCharDefinitions.find_by_name name
end

(** 初始化模块 - 在模块加载时进行必要的初始化 *)
let () = 
  (* 预热缓存以提升首次访问性能 *)
  CachedData.warm_cache ();