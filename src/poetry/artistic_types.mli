(** 骆言诗词艺术性评价类型定义模块接口 *)

(** 艺术性评价维度 *)
type artistic_dimension =
  | RhymeHarmony
  | TonalBalance
  | Parallelism
  | Imagery
  | Rhythm
  | Elegance
  | ClassicalElegance
  | ModernInnovation
  | CulturalDepth
  | EmotionalResonance
  | IntellectualDepth

(** 评价等级 *)
type evaluation_grade = Excellent | Good | Fair | Poor

type artistic_report = {
  verse : string;
  rhyme_score : float;
  tone_score : float;
  parallelism_score : float;
  imagery_score : float;
  rhythm_score : float;
  elegance_score : float;
  overall_grade : evaluation_grade;
  suggestions : string list;
}
(** 艺术性评价报告 *)

type artistic_scores = {
  rhyme_harmony : float;
  tonal_balance : float;
  parallelism : float;
  imagery : float;
  rhythm : float;
  elegance : float;
}
(** 艺术性分数记录 *)

(** 诗词形式定义 *)
type poetry_form =
  | SiYanPianTi
  | WuYanLuShi
  | QiYanJueJu
  | CiPai of string
  | ModernPoetry
  | SiYanParallelProse

type siyan_artistic_standards = {
  char_count : int;
  tone_pattern : bool list;
  parallelism_required : bool;
  rhythm_weight : float;
}
(** 四言骈体艺术性评价标准 *)

type wuyan_lushi_standards = {
  line_count : int;
  char_per_line : int;
  rhyme_scheme : bool array;
  parallelism_required : bool array;
  tone_pattern : bool list list;
  rhythm_weight : float;
}
(** 五言律诗艺术性评价标准 *)

type qiyan_jueju_standards = {
  line_count : int;
  char_per_line : int;
  rhyme_scheme : bool array;
  parallelism_required : bool array;
  tone_pattern : bool list list;
  rhythm_weight : float;
}
(** 七言绝句艺术性评价标准 *)

val dimension_to_string : artistic_dimension -> string
(** 类型转换函数 *)

val grade_to_string : evaluation_grade -> string
val form_to_string : poetry_form -> string

val create_empty_report : string -> artistic_report
(** 评价报告操作函数 *)

val calculate_overall_score : artistic_report -> float
val update_overall_grade : artistic_report -> artistic_report

(** 权重配置模块 *)
module WeightConfig : sig
  val rhyme_weight : float
  val tone_weight : float
  val parallelism_weight : float
  val imagery_weight : float
  val rhythm_weight : float
  val elegance_weight : float
  val all_weights : float list
  val calculate_weighted_score : artistic_report -> float
end

(** 评价报告验证器 *)
module ReportValidator : sig
  val is_valid_score : float -> bool
  val validate_report : artistic_report -> bool
  val clamp_score : float -> float
  val normalize_report : artistic_report -> artistic_report
end
