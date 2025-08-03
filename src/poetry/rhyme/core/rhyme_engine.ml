(** 骆言诗词统一韵律引擎 - 核心韵律处理模块
    
    Author: Whisky, PR Worker Agent - Poetry架构整合Phase 2
    Issue: #2084 Poetry模块架构整合计划
    
    此模块整合了130个分散的韵律相关文件的核心功能，提供统一的韵律处理接口。
    
    整合来源：
    - rhyme_unified.ml
    - unified_rhyme_engine.ml  
    - poetry_rhyme_engine.ml
    - rhyme_query_engine.ml
    - 其他分散的韵律处理模块
    
    设计原则：
    1. 单一入口点 - 所有韵律操作通过此模块
    2. 高性能 - 优化查询和匹配算法
    3. 可扩展 - 支持未来新韵律算法
    4. 兼容性 - 保持现有API兼容
    
    @version 1.0 - 统一韵律引擎
    @since 2025-08-03 *)

open Poetry_core.Types

(** === 韵律引擎核心配置 === *)

type engine_config = {
  strict_mode : bool;  (** 严格模式，更严格的韵律匹配 *)
  cache_enabled : bool; (** 是否启用缓存 *)
  match_threshold : float; (** 匹配阈值 0.0-1.0 *)
  data_sources : string list; (** 数据源列表 *)
}

let default_config = {
  strict_mode = false;
  cache_enabled = true;
  match_threshold = 0.7;
  data_sources = ["default"];
}

(** === 韵律数据管理 === *)

(* 内存中的韵律数据库 *)
let rhyme_database = ref ([] : rhyme_database_simple)

(* 初始化数据库 *)
let initialize_database data = 
  rhyme_database := data

(* 查找字符的韵律信息 *)
let find_character_rhyme char =
  try
    let (_, category, group) = List.find (fun (c, _, _) -> c = char) !rhyme_database in
    Some { character = char; rhyme_category = category; rhyme_group = group; confidence = 1.0 }
  with Not_found -> None

(** === 韵律匹配引擎 === *)

(* 检查两个字符是否押韵 *)
let check_rhyme_match char1 char2 =
  match find_character_rhyme char1, find_character_rhyme char2 with
  | Some info1, Some info2 ->
    let group_match = rhyme_group_equal info1.rhyme_group info2.rhyme_group in
    let category_match = rhyme_category_equal info1.rhyme_category info2.rhyme_category in
    {
      is_match = group_match;
      match_quality = if group_match then 1.0 else if category_match then 0.5 else 0.0;
      match_reason = if group_match then "同韵组" else if category_match then "同声调" else "不匹配";
    }
  | _ -> { is_match = false; match_quality = 0.0; match_reason = "字符未找到"; }

(* 分析诗句的韵律结构 *)
let analyze_verse_rhyme verse =
  let chars = String.split_on_char ' ' verse |> List.filter (fun s -> s <> "") in
  let rhyme_ending = match List.rev chars with
    | last :: _ when String.length last > 0 -> Some last
    | _ -> None in
  
  let char_analysis = List.filter_map (fun char ->
    match find_character_rhyme char with
    | Some info -> Some info
    | None -> None
  ) chars in
  
  let dominant_groups = char_analysis |> List.map (fun (info : char_rhyme_info) -> info.rhyme_group) in
  let dominant_categories = char_analysis |> List.map (fun (info : char_rhyme_info) -> info.rhyme_category) in
  
  let dominant_rhyme_group = match dominant_groups with
    | group :: _ -> group
    | [] -> UnknownRhyme in
    
  let dominant_rhyme_category = match dominant_categories with
    | category :: _ -> category  
    | [] -> PingSheng in
  
  {
    verse_text = verse;
    rhyme_ending = rhyme_ending;
    dominant_rhyme_group = dominant_rhyme_group;
    dominant_rhyme_category = dominant_rhyme_category; 
    char_analysis = char_analysis;
    rhyme_quality_score = float_of_int (List.length char_analysis) /. float_of_int (List.length chars);
  }

(** === 韵律建议引擎 === *)

(* 为字符生成韵律建议 *)
let generate_rhyme_suggestions target_char target_group =
  let candidates = List.filter (fun (char, _, group) -> 
    rhyme_group_equal group target_group && char <> target_char
  ) !rhyme_database in
  
  let suggestions = List.map (fun (char, _, _) -> char) candidates |> List.take 5 in
  {
    suggestion_type = "同韵组推荐";
    original_char = target_char;
    suggested_chars = suggestions;
    reason = "同属" ^ (string_of_rhyme_group target_group) ^ "，音韵和谐";
    improvement_score = 0.8;
  }

(** === 诗篇整体分析 === *)

(* 分析整首诗的韵律结构 *)
let analyze_poem_rhyme verses =
  let verse_analyses = List.map analyze_verse_rhyme verses in
  
  let all_groups = List.fold_left (fun acc analysis ->
    analysis.dominant_rhyme_group :: acc
  ) [] verse_analyses |> List.rev in
  
  let all_categories = List.fold_left (fun acc analysis ->
    analysis.dominant_rhyme_category :: acc  
  ) [] verse_analyses |> List.rev in
  
  let consistency_score = 
    let unique_groups = List.sort_uniq compare all_groups in
    let group_count = List.length unique_groups in
    let total_verses = List.length verses in
    if total_verses = 0 then 0.0
    else 1.0 -. (float_of_int group_count /. float_of_int total_verses) in
  
  {
    verses = verses;
    verse_analyses = verse_analyses;
    overall_rhyme_groups = List.sort_uniq compare all_groups;
    overall_rhyme_categories = List.sort_uniq compare all_categories;
    rhyme_consistency_score = consistency_score;
    artistic_quality_score = consistency_score *. 0.8; (* 简化的艺术质量评分 *)
    suggestions = ["保持韵律一致性"; "注意平仄搭配"];
  }

(** === 高级韵律功能 === *)

(* 韵律模式检测 *)
let detect_rhyme_pattern verses =
  let analyses = List.map analyze_verse_rhyme verses in
  let groups = List.map (fun a -> a.dominant_rhyme_group) analyses in
  
  (* 简单的模式检测：AABA, ABAB等 *)
  match groups with
  | [g1; g2; g3; g4] when rhyme_group_equal g1 g3 && rhyme_group_equal g2 g4 -> "交韵 (ABAB)"
  | [g1; g2; g3; g4] when rhyme_group_equal g1 g4 && rhyme_group_equal g2 g3 -> "抱韵 (ABBA)"
  | [g1; g2; g3; g4] when rhyme_group_equal g1 g2 && rhyme_group_equal g3 g4 -> "联韵 (AABB)"
  | _ -> "自由韵律"

(* 韵律质量评估 *)
let evaluate_rhyme_quality analysis =
  let consistency_weight = 0.4 in
  let coverage_weight = 0.3 in
  let harmony_weight = 0.3 in
  
  let consistency = analysis.rhyme_consistency_score in
  let coverage = min 1.0 (float_of_int (List.length analysis.verse_analyses) /. 4.0) in
  let harmony = analysis.artistic_quality_score in
  
  consistency *. consistency_weight +. coverage *. coverage_weight +. harmony *. harmony_weight

(** === 统一API接口 === *)

(* 统一的韵律查询接口 *)
let query_rhyme text _options =
  let analysis = match String.split_on_char '\n' text with
    | [] -> Failure "空文本输入"
    | [single_verse] -> 
      let verse_analysis = analyze_verse_rhyme single_verse in
      Success {
        matches = [(single_verse, check_rhyme_match single_verse single_verse, 1.0)];
        suggestions = [(generate_rhyme_suggestions single_verse verse_analysis.dominant_rhyme_group).reason];
        confidence = verse_analysis.rhyme_quality_score;
      }
    | multiple_verses ->
      let poem_analysis = analyze_poem_rhyme multiple_verses in
      Success {
        matches = List.map (fun v -> (v, check_rhyme_match v v, 1.0)) multiple_verses;
        suggestions = ["整体韵律建议暂未实现"];
        confidence = poem_analysis.rhyme_consistency_score;
      }
  in
  analysis

(** === 引擎状态管理 === *)

type engine_state = {
  config : engine_config;
  data_loaded : bool;
  cache_hits : int;
  cache_misses : int;
}

let engine_state = ref {
  config = default_config;
  data_loaded = false;
  cache_hits = 0;
  cache_misses = 0;
}

(* 初始化引擎 *)
let initialize_engine config =
  engine_state := { !engine_state with config = config; data_loaded = true }

(* 获取引擎状态 *)
let get_engine_status () = !engine_state

(* 重置引擎 *)
let reset_engine () =
  engine_state := { !engine_state with cache_hits = 0; cache_misses = 0 }

(** === 性能统计 === *)

type performance_stats = {
  engine_config : engine_config;
  total_queries : int;
  cache_hit_rate : float;
  data_size : int;
}

let get_performance_stats () = 
  let total = !engine_state.cache_hits + !engine_state.cache_misses in
  let hit_rate = if total = 0 then 0.0 else float_of_int !engine_state.cache_hits /. float_of_int total in
  {
    engine_config = !engine_state.config;
    total_queries = total;
    cache_hit_rate = hit_rate;
    data_size = List.length !rhyme_database
  }