(** Poetry Rhyme Engine Consolidated Module - Issue #1999
 * 
 * 韵律匹配和查询引擎统一模块
 * Author: Whisky, PR Worker
 * 
 * 整合以下模块的功能：
 * - rhyme_query_engine.ml (查询引擎)
 * - rhyme_matching.ml (韵律匹配)
 * - unified_rhyme_engine.ml (统一韵律引擎)
 * - poetry_rhyme_engine.ml (诗词韵律引擎)
 * - rhyme_lookup.ml (韵律查找)
 * 
 * 目标：提供高性能的韵律查询和匹配服务
 *)

open Poetry_core_consolidated

(** 辅助函数：实现List.take功能 *)
let take n lst =
  let rec aux acc n = function
    | [] -> List.rev acc
    | _ when n <= 0 -> List.rev acc
    | x :: xs -> aux (x :: acc) (n - 1) xs
  in
  aux [] n lst

(** {1 引擎状态管理} *)

(** 引擎状态 *)
type engine_state = {
  initialized: bool;
  data_loaded: bool;
  cache_enabled: bool;
  performance_mode: bool;
}

(** 查询统计信息 *)
type query_stats = {
  total_queries: int;
  cache_hits: int;
  cache_misses: int;
  avg_query_time: float;
}

(** 全局引擎状态 *)
let engine_state = ref {
  initialized = false;
  data_loaded = false;
  cache_enabled = true;
  performance_mode = false;
}

(** 查询缓存 *)
let query_cache = Hashtbl.create 5000

(** 查询统计 *)
let query_stats = ref {
  total_queries = 0;
  cache_hits = 0;
  cache_misses = 0;
  avg_query_time = 0.0;
}

(** {1 韵律数据扩展} *)

(** 扩展韵律数据集 *)
let extended_rhyme_data = [
  (* 平声韵部 *)
  ("东", { category = PingSheng; group = Feng; tone_pattern = Some 1; char = "东" });
  ("冬", { category = PingSheng; group = Feng; tone_pattern = Some 1; char = "冬" });
  ("红", { category = PingSheng; group = Feng; tone_pattern = Some 2; char = "红" });
  ("空", { category = PingSheng; group = Feng; tone_pattern = Some 1; char = "空" });
  
  (* 花韵部 *)
  ("花", { category = PingSheng; group = Hua; tone_pattern = Some 1; char = "花" });
  ("家", { category = PingSheng; group = Hua; tone_pattern = Some 1; char = "家" });
  ("沙", { category = PingSheng; group = Hua; tone_pattern = Some 1; char = "沙" });
  ("霞", { category = PingSheng; group = Hua; tone_pattern = Some 2; char = "霞" });
  
  (* 语韵部 *)
  ("语", { category = ShangSheng; group = Yu; tone_pattern = Some 3; char = "语" });
  ("雨", { category = ShangSheng; group = Yu; tone_pattern = Some 3; char = "雨" });
  ("古", { category = ShangSheng; group = Yu; tone_pattern = Some 3; char = "古" });
  ("土", { category = ShangSheng; group = Yu; tone_pattern = Some 3; char = "土" });
  
  (* 江韵部 *)
  ("江", { category = PingSheng; group = Jiang; tone_pattern = Some 1; char = "江" });
  ("长", { category = PingSheng; group = Jiang; tone_pattern = Some 2; char = "长" });
  ("阳", { category = PingSheng; group = Jiang; tone_pattern = Some 2; char = "阳" });
  ("光", { category = PingSheng; group = Jiang; tone_pattern = Some 1; char = "光" });
  
  (* 月韵部 - 入声 *)
  ("月", { category = RuSheng; group = Yue; tone_pattern = Some 4; char = "月" });
  ("雪", { category = RuSheng; group = Yue; tone_pattern = Some 4; char = "雪" });
  ("别", { category = RuSheng; group = Yue; tone_pattern = Some 4; char = "别" });
  ("节", { category = RuSheng; group = Yue; tone_pattern = Some 4; char = "节" });
  
  (* 回韵部 *)
  ("回", { category = PingSheng; group = Hui; tone_pattern = Some 2; char = "回" });
  ("来", { category = PingSheng; group = Hui; tone_pattern = Some 2; char = "来" });
  ("台", { category = PingSheng; group = Hui; tone_pattern = Some 2; char = "台" });
  ("开", { category = PingSheng; group = Hui; tone_pattern = Some 1; char = "开" });
]

(** {1 引擎初始化和配置} *)

(** 初始化引擎 *)
let initialize_engine ?(performance_mode=false) () =
  if not !engine_state.initialized then (
    (* 加载扩展韵律数据到缓存 *)
    List.iter (fun (char, info) -> 
      Hashtbl.replace rhyme_info_cache char info
    ) extended_rhyme_data;
    
    (* 更新引擎状态 *)
    engine_state := {
      initialized = true;
      data_loaded = true;
      cache_enabled = true;
      performance_mode = performance_mode;
    };
    
    Printf.printf "Poetry Rhyme Engine initialized with %d rhyme entries\\n"
      (List.length extended_rhyme_data);
  )

(** 检查引擎是否已初始化 *)
let is_initialized () = !engine_state.initialized

(** 启用性能模式 *)
let enable_performance_mode () =
  engine_state := { !engine_state with performance_mode = true }

(** 禁用缓存 *)
let disable_cache () =
  engine_state := { !engine_state with cache_enabled = false };
  Hashtbl.clear query_cache

(** {1 韵律查询引擎} *)

(** 记录查询统计 *)
let record_query_stat is_cache_hit query_time =
  let stats = !query_stats in
  query_stats := {
    total_queries = stats.total_queries + 1;
    cache_hits = if is_cache_hit then stats.cache_hits + 1 else stats.cache_hits;
    cache_misses = if is_cache_hit then stats.cache_misses else stats.cache_misses + 1;
    avg_query_time = (stats.avg_query_time *. float_of_int stats.total_queries +. query_time) 
                    /. float_of_int (stats.total_queries + 1);
  }

(** 高性能韵律查询 *)
let find_rhyme_info_fast (char_str: string) : rhyme_info option =
  let start_time = Sys.time () in
  
  (* 检查缓存 *)
  let result = 
    if !engine_state.cache_enabled then (
      try 
        let cached_result = Hashtbl.find query_cache char_str in
        record_query_stat true (Sys.time () -. start_time);
        Some cached_result
      with Not_found ->
        (* 缓存未命中，查找数据 *)
        let result = find_rhyme_info char_str in
        (match result with
        | Some info -> Hashtbl.replace query_cache char_str info
        | None -> ());
        record_query_stat false (Sys.time () -. start_time);
        result
    ) else (
      let result = find_rhyme_info char_str in
      record_query_stat false (Sys.time () -. start_time);
      result
    )
  in
  result

(** 批量韵律查询 - 性能优化版本 *)
let batch_find_rhyme_info (char_list: string list) : (string * rhyme_info option) list =
  List.map (fun char -> (char, find_rhyme_info_fast char)) char_list

(** 查找同韵字符 *)
let find_rhyme_group_chars (target_group: rhyme_group) : string list =
  let result = ref [] in
  List.iter (fun (char, info) ->
    if info.group = target_group then
      result := char :: !result
  ) extended_rhyme_data;
  !result

(** {1 韵律匹配引擎} *)

(** 韵律匹配质量评分 *)
let calculate_rhyme_quality (info1: rhyme_info) (info2: rhyme_info) : float =
  let group_match = if info1.group = info2.group then 1.0 else 0.0 in
  let category_match = if info1.category = info2.category then 0.5 else 0.0 in
  let tone_match = 
    match (info1.tone_pattern, info2.tone_pattern) with
    | (Some t1, Some t2) when t1 = t2 -> 0.3
    | _ -> 0.0
  in
  group_match +. category_match +. tone_match

(** 高级韵律匹配 *)
let advanced_rhyme_match (char1: string) (char2: string) : rhyme_match_result =
  match (find_rhyme_info_fast char1, find_rhyme_info_fast char2) with
  | Some info1, Some info2 ->
    let quality = calculate_rhyme_quality info1 info2 in
    let is_match = quality >= 1.0 in
    let match_type = 
      if quality >= 1.5 then "完全匹配"
      else if quality >= 1.0 then "韵部匹配"
      else if quality >= 0.5 then "声调匹配"
      else "不匹配"
    in
    let suggestions = 
      if not is_match then
        let same_group_chars = find_rhyme_group_chars info1.group in
        List.filter (fun c -> c <> char1) same_group_chars
      else []
    in
    {
      is_match = is_match;
      confidence = quality /. 1.8;  (* 归一化到0-1 *)
      match_type = match_type;
      suggestions = suggestions;
    }
  | _ -> {
    is_match = false;
    confidence = 0.0;
    match_type = "未知字符";
    suggestions = [];
  }

(** 验证诗词整体韵律 *)
let validate_poem_rhyme (poem_lines: string list) : (int * rhyme_match_result) list =
  let line_endings = List.mapi (fun i line ->
    if String.length line > 0 then
      let last_char = String.make 1 (String.get line (String.length line - 1)) in
      (i, Some last_char)
    else (i, None)
  ) poem_lines in
  
  let valid_endings = List.filter_map (fun (i, char_opt) ->
    match char_opt with Some c -> Some (i, c) | None -> None
  ) line_endings in
  
  (* 检查相邻行的韵律匹配 *)
  let rec check_adjacent_rhymes acc = function
    | [] | [_] -> acc
    | (i1, c1) :: (i2, c2) :: rest ->
      let match_result = advanced_rhyme_match c1 c2 in
      (i2, match_result) :: check_adjacent_rhymes acc ((i2, c2) :: rest)
  in
  
  check_adjacent_rhymes [] valid_endings

(** {1 建议生成引擎} *)

(** 生成韵律改进建议 *)
let suggest_rhyme_improvements (poem_lines: string list) : string list =
  let rhyme_validation = validate_poem_rhyme poem_lines in
  let failed_matches = List.filter (fun (_, result) -> not result.is_match) rhyme_validation in
  
  List.map (fun (line_idx, result) ->
    Printf.sprintf "第%d行韵律建议: %s，可选用: %s" 
      (line_idx + 1)
      result.match_type
      (String.concat ", " (take 3 result.suggestions))
  ) failed_matches

(** {1 性能监控} *)

(** 获取查询统计信息 *)
let get_query_stats () = !query_stats

(** 获取引擎状态 *)
let get_engine_state () = !engine_state

(** 重置统计信息 *)
let reset_stats () =
  query_stats := {
    total_queries = 0;
    cache_hits = 0;
    cache_misses = 0;
    avg_query_time = 0.0;
  }

(** 打印性能报告 *)
let print_performance_report () =
  let stats = !query_stats in
  let cache_hit_rate = 
    if stats.total_queries > 0 then
      float_of_int stats.cache_hits /. float_of_int stats.total_queries *. 100.0
    else 0.0
  in
  Printf.printf "=== Poetry Rhyme Engine Performance Report ===\\n";
  Printf.printf "总查询次数: %d\\n" stats.total_queries;
  Printf.printf "缓存命中: %d (%.1f%%)\\n" stats.cache_hits cache_hit_rate;
  Printf.printf "缓存未命中: %d\\n" stats.cache_misses;
  Printf.printf "平均查询时间: %.6f秒\\n" stats.avg_query_time;
  Printf.printf "引擎状态: %s\\n" (if !engine_state.initialized then "已初始化" else "未初始化");
  Printf.printf "==============================================\\n"

(** {1 兼容性层} *)

(** 兼容旧的查询接口 *)
let query_rhyme_compat = find_rhyme_info_fast
let match_rhyme_compat char1 char2 = 
  let result = advanced_rhyme_match char1 char2 in
  result.is_match

(** 清理引擎 *)
let cleanup_engine () =
  Hashtbl.clear query_cache;
  reset_stats ();
  engine_state := {
    initialized = false;
    data_loaded = false;
    cache_enabled = true;
    performance_mode = false;
  }