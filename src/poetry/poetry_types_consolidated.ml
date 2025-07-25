(** 骆言诗词类型整合模块 - 统一诗词分析类型定义

    此模块整合了诗词分析系统中的所有核心类型定义， 包括音韵类型、艺术性评价类型、数据结构等。

    技术债务改进：将140+个分散模块的类型定义统一至此处， 减少模块间依赖，提高代码维护性。

    @author 骆言诗词编程团队
    @version 2.0 - 整合版本
    @since 2025-07-24 *)

(** {1 核心音韵类型} *)

type rhyme_category = PingSheng | ZeSheng | ShangSheng | QuSheng | RuSheng

type rhyme_group =
  | AnRhyme
  | SiRhyme
  | TianRhyme
  | WangRhyme
  | QuRhyme
  | YuRhyme
  | HuaRhyme
  | FengRhyme
  | YueRhyme
  | JiangRhyme
  | HuiRhyme
  | UnknownRhyme

type rhyme_analysis_report = {
  verse : string;
  rhyme_ending : char option;
  rhyme_group : rhyme_group;
  rhyme_category : rhyme_category;
  char_analysis : (char * rhyme_category * rhyme_group) list;
}

type poem_rhyme_analysis = {
  verses : string list;
  verse_reports : rhyme_analysis_report list;
  rhyme_groups : rhyme_group list;
  rhyme_categories : rhyme_category list;
  rhyme_quality : float;
  rhyme_consistency : bool;
}

(** {1 艺术性评价类型} *)

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

type artistic_scores = {
  rhyme_harmony : float;
  tonal_balance : float;
  parallelism : float;
  imagery : float;
  rhythm : float;
  elegance : float;
}

(** {1 诗词形式定义} *)

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

type wuyan_lushi_standards = {
  line_count : int;
  char_per_line : int;
  rhyme_scheme : bool array;
  parallelism_required : bool array;
  tone_pattern : bool list list;
  rhythm_weight : float;
}

type qiyan_jueju_standards = {
  line_count : int;
  char_per_line : int;
  rhyme_scheme : bool array;
  parallelism_required : bool array;
  tone_pattern : bool list list;
  rhythm_weight : float;
}

(** {1 声调分析类型} *)

type tone_info = { char : char; tone : rhyme_category; is_tonal_mismatch : bool }

type tone_analysis_report = {
  verse : string;
  tone_infos : tone_info list;
  tone_pattern : bool list;
  pattern_score : float;
  violations : int;
}

(** {1 综合分析类型} *)

type verse_summary = {
  verse : string;
  rhyme_info : rhyme_analysis_report;
  tone_info : tone_analysis_report;
  artistic_info : artistic_report;
}

type comprehensive_analysis = {
  poem_text : string list;
  form : poetry_form;
  verse_summaries : verse_summary list;
  overall_rhyme : poem_rhyme_analysis;
  overall_artistic : artistic_scores;
  final_grade : evaluation_grade;
  critique : string;
}

(** {1 类型转换和工具函数} *)

let rhyme_category_to_string = function
  | PingSheng -> "平声"
  | ZeSheng -> "仄声"
  | ShangSheng -> "上声"
  | QuSheng -> "去声"
  | RuSheng -> "入声"

let rhyme_group_to_string = function
  | AnRhyme -> "安韵"
  | SiRhyme -> "思韵"
  | TianRhyme -> "天韵"
  | WangRhyme -> "望韵"
  | QuRhyme -> "去韵"
  | YuRhyme -> "鱼韵"
  | HuaRhyme -> "花韵"
  | FengRhyme -> "风韵"
  | YueRhyme -> "月韵"
  | JiangRhyme -> "江韵"
  | HuiRhyme -> "灰韵"
  | UnknownRhyme -> "未知韵"

let dimension_to_string = function
  | RhymeHarmony -> "韵律和谐"
  | TonalBalance -> "声调平衡"
  | Parallelism -> "对仗工整"
  | Imagery -> "意象深度"
  | Rhythm -> "节奏韵味"
  | Elegance -> "典雅风格"
  | ClassicalElegance -> "古典雅致"
  | ModernInnovation -> "现代创新"
  | CulturalDepth -> "文化深度"
  | EmotionalResonance -> "情感共鸣"
  | IntellectualDepth -> "思想深度"

let grade_to_string = function Excellent -> "优秀" | Good -> "良好" | Fair -> "一般" | Poor -> "较差"

let form_to_string = function
  | SiYanPianTi -> "四言骈体"
  | WuYanLuShi -> "五言律诗"
  | QiYanJueJu -> "七言绝句"
  | CiPai name -> "词牌·" ^ name
  | ModernPoetry -> "现代诗"
  | SiYanParallelProse -> "四言骈体散文"

let rhyme_category_equal cat1 cat2 = cat1 = cat2
let rhyme_group_equal group1 group2 = group1 = group2
let is_ping_sheng = function PingSheng -> true | _ -> false
let is_ze_sheng = function ZeSheng | ShangSheng | QuSheng | RuSheng -> true | PingSheng -> false

let create_empty_report verse =
  {
    verse;
    rhyme_score = 0.0;
    tone_score = 0.0;
    parallelism_score = 0.0;
    imagery_score = 0.0;
    rhythm_score = 0.0;
    elegance_score = 0.0;
    overall_grade = Poor;
    suggestions = [];
  }

let calculate_overall_score report =
  let total =
    report.rhyme_score +. report.tone_score +. report.parallelism_score +. report.imagery_score
    +. report.rhythm_score +. report.elegance_score
  in
  total /. 6.0

let update_overall_grade report =
  let score = calculate_overall_score report in
  let grade =
    if score >= 0.9 then Excellent
    else if score >= 0.7 then Good
    else if score >= 0.5 then Fair
    else Poor
  in
  { report with overall_grade = grade }

(** {1 配置模块} *)

module WeightConfig = struct
  let rhyme_weight = 0.25
  let tone_weight = 0.20
  let parallelism_weight = 0.15
  let imagery_weight = 0.15
  let rhythm_weight = 0.15
  let elegance_weight = 0.10

  let all_weights =
    [
      rhyme_weight; tone_weight; parallelism_weight; imagery_weight; rhythm_weight; elegance_weight;
    ]

  let calculate_weighted_score report =
    (report.rhyme_score *. rhyme_weight)
    +. (report.tone_score *. tone_weight)
    +. (report.parallelism_score *. parallelism_weight)
    +. (report.imagery_score *. imagery_weight)
    +. (report.rhythm_score *. rhythm_weight)
    +. (report.elegance_score *. elegance_weight)
end

module ReportValidator = struct
  let is_valid_score score = score >= 0.0 && score <= 1.0
  let clamp_score score = if score < 0.0 then 0.0 else if score > 1.0 then 1.0 else score

  let validate_report report =
    is_valid_score report.rhyme_score && is_valid_score report.tone_score
    && is_valid_score report.parallelism_score
    && is_valid_score report.imagery_score
    && is_valid_score report.rhythm_score
    && is_valid_score report.elegance_score

  let normalize_report report =
    {
      report with
      rhyme_score = clamp_score report.rhyme_score;
      tone_score = clamp_score report.tone_score;
      parallelism_score = clamp_score report.parallelism_score;
      imagery_score = clamp_score report.imagery_score;
      rhythm_score = clamp_score report.rhythm_score;
      elegance_score = clamp_score report.elegance_score;
    }
end
