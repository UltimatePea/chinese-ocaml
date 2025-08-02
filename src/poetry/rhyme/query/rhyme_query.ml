(** 骆言韵律查询统一模块 - Phase 1整合版本
    
    Author: Whisky, PR Worker
    Date: 2025-08-02
    Issue: #2084 Poetry模块架构整合计划
    
    此模块整合了以下分散的韵律查询模块：
    - rhyme_query_engine.ml (查询引擎)
    - data/rhyme_query_engine.ml (数据查询)
    - rhyme_lookup.ml (韵律查找)
    - rhyme_scoring.ml (韵律评分)
    - rhyme_utils.ml (工具函数)
    
    整合目标: 5个查询文件 → 1个统一查询模块
    *)

open Poetry_core.Poetry_types

(** {1 辅助函数} *)

(** 从列表中取前n个元素 *)
let rec list_take n lst =
  if n <= 0 || lst = [] then []
  else List.hd lst :: list_take (n - 1) (List.tl lst)

(** {1 查询结果类型} *)

type rhyme_search_result = {
  query: string;
  matches: (string * float) list;  (* 字符和相似度 *)
  total_matches: int;
  execution_time: float;
}

type rhyme_similarity_result = {
  char1: string;
  char2: string;
  group_similarity: float;
  category_similarity: float;
  overall_similarity: float;
  explanation: string;
}

type batch_query_result = {
  queries: string list;
  results: rhyme_search_result list;
  success_rate: float;
  total_time: float;
}

(** {2 查询配置} *)

type query_config = {
  max_results: int;
  similarity_threshold: float;
  include_variants: bool;
  group_weight: float;
  category_weight: float;
}

let default_query_config = {
  max_results = 50;
  similarity_threshold = 0.3;
  include_variants = true;
  group_weight = 0.7;
  category_weight = 0.3;
}

(** {3 核心查询功能} *)

(** 查找与指定字符押韵的所有字符 *)
let find_rhyming_characters ?(config = default_query_config) target_char =
  let start_time = Unix.time () in
  
  match Rhyme_database.find_character_rhyme target_char with
  | None -> {
      query = target_char;
      matches = [];
      total_matches = 0;
      execution_time = Unix.time () -. start_time;
    }
  | Some target_entry ->
      let all_data = Rhyme_database.get_rhyme_data_simple () in
      let matches = List.fold_left (fun acc (char, category, group) ->
        if String.equal char target_char then acc
        else
          let group_match = if group = target_entry.group then config.group_weight else 0.0 in
          let category_match = if category = target_entry.category then config.category_weight else 0.0 in
          let similarity = group_match +. category_match in
          
          if similarity >= config.similarity_threshold then
            (char, similarity) :: acc
          else acc
      ) [] all_data in
      
      let sorted_matches = List.sort (fun (_, s1) (_, s2) -> 
        Float.compare s2 s1
      ) matches in
      
      let limited_matches = 
        if List.length sorted_matches > config.max_results then
          list_take config.max_results sorted_matches
        else sorted_matches
      in
      
      {
        query = target_char;
        matches = limited_matches;
        total_matches = List.length matches;
        execution_time = Unix.time () -. start_time;
      }

(** 计算两个字符的韵律相似度 *)
let calculate_rhyme_similarity ?(config = default_query_config) char1 char2 =
  match (Rhyme_database.find_character_rhyme char1, Rhyme_database.find_character_rhyme char2) with
  | (Some entry1, Some entry2) ->
      let group_similarity = 
        if entry1.group = entry2.group then 1.0 else 0.0
      in
      let category_similarity =
        if entry1.category = entry2.category then 1.0 
        else if (is_ping_sheng entry1.category && is_ping_sheng entry2.category) ||
                (is_ze_sheng entry1.category && is_ze_sheng entry2.category) then 0.5
        else 0.0
      in
      let overall_similarity = 
        (group_similarity *. config.group_weight) +. 
        (category_similarity *. config.category_weight)
      in
      let explanation = 
        if group_similarity = 1.0 && category_similarity = 1.0 then
          "韵组和声调完全匹配"
        else if group_similarity = 1.0 then
          "韵组匹配，声调不同"
        else if category_similarity > 0.0 then
          "声调类型相近，韵组不同"
        else
          "韵组和声调都不匹配"
      in
      {
        char1;
        char2;
        group_similarity;
        category_similarity;
        overall_similarity;
        explanation;
      }
  | _ -> {
      char1;
      char2;
      group_similarity = 0.0;
      category_similarity = 0.0;
      overall_similarity = 0.0;
      explanation = "字符韵律信息不完整";
    }

(** {4 批量查询功能} *)

(** 批量查找韵律匹配 *)
let batch_find_rhymes ?(config = default_query_config) characters =
  let start_time = Unix.time () in
  let results = List.map (find_rhyming_characters ~config) characters in
  let success_count = List.fold_left (fun acc result ->
    if result.total_matches > 0 then acc + 1 else acc
  ) 0 results in
  let success_rate = 
    if List.length characters > 0 then
      float_of_int success_count /. float_of_int (List.length characters)
    else 0.0
  in
  {
    queries = characters;
    results;
    success_rate;
    total_time = Unix.time () -. start_time;
  }

(** 查找韵组内的所有字符 *)
let find_characters_in_group group =
  Rhyme_database.get_all_characters_in_group group

(** {5 高级查询功能} *)

(** 查找最佳韵律匹配 *)
let find_best_rhyme_match ?(config = default_query_config) target_char =
  let result = find_rhyming_characters ~config target_char in
  match result.matches with
  | [] -> None
  | (best_char, score) :: _ -> Some (best_char, score)

(** 按韵组分组查询结果 *)
let group_matches_by_rhyme matches =
  let group_table = Hashtbl.create 16 in
  List.iter (fun (char, score) ->
    match Rhyme_database.find_character_rhyme char with
    | Some entry ->
        let current_list = try Hashtbl.find group_table entry.group with Not_found -> [] in
        Hashtbl.replace group_table entry.group ((char, score) :: current_list)
    | None -> ()
  ) matches;
  
  Hashtbl.fold (fun group chars acc ->
    (group, List.sort (fun (_, s1) (_, s2) -> Float.compare s2 s1) chars) :: acc
  ) group_table []

(** {6 查询统计和分析} *)

(** 分析查询结果质量 *)
let analyze_query_quality result =
  let high_quality = List.length (List.filter (fun (_, score) -> score > 0.8) result.matches) in
  let medium_quality = List.length (List.filter (fun (_, score) -> score > 0.5 && score <= 0.8) result.matches) in
  let low_quality = List.length (List.filter (fun (_, score) -> score <= 0.5) result.matches) in
  
  Printf.sprintf "查询质量分析 - 高质量: %d, 中等质量: %d, 低质量: %d" 
    high_quality medium_quality low_quality

(** 获取查询性能统计 *)
let get_performance_stats results =
  let total_queries = List.length results in
  let total_time = List.fold_left (fun acc r -> acc +. r.execution_time) 0.0 results in
  let avg_time = if total_queries > 0 then total_time /. float_of_int total_queries else 0.0 in
  let total_matches = List.fold_left (fun acc r -> acc + r.total_matches) 0 results in
  
  Printf.sprintf "性能统计 - 总查询: %d, 总时间: %.3fs, 平均时间: %.3fs, 总匹配: %d"
    total_queries total_time avg_time total_matches

(** {7 实用工具函数} *)

(** 格式化查询结果为字符串 *)
let format_search_result result =
  let matches_str = String.concat ", " (List.map (fun (char, score) ->
    Printf.sprintf "%s(%.2f)" char score
  ) (list_take 10 result.matches)) in
  
  Printf.sprintf "查询: %s | 匹配: %d | 结果: %s | 耗时: %.3fs"
    result.query result.total_matches matches_str result.execution_time

(** 导出查询结果为JSON *)
let export_result_to_json result =
  let matches_json = String.concat "," (List.map (fun (char, score) ->
    Printf.sprintf {|{"character":"%s","score":%.2f}|} char score
  ) result.matches) in
  
  Printf.sprintf {|{
  "query": "%s",
  "total_matches": %d,
  "execution_time": %.3f,
  "matches": [%s]
}|} result.query result.total_matches result.execution_time matches_json

(** {8 向后兼容接口} *)

(** 兼容旧版本的查询接口 *)
let query_rhyme_matches = find_rhyming_characters
let rhyme_similarity_score = calculate_rhyme_similarity
let get_rhyme_group_chars = find_characters_in_group

(** 兼容函数 - 简单韵律检查 *)
let simple_rhyme_check char1 char2 =
  let similarity = calculate_rhyme_similarity char1 char2 in
  similarity.overall_similarity > 0.5