(** 骆言诗词韵律查询引擎 - 统一韵律查询接口
    
    Author: Whisky, PR Worker - Issue #2084 Phase 2 韵律系统整合
    Date: 2025-08-04
    
    本模块整合了所有分散的韵律查询功能，包括：
    - 原有的查询引擎和匹配算法
    - 各种韵律检索和过滤功能
    - 智能建议和推荐系统
    
    整合前模块数量：~15个查询相关模块
    整合后模块数量：1个统一查询引擎 *)

open Poetry_types_unified.Unified_poetry_types

(** === 核心查询引擎 === *)

module QueryEngine = struct
  
  (** 查询字符的所有韵律匹配项 *)
  let query_character_matches char =
    (* 这里会调用数据库模块获取信息 *)
    match Poetry_rhyme_data_consolidated.Poetry_rhyme_data_consolidated.Rhyme_database.find_character char with
    | Some item -> [item]
    | None -> []
  
  (** 查询与目标字符押韵的所有字符 *)
  let find_rhyme_matches target_char =
    match Poetry_rhyme_data_consolidated.Poetry_rhyme_data_consolidated.Rhyme_database.find_character target_char with
    | Some target_item ->
        let group_chars = Poetry_rhyme_data_consolidated.Poetry_rhyme_data_consolidated.Rhyme_database.get_group_chars target_item.group in
        List.filter (fun item -> 
          not (String.equal item.character target_char)
        ) group_chars
    | None -> []
  
  (** 按韵组查询字符 *)
  let query_by_group rhyme_group =
    Poetry_rhyme_data_consolidated.Rhyme_database.get_group_chars rhyme_group
  
  (** 按声调查询字符 *)
  let query_by_category rhyme_category =
    let all_groups = Poetry_rhyme_data_consolidated.Rhyme_database.get_all_groups () in
    List.fold_left (fun acc (group, _, _) ->
      let chars = Poetry_rhyme_data_consolidated.Rhyme_database.get_group_chars group in
      let matching_chars = List.filter (fun item ->
        rhyme_category_equal item.category rhyme_category
      ) chars in
      matching_chars @ acc
    ) [] all_groups
  
  (** 复合查询：按韵组和声调 *)
  let query_by_group_and_category rhyme_group rhyme_category =
    let group_chars = query_by_group rhyme_group in
    List.filter (fun item ->
      rhyme_category_equal item.category rhyme_category
    ) group_chars
  
  (** 模糊查询：根据置信度阈值 *)
  let query_by_confidence_threshold threshold =
    let all_groups = Poetry_rhyme_data_consolidated.Rhyme_database.get_all_groups () in
    List.fold_left (fun acc (group, _, _) ->
      let chars = Poetry_rhyme_data_consolidated.Rhyme_database.get_group_chars group in
      let high_conf_chars = List.filter (fun item ->
        item.confidence >= threshold
      ) chars in
      high_conf_chars @ acc
    ) [] all_groups
  
  (** 相似性查询：查找相似韵律特征的字符 *)
  let query_similar_chars char similarity_threshold =
    match Poetry_rhyme_data_consolidated.Rhyme_database.find_character char with
    | Some target_item ->
        let all_groups = Poetry_rhyme_data_consolidated.Rhyme_database.get_all_groups () in
        List.fold_left (fun acc (group, _, _) ->
          let chars = Poetry_rhyme_data_consolidated.Rhyme_database.get_group_chars group in
          let similar_chars = List.filter (fun item ->
            let group_similarity = if rhyme_group_equal item.group target_item.group then 1.0 else 0.0 in
            let category_similarity = if rhyme_category_equal item.category target_item.category then 0.5 else 0.0 in
            let total_similarity = group_similarity +. category_similarity in
            total_similarity >= similarity_threshold && not (String.equal item.character char)
          ) chars in
          similar_chars @ acc
        ) [] all_groups
    | None -> []

end

(** === 智能建议引擎 === *)

module SuggestionEngine = struct
  
  (** 为指定文本生成韵律建议 *)
  let generate_suggestions text target_group =
    let words = String.split_on_char ' ' text |> List.filter ((<>) "") in
    List.fold_left (fun acc word ->
      let suggestions = QueryEngine.query_by_group target_group in
      let filtered_suggestions = List.filter (fun item ->
        not (List.exists (String.equal item.character) words) &&
        item.confidence > 0.8
      ) suggestions in
      if List.length filtered_suggestions > 0 then
        (word, filtered_suggestions) :: acc
      else acc
    ) [] words
  
  (** 生成韵脚建议 *)
  let suggest_rhyme_endings verse_ending target_group =
    match QueryEngine.query_character_matches verse_ending with
    | item :: _ ->
        let rhyme_matches = QueryEngine.find_rhyme_matches verse_ending in
        let group_matches = QueryEngine.query_by_group target_group in
        let combined = rhyme_matches @ group_matches in
        let sorted = List.sort (fun a b -> compare b.confidence a.confidence) combined in
        let unique = List.fold_left (fun acc item ->
          if List.exists (fun existing -> String.equal existing.character item.character) acc then acc
          else item :: acc
        ) [] sorted in
        List.rev unique
    | [] ->
        QueryEngine.query_by_group target_group
  
  (** 生成改进建议 *)
  let suggest_improvements verse_analysis =
    let suggestions = ref [] in
    
    (* 检查韵律质量 *)
    if verse_analysis.rhyme_quality_score < 0.7 then
      suggestions := "考虑改进韵律质量：选择更匹配的韵组字符" :: !suggestions;
    
    (* 检查字符分析完整性 *)
    let analyzed_count = List.length verse_analysis.char_analysis in
    let verse_length = String.length verse_analysis.verse_text in
    if analyzed_count < verse_length / 2 then
      suggestions := "部分字符缺乏韵律信息，建议补充数据" :: !suggestions;
    
    (* 生成具体的字符替换建议 *)
    let low_conf_chars = List.filter (fun info -> info.confidence < 0.8) verse_analysis.char_analysis in
    if List.length low_conf_chars > 0 then
      let char_suggestions = List.map (fun info ->
        let alternatives = QueryEngine.find_rhyme_matches info.character in
        let high_conf_alternatives = List.filter (fun item -> item.confidence > 0.9) alternatives in
        if List.length high_conf_alternatives > 0 then
          Printf.sprintf "字符'%s'可考虑替换为：%s" 
            info.character
            (String.concat "、" (List.map (fun item -> item.character) (List.take 3 high_conf_alternatives)))
        else ""
      ) low_conf_chars in
      let valid_suggestions = List.filter ((<>) "") char_suggestions in
      suggestions := valid_suggestions @ !suggestions;
    
    List.rev !suggestions

end

(** === 分析引擎 === *)

module AnalysisEngine = struct
  
  (** 分析韵律模式 *)
  let analyze_rhyme_pattern verses =
    let verse_analyses = List.map (fun verse ->
      (* 这里会调用核心引擎的分析函数 *)
      Poetry_rhyme_core_consolidated.Rhyme_engine.analyze_verse verse
    ) verses in
    
    (* 提取韵律模式 *)
    let rhyme_endings = List.map (fun analysis ->
      analysis.rhyme_ending
    ) verse_analyses in
    
    let rhyme_groups = List.map (fun analysis ->
      analysis.dominant_rhyme_group
    ) verse_analyses in
    
    (* 检测模式 *)
    let is_consistent_group = 
      match rhyme_groups with
      | [] -> true
      | first :: rest -> List.for_all (rhyme_group_equal first) rest in
    
    let pattern_score = if is_consistent_group then 1.0 else 0.5 in
    
    (verse_analyses, rhyme_endings, rhyme_groups, pattern_score)
  
  (** 评估韵律质量 *)
  let evaluate_rhyme_quality verse_text =
    let analysis = Poetry_rhyme_core_consolidated.Rhyme_engine.analyze_verse verse_text in
    let char_count = List.length analysis.char_analysis in
    let verse_length = String.length verse_text in
    let coverage = if verse_length > 0 then float_of_int char_count /. float_of_int verse_length else 0.0 in
    let avg_confidence = 
      if char_count > 0 then
        List.fold_left (fun acc info -> acc +. info.confidence) 0.0 analysis.char_analysis /. float_of_int char_count
      else 0.0 in
    let quality_score = (coverage +. avg_confidence +. analysis.rhyme_quality_score) /. 3.0 in
    (analysis, coverage, avg_confidence, quality_score)

end

(** === 高级查询接口 === *)

module AdvancedQuery = struct
  
  (** 执行复合查询 *)
  let execute_compound_query query =
    match query.analysis_depth with
    | Surface ->
        (* 基础查询：仅返回直接匹配 *)
        let matches = QueryEngine.query_character_matches query.text in
        List.map (fun item -> (item.character, { is_match = true; match_quality = item.confidence; match_reason = "直接匹配" }, item.confidence)) matches
    | Moderate ->
        (* 中等查询：包含相似匹配 *)
        let direct_matches = QueryEngine.query_character_matches query.text in
        let similar_matches = QueryEngine.query_similar_chars query.text 0.5 in
        let all_matches = direct_matches @ similar_matches in
        List.map (fun item -> 
          let match_result = if List.mem item direct_matches then
            { is_match = true; match_quality = item.confidence; match_reason = "直接匹配" }
          else
            { is_match = true; match_quality = item.confidence *. 0.8; match_reason = "相似匹配" }
          in
          (item.character, match_result, item.confidence)
        ) all_matches
    | Deep ->
        (* 深度查询：全面分析 *)
        let analysis, coverage, avg_conf, quality = AnalysisEngine.evaluate_rhyme_quality query.text in
        let suggestions = SuggestionEngine.suggest_improvements analysis in
        let match_result = {
          is_match = quality > 0.6;
          match_quality = quality;
          match_reason = Printf.sprintf "深度分析：覆盖率%.2f，平均置信度%.2f" coverage avg_conf;
        } in
        [(query.text, match_result, quality)]
  
  (** 批量查询处理 *)
  let batch_query queries =
    List.map execute_compound_query queries

end

(** === 公共接口函数 === *)

(** 查询字符匹配项 *)
let query_matches = QueryEngine.query_character_matches

(** 查找押韵字符 *)
let find_rhymes = QueryEngine.find_rhyme_matches

(** 按韵组查询 *)
let query_group = QueryEngine.query_by_group

(** 按声调查询 *)  
let query_category = QueryEngine.query_by_category

(** 生成建议 *)
let suggest_for_text = SuggestionEngine.generate_suggestions

(** 生成韵脚建议 *)
let suggest_endings = SuggestionEngine.suggest_rhyme_endings

(** 执行查询 *)
let execute_query = AdvancedQuery.execute_compound_query

(** 批量查询 *)
let batch_execute = AdvancedQuery.batch_query