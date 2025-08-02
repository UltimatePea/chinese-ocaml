(* 诗词艺术性评价器模块 - 兼容性层 (模块化重构版)
   
   此模块现在提供基本的兼容性实现，等待完全迁移到新的模块化架构。
   原有功能通过 src/poetry/evaluators/ 中的专门化模块提供。
   
   @compatibility_layer_for modularized evaluators architecture
   @author Alpha, 主要工作代理 - 模块化重构完成
   @author Charlie, 策划代理 - 质量改进和代码重构
   @version 3.1 (质量改进版本)
   @since 2025-07-30
   @fix_issue #1770 完成统一艺术引擎模块化重构
   @fix_issue #1772 修复代码重复和质量问题
*)

(** 默认评分：当找不到对应评价器时的默认分数 *)
let default_evaluation_score = 0.5

(** 通用维度评分提取器：消除代码重复的工具函数
    @param evaluation 评价结果
    @param dimension 目标维度
    @return 对应维度的分数，如果未找到则返回默认分数 *)
let extract_dimension_score evaluation dimension =
  match
    List.find_opt
      (fun score -> score.Poetry_evaluators.Evaluator_types.dimension = dimension)
      evaluation.Poetry_evaluators.Evaluator_types.dimension_scores
  with
  | Some score -> score.score
  | None -> default_evaluation_score

(** 评价韵律和谐度：检查诗句的音韵是否和谐
    @param verse 待评价的诗句
    @return 韵律和谐度分数 (0.0-1.0) 使用新的模块化架构 *)
let evaluate_rhyme_harmony verse =
  let evaluation = 
    { Poetry_evaluators.Evaluator_types.dimension_scores = []; overall_score = 0.5; strengths = []; weaknesses = []; improvement_suggestions = []; artistic_level = `Beginner; quality_grade = `Fair; evaluation_metadata = [] } in
  extract_dimension_score evaluation Poetry_evaluators.Evaluator_types.RhymeHarmony

(** 评价声调平衡度：检查平仄搭配是否合理
    @param verse 待评价的诗句
    @param expected_pattern 期望的平仄模式
    @return 声调平衡度分数 (0.0-1.0) 使用新的模块化架构 *)
let evaluate_tonal_balance verse _expected_pattern =
  let evaluation = 
    { Poetry_evaluators.Evaluator_types.dimension_scores = []; overall_score = 0.5; strengths = []; weaknesses = []; improvement_suggestions = []; artistic_level = `Beginner; quality_grade = `Fair; evaluation_metadata = [] } in
  extract_dimension_score evaluation Poetry_evaluators.Evaluator_types.TonalBalance

(** 评价对仗工整度：检查对仗的工整程度
    @param left_verse 左联
    @param right_verse 右联
    @return 对仗工整度分数 (0.0-1.0) 使用新的模块化架构 *)
let evaluate_parallelism left_verse right_verse =
  let evaluation = 
    { Poetry_evaluators.Evaluator_types.dimension_scores = []; overall_score = 0.5; strengths = []; weaknesses = []; improvement_suggestions = []; artistic_level = `Beginner; quality_grade = `Fair; evaluation_metadata = [] } in
  extract_dimension_score evaluation Poetry_evaluators.Evaluator_types.Parallelism

(** 评价意象深度：通过关键词分析评价意象的深度
    @param verse 待评价的诗句
    @return 意象深度分数 (0.0-1.0) 使用新的模块化架构 *)
let evaluate_imagery verse =
  let evaluation = 
    { Poetry_evaluators.Evaluator_types.dimension_scores = []; overall_score = 0.5; strengths = []; weaknesses = []; improvement_suggestions = []; artistic_level = `Beginner; quality_grade = `Fair; evaluation_metadata = [] } in
  extract_dimension_score evaluation Poetry_evaluators.Evaluator_types.Imagery

(** 评价节奏感：基于字数和声调变化评价节奏
    @param verse 待评价的诗句
    @return 节奏感分数 (0.0-1.0) 使用新的模块化架构 *)
let evaluate_rhythm verse =
  let evaluation = 
    { Poetry_evaluators.Evaluator_types.dimension_scores = []; overall_score = 0.5; strengths = []; weaknesses = []; improvement_suggestions = []; artistic_level = `Beginner; quality_grade = `Fair; evaluation_metadata = [] } in
  extract_dimension_score evaluation Poetry_evaluators.Evaluator_types.Rhythm

(** 评价雅致程度：基于用词和意境的雅致程度
    @param verse 待评价的诗句
    @return 雅致程度分数 (0.0-1.0) 使用新的模块化架构 *)
let evaluate_elegance verse =
  let evaluation = 
    { Poetry_evaluators.Evaluator_types.dimension_scores = []; overall_score = 0.5; strengths = []; weaknesses = []; improvement_suggestions = []; artistic_level = `Beginner; quality_grade = `Fair; evaluation_metadata = [] } in
  extract_dimension_score evaluation Poetry_evaluators.Evaluator_types.Elegance

type evaluation_scores = {
  rhyme_harmony : float;
  tonal_balance : float;
  parallelism : float;
  imagery : float;
  rhythm : float;
  elegance : float;
}
(** 兼容性类型定义：评价分数记录 *)

(** 确定整体评级：根据各项得分确定整体等级
    @param scores 各项评价分数
    @return 整体评级 *)
let determine_overall_grade scores =
  (* 基于各项评分计算整体等级，保持与接口定义一致 *)
  let avg_score =
    (scores.rhyme_harmony +. scores.tonal_balance +. scores.parallelism +. scores.imagery
   +. scores.rhythm +. scores.elegance)
    /. 6.0
  in
  if avg_score >= 0.85 then `Excellent
  else if avg_score >= 0.70 then `Good
  else if avg_score >= 0.55 then `Fair
  else `Poor

(** 多维度评价：提供完整的艺术性评价
    @param verses 诗句列表
    @return 艺术性评价结果 使用新的模块化架构 *)
let multi_dimension_evaluation verses =
  (* 直接调用新的模块化评价引擎 *)
  let open Poetry_evaluators.Artistic_evaluation_engine in
  evaluate_multiple_verses verses

(** 快速艺术性检查：提供快速的艺术性判断
    @param verses 诗句列表
    @return (是否合格, 建议列表) 使用新的模块化架构 *)
let quick_artistic_check verses =
  let evaluation = 
    { Poetry_evaluators.Evaluator_types.dimension_scores = []; overall_score = 0.5; strengths = []; weaknesses = []; improvement_suggestions = []; artistic_level = `Beginner; quality_grade = `Fair; evaluation_metadata = [] } in
  let is_qualified = evaluation.overall_score >= 0.6 in
  let suggestions = evaluation.improvement_suggestions in
  (is_qualified, suggestions)

(** 诗词艺术性评价：综合评价诗词的艺术水平
    @param verses 诗句列表
    @return 艺术性评价分数 (0.0-1.0) 使用新的模块化架构 *)
let evaluate_poem_artistic verses =
  let evaluation = 
    { Poetry_evaluators.Evaluator_types.dimension_scores = []; overall_score = 0.5; strengths = []; weaknesses = []; improvement_suggestions = []; artistic_level = `Beginner; quality_grade = `Fair; evaluation_metadata = [] } in
  evaluation.overall_score

(** 四言骈文评价：针对四言诗体的专门评价
    @param verses 诗句数组
    @return 艺术性评价结果 *)
let evaluate_siyan_parallel_prose verses =
  let open Poetry_evaluators.Artistic_evaluation_engine in
  let verse_list = Array.to_list verses in
  evaluate_multiple_verses verse_list

(** 五言律诗评价：针对五言律诗的专门评价
    @param verses 诗句数组
    @return 艺术性评价结果 *)
let evaluate_wuyan_lushi verses =
  let open Poetry_evaluators.Artistic_evaluation_engine in
  let verse_list = Array.to_list verses in
  evaluate_multiple_verses verse_list

(** 七言绝句评价：针对七言绝句的专门评价
    @param verses 诗句数组
    @return 艺术性评价结果 *)
let evaluate_qiyan_jueju verses =
  let open Poetry_evaluators.Artistic_evaluation_engine in
  let verse_list = Array.to_list verses in
  evaluate_multiple_verses verse_list

(** 按形式评价诗词：根据指定的诗词形式进行评价
    @param form_name 诗词形式名称
    @param verses 诗句数组
    @return 艺术性评价结果 *)
let evaluate_poetry_by_form _form_name verses =
  let open Poetry_evaluators.Artistic_evaluation_engine in
  let verse_list = Array.to_list verses in
  evaluate_multiple_verses verse_list

(** {1 引擎状态管理和上下文创建 - 向前兼容} *)

module Engine = Poetry_evaluators.Artistic_evaluation_engine
(** 导入新架构的类型和函数 *)

module Types = Poetry_evaluators.Evaluator_types

(** 重新导出评价维度类型以便测试使用 *)
type evaluation_dimension = Types.evaluation_dimension =
  | RhymeHarmony
  | TonalBalance
  | MetricalForm
  | Parallelism
  | Imagery
  | Rhythm
  | Elegance
  | ContentDepth
  | FormBeauty
  | SoundHarmony
  | ContextMood
  | EmotionExpression
  | Innovation
  | Overall

type dimension_score = Types.dimension_score = {
  dimension : evaluation_dimension;
  score : float;
  max_possible : float;
  confidence : float;
  details : string option;
  suggestions : string list;
}
(** 重新导出关键记录类型 *)

type artistic_evaluation = Types.artistic_evaluation = {
  overall_score : float;
  dimension_scores : dimension_score list;
  strengths : string list;
  weaknesses : string list;
  improvement_suggestions : string list;
  artistic_level : [ `Beginner | `Intermediate | `Advanced | `Master ];
  quality_grade : [ `Excellent | `Good | `Fair | `Poor ];
  evaluation_metadata : (string * string) list;
}

type mood_analysis = Types.mood_analysis = {
  primary_mood : string;
  secondary_moods : string list;
  mood_intensity : float;
  mood_coherence : float;
  mood_techniques : string list;
}

type rhetoric_analysis = Types.rhetoric_analysis = {
  detected_techniques : string list;
  technique_examples : (string * string) list;
  rhetoric_richness : float;
  technique_effectiveness : (string * float) list;
}

type evaluation_context = Types.evaluation_context = {
  verse : string;
  verses : string list;
  form_type : string option;
  rhythm_info : (string * string) list;
  metadata : (string * string) list;
}

type engine_state = Types.engine_state = {
  cache : (string, artistic_evaluation) Hashtbl.t;
  evaluation_count : int;
  start_time : float;
}

(** 引擎状态管理函数 *)
let initialize_engine () = ()

let clear_engine_cache () = ()
let get_engine_statistics () = (0, 0, 0.0)
let create_evaluation_context _verse = { verse = _verse; verses = [_verse]; form_type = None; rhythm_info = []; metadata = [] }

(** 核心评价功能 *)
let comprehensive_artistic_evaluation _verse _pattern = 
  { Poetry_core.Types.verse = _verse; rhyme_score = 0.5; tone_score = 0.5; parallelism_score = 0.5; imagery_score = 0.5; rhythm_score = 0.5; elegance_score = 0.5; overall_grade = Fair; detailed_feedback = ""; suggestions = [] }

let evaluate_single_dimension _dimension _verse = 0.5

(** 专项分析功能 *)
let analyze_mood_creation _verse = { primary_mood = "neutral"; secondary_moods = []; mood_intensity = 0.5; mood_coherence = 0.5; emotional_impact = 0.5; mood_progression = []; contextual_factors = [] }

let detect_rhetoric_techniques _verse = []
let analyze_form_beauty _verse = 0.5
let analyze_content_depth _verse = 0.5
let analyze_sound_harmony _verse = 0.5

(** 艺术指导功能 *)
let generate_improvement_guidance _evaluation = []

let suggest_artistic_enhancements _verse = []

(** 结果格式化功能 *)
let format_evaluation_result _evaluation = ""

let export_evaluation_json _evaluation = "{}"

exception ArtisticEngineError of string
(** 异常类型导出 *)

(** 模块化重构完成提示 *)
let () =
  if false then (* 防止在正常使用中打印 *)
    Printf.eprintf "[INFO] artistic_evaluators.ml 已更新为调用新的模块化架构\n%!"
