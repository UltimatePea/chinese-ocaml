(** 统一韵律分析模块 - 整合基础与高级韵律分析功能
    
    古之诗者，音韵为要。声韵调谐，方称佳构。
    此模块整合原有的 rhyme_analysis 与 rhyme_advanced_analysis 两模块，
    提供统一的韵律分析接口，消除功能重复，提升代码质量。
    
    Author: Beta, 代码审查代理
    版本: 统一重构版 v1.0
    日期: 2025-07-28 *)

(* 导入核心类型和依赖模块 *)
open Poetry_core.Rhyme_core_types
open Poetry_types_consolidated

(* 为了兼容Rhyme_api_core返回的Rhyme_types前缀类型，创建别名 *)
module RT = Rhyme_types

(* 类型转换函数：从Rhyme_types到Poetry_core.Rhyme_core_types *)
let convert_category = function
  | RT.PingSheng -> PingSheng
  | RT.ZeSheng -> ZeSheng
  | RT.ShangSheng -> ShangSheng
  | RT.QuSheng -> QuSheng
  | RT.RuSheng -> RuSheng

let convert_group = function
  | RT.AnRhyme -> AnRhyme
  | RT.SiRhyme -> SiRhyme
  | RT.TianRhyme -> TianRhyme
  | RT.WangRhyme -> WangRhyme
  | RT.QuRhyme -> QuRhyme
  | RT.YuRhyme -> YuRhyme
  | RT.HuaRhyme -> HuaRhyme
  | RT.FengRhyme -> FengRhyme
  | RT.YueRhyme -> YueRhyme
  | RT.JiangRhyme -> JiangRhyme
  | RT.HuiRhyme -> HuiRhyme
  | RT.UnknownRhyme -> UnknownRhyme

(** {1 基础工具函数} *)

(** UTF-8字符列表转换函数 *)
let utf8_to_char_list s =
  let rec aux acc i =
    if i >= String.length s then List.rev acc 
    else aux (String.make 1 s.[i] :: acc) (i + 1)
  in
  aux [] 0

(** {1 基础韵律分析函数（原 rhyme_analysis.ml）} *)

(* 重新导出核心函数，保持向后兼容性 *)

(* 音韵匹配相关函数 *)
let find_rhyme_info = Rhyme_matching.find_rhyme_info
let detect_rhyme_category = Rhyme_matching.detect_rhyme_category
let detect_rhyme_category_by_string = Rhyme_matching.detect_rhyme_category_by_string
let detect_rhyme_group = Rhyme_matching.detect_rhyme_group
let chars_rhyme = Rhyme_matching.chars_rhyme
let suggest_rhyme_characters = Rhyme_matching.suggest_rhyme_characters

(* 韵律模式相关函数 *)
let extract_rhyme_ending = Rhyme_pattern.extract_rhyme_ending
let validate_rhyme_consistency = Rhyme_pattern.validate_rhyme_consistency
let validate_rhyme_scheme = Rhyme_pattern.validate_rhyme_scheme

(** 生成韵律报告 - 基础版本 *)
let generate_rhyme_report verse =
  let rhyme_ending_char = extract_rhyme_ending verse in
  let dominant_rhyme_group =
    match rhyme_ending_char with
    | Some char -> Rhyme_matching.detect_rhyme_group char
    | None -> UnknownRhyme
  in
  let dominant_rhyme_category =
    match rhyme_ending_char with
    | Some char -> Rhyme_matching.detect_rhyme_category char
    | None -> PingSheng
  in
  (* 使用 Poetry_core.Rhyme_core_types 的 verse_rhyme_analysis 类型 *)
  {
    verse_text = verse;
    rhyme_ending = (match rhyme_ending_char with Some c -> Some (String.make 1 c) | None -> None);
    dominant_rhyme_group = dominant_rhyme_group;
    dominant_rhyme_category = dominant_rhyme_category;
    char_analysis = []; (* 简化版本，暂时留空 *)
    rhyme_quality_score = 0.5; (* 默认评分 *)
  }

(** {1 高级韵律分析函数（原 rhyme_advanced_analysis.ml）} *)

(** 分析文本的韵律模式
    
    分析给定文本的整体韵律模式，返回韵类和韵组的统计信息。
    提供比基础版本更详细的统计分析功能。
    
    @param text 要分析的文本
    @return (韵类分布, 韵组分布) *)
let analyze_rhyme_pattern text =
  Unified_rhyme_data.load_rhyme_data_to_cache ();
  let chars = List.init (String.length text) (String.get text) in
  let string_chars = List.map (String.make 1) chars in

  let category_counts = Hashtbl.create 10 in
  let group_counts = Hashtbl.create 20 in

  List.iter
    (fun char ->
      match Rhyme_api_core.find_rhyme_info char with
      | Some (category, group) ->
          let converted_cat = convert_category category in
          let converted_grp = convert_group group in
          let cat_count = try Hashtbl.find category_counts converted_cat with Not_found -> 0 in
          let grp_count = try Hashtbl.find group_counts converted_grp with Not_found -> 0 in
          Hashtbl.replace category_counts converted_cat (cat_count + 1);
          Hashtbl.replace group_counts converted_grp (grp_count + 1)
      | None -> ())
    string_chars;

  let category_list = Hashtbl.fold (fun k v acc -> (k, v) :: acc) category_counts [] in
  let group_list = Hashtbl.fold (fun k v acc -> (k, v) :: acc) group_counts [] in
  (category_list, group_list)

(** 获取韵律数据统计信息 *)
let get_rhyme_stats () =
  Unified_rhyme_data.load_rhyme_data_to_cache ();
  let total_chars, total_groups = Rhyme_cache.get_cache_stats_global () in

  let category_counts = Hashtbl.create 10 in
  let all_chars = Rhyme_cache.get_all_cached_chars_global () in

  List.iter
    (fun char ->
      match Rhyme_api_core.find_rhyme_info char with
      | Some (category, _) ->
          let converted_cat = convert_category category in
          let count = try Hashtbl.find category_counts converted_cat with Not_found -> 0 in
          Hashtbl.replace category_counts converted_cat (count + 1)
      | None -> ())
    all_chars;

  let category_stats = Hashtbl.fold (fun k v acc -> (k, v) :: acc) category_counts [] in
  (total_chars, total_groups, category_stats)

(** 综合韵律分析结果类型 *)
type comprehensive_analysis = {
  basic_report : Poetry_types_consolidated.verse_rhyme_analysis;
  pattern_analysis : (rhyme_category * int) list * (rhyme_group * int) list;
  stats : int * int * (rhyme_category * int) list;
  analysis_version : string;
  timestamp : float;
}

(** 综合韵律分析 - 整合基础与高级分析
    
    结合基础韵律报告和高级模式分析，提供全面的韵律分析结果。
    这是新增的统一接口，体现重构的价值。 *)
let comprehensive_rhyme_analysis text =
  let basic_report = generate_rhyme_report text in
  let pattern_analysis = analyze_rhyme_pattern text in
  let stats = get_rhyme_stats () in
  
  {
    basic_report;
    pattern_analysis = pattern_analysis;
    stats;
    analysis_version = "unified_v1.0";
    timestamp = Unix.time ();
  }

(** {1 向后兼容性接口} *)

(* 保持原有接口名称，方便迁移 *)
let analyze_rhyme_pattern_basic = generate_rhyme_report
let analyze_rhyme_pattern_advanced = analyze_rhyme_pattern

(** 韵律质量评估 - 统一评估标准 *)
let evaluate_rhyme_quality verse =
  let report = generate_rhyme_report verse in
  let (categories, groups) = analyze_rhyme_pattern verse in
  
  (* 基于统计信息计算质量分数 *)
  let category_diversity = List.length categories in
  let group_diversity = List.length groups in
  let base_score = report.rhyme_quality_score in
  
  (* 多样性加分 *)
  let diversity_bonus = (float_of_int category_diversity) *. 0.1 +. (float_of_int group_diversity) *. 0.05 in
  let final_score = min 1.0 (base_score +. diversity_bonus) in
  
  {
    report with 
    rhyme_quality_score = final_score;
  }