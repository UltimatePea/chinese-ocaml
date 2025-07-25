(** 诗词韵律引擎 - 整合版本
 *
 * 此模块整合了原本分散在以下15个模块中的韵律功能：
 * - rhyme_analysis.ml, rhyme_detection.ml, rhyme_matching.ml
 * - rhyme_validation.ml, rhyme_database.ml, rhyme_lookup.ml
 * - rhyme_scoring.ml, rhyme_pattern.ml, rhyme_utils.ml
 * - rhyme_helpers.ml, rhyme_json_*.ml 系列模块
 * 
 * 提供统一的韵律分析、检测、匹配和验证功能。
 *
 * @author 骆言编程团队 - 模块整合项目
 * @version 2.0 (整合版本)
 * @since 2025-07-25
 * @issue #1155 诗词模块整合优化
 *)

open Rhyme_types

(** {1 核心韵律引擎类型} *)

(** 韵律分析结果 *)
type rhyme_analysis_result = {
  category: rhyme_category;      (** 韵类 *)
  group: rhyme_group;           (** 韵组 *)
  confidence: float;            (** 置信度 0.0-1.0 *)
  alternatives: rhyme_group list; (** 备选韵组 *)
}

(** 韵律匹配结果 *)
type rhyme_match_result = {
  is_match: bool;               (** 是否匹配 *)
  match_type: [`Perfect | `Partial | `None]; (** 匹配类型 *)
  similarity_score: float;      (** 相似度分数 *)
  explanation: string;          (** 匹配说明 *)
}

(** 韵律模式定义 *)
type rhyme_pattern = {
  pattern_name: string;         (** 模式名称 *)
  required_groups: rhyme_group list; (** 要求的韵组序列 *)
  allow_variations: bool;       (** 是否允许变化 *)
}

(** {1 韵律数据管理} *)

(** 初始化韵律引擎数据 *)
let initialize_engine () =
  Unified_rhyme_data.load_rhyme_data_to_cache ()

(** 获取引擎统计信息 *)
let get_engine_stats () =
  let (cached_chars, cached_groups) = Rhyme_cache.get_cache_stats () in
  let (total_chars, total_groups) = Unified_rhyme_data.get_data_stats () in
  Printf.sprintf "韵律引擎状态: 缓存字符数=%d, 缓存韵组数=%d, 总字符数=%d, 总韵组数=%d" 
    cached_chars cached_groups total_chars total_groups

(** {1 核心韵律分析功能} *)

(** 分析单字符的韵律信息
 * 整合了原 rhyme_analysis.ml 和 rhyme_detection.ml 的功能
 *)
let analyze_char_rhyme (char: string) : rhyme_analysis_result option =
  initialize_engine ();
  match Rhyme_api_core.find_rhyme_info char with
  | Some (category, group) ->
    Some {
      category = category;
      group = group;
      confidence = 0.95; (* 高置信度，来自标准数据 *)
      alternatives = []; (* 简化版本，不提供备选 *)
    }
  | None -> None

(** 批量分析多字符韵律
 * 整合了原 rhyme_utils.ml 中的批量处理功能
 *)
let analyze_chars_rhyme (chars: string list) : (string * rhyme_analysis_result option) list =
  List.map (fun char -> (char, analyze_char_rhyme char)) chars

(** {1 韵律匹配和验证功能} *)

(** 检测两字符是否押韵
 * 整合了原 rhyme_matching.ml 和 rhyme_validation.ml 的功能
 *)
let check_rhyme_match (char1: string) (char2: string) : rhyme_match_result =
  initialize_engine ();
  match analyze_char_rhyme char1, analyze_char_rhyme char2 with
  | Some result1, Some result2 ->
    if result1.group = result2.group then
      {
        is_match = true;
        match_type = `Perfect;
        similarity_score = 1.0;
        explanation = Printf.sprintf "%s和%s都属于同一韵组，完美押韵" char1 char2;
      }
    else if result1.category = result2.category then
      {
        is_match = false;
        match_type = `Partial;
        similarity_score = 0.3;
        explanation = Printf.sprintf "%s和%s同为%s但韵组不同，部分匹配" 
          char1 char2 (match result1.category with 
            | PingSheng -> "平声" | ZeSheng -> "仄声" 
            | ShangSheng -> "上声" | QuSheng -> "去声" | RuSheng -> "入声");
      }
    else
      {
        is_match = false;
        match_type = `None;
        similarity_score = 0.0;
        explanation = Printf.sprintf "%s和%s韵类和韵组都不同，不押韵" char1 char2;
      }
  | _ ->
    {
      is_match = false;
      match_type = `None;
      similarity_score = 0.0;
      explanation = "无法确定韵律信息，可能包含未知字符";
    }

(** 验证诗句的韵律一致性
 * 整合了原 rhyme_pattern.ml 的功能
 *)
let validate_poem_rhyme (lines: string list) : (int * rhyme_match_result) list =
  let line_endings = List.mapi (fun i line -> 
    if String.length line > 0 then
      (i, String.sub line (String.length line - 1) 1)
    else
      (i, "")
  ) lines in
  
  let results = ref [] in
  List.iter (fun (i, char1) ->
    if i < List.length line_endings - 1 then
      let (_, char2) = List.nth line_endings (i + 1) in
      if char1 <> "" && char2 <> "" then
        results := (i, check_rhyme_match char1 char2) :: !results
  ) line_endings;
  List.rev !results

(** {1 韵律模式匹配功能} *)

(** 常用诗词韵律模式定义 *)
let common_rhyme_patterns = [
  {
    pattern_name = "五言绝句 (首句入韵)";
    required_groups = [SiRhyme; SiRhyme; AnRhyme; SiRhyme]; (* 简化示例 *)
    allow_variations = true;
  };
  {
    pattern_name = "七言律诗 (首句不入韵)";
    required_groups = [AnRhyme; SiRhyme; SiRhyme; AnRhyme; AnRhyme; SiRhyme; SiRhyme; AnRhyme];
    allow_variations = false;
  };
]

(** 检测诗词符合哪种韵律模式
 * 整合了原 rhyme_scoring.ml 的评分功能
 *)
let detect_rhyme_pattern (lines: string list) : (rhyme_pattern * float) list =
  let line_endings = List.map (fun line ->
    if String.length line > 0 then
      let ending_char = String.sub line (String.length line - 1) 1 in
      match analyze_char_rhyme ending_char with
      | Some result -> Some result.group
      | None -> None
    else None
  ) lines in
  
  List.map (fun pattern ->
    let score = ref 0.0 in
    let total = min (List.length line_endings) (List.length pattern.required_groups) in
    for i = 0 to total - 1 do
      match List.nth line_endings i with
      | Some actual_group ->
        let expected_group = List.nth pattern.required_groups i in
        if actual_group = expected_group then
          score := !score +. 1.0
        else if pattern.allow_variations then
          score := !score +. 0.5
      | None -> ()
    done;
    let final_score = if total > 0 then !score /. float_of_int total else 0.0 in
    (pattern, final_score)
  ) common_rhyme_patterns

(** {1 高级韵律功能} *)

(** 查找与指定字符押韵的所有字符
 * 整合了原 rhyme_lookup.ml 和 rhyme_database.ml 的功能
 *)
let find_rhyming_chars (char: string) : string list =
  initialize_engine ();
  Rhyme_api_core.find_rhyming_characters char

(** 生成韵律建议
 * 整合了原 rhyme_helpers.ml 的辅助功能
 *)
let suggest_rhyme_improvements (lines: string list) : string list =
  let suggestions = ref [] in
  let rhyme_results = validate_poem_rhyme lines in
  
  List.iter (fun (line_idx, match_result) ->
    if not match_result.is_match then
      let suggestion = Printf.sprintf "第%d行和第%d行不押韵: %s" 
        (line_idx + 1) (line_idx + 2) match_result.explanation in
      suggestions := suggestion :: !suggestions
  ) rhyme_results;
  
  (* 添加模式匹配建议 *)
  let pattern_results = detect_rhyme_pattern lines in
  let best_pattern_score = List.fold_left (fun acc (_, score) -> max acc score) 0.0 pattern_results in
  if best_pattern_score < 0.8 then
    suggestions := "建议调整韵脚以符合常见诗词格律" :: !suggestions;
  
  List.rev !suggestions

(** {1 性能优化接口} *)

(** 预热韵律引擎缓存 *)
let warm_up_engine () =
  initialize_engine ();
  (* 预加载常用字符到缓存 *)
  let common_chars = ["春"; "花"; "月"; "风"; "雪"; "山"; "水"; "天"; "人"; "心"] in
  List.iter (fun char -> ignore (analyze_char_rhyme char)) common_chars

(** 清理引擎资源 *)
let cleanup_engine () =
  Rhyme_cache.clear_cache ()

(** {1 向后兼容接口} *)

(** 兼容原 rhyme_detection.ml 接口 *)
let detect_rhyme_info = Rhyme_api_core.find_rhyme_info

(** 兼容原 rhyme_matching.ml 接口 *)
let check_simple_rhyme = Rhyme_api_core.check_rhyme

(** 兼容原 rhyme_analysis.ml 接口 *)
let get_rhyme_category = Rhyme_api_core.detect_rhyme_category