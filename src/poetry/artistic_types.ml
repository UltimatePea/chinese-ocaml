(** 骆言诗词艺术性评价类型定义模块
    从artistic_evaluation.ml重构而来，集中管理所有艺术性评价相关的类型定义 *)

(** 艺术性评价维度 *)
type artistic_dimension =
  | RhymeHarmony (* 韵律和谐 *)
  | TonalBalance (* 声调平衡 *)
  | Parallelism (* 对仗工整 *)
  | Imagery (* 意象深度 *)
  | Rhythm (* 节奏感 *)
  | Elegance (* 雅致程度 *)
  | ClassicalElegance (* 古典雅致 - 新增维度 *)
  | ModernInnovation (* 现代创新 - 新增维度 *)
  | CulturalDepth (* 文化深度 - 新增维度 *)
  | EmotionalResonance (* 情感共鸣 - 新增维度 *)
  | IntellectualDepth (* 理性深度 - 新增维度 *)

(** 评价等级：依传统诗词品评标准 *)
type evaluation_grade =
  | Excellent (* 上品 - 意境高远，韵律和谐，可称佳作 *)
  | Good (* 中品 - 格律工整，音韵协调，颇具水准 *)
  | Fair (* 下品 - 基本合格，略有瑕疵，尚可改进 *)
  | Poor (* 不入流 - 格律错乱，音韵不谐，需重修 *)

(** 艺术性评价报告：全面分析诗词的艺术特征 *)
type artistic_report = {
  verse : string; (* 原诗句 *)
  rhyme_score : float; (* 韵律得分 *)
  tone_score : float; (* 声调得分 *)
  parallelism_score : float; (* 对仗得分 *)
  imagery_score : float; (* 意象得分 *)
  rhythm_score : float; (* 节奏得分 *)
  elegance_score : float; (* 雅致得分 *)
  overall_grade : evaluation_grade; (* 总体评价 *)
  suggestions : string list; (* 改进建议 *)
}

(** 诗词形式定义 - 支持多种经典诗词格式 *)
type poetry_form =
  | SiYanPianTi (* 四言骈体 - 已支持 *)
  | WuYanLuShi (* 五言律诗 - 新增支持 *)
  | QiYanJueJu (* 七言绝句 - 新增支持 *)
  | CiPai of string (* 词牌格律 - 新增支持 *)
  | ModernPoetry (* 现代诗 - 新增支持 *)

(** 四言骈体艺术性评价标准 *)
type siyan_artistic_standards = {
  char_count : int; (* 字数标准：每句四字 *)
  tone_pattern : bool list; (* 声调模式：平仄相对 *)
  parallelism_required : bool; (* 是否要求对仗 *)
  rhythm_weight : float; (* 节奏权重 *)
}

(** 五言律诗艺术性评价标准 *)
type wuyan_lushi_standards = {
  line_count : int; (* 句数标准：八句 *)
  char_per_line : int; (* 每句字数：五字 *)
  rhyme_scheme : bool array; (* 韵脚模式：2-4-6-8句押韵 *)
  parallelism_required : bool array; (* 对仗要求：颔联、颈联对仗 *)
  tone_pattern : bool list list; (* 声调模式：平仄相对 *)
  rhythm_weight : float; (* 节奏权重 *)
}

(** 七言绝句艺术性评价标准 *)
type qiyan_jueju_standards = {
  line_count : int; (* 句数标准：四句 *)
  char_per_line : int; (* 每句字数：七字 *)
  rhyme_scheme : bool array; (* 韵脚模式：2-4句押韵 *)
  parallelism_required : bool array; (* 对仗要求：后两句对仗 *)
  tone_pattern : bool list list; (* 声调模式：平仄相对 *)
  rhythm_weight : float; (* 节奏权重 *)
}

(** 艺术性评价维度转换为字符串 *)
let dimension_to_string = function
  | RhymeHarmony -> "韵律和谐"
  | TonalBalance -> "声调平衡"
  | Parallelism -> "对仗工整"
  | Imagery -> "意象深度"
  | Rhythm -> "节奏感"
  | Elegance -> "雅致程度"
  | ClassicalElegance -> "古典雅致"
  | ModernInnovation -> "现代创新"
  | CulturalDepth -> "文化深度"
  | EmotionalResonance -> "情感共鸣"
  | IntellectualDepth -> "理性深度"

(** 评价等级转换为字符串 *)
let grade_to_string = function
  | Excellent -> "上品"
  | Good -> "中品"
  | Fair -> "下品"
  | Poor -> "不入流"

(** 诗词形式转换为字符串 *)
let form_to_string = function
  | SiYanPianTi -> "四言骈体"
  | WuYanLuShi -> "五言律诗"
  | QiYanJueJu -> "七言绝句"
  | CiPai name -> "词牌：" ^ name
  | ModernPoetry -> "现代诗"

(** 创建空的艺术性评价报告 *)
let create_empty_report verse = {
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

(** 计算综合艺术性得分 *)
let calculate_overall_score report =
  let scores = [
    report.rhyme_score;
    report.tone_score;
    report.parallelism_score;
    report.imagery_score;
    report.rhythm_score;
    report.elegance_score;
  ] in
  let total = List.fold_left (+.) 0.0 scores in
  total /. (float_of_int (List.length scores))

(** 根据综合得分确定评价等级 *)
let determine_grade overall_score =
  if overall_score >= 90.0 then Excellent
  else if overall_score >= 75.0 then Good
  else if overall_score >= 60.0 then Fair
  else Poor

(** 更新评价报告的总体等级 *)
let update_overall_grade report =
  let overall_score = calculate_overall_score report in
  { report with overall_grade = determine_grade overall_score }

(** 默认的评价维度权重配置 *)
module WeightConfig = struct
  let rhyme_weight = 0.20
  let tone_weight = 0.15
  let parallelism_weight = 0.15
  let imagery_weight = 0.20
  let rhythm_weight = 0.15
  let elegance_weight = 0.15
  
  (** 获取所有权重的列表 *)
  let all_weights = [
    rhyme_weight;
    tone_weight;
    parallelism_weight;
    imagery_weight;
    rhythm_weight;
    elegance_weight;
  ]
  
  (** 计算加权综合得分 *)
  let calculate_weighted_score report =
    let weighted_sum = 
      report.rhyme_score *. rhyme_weight +.
      report.tone_score *. tone_weight +.
      report.parallelism_score *. parallelism_weight +.
      report.imagery_score *. imagery_weight +.
      report.rhythm_score *. rhythm_weight +.
      report.elegance_score *. elegance_weight
    in
    let total_weight = List.fold_left (+.) 0.0 all_weights in
    weighted_sum /. total_weight
end

(** 评价报告验证器 *)
module ReportValidator = struct
  (** 验证分数是否在有效范围内 *)
  let is_valid_score score = score >= 0.0 && score <= 100.0
  
  (** 验证评价报告的所有分数 *)
  let validate_report report =
    let scores = [
      report.rhyme_score;
      report.tone_score;
      report.parallelism_score;
      report.imagery_score;
      report.rhythm_score;
      report.elegance_score;
    ] in
    List.for_all is_valid_score scores
  
  (** 修正超出范围的分数 *)
  let clamp_score score =
    if score < 0.0 then 0.0
    else if score > 100.0 then 100.0
    else score
  
  (** 修正评价报告中的所有分数 *)
  let normalize_report report = {
    report with
    rhyme_score = clamp_score report.rhyme_score;
    tone_score = clamp_score report.tone_score;
    parallelism_score = clamp_score report.parallelism_score;
    imagery_score = clamp_score report.imagery_score;
    rhythm_score = clamp_score report.rhythm_score;
    elegance_score = clamp_score report.elegance_score;
  }
end