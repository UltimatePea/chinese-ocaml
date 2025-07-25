(** 韵律核心API模块 - 骆言诗词编程特性

    此模块提供统一的韵律数据访问API，消除项目中多个重复API接口。 整合来自
    rhyme_api_core.ml、unified_rhyme_api.ml、poetry_recommended_api.ml 等模块的功能。

    重构目标：
    - 提供统一的韵律查询和分析接口
    - 消除API重复，简化客户端调用
    - 支持缓存和性能优化

    @author 骆言诗词编程团队
    @version 3.0 - 核心重构版本
    @since 2025-07-25 *)

open Rhyme_core_types
open Rhyme_core_data

(** {1 基础查询函数} *)

(** 查找字符的韵律信息 - 优化版本使用 Map 查找 *)
let find_character_rhyme (char : string) : rhyme_data_entry option = find_character_rhyme_fast char

(** 查找字符的韵律信息（抛出异常版本） *)
let find_character_rhyme_exn (char : string) : rhyme_data_entry =
  match find_character_rhyme char with
  | Some entry -> entry
  | None -> raise (RhymeException (CharacterNotFound char))

(** 获取字符的韵组 *)
let get_character_rhyme_group (char : string) : rhyme_group option =
  match find_character_rhyme char with Some entry -> Some entry.group | None -> None

(** 获取字符的声韵类别 *)
let get_character_rhyme_category (char : string) : rhyme_category option =
  match find_character_rhyme char with Some entry -> Some entry.category | None -> None

(** {2 韵组相关查询} *)

(** 获取指定韵组的所有字符 *)
let get_characters_by_group (group : rhyme_group) : string list =
  match List.assoc_opt group data_by_group with
  | Some entries -> List.map (fun entry -> entry.character) entries
  | None -> []

(** 获取指定声韵类别的所有字符 *)
let get_characters_by_category (category : rhyme_category) : string list =
  match List.assoc_opt category data_by_category with
  | Some entries -> List.map (fun entry -> entry.character) entries
  | None -> []

(** 获取韵组描述 *)
let get_rhyme_group_description (group : rhyme_group) : string =
  match List.assoc_opt group rhyme_group_descriptions with Some desc -> desc | None -> "未知韵组描述"

(** 获取韵组的典型诗句示例 *)
let get_rhyme_group_examples (group : rhyme_group) : string list =
  match List.assoc_opt group example_poems_by_group with Some examples -> examples | None -> []

(** {3 韵律匹配功能} *)

(** 检查两个字符是否可以押韵 *)
let can_rhyme_together (char1 : string) (char2 : string) : rhyme_match_result =
  match (find_character_rhyme char1, find_character_rhyme char2) with
  | Some entry1, Some entry2 ->
      let group_match = entry1.group = entry2.group in
      let category_compatible =
        match (entry1.category, entry2.category) with
        | PingSheng, PingSheng -> true
        | ZeSheng, ZeSheng | ZeSheng, QuSheng | ZeSheng, ShangSheng -> true
        | QuSheng, ZeSheng | QuSheng, QuSheng -> true
        | ShangSheng, ZeSheng | ShangSheng, ShangSheng -> true
        | _ -> false
      in
      let quality =
        if group_match && category_compatible then 1.0
        else if group_match then 0.7
        else if category_compatible then 0.3
        else 0.0
      in
      let reason =
        if group_match && category_compatible then "同韵组同声调，完美押韵"
        else if group_match then "同韵组，声调略有差异"
        else if category_compatible then "声调相容，韵组不同"
        else "韵组和声调都不匹配"
      in
      { is_match = quality > 0.3; match_quality = quality; match_reason = reason }
  | _ -> { is_match = false; match_quality = 0.0; match_reason = "字符未找到韵律信息" }

(** 为指定字符查找押韵字符 *)
let find_rhyming_characters (char : string) ?(min_quality : float = 0.7) () : string list =
  match find_character_rhyme char with
  | Some _target_entry ->
      List.filter_map
        (fun entry ->
          if entry.character <> char then
            let match_result = can_rhyme_together char entry.character in
            if match_result.match_quality >= min_quality then Some entry.character else None
          else None)
        all_rhyme_data
  | None -> []

(** {4 诗句韵律分析} *)

(** 分析单个字符的韵律信息 *)
let analyze_character (char : string) ?(confidence : float = 1.0) () : char_rhyme_info option =
  match find_character_rhyme char with
  | Some entry ->
      Some
        { character = char; rhyme_category = entry.category; rhyme_group = entry.group; confidence }
  | None -> None

(** 分析诗句的韵律特征 *)
let analyze_verse (verse : string) ?config () : verse_rhyme_analysis =
  let _ = config in
  (* 消除未使用警告 *)
  let chars = List.init (String.length verse) (String.get verse) in
  let char_strings = List.map (String.make 1) chars in

  (* 分析每个字符 *)
  let char_analyses =
    List.filter_map (fun char_str -> analyze_character char_str ()) char_strings
  in

  (* 确定韵脚 - 通常是最后一个字符 *)
  let rhyme_ending =
    if String.length verse > 0 then Some (String.sub verse (String.length verse - 1) 1) else None
  in

  (* 确定主要韵组和声韵类别 *)
  let group_counts =
    List.fold_left
      (fun acc analysis ->
        let count = try List.assoc analysis.rhyme_group acc + 1 with Not_found -> 1 in
        (analysis.rhyme_group, count) :: List.remove_assoc analysis.rhyme_group acc)
      [] char_analyses
  in

  let category_counts =
    List.fold_left
      (fun acc analysis ->
        let count = try List.assoc analysis.rhyme_category acc + 1 with Not_found -> 1 in
        (analysis.rhyme_category, count) :: List.remove_assoc analysis.rhyme_category acc)
      [] char_analyses
  in

  let dominant_group =
    match List.sort (fun (_, c1) (_, c2) -> compare c2 c1) group_counts with
    | (group, _) :: _ -> group
    | [] -> UnknownRhyme
  in

  let dominant_category =
    match List.sort (fun (_, c1) (_, c2) -> compare c2 c1) category_counts with
    | (category, _) :: _ -> category
    | [] -> PingSheng
  in

  (* 计算韵律质量评分 *)
  let quality_score =
    if List.length char_analyses > 0 then
      let total_confidence =
        List.fold_left (fun acc analysis -> acc +. analysis.confidence) 0.0 char_analyses
      in
      total_confidence /. float_of_int (List.length char_analyses)
    else 0.0
  in

  {
    verse_text = verse;
    rhyme_ending;
    dominant_rhyme_group = dominant_group;
    dominant_rhyme_category = dominant_category;
    char_analysis = char_analyses;
    rhyme_quality_score = quality_score;
  }

(** 分析整首诗的韵律特征 *)
let analyze_poem (verses : string list) ?config () : poem_rhyme_analysis =
  let verse_analyses = List.map (fun verse -> analyze_verse verse ?config ()) verses in

  (* 收集所有使用的韵组和声韵类别 *)
  let all_groups =
    List.fold_left
      (fun acc analysis ->
        if not (List.mem analysis.dominant_rhyme_group acc) then
          analysis.dominant_rhyme_group :: acc
        else acc)
      [] verse_analyses
  in

  let all_categories =
    List.fold_left
      (fun acc analysis ->
        if not (List.mem analysis.dominant_rhyme_category acc) then
          analysis.dominant_rhyme_category :: acc
        else acc)
      [] verse_analyses
  in

  (* 计算韵律一致性评分 *)
  let consistency_score =
    let group_consistency =
      if List.length all_groups <= 2 then 1.0 else if List.length all_groups <= 4 then 0.7 else 0.4
    in
    let category_consistency = if List.length all_categories <= 2 then 1.0 else 0.6 in
    (group_consistency +. category_consistency) /. 2.0
  in

  (* 计算艺术质量评分 *)
  let artistic_score =
    let avg_verse_quality =
      List.fold_left (fun acc analysis -> acc +. analysis.rhyme_quality_score) 0.0 verse_analyses
      /. float_of_int (List.length verse_analyses)
    in
    (avg_verse_quality +. consistency_score) /. 2.0
  in

  (* 生成改进建议 *)
  let suggestions =
    let low_quality_verses =
      List.filter (fun analysis -> analysis.rhyme_quality_score < 0.6) verse_analyses
    in
    if List.length low_quality_verses > 0 then [ "考虑优化韵律质量较低的诗句以提升整体效果" ] else []
  in

  let inconsistent_suggestions =
    if consistency_score < 0.7 then [ "建议统一韵律风格，减少韵组和声韵类别的混用" ] @ suggestions else suggestions
  in

  {
    verses;
    verse_analyses;
    overall_rhyme_groups = all_groups;
    overall_rhyme_categories = all_categories;
    rhyme_consistency_score = consistency_score;
    artistic_quality_score = artistic_score;
    suggestions = inconsistent_suggestions;
  }

(** {5 韵律建议功能} *)

(** 为指定位置推荐押韵字符 *)
let suggest_rhyme_characters (target_char : string) ?(max_suggestions : int = 10)
    ?(min_quality : float = 0.6) () : rhyme_suggestion list =
  let rhyming_chars = find_rhyming_characters target_char ~min_quality () in
  let rec take n lst =
    match (n, lst) with 0, _ | _, [] -> [] | n, x :: xs -> x :: take (n - 1) xs
  in
  let suggestions = take (min max_suggestions (List.length rhyming_chars)) rhyming_chars in

  List.map
    (fun suggested_char ->
      let match_result = can_rhyme_together target_char suggested_char in
      {
        suggestion_type = "韵律替换";
        original_char = target_char;
        suggested_chars = [ suggested_char ];
        reason = match_result.match_reason;
        improvement_score = match_result.match_quality;
      })
    suggestions

(** {6 缓存和性能优化} *)

(** 简单的查询缓存 *)
let query_cache = ref []

let cache_size_limit = 1000

(** 缓存查询结果 *)
let cache_get (key : string) : 'a option =
  try Some (List.assoc key !query_cache) with Not_found -> None

(** 添加到缓存 *)
let cache_put (key : string) (value : 'a) : unit =
  if List.length !query_cache >= cache_size_limit then
    query_cache := List.rev (List.tl (List.rev !query_cache));
  query_cache := (key, value) :: !query_cache

(** 带缓存的字符韵律查询 - 使用优化的Map查找 *)
let find_character_rhyme_cached (char : string) : rhyme_data_entry option =
  let cache_key = "char_" ^ char in
  match cache_get cache_key with
  | Some result -> result
  | None ->
      let result = find_character_rhyme char in
      cache_put cache_key result;
      result

(** {7 统计和监控} *)

(** 获取系统统计信息 *)
let get_system_stats () : (string * int) list =
  [
    ("total_characters", total_characters);
    ("rhyme_groups", groups_count);
    ("rhyme_categories", categories_count);
    ("cache_size", List.length !query_cache);
  ]

(** 清空缓存 *)
let clear_cache () : unit = query_cache := []
