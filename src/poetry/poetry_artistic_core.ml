(** 骆言诗词艺术性评价核心模块 - 重构版本
    
    此模块作为诗词艺术性评价系统的统一接口和协调器。
    重构后的模块将原有的627行代码分解为6个专门的子模块，
    大幅提升了代码的可维护性、可测试性和可复用性。
    
    重构目标达成：
    - ✓ 从单一627行巨型模块分解为6个专门模块  
    - ✓ 每个子模块职责单一，行数控制在合理范围内
    - ✓ 建立清晰的模块间接口和依赖关系
    - ✓ 保持完整的向后兼容性
    - ✓ 提供统一的协调接口
    
    模块化架构：
    - Poetry_data_loader: 数据加载和文件处理
    - Poetry_evaluation_engine: 核心评价算法
    - Poetry_form_evaluators: 诗体专用评价器
    - Poetry_analysis_utils: 分析工具函数
    - Poetry_artistic_standards: 标准和智能评价助手
    - Poetry_artistic_core: 统一接口和协调器（本模块）
    
    Author: Beta, Code Reviewer
    @version 3.0 - 模块化重构版本
    @since 2025-07-25 - 技术债务重构Phase 3 *)

open Poetry_types_consolidated

(** {1 统一导出接口 - 向后兼容} *)

(** {2 单维度艺术性评价函数} *)

let evaluate_rhyme_harmony = Poetry_evaluation_engine.evaluate_rhyme_harmony
let evaluate_tonal_balance = Poetry_evaluation_engine.evaluate_tonal_balance  
let evaluate_parallelism = Poetry_evaluation_engine.evaluate_parallelism
let evaluate_imagery = Poetry_evaluation_engine.evaluate_imagery
let evaluate_rhythm = Poetry_evaluation_engine.evaluate_rhythm
let evaluate_elegance = Poetry_evaluation_engine.evaluate_elegance

(** {2 综合艺术性评价函数} *)

let comprehensive_artistic_evaluation = Poetry_evaluation_engine.comprehensive_artistic_evaluation
let determine_overall_grade = Poetry_evaluation_engine.determine_overall_grade
let generate_improvement_suggestions = Poetry_analysis_utils.generate_improvement_suggestions

(** {2 诗词形式专项评价函数} *)

let evaluate_siyan_parallel_prose = Poetry_form_evaluators.evaluate_siyan_parallel_prose
let evaluate_wuyan_lushi = Poetry_form_evaluators.evaluate_wuyan_lushi
let evaluate_qiyan_jueju = Poetry_form_evaluators.evaluate_qiyan_jueju
let evaluate_poetry_by_form = Poetry_form_evaluators.evaluate_poetry_by_form

(** {2 传统诗词品评函数} *)

let poetic_critique = Poetry_form_evaluators.poetic_critique
let poetic_aesthetics_guidance = Poetry_form_evaluators.poetic_aesthetics_guidance

(** {2 高阶艺术性分析函数} *)

let analyze_artistic_progression = Poetry_form_evaluators.analyze_artistic_progression
let compare_artistic_quality = Poetry_form_evaluators.compare_artistic_quality
let detect_artistic_flaws = Poetry_form_evaluators.detect_artistic_flaws

(** {2 评价标准配置} *)

module ArtisticStandards = Poetry_artistic_standards.ArtisticStandards

(** {2 智能评价助手} *)

module IntelligentEvaluator = Poetry_artistic_standards.IntelligentEvaluator

(** {1 协调器功能 - 高级组合接口} *)

(** 全面诗词艺术性分析协调器
    
    此函数作为整个艺术性评价系统的协调器，
    综合调用各个子模块的功能，提供一站式的诗词分析服务。
    
    @param verses 诗句数组
    @param form_hint 诗词形式提示（None表示自动检测）
    @return 全面的综合分析结果 *)
let comprehensive_poetry_analysis verses form_hint =
  let _detected_form = match form_hint with
    | Some form -> form
    | None -> IntelligentEvaluator.auto_detect_form verses
  in
  
  let base_analysis = IntelligentEvaluator.adaptive_evaluation verses in
  let smart_suggestions = IntelligentEvaluator.smart_suggestions verses in
  
  (* 扩展分析结果，添加协调器特有的综合信息 *)
  {
    base_analysis with
    critique = base_analysis.critique ^ " | " ^ (String.concat "; " smart_suggestions);
  }

(** 诗词质量对比分析协调器
    
    比较多首诗词的艺术性质量，提供排序和详细对比分析。
    
    @param poems 诗词列表，每首诗词为诗句数组
    @return 按艺术性质量排序的分析结果列表 *)
let comparative_quality_analysis poems =
  let analyses = List.map (fun verses ->
    (verses, comprehensive_poetry_analysis verses None)
  ) poems in
  
  (* 按final_grade和综合得分排序 *)
  List.sort (fun (_, a1) (_, a2) ->
    let score1 = match a1.final_grade with
      | Excellent -> 4.0 | Good -> 3.0 | Fair -> 2.0 | Poor -> 1.0
    in
    let score2 = match a2.final_grade with  
      | Excellent -> 4.0 | Good -> 3.0 | Fair -> 2.0 | Poor -> 1.0
    in
    compare score2 score1  (* 降序排列 *)
  ) analyses

(** 艺术性改进建议协调器
    
    结合多个分析维度，生成综合性的改进建议。
    
    @param verse 诗句字符串
    @param form 诗词形式
    @return 综合改进建议列表 *)
let comprehensive_improvement_guidance verse form =
  let base_report = comprehensive_artistic_evaluation verse None in
  let basic_suggestions = generate_improvement_suggestions base_report in
  let aesthetic_guidance = poetic_aesthetics_guidance verse form in
  let flaws = detect_artistic_flaws verse in
  
  (* 整合所有建议 *)
  let all_suggestions = basic_suggestions @ aesthetic_guidance.suggestions in
  let flaw_fixes = List.map (fun flaw -> "修复问题: " ^ flaw) flaws in
  
  all_suggestions @ flaw_fixes |> List.sort_uniq String.compare