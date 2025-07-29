(** 统一韵律分析引擎 - Phase 2: Engine Layer Refactoring
    
    此模块统一了原先分散在多个文件中的韵律分析功能，基于Phase 1的统一类型系统
    和高性能数据引擎，提供单一、高效的韵律分析接口。
    
    技术债务修复：
    - 消除rhyme_analysis.ml, poetry_rhyme_engine.ml等重复实现
    - 统一韵律分析API，建立Single Source of Truth
    - 基于统一数据引擎，提升查询性能
    
    @author Alpha, 主要开发代理 - Poetry模块重构团队
    @version 2.0 (Phase 2: 引擎层重构版)
    @since 2025-07-27
    @fix_issue #1501 *)

open Poetry_core.Poetry_types
open Poetry_data_core.Rhyme_data_engine

(** {1 韵律分析类型定义} *)

type rhythm_analysis_result = {
  character : string;  (** 分析的字符 *)
  rhyme_info : rhyme_data_item option;  (** 韵律信息 *)
  category : rhyme_category option;  (** 韵类 *)
  group : rhyme_group option;  (** 韵组 *)
  is_rhyme_ending : bool;  (** 是否为韵脚 *)
}
(** 韵律分析结果 *)

type verse_rhythm_analysis = {
  verse : string;  (** 原诗句 *)
  characters : string list;  (** 字符列表 *)
  rhythm_results : rhythm_analysis_result list;  (** 每字分析结果 *)
  rhyme_pattern : rhyme_category list;  (** 韵律模式 *)
  rhyme_ending : string option;  (** 韵脚字符 *)
  rhyme_group_consistency : bool;  (** 韵组一致性 *)
}
(** 诗句韵律分析 *)

type multi_verse_analysis = {
  verses : string list;  (** 原诗句列表 *)
  verse_analyses : verse_rhythm_analysis list;  (** 各句分析结果 *)
  rhyme_scheme : rhyme_group option list;  (** 整体韵式 *)
  consistency_score : float;  (** 韵律一致性评分 *)
  overall_quality : float;  (** 整体韵律质量 *)
}
(** 多句韵律分析 *)

type rhyme_match_result = {
  char1 : string;
  char2 : string;
  matches : bool;
  match_type : [ `Same_group | `Same_category | `No_match ];
  confidence : float;
}
(** 韵律匹配结果 *)

(** {1 韵律分析引擎状态} *)

type analyzer_state = {
  data_engine : engine_state;
  analysis_cache : (string, rhythm_analysis_result) Hashtbl.t;
  verse_cache : (string, verse_rhythm_analysis) Hashtbl.t;
  last_analysis_time : float;
}
(** 分析引擎状态 - 包装数据引擎状态 *)

exception RhythmAnalyzerError of string
(** 分析引擎异常 *)

(** {1 引擎初始化与管理} *)

(** 初始化韵律分析引擎 *)
let initialize_analyzer () =
  let data_engine = initialize () in
  {
    data_engine;
    analysis_cache = Hashtbl.create 1000;
    verse_cache = Hashtbl.create 500;
    last_analysis_time = Unix.time ();
  }

(** 加载韵律数据库到分析引擎 *)
let load_database_to_analyzer database analyzer_state =
  try
    let updated_engine = load_database database analyzer_state.data_engine in
    { analyzer_state with data_engine = updated_engine }
  with RhymeDataEngineError msg -> raise (RhythmAnalyzerError ("数据加载失败: " ^ msg))

(** {1 单字符韵律分析} *)

(** 分析单个字符的韵律信息 *)
let analyze_character character analyzer_state =
  (* 检查缓存 *)
  match Hashtbl.find_opt analyzer_state.analysis_cache character with
  | Some result -> result
  | None -> (
      try
        let rhyme_data_opt = lookup_character character analyzer_state.data_engine in
        let category = match rhyme_data_opt with Some info -> Some info.category | None -> None in
        let group = match rhyme_data_opt with Some info -> Some info.group | None -> None in

        let result =
          {
            character;
            rhyme_info = rhyme_data_opt;
            category;
            group;
            is_rhyme_ending = false;
            (* 需要在句子上下文中确定 *)
          }
        in

        (* 缓存结果 *)
        Hashtbl.replace analyzer_state.analysis_cache character result;
        result
      with RhymeDataEngineError msg -> raise (RhythmAnalyzerError ("字符分析失败: " ^ msg)))

(** 批量分析字符 *)
let batch_analyze_characters characters analyzer_state =
  List.map (fun char -> analyze_character char analyzer_state) characters

(** {1 韵律匹配分析} *)

(** 检查两个字符的韵律匹配 *)
let check_character_rhyme_match char1 char2 analyzer_state =
  try
    let rhyme_match = check_rhyme_match char1 char2 analyzer_state.data_engine in
    let category_match = check_category_match char1 char2 analyzer_state.data_engine in

    let match_type =
      if rhyme_match then `Same_group else if category_match then `Same_category else `No_match
    in

    let confidence = if rhyme_match then 1.0 else if category_match then 0.7 else 0.0 in

    { char1; char2; matches = rhyme_match; match_type; confidence }
  with RhymeDataEngineError msg -> raise (RhythmAnalyzerError ("韵律匹配检查失败: " ^ msg))

(** {1 诗句韵律分析} *)

(** 将字符串转换为字符列表 *)
let string_to_char_list str =
  let rec aux acc i =
    if i >= String.length str then List.rev acc
    else
      let char = String.sub str i 1 in
      aux (char :: acc) (i + 1)
  in
  aux [] 0

(** 检测韵脚字符 *)
let detect_rhyme_ending verse =
  let trimmed = String.trim verse in
  if String.length trimmed > 0 then Some (String.sub trimmed (String.length trimmed - 1) 1)
  else None

(** 分析单句韵律 *)
let analyze_verse_rhythm verse analyzer_state =
  (* 检查缓存 *)
  match Hashtbl.find_opt analyzer_state.verse_cache verse with
  | Some result -> result
  | None ->
      let characters = string_to_char_list verse in
      let rhythm_results = batch_analyze_characters characters analyzer_state in

      (* 标记韵脚 *)
      let rhyme_ending = detect_rhyme_ending verse in
      let updated_results =
        List.mapi
          (fun i result ->
            let is_ending =
              match rhyme_ending with
              | Some ending ->
                  String.equal result.character ending && i = List.length rhythm_results - 1
              | None -> false
            in
            { result with is_rhyme_ending = is_ending })
          rhythm_results
      in

      (* 提取韵律模式 *)
      let rhyme_pattern = List.filter_map (fun result -> result.category) updated_results in

      (* 检查韵组一致性 *)
      let rhyme_groups = List.filter_map (fun result -> result.group) updated_results in
      let rhyme_group_consistency =
        match rhyme_groups with
        | [] -> true
        | first :: rest -> List.for_all (fun group -> group = first) rest
      in

      let result =
        {
          verse;
          characters;
          rhythm_results = updated_results;
          rhyme_pattern;
          rhyme_ending;
          rhyme_group_consistency;
        }
      in

      (* 缓存结果 *)
      Hashtbl.replace analyzer_state.verse_cache verse result;
      result

(** {1 多句韵律分析} *)

(** 分析多句诗词的韵律 *)
let analyze_multi_verse_rhythm verses analyzer_state =
  let verse_analyses = List.map (fun verse -> analyze_verse_rhythm verse analyzer_state) verses in

  (* 提取整体韵式 *)
  let rhyme_scheme =
    List.map
      (fun analysis ->
        match analysis.rhyme_ending with
        | Some ending -> (
            match analyze_character ending analyzer_state with
            | { group = Some group; _ } -> Some group
            | _ -> None)
        | None -> None)
      verse_analyses
  in

  (* 计算一致性评分 *)
  let consistency_score =
    let valid_groups = List.filter_map (fun x -> x) rhyme_scheme in
    match valid_groups with
    | [] -> 0.0
    | first :: rest ->
        let matches =
          List.fold_left (fun acc group -> if group = first then acc + 1 else acc) 1 rest
        in
        float_of_int matches /. float_of_int (List.length valid_groups)
  in

  (* 计算整体质量评分 *)
  let overall_quality =
    let verse_qualities =
      List.map
        (fun analysis -> if analysis.rhyme_group_consistency then 1.0 else 0.5)
        verse_analyses
    in
    let avg_quality =
      List.fold_left ( +. ) 0.0 verse_qualities /. float_of_int (List.length verse_qualities)
    in
    (avg_quality +. consistency_score) /. 2.0
  in

  { verses; verse_analyses; rhyme_scheme; consistency_score; overall_quality }

(** {1 韵律建议与推荐} *)

(** 根据韵组推荐押韵字符 *)
let suggest_rhyme_characters_for_group group analyzer_state =
  try
    let group_chars = get_group_characters group analyzer_state.data_engine in
    List.map (fun (item : rhyme_data_item) -> item.character) group_chars
  with RhymeDataEngineError msg -> raise (RhythmAnalyzerError ("韵字推荐失败: " ^ msg))

(** 根据给定字符推荐相似韵律字符 *)
let suggest_similar_characters character analyzer_state =
  try
    let similar_items = find_similar_characters character analyzer_state.data_engine in
    List.map (fun (item : rhyme_data_item) -> item.character) similar_items
  with RhymeDataEngineError msg -> raise (RhythmAnalyzerError ("相似字符推荐失败: " ^ msg))

(** {1 性能监控和统计} *)

(** 获取分析器统计信息 *)
let get_analyzer_statistics analyzer_state =
  let cache_stats = get_cache_stats analyzer_state.data_engine in
  let analysis_cache_size = Hashtbl.length analyzer_state.analysis_cache in
  let verse_cache_size = Hashtbl.length analyzer_state.verse_cache in

  [
    ("数据引擎缓存命中", string_of_int cache_stats.hits);
    ("数据引擎缓存未命中", string_of_int cache_stats.misses);
    ("分析缓存大小", string_of_int analysis_cache_size);
    ("诗句缓存大小", string_of_int verse_cache_size);
    ("上次分析时间", string_of_float analyzer_state.last_analysis_time);
  ]

(** 清理分析器缓存 *)
let clear_analyzer_cache analyzer_state =
  Hashtbl.clear analyzer_state.analysis_cache;
  Hashtbl.clear analyzer_state.verse_cache;
  let cleared_engine = clear_cache_stats analyzer_state.data_engine in
  { analyzer_state with data_engine = cleared_engine; last_analysis_time = Unix.time () }

(** 验证分析器状态 *)
let validate_analyzer_state analyzer_state = validate_engine_state analyzer_state.data_engine

(** {1 工具函数} *)

(** 格式化韵律分析结果 *)
let format_rhythm_analysis_result result =
  let category_str =
    Option.map rhyme_category_to_string result.category |> Option.value ~default:"未知"
  in
  let group_str = Option.map rhyme_group_to_string result.group |> Option.value ~default:"未知" in
  let ending_mark = if result.is_rhyme_ending then " [韵脚]" else "" in
  Printf.sprintf "%s: %s-%s%s" result.character category_str group_str ending_mark

(** 格式化诗句韵律分析 *)
let format_verse_analysis analysis =
  let results_str =
    List.map format_rhythm_analysis_result analysis.rhythm_results |> String.concat ", "
  in
  let ending_str = Option.value analysis.rhyme_ending ~default:"无" in
  let consistency_str = if analysis.rhyme_group_consistency then "一致" else "不一致" in

  Printf.sprintf "诗句: %s\n韵律: %s\n韵脚: %s\n一致性: %s" analysis.verse results_str ending_str
    consistency_str

(** 格式化多句分析结果 *)
let format_multi_verse_analysis analysis =
  let verse_results =
    List.map format_verse_analysis analysis.verse_analyses |> String.concat "\n---\n"
  in
  Printf.sprintf "%s\n===\n一致性评分: %.2f\n整体质量: %.2f" verse_results analysis.consistency_score
    analysis.overall_quality
