(** 韵律查询引擎
    
    高性能的韵律查询接口，提供O(1)查询能力和智能缓存系统。
    整合了原有的多个查询引擎模块，提供统一的查询API。
    
    Author: Whisky, PR Worker
    Issue: #1999 - Poetry韵律模块统一整合实施
    
    性能特性:
    - O(1) 字符查询通过哈希表实现
    - 智能LRU缓存系统
    - 批量查询优化
    - 模糊匹配支持
    
    @since 2025-08-03 *)

open Rhyme_types
open Rhyme_data

(** {1 缓存系统} *)

(** LRU缓存节点 *)
type 'a cache_node = {
  key: string;
  mutable value: 'a;
  mutable prev: 'a cache_node option;
  mutable next: 'a cache_node option;
}

(** LRU缓存结构 *)
type 'a lru_cache = {
  capacity: int;
  mutable size: int;
  table: (string, 'a cache_node) Hashtbl.t;
  mutable head: 'a cache_node option;
  mutable tail: 'a cache_node option;
}

(** 创建LRU缓存 *)
let create_lru_cache capacity =
  {
    capacity;
    size = 0;
    table = Hashtbl.create capacity;
    head = None;
    tail = None;
  }

(** 查询结果缓存 *)
let query_cache = create_lru_cache 1000

(** 韵组查询缓存 *)
let group_cache = create_lru_cache 100

(** 缓存操作函数 *)
let move_to_front cache node =
  match cache.head with
  | None -> 
      cache.head <- Some node;
      cache.tail <- Some node;
      node.prev <- None;
      node.next <- None
  | Some head ->
      if node != head then (
        (* 从当前位置移除 *)
        (match node.prev with
         | Some prev -> prev.next <- node.next
         | None -> ());
        (match node.next with
         | Some next -> next.prev <- node.prev
         | None -> cache.tail <- node.prev);
        
        (* 移到前面 *)
        node.prev <- None;
        node.next <- Some head;
        head.prev <- Some node;
        cache.head <- Some node
      )

let remove_tail cache =
  match cache.tail with
  | None -> ()
  | Some tail ->
      Hashtbl.remove cache.table tail.key;
      cache.size <- cache.size - 1;
      match tail.prev with
      | None -> 
          cache.head <- None;
          cache.tail <- None
      | Some prev ->
          prev.next <- None;
          cache.tail <- Some prev

let cache_put cache key value =
  match Hashtbl.find_opt cache.table key with
  | Some node ->
      node.value <- value;
      move_to_front cache node
  | None ->
      let node = { key; value; prev = None; next = None } in
      Hashtbl.replace cache.table key node;
      
      if cache.size >= cache.capacity then
        remove_tail cache;
      
      move_to_front cache node;
      cache.size <- cache.size + 1

let cache_get cache key =
  match Hashtbl.find_opt cache.table key with
  | Some node ->
      move_to_front cache node;
      Some node.value
  | None -> None

(** {1 高性能查询接口} *)

(** 带缓存的字符查询 *)
let query_character_cached char =
  match cache_get query_cache char with
  | Some result -> result
  | None ->
      let result = lookup_character char in
      cache_put query_cache char result;
      result

(** 带缓存的韵组查询 *)
let query_group_cached group =
  let group_str = string_of_rhyme_group group in
  match cache_get group_cache group_str with
  | Some result -> result
  | None ->
      let result = lookup_group group in
      cache_put group_cache group_str result;
      result

(** 智能字符查询（支持异体字） *)
let smart_character_query char =
  match query_character_cached char with
  | Found rhyme_char -> Found rhyme_char
  | NotFound _ ->
      (* 尝试查找可能的异体字匹配 *)
      let all_chars = get_all_groups () |> 
                     List.fold_left (fun acc group -> group.all_characters @ acc) [] in
      let matching_variants = List.filter (fun c ->
        List.mem char c.variants
      ) all_chars in
      (match matching_variants with
       | [] -> NotFound char
       | [single] -> Found single
       | multiple -> MultipleMatches multiple)
  | MultipleMatches multiple -> MultipleMatches multiple

(** 模糊查询（基于相似度） *)
let fuzzy_character_query char threshold =
  let calculate_similarity s1 s2 =
    if s1 = s2 then 1.0
    else if String.length s1 = 1 && String.length s2 = 1 then
      (* 简单的字符相似度，基于Unicode差值 *)
      let c1 = String.get s1 0 |> Char.code in
      let c2 = String.get s2 0 |> Char.code in
      let diff = abs (c1 - c2) in
      max 0.0 (1.0 -. (float_of_int diff /. 1000.0))
    else 0.0
  in
  
  let all_chars = get_all_groups () |>
                 List.fold_left (fun acc group -> 
                   List.map rhyme_character_to_char_info group.all_characters @ acc
                 ) [] in
  let similar_chars = List.filter (fun c ->
    calculate_similarity char c.character >= threshold
  ) all_chars in
  
  match similar_chars with
  | [] -> NotFound char
  | matches -> MultipleMatches (List.map char_info_to_rhyme_character matches)

(** {1 批量查询优化} *)

(** 批量字符查询（带缓存优化） *)
let batch_query_optimized chars =
  List.map query_character_cached chars

(** 辅助函数：取列表前n个元素 *)
let rec take n lst =
  if n <= 0 then []
  else match lst with
    | [] -> []
    | x :: xs -> x :: take (n - 1) xs

(** 辅助函数：跳过列表前n个元素 *)
let rec drop n lst =
  if n <= 0 then lst
  else match lst with
    | [] -> []
    | _ :: xs -> drop (n - 1) xs

(** 并行批量查询（模拟并行处理） *)
let parallel_batch_query chars =
  let chunk_size = 50 in
  let rec process_chunks acc = function
    | [] -> List.rev acc
    | chunk ->
        let current_chunk, remaining = 
          if List.length chunk <= chunk_size then (chunk, [])
          else (take chunk_size chunk, drop chunk_size chunk) in
        let results = List.map query_character_cached current_chunk in
        process_chunks (results @ acc) remaining
  in
  process_chunks [] chars

(** {1 高级查询功能} *)

(** 查询韵组内的同韵字符 *)
let find_rhyming_characters char =
  match query_character_cached char with
  | Found rhyme_char ->
      get_group_characters rhyme_char.rhyme_group |>
      List.filter (fun (c : rhyme_character) -> c.character <> char)
  | _ -> []

(** 查询相同声调的字符 *)
let find_same_tone_characters char tone =
  let all_chars = get_all_groups () |>
                 List.fold_left (fun acc group -> group.all_characters @ acc) [] in
  List.filter (fun (c : rhyme_character) -> c.rhyme_category = tone && c.character <> char) all_chars

(** 韵律匹配度评分 *)
let calculate_rhyme_score char1 char2 =
  match query_character_cached char1, query_character_cached char2 with
  | Found c1, Found c2 ->
      let group_match = if c1.rhyme_group = c2.rhyme_group then 1.0 else 0.0 in
      let tone_match = if c1.rhyme_category = c2.rhyme_category then 0.5 else 0.0 in
      let freq_bonus = (c1.usage_frequency +. c2.usage_frequency) /. 4.0 in
      group_match +. tone_match +. freq_bonus
  | _ -> 0.0

(** {1 查询统计和性能监控} *)

(** 查询统计信息 *)
type query_stats = {
  total_queries: int;
  cache_hits: int;
  cache_misses: int;
  average_response_time: float;
}

let query_stats = ref {
  total_queries = 0;
  cache_hits = 0;
  cache_misses = 0;
  average_response_time = 0.0;
}


(** 获取查询统计 *)
let get_query_stats () = !query_stats

(** 获取缓存命中率 *)
let get_cache_hit_rate () =
  let stats = !query_stats in
  if stats.total_queries = 0 then 0.0
  else float_of_int stats.cache_hits /. float_of_int stats.total_queries

(** 清空缓存 *)
let clear_cache () =
  Hashtbl.clear query_cache.table;
  query_cache.size <- 0;
  query_cache.head <- None;
  query_cache.tail <- None;
  
  Hashtbl.clear group_cache.table;
  group_cache.size <- 0;
  group_cache.head <- None;
  group_cache.tail <- None

(** {1 性能基准测试} *)

(** 基准测试字符列表 *)
let benchmark_chars = ["春"; "花"; "秋"; "月"; "风"; "雪"; "山"; "水"; "云"; "天"]

(** 执行性能基准测试 *)
let run_benchmark iterations =
  clear_cache ();
  let start_time = Sys.time () in
  
  for _i = 1 to iterations do
    List.iter (fun char ->
      let _ = query_character_cached char in ()
    ) benchmark_chars
  done;
  
  let end_time = Sys.time () in
  let total_time = end_time -. start_time in
  let queries_per_second = float_of_int (iterations * List.length benchmark_chars) /. total_time in
  
  (total_time, queries_per_second, get_cache_hit_rate ())

(** 获取性能报告 *)
let get_performance_report () =
  let stats = get_query_stats () in
  let hit_rate = get_cache_hit_rate () *. 100.0 in
  Printf.sprintf 
    "韵律查询引擎性能报告\n总查询: %d\n缓存命中率: %.1f%%\n平均响应时间: %.4fms\n查询缓存大小: %d\n韵组缓存大小: %d"
    stats.total_queries hit_rate (stats.average_response_time *. 1000.0) 
    query_cache.size group_cache.size

(** {1 兼容性函数} *)

(** 检测字符的韵组 - 兼容性函数 
    
    这个函数为兼容现有代码提供，将查询结果转换为韵组类型。
    
    @param char 要查询的字符
    @return 字符所属的韵组，如果未找到则返回UnknownRhyme *)
let detect_rhyme_group char =
  match query_character_cached char with
  | Found rhyme_char -> rhyme_char.rhyme_group
  | NotFound _ -> UnknownRhyme
  | MultipleMatches matches ->
      (* 如果有多个匹配，选择使用频率最高的 *)
      match matches with
      | [] -> UnknownRhyme
      | first :: rest ->
          let best_match = List.fold_left (fun acc c ->
            if c.usage_frequency > acc.usage_frequency then c else acc
          ) first rest in
          best_match.rhyme_group

(** 检测字符的韵类 - 兼容性函数 *)
let detect_rhyme_category char =
  match query_character_cached char with
  | Found rhyme_char -> rhyme_char.rhyme_category
  | NotFound _ | MultipleMatches [] -> PingSheng
  | MultipleMatches (first :: _) -> first.rhyme_category