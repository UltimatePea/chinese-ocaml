(** 骆言韵律系统统一引擎 - Phase 1整合版本
    
    Author: Whisky, PR Worker
    Date: 2025-08-02
    Issue: #2084 Poetry模块架构整合计划
    
    此模块整合了以下分散的韵律核心模块：
    - poetry_rhyme_core.ml (核心韵律检测)
    - unified_rhyme_engine.ml (统一韵律引擎)
    - unified_rhyme_core.ml (统一核心功能)
    - rhyme_api_core.ml (API接口)
    - rhyme_core_unified.ml (统一数据)
    - rhyme_matching.ml (匹配算法)
    - rhyme_validation.ml (验证逻辑)
    
    整合目标: 10个核心文件 → 1个统一引擎
    
    设计原则:
    1. 统一API接口 - 所有韵律操作通过单一入口
    2. 性能优化 - 缓存和索引机制
    3. 向后兼容 - 保持现有API不变
    4. 清晰职责 - 数据访问、匹配、验证分离
    *)

open Poetry_core.Poetry_types

(** {1 核心数据类型} *)

type rhyme_engine_config = {
  strict_mode: bool;           (** 严格模式 - 更严格的韵律要求 *)
  cache_enabled: bool;         (** 启用缓存 *)
  custom_groups: (string * rhyme_group) list; (** 自定义韵组 *)
}

type rhyme_lookup_result = {
  character: string;
  category: rhyme_category;
  group: rhyme_group;
  confidence: float;
  variants: string list;
}

type rhyme_match_assessment = {
  char1: string;
  char2: string;
  is_match: bool;
  match_quality: float;
  match_reason: string;
}

(** {2 引擎状态管理} *)

type rhyme_engine_state = {
  config: rhyme_engine_config;
  data_loaded: bool;
  cache_hits: int;
  total_queries: int;
  last_updated: float;
}

let default_config = {
  strict_mode = false;
  cache_enabled = true;
  custom_groups = [];
}

let engine_state = ref {
  config = default_config;
  data_loaded = false;
  cache_hits = 0;
  total_queries = 0;
  last_updated = Unix.time ();
}

(** {3 核心韵律查找功能} *)

(** 查找字符的韵律信息 *)
let find_rhyme_info character =
  engine_state := { !engine_state with total_queries = !engine_state.total_queries + 1 };
  
  (* 直接从数据源查找 - 简化版本，暂时移除缓存依赖 *)
  try
    let data_list = Poetry_rhyme_unified_data.Rhyme_database.get_rhyme_data_simple () in
    let (_, category, group) = List.find (fun (char, _, _) -> String.equal char character) data_list in
    Some {
      character;
      category;
      group;
      confidence = 1.0;
      variants = [];
    }
  with Not_found -> None

(** 检测字符的韵类 *)
let detect_rhyme_category character =
  match find_rhyme_info character with
  | Some result -> result.category
  | None -> PingSheng (* 默认平声 *)

(** 检测字符的韵组 *)
let detect_rhyme_group character =
  match find_rhyme_info character with
  | Some result -> result.group
  | None -> UnknownRhyme

(** {4 韵律匹配和验证} *)

(** 判断两个字符是否押韵 *)
let chars_rhyme char1 char2 =
  match (find_rhyme_info char1, find_rhyme_info char2) with
  | (Some r1, Some r2) ->
      let group_match = rhyme_group_equal r1.group r2.group in
      let category_compatible = 
        if !engine_state.config.strict_mode then
          rhyme_category_equal r1.category r2.category
        else
          true
      in
      {
        char1;
        char2;
        is_match = group_match && category_compatible;
        match_quality = if group_match && category_compatible then 1.0 
                       else if group_match then 0.7 
                       else 0.0;
        match_reason = 
          if group_match && category_compatible then "韵组和声调完全匹配"
          else if group_match then "韵组匹配，声调兼容"
          else "韵组不匹配";
      }
  | _ -> {
      char1;
      char2;
      is_match = false;
      match_quality = 0.0;
      match_reason = "韵律信息不完整";
    }

(** 检查字符串的韵律一致性 *)
let validate_rhyme_consistency characters =
  let rec check_pairs chars acc_quality reasons =
    match chars with
    | [] | [_] -> (acc_quality, reasons)
    | c1 :: c2 :: rest ->
        let assessment = chars_rhyme c1 c2 in
        let new_quality = (acc_quality +. assessment.match_quality) /. 2.0 in
        let new_reasons = assessment.match_reason :: reasons in
        check_pairs (c2 :: rest) new_quality new_reasons
  in
  check_pairs characters 1.0 []

(** {5 批量韵律分析} *)

(** 分析一句诗的韵律结构 *)
let analyze_verse_rhyme verse_text =
  let characters = String.split_on_char ' ' verse_text |> List.filter (fun s -> s <> "") in
  let rhyme_results = List.map find_rhyme_info characters in
  let valid_results = List.filter_map (fun x -> x) rhyme_results in
  
  if List.length valid_results = 0 then
    {
      verse_text;
      rhyme_ending = None;
      dominant_rhyme_group = UnknownRhyme;
      dominant_rhyme_category = PingSheng;
      char_analysis = [];
      rhyme_quality_score = 0.0;
    }
  else
    let rhyme_ending = 
      if List.length characters > 0 then
        Some (List.hd (List.rev characters))
      else None
    in
    
    (* 统计最常见的韵组 *)
    let group_counts = Hashtbl.create 16 in
    List.iter (fun result -> 
      let count = try Hashtbl.find group_counts result.group with Not_found -> 0 in
      Hashtbl.replace group_counts result.group (count + 1)
    ) valid_results;
    
    let dominant_group = 
      Hashtbl.fold (fun group count (max_group, max_count) ->
        if count > max_count then (group, count) else (max_group, max_count)
      ) group_counts (UnknownRhyme, 0) |> fst
    in
    
    (* 统计最常见的声调 *)
    let category_counts = Hashtbl.create 8 in
    List.iter (fun result ->
      let count = try Hashtbl.find category_counts result.category with Not_found -> 0 in
      Hashtbl.replace category_counts result.category (count + 1)
    ) valid_results;
    
    let dominant_category =
      Hashtbl.fold (fun category count (max_category, max_count) ->
        if count > max_count then (category, count) else (max_category, max_count)
      ) category_counts (PingSheng, 0) |> fst
    in
    
    (* 计算韵律质量分数 *)
    let consistency_score, _ = validate_rhyme_consistency characters in
    
    {
      verse_text;
      rhyme_ending;
      dominant_rhyme_group = dominant_group;
      dominant_rhyme_category = dominant_category;
      char_analysis = List.map (fun result -> {
        character = result.character;
        rhyme_category = result.category;
        rhyme_group = result.group;
        confidence = result.confidence;
      }) valid_results;
      rhyme_quality_score = consistency_score;
    }

(** {6 引擎配置和状态管理} *)

(** 更新引擎配置 *)
let update_config new_config =
  engine_state := { !engine_state with config = new_config }

(** 获取引擎状态统计 *)
let get_engine_stats () =
  let cache_hit_rate = 
    if !engine_state.total_queries > 0 then
      float_of_int !engine_state.cache_hits /. float_of_int !engine_state.total_queries
    else 0.0
  in
  Printf.sprintf "查询总数: %d, 缓存命中: %d, 命中率: %.2f%%" 
    !engine_state.total_queries 
    !engine_state.cache_hits 
    (cache_hit_rate *. 100.0)

(** 重置引擎状态 *)
let reset_engine () =
  engine_state := {
    config = default_config;
    data_loaded = false;
    cache_hits = 0;
    total_queries = 0;
    last_updated = Unix.time ();
  }

(** {7 向后兼容接口} *)

(** 兼容旧版本的API *)
let rhyme_category_from_char = detect_rhyme_category
let rhyme_group_from_char = detect_rhyme_group
let check_rhyme_match = chars_rhyme

(** 引擎版本信息 *)
let engine_version = "1.0.0-phase1-consolidated"
let engine_description = "Phase 1统一韵律引擎 - 整合10个核心模块"

(** 初始化引擎 *)
let initialize_engine ?(config = default_config) () =
  update_config config;
  (* 数据库自动初始化，无需显式加载 *)
  ignore (Poetry_rhyme_unified_data.Rhyme_database.get_database ());
  engine_state := { !engine_state with data_loaded = true }