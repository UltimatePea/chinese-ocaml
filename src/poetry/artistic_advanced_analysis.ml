(** 骆言诗词高阶艺术性分析模块
    
    从poetry_artistic_core.ml重构而来，提供高级分析功能和智能评价助手。
    
    @author 骆言技术债务清理团队 - Alpha Agent
    @version 1.0 - 重构版本
    @since 2025-07-25 *)

open Poetry_types_consolidated
open Poetry_rhyme_core
open Artistic_core_evaluators
open Artistic_form_evaluators

(** {1 传统诗词品评函数} *)

(** 传统诗词品评
    @param verse 诗句
    @param form 诗词形式
    @return 带有品评意见的艺术性评价报告 *)
let poetic_critique verse form =
  let base_report = comprehensive_artistic_evaluation verse None in
  let critique_suggestions = match form with
    | SiYanPianTi | SiYanParallelProse ->
      ["骈体之美在于对仗工整，声韵和谐"]
    | WuYanLuShi ->
      ["律诗之妙在于格律严谨，意境深远"]  
    | QiYanJueJu ->
      ["绝句之巧在于起承转合，言简意赅"]
    | _ ->
      ["诗词之道，在于意境与声韵并重"]
  in
  { base_report with suggestions = critique_suggestions }

(** 诗词美学指导
    @param verse 诗句
    @param form 诗词形式
    @return 带有美学指导的艺术性评价报告 *)
let poetic_aesthetics_guidance verse form =
  let base_report = comprehensive_artistic_evaluation verse None in
  let guidance = match form with
    | SiYanPianTi | SiYanParallelProse ->
      ["注重对偶工整"; "追求声律和谐"; "用词典雅得体"]
    | WuYanLuShi ->
      ["遵循格律规范"; "中间两联对仗"; "首尾呼应"]
    | QiYanJueJu ->
      ["起句立意"; "承句发展"; "转句生变"; "合句收束"]
    | _ ->
      ["意境为先"; "声韵和谐"; "用词精练"]
  in
  { base_report with suggestions = guidance }

(** {1 高阶艺术性分析函数} *)

(** 计算综合艺术性评分
    @param report 艺术性评价报告
    @return 综合评分 *)
let calculate_overall_score report =
  (report.rhyme_score +. report.tone_score +. report.parallelism_score +.
   report.imagery_score +. report.rhythm_score +. report.elegance_score) /. 6.0

(** 分析诗句组的艺术性发展趋势
    @param verses 诗句数组
    @return 各句的艺术性评分列表 *)
let analyze_artistic_progression verses =
  Array.map (fun verse ->
    let report = comprehensive_artistic_evaluation verse None in
    calculate_overall_score report
  ) verses |> Array.to_list

(** 比较两首诗的艺术性质量
    @param verse1 第一首诗
    @param verse2 第二首诗
    @return 比较结果：1表示第一首更好，-1表示第二首更好，0表示相等 *)
let compare_artistic_quality verse1 verse2 =
  let score1 = let r = comprehensive_artistic_evaluation verse1 None in calculate_overall_score r in
  let score2 = let r = comprehensive_artistic_evaluation verse2 None in calculate_overall_score r in
  if score1 > score2 then 1
  else if score1 < score2 then -1
  else 0

(** 检测诗句的艺术性缺陷
    @param verse 诗句
    @return 检测到的缺陷列表 *)
let detect_artistic_flaws verse =
  let report = comprehensive_artistic_evaluation verse None in
  let flaws = ref [] in
  
  if report.rhyme_score < 0.5 then
    flaws := "韵律和谐度不足" :: !flaws;
  if report.tone_score < 0.5 then
    flaws := "平仄搭配不当" :: !flaws;
  if report.imagery_score < 0.5 then
    flaws := "意象贫乏" :: !flaws;
  if report.rhythm_score < 0.5 then
    flaws := "节奏感不强" :: !flaws;
  if report.elegance_score < 0.5 then
    flaws := "用词不够雅致" :: !flaws;
    
  List.rev !flaws

(** {1 评价标准配置} *)

module ArtisticStandards = struct
  (** 四言诗艺术标准 *)
  let siyan_standards = {
    char_count = 4;
    tone_pattern = [true; false; true; false];  (* 简化的平仄模式 *)
    parallelism_required = true;
    rhythm_weight = 0.3;
  }

  (** 五言律诗艺术标准 *)
  let wuyan_lushi_standards : Poetry_types_consolidated.wuyan_lushi_standards = {
    line_count = 8;
    char_per_line = 5;
    rhyme_scheme = [|false; true; false; true; false; true; false; true|];
    parallelism_required = [|false; false; true; true; true; true; false; false|];
    tone_pattern = [];  (* 简化版本暂不实现详细平仄模式 *)
    rhythm_weight = 0.25;
  }

  (** 七言绝句艺术标准 *)
  let qiyan_jueju_standards = {
    line_count = 4;
    char_per_line = 7;
    rhyme_scheme = [|false; true; false; true|];
    parallelism_required = [|false; false; false; false|];
    tone_pattern = [];
    rhythm_weight = 0.2;
  }

  (** 获取特定诗词形式的评价权重
      @param form 诗词形式
      @return 各维度评价权重列表 [韵律;声调;对仗;意象;节奏;雅致] *)
  let get_standards_for_form = function
    | SiYanPianTi | SiYanParallelProse -> [0.2; 0.25; 0.3; 0.1; 0.1; 0.05]
    | WuYanLuShi -> [0.25; 0.25; 0.25; 0.1; 0.1; 0.05]
    | QiYanJueJu -> [0.3; 0.2; 0.1; 0.2; 0.15; 0.05]
    | _ -> [0.2; 0.2; 0.2; 0.2; 0.15; 0.05]  (* 默认权重 *)
end

(** {1 智能评价助手} *)

module IntelligentEvaluator = struct
  (** 自动检测诗词形式
      @param verses 诗句数组
      @return 检测到的诗词形式 *)
  let auto_detect_form verses =
    let verse_count = Array.length verses in
    if verse_count = 0 then ModernPoetry
    else
      let first_len = String.length verses.(0) in
      match verse_count, first_len with
      | 4, 7 -> QiYanJueJu
      | 8, 5 -> WuYanLuShi
      | _, 4 -> SiYanPianTi
      | _ -> ModernPoetry

  (** 自适应诗词评价
      @param verses 诗句数组
      @return 完整的诗词评价分析报告 *)
  let adaptive_evaluation verses =
    let form = auto_detect_form verses in
    let report = evaluate_poetry_by_form form verses in
    {
      poem_text = Array.to_list verses;
      form;
      verse_summaries = [];  (* 简化版本 *)
      overall_rhyme = analyze_poem_rhyme (Array.to_list verses);
      overall_artistic = {
        rhyme_harmony = report.rhyme_score;
        tonal_balance = report.tone_score;
        parallelism = report.parallelism_score;
        imagery = report.imagery_score;
        rhythm = report.rhythm_score;
        elegance = report.elegance_score;
      };
      final_grade = report.overall_grade;
      critique = match report.overall_grade with
        | Excellent -> "艺术性优秀，达到很高水准"
        | Good -> "艺术性良好，有进一步提升空间"
        | Fair -> "艺术性一般，需要多方面改进"
        | Poor -> "艺术性较差，建议重新创作";
    }

  (** 智能建议生成
      @param verses 诗句数组
      @return 针对性建议列表 *)
  let smart_suggestions verses =
    let analysis = adaptive_evaluation verses in
    let base_suggestions = match analysis.final_grade with
      | Excellent -> ["已达很高水准，可尝试更复杂的形式"]
      | Good -> ["整体不错，可在意象和用词上进一步提升"]
      | Fair -> ["需要加强韵律和平仄的把握"]
      | Poor -> ["建议从基础格律学起，多读经典作品"]
    in
    
    let form_specific = match analysis.form with
      | SiYanPianTi -> ["注重对仗的工整性"]
      | WuYanLuShi -> ["严格遵循律诗格律"]
      | QiYanJueJu -> ["注意起承转合的结构"]
      | _ -> ["发挥自由创作的优势"]
    in
    
    base_suggestions @ form_specific
end