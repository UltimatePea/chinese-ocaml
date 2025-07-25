(** Unicode字符映射和查找功能 - 性能优化版本 *)

open Unicode_types

(** 简单LRU缓存实现 *)
module LRUCache = struct
  type 'a t = {
    mutable data: (string, 'a) Hashtbl.t;
    mutable access_order: string Queue.t;
    max_size: int;
  }

  let create size = {
    data = Hashtbl.create size;
    access_order = Queue.create ();
    max_size = size;
  }

  [@@@warning "-32"] (* 禁用未使用值警告 - 这些是内部工具函数 *)
  let get cache key =
    match Hashtbl.find_opt cache.data key with
    | Some value ->
        (* 更新访问顺序 - 简化版本，不维护完整LRU *)
        Some value
    | None -> None

  let put cache key value =
    if Hashtbl.length cache.data >= cache.max_size then (
      (* 简单清理策略：当达到容量时清理一半 *)
      let keys_to_remove = ref [] in
      let count = ref 0 in
      Hashtbl.iter (fun k _ -> 
        if !count < cache.max_size / 2 then (
          keys_to_remove := k :: !keys_to_remove;
          incr count
        )
      ) cache.data;
      List.iter (Hashtbl.remove cache.data) !keys_to_remove
    );
    Hashtbl.replace cache.data key value
  [@@@warning "+32"] (* 恢复未使用值警告 *)
end

(** 字符映射表管理模块 - 哈希表优化版 *)
module CharMap = struct
  (* 使用懒初始化的哈希表替代关联列表 *)
  let name_to_char_tbl = lazy (
    let tbl = Hashtbl.create 1024 in
    List.iter (fun def -> Hashtbl.replace tbl def.name def.char) char_definitions;
    tbl
  )

  let name_to_triple_tbl = lazy (
    let tbl = Hashtbl.create 1024 in
    List.iter (fun def -> Hashtbl.replace tbl def.name def.triple) char_definitions;
    tbl
  )

  let char_to_triple_tbl = lazy (
    let tbl = Hashtbl.create 1024 in
    List.iter (fun def -> Hashtbl.replace tbl def.char def.triple) char_definitions;
    tbl
  )

  (* 字符分类缓存 *)
  let category_cache = LRUCache.create 256

  (* 保持向后兼容的关联列表接口（标记为已弃用） *)
  [@@@warning "-3"] (* 禁用弃用警告 *)
  let name_to_char_map =
    List.fold_left (fun acc def -> (def.name, def.char) :: acc) [] char_definitions

  let name_to_triple_map =
    List.fold_left (fun acc def -> (def.name, def.triple) :: acc) [] char_definitions

  let char_to_triple_map =
    List.fold_left (fun acc def -> (def.char, def.triple) :: acc) [] char_definitions
  [@@@warning "+3"] (* 恢复弃用警告 *)

  (* 新的高性能查找函数 *)
  let find_char_by_name name =
    Hashtbl.find_opt (Lazy.force name_to_char_tbl) name

  let find_triple_by_name name =
    Hashtbl.find_opt (Lazy.force name_to_triple_tbl) name

  let find_triple_by_char char_str =
    Hashtbl.find_opt (Lazy.force char_to_triple_tbl) char_str
end

(** Legacy兼容性查找模块 - 性能优化版 *)
module Legacy = struct
  (* 分类过滤缓存 *)
  let category_filter_cache = Hashtbl.create 64

  (** 过滤指定类别的字符 - 缓存优化版 *)
  let filter_by_category category =
    match Hashtbl.find_opt category_filter_cache category with
    | Some cached_result -> cached_result
    | None ->
        let result = List.filter (fun def -> def.category = category) char_definitions in
        Hashtbl.replace category_filter_cache category result;
        result

  (** 获取指定类别的字符列表 *)
  let get_chars_by_category category = 
    List.map (fun def -> def.char) (filter_by_category category)

  (** 获取指定类别的字符名称列表 *)
  let get_names_by_category category = 
    List.map (fun def -> def.name) (filter_by_category category)

  (** 查找字符对应的UTF-8三元组 - 优化版 *)
  let find_triple_by_char char_str =
    CharMap.find_triple_by_char char_str

  (** 查找名称对应的字符 - 优化版 *)
  let find_char_by_name name =
    CharMap.find_char_by_name name

  (** 获取字符的字节组合 - 向后兼容函数，性能优化版 *)
  let get_char_bytes char_name =
    match find_char_by_name char_name with
    | Some char_str -> (
        match find_triple_by_char char_str with
        | Some triple -> (triple.byte1, triple.byte2, triple.byte3)
        | None -> (0, 0, 0))
    | None -> (0, 0, 0)

  (* 字符分类缓存表 *)
  let char_category_cache = Hashtbl.create 512

  (** 检查字符是否属于指定类别 - 缓存优化版 *)
  let is_char_category char_str category =
    let cache_key = char_str ^ "|" ^ category in
    match Hashtbl.find_opt char_category_cache cache_key with
    | Some cached_result -> cached_result
    | None ->
        let result = 
          try
            let def = List.find (fun d -> d.char = char_str) char_definitions in
            def.category = category
          with Not_found -> false
        in
        Hashtbl.replace char_category_cache cache_key result;
        result
end

(** 性能优化版本的新增高级查找模块 *)
module Optimized = struct
  (** 批量字符查找 - 利用哈希表的高效性 *)
  let batch_find_chars_by_names names =
    let tbl = Lazy.force CharMap.name_to_char_tbl in
    List.filter_map (fun name -> 
      match Hashtbl.find_opt tbl name with
      | Some char -> Some (name, char)
      | None -> None
    ) names

  type mapping_stats = {
    total_definitions: int;
    hash_table_size: int;
    cache_size: int;
  }

  (** 字符统计信息 - 用于性能分析 *)
  let get_mapping_stats () = {
    total_definitions = List.length char_definitions;
    hash_table_size = Hashtbl.length (Lazy.force CharMap.name_to_char_tbl);
    cache_size = Hashtbl.length CharMap.category_cache.data;
  }
end

(** 性能监控和调试模块 *)
module Performance = struct
  let query_count = ref 0
  let cache_hits = ref 0
  let cache_misses = ref 0

  let increment_query () = incr query_count
  let increment_cache_hit () = incr cache_hits
  let increment_cache_miss () = incr cache_misses

  type perf_stats = {
    total_queries: int;
    cache_hit_rate: float;
    cache_hits: int;
    cache_misses: int;
  }

  let get_stats () = {
    total_queries = !query_count;
    cache_hit_rate = if !query_count = 0 then 0.0 else (float !cache_hits) /. (float !query_count);
    cache_hits = !cache_hits;
    cache_misses = !cache_misses;
  }

  let reset_stats () =
    query_count := 0;
    cache_hits := 0;
    cache_misses := 0
end
