(** 骆言诗词统一艺术标准模块 - Poetry模块整合优化 Fix #1707
    
    此模块是数据层第四个模块，统一定义所有诗词艺术性评价标准。
    整合来源：poetry_artistic_standards.ml, artistic_types.ml, artistic_evaluators.ml,
             artistic_evaluation.ml, poetry_artistic_core.ml等艺术性相关模块
    
    Author: Alpha, 主要工作代理
    
    美者，神之美也。标者，度之标也。统一艺术标准，品鉴千古文华。 *)

open Unified_data_types

(** {1 艺术评价标准体系} *)

(** 评价标准级别 *)
type standard_level =
  | Professional  (** 专业级 - 严格的学术标准 *)
  | Academic      (** 学院级 - 教学和研究标准 *)
  | Popular       (** 大众级 - 普及性标准 *)
  | Beginner      (** 初学级 - 宽松的入门标准 *)

(** 传统评价流派 *)
type evaluation_school =
  | Classical     (** 古典派 - 严格按古典标准 *)
  | Modern        (** 现代派 - 融合现代审美 *)
  | Contemporary  (** 当代派 - 当代文学标准 *)
  | Comprehensive (** 综合派 - 综合各家所长 *)

(** 艺术维度标准配置 *)
type dimension_standard = {
  dimension : artistic_dimension;      (** 维度名称 *)
  weight : float;                      (** 权重系数 *)
  threshold_excellent : float;         (** 优秀阈值 *)
  threshold_good : float;              (** 良好阈值 *)
  threshold_fair : float;              (** 一般阈值 *)
  evaluation_criteria : string list;   (** 评价标准 *)
  improvement_suggestions : string list; (** 改进建议模板 *)
}

(** 综合评价标准配置 *)
type artistic_standard_config = {
  standard_name : string;              (** 标准名称 *)
  level : standard_level;              (** 标准级别 *)
  school : evaluation_school;          (** 评价流派 *)
  dimensions : dimension_standard list; (** 各维度标准 *)
  overall_weights : (artistic_dimension * float) list; (** 总体权重配置 *)
  grade_thresholds : (evaluation_grade * float) list; (** 等级阈值 *)
  description : string;                (** 标准描述 *)
}

(** {1 具体艺术标准定义} *)

(** 韵律和谐标准 *)
let rhyme_harmony_standard = {
  dimension = RhymeHarmony;
  weight = 1.0;
  threshold_excellent = 0.90;
  threshold_good = 0.75;
  threshold_fair = 0.60;
  evaluation_criteria = [
    "押韵准确性 - 韵脚字符是否属于同一韵组";
    "韵律流畅性 - 整体音韵是否和谐";
    "韵脚分布 - 押韵句的分布是否合理";
    "声韵搭配 - 平仄与韵组的协调性";
  ];
  improvement_suggestions = [
    "选择同韵组字符作为韵脚";
    "注意韵脚字的声调搭配";
    "避免过于生僻的韵字";
    "保持韵律的连贯性";
  ];
}

(** 声调平衡标准 *)
let tonal_balance_standard = {
  dimension = TonalBalance;
  weight = 1.0;
  threshold_excellent = 0.88;
  threshold_good = 0.72;
  threshold_fair = 0.55;
  evaluation_criteria = [
    "平仄交替 - 相邻字符声调的交替性";
    "节奏感 - 声调变化产生的节奏效果";
    "对句呼应 - 对仗句之间的声调呼应";
    "整体协调 - 全诗声调分布的均衡性";
  ];
  improvement_suggestions = [
    "注意平仄相间，避免同调连用";
    "对仗句要做到平仄相对";
    "韵脚字的声调要符合诗体要求";
    "营造抑扬顿挫的音律美感";
  ];
}

(** 对仗工整标准 *)
let parallelism_standard = {
  dimension = Parallelism;
  weight = 1.0;
  threshold_excellent = 0.92;
  threshold_good = 0.78;
  threshold_fair = 0.62;
  evaluation_criteria = [
    "词性对仗 - 相对应位置词性的一致性";
    "意义对仗 - 语义内容的对称性";
    "结构对仗 - 句式结构的相似性";
    "音韵对仗 - 字数和声调的对应性";
  ];
  improvement_suggestions = [
    "确保对句字数完全相等";
    "名词对名词，动词对动词";
    "注意语义的对称呼应";
    "避免合掌(重复内容)";
  ];
}

(** 意象深度标准 *)
let imagery_standard = {
  dimension = Imagery;
  weight = 1.0;
  threshold_excellent = 0.85;
  threshold_good = 0.70;
  threshold_fair = 0.55;
  evaluation_criteria = [
    "意象鲜明性 - 描绘的画面是否清晰";
    "意象丰富性 - 意象层次的丰富程度";
    "意象关联性 - 各意象之间的内在联系";
    "文化内涵 - 意象承载的文化意蕴";
  ];
  improvement_suggestions = [
    "选择具体可感的意象";
    "注意意象的层次递进";
    "运用传统文化意象";
    "营造意境的整体感";
  ];
}

(** 节奏韵味标准 *)
let rhythm_standard = {
  dimension = Rhythm;
  weight = 1.0;
  threshold_excellent = 0.83;
  threshold_good = 0.68;
  threshold_fair = 0.52;
  evaluation_criteria = [
    "音步规律 - 音步划分的规整性";
    "停顿自然 - 语句停顿的自然性";
    "语流顺畅 - 整体语流的流畅度";
    "音乐感 - 诵读时的音乐美感";
  ];
  improvement_suggestions = [
    "注意句内的停顿节拍";
    "避免拗口的字词搭配";
    "营造朗朗上口的效果";
    "考虑诵读时的音乐性";
  ];
}

(** 典雅风格标准 *)
let elegance_standard = {
  dimension = Elegance;
  weight = 1.0;
  threshold_excellent = 0.87;
  threshold_good = 0.73;
  threshold_fair = 0.58;
  evaluation_criteria = [
    "用词典雅 - 词汇选择的雅致程度";
    "表达含蓄 - 情感表达的含蓄性";
    "意境高远 - 思想境界的高度";
    "文化底蕴 - 体现的文化修养";
  ];
  improvement_suggestions = [
    "选择文雅的词汇表达";
    "避免直白浅露的表述";
    "体现深层的人文关怀";
    "融入古典文化元素";
  ];
}

(** 古典雅致标准 *)
let classical_elegance_standard = {
  dimension = ClassicalElegance;
  weight = 1.0;
  threshold_excellent = 0.90;
  threshold_good = 0.76;
  threshold_fair = 0.60;
  evaluation_criteria = [
    "古典韵味 - 符合传统诗词美学";
    "典故运用 - 恰当使用典故";
    "语言纯正 - 语言的古雅纯正性";
    "传统意境 - 营造传统诗意境界";
  ];
  improvement_suggestions = [
    "多用古典诗词中的经典意象";
    "适当化用典故和前人诗句";
    "保持语言的古雅韵味";
    "体现传统文人情怀";
  ];
}

(** 现代创新标准 *)
let modern_innovation_standard = {
  dimension = ModernInnovation;
  weight = 1.0;
  threshold_excellent = 0.82;
  threshold_good = 0.67;
  threshold_fair = 0.50;
  evaluation_criteria = [
    "创新表达 - 表达方式的新颖性";
    "现代意识 - 体现现代人的思考";
    "语言创新 - 语言运用的创新性";
    "时代特色 - 反映时代特征";
  ];
  improvement_suggestions = [
    "尝试新颖的表达角度";
    "融入现代生活元素";
    "运用现代汉语的优势";
    "体现当代人的思维方式";
  ];
}

(** 文化深度标准 *)
let cultural_depth_standard = {
  dimension = CulturalDepth;
  weight = 1.0;
  threshold_excellent = 0.88;
  threshold_good = 0.74;
  threshold_fair = 0.59;
  evaluation_criteria = [
    "文化内涵 - 蕴含的文化内容";
    "历史意识 - 体现的历史感";
    "哲理思辨 - 哲学思考的深度";
    "人文关怀 - 人文精神的体现";
  ];
  improvement_suggestions = [
    "融入深层的文化思考";
    "体现对历史的理解";
    "展现哲理性的思辨";
    "表达人文主义关怀";
  ];
}

(** 情感共鸣标准 *)
let emotional_resonance_standard = {
  dimension = EmotionalResonance;
  weight = 1.0;
  threshold_excellent = 0.86;
  threshold_good = 0.71;
  threshold_fair = 0.56;
  evaluation_criteria = [
    "情感真挚 - 情感表达的真实性";
    "情感强度 - 情感冲击的强烈程度";
    "情感层次 - 情感表达的丰富性";
    "共鸣力度 - 引发读者共鸣的能力";
  ];
  improvement_suggestions = [
    "表达真实的内心情感";
    "注意情感的层次递进";
    "运用能引起共鸣的意象";
    "避免矫揉造作的情感";
  ];
}

(** 理性深度标准 *)
let intellectual_depth_standard = {
  dimension = IntellectualDepth;
  weight = 1.0;
  threshold_excellent = 0.84;
  threshold_good = 0.69;
  threshold_fair = 0.54;
  evaluation_criteria = [
    "思想深度 - 思考的深刻程度";
    "逻辑性 - 思路的逻辑性";
    "启发性 - 给读者的启发价值";
    "思辨性 - 理性思辨的水平";
  ];
  improvement_suggestions = [
    "深入思考诗歌主题";
    "保持逻辑的清晰性";
    "提供有价值的思考角度";
    "体现理性的思辨精神";
  ];
}

(** {1 标准配置集合} *)

(** 专业级古典标准 *)
let professional_classical_standard = {
  standard_name = "专业级古典标准";
  level = Professional;
  school = Classical;
  dimensions = [
    rhyme_harmony_standard;
    tonal_balance_standard;
    parallelism_standard;
    imagery_standard;
    rhythm_standard;
    elegance_standard;
    classical_elegance_standard;
    cultural_depth_standard;
    intellectual_depth_standard;
  ];
  overall_weights = [
    (RhymeHarmony, 0.23);
    (TonalBalance, 0.23);
    (Parallelism, 0.18);
    (Imagery, 0.11);
    (Rhythm, 0.07);
    (Elegance, 0.05);
    (ClassicalElegance, 0.03);
    (CulturalDepth, 0.02);
    (IntellectualDepth, 0.08);
  ];
  grade_thresholds = [
    (Excellent, 0.90);
    (Good, 0.75);
    (Fair, 0.60);
    (Poor, 0.0);
  ];
  description = "严格按照古典诗词标准评价，注重格律和传统美学";
}

(** 学院级综合标准 *)
let academic_comprehensive_standard = {
  standard_name = "学院级综合标准";
  level = Academic;
  school = Comprehensive;
  dimensions = [
    rhyme_harmony_standard;
    tonal_balance_standard;
    parallelism_standard;
    imagery_standard;
    rhythm_standard;
    elegance_standard;
    cultural_depth_standard;
    emotional_resonance_standard;
  ];
  overall_weights = [
    (RhymeHarmony, 0.20);
    (TonalBalance, 0.20);
    (Parallelism, 0.15);
    (Imagery, 0.15);
    (Rhythm, 0.10);
    (Elegance, 0.08);
    (CulturalDepth, 0.07);
    (EmotionalResonance, 0.05);
  ];
  grade_thresholds = [
    (Excellent, 0.85);
    (Good, 0.70);
    (Fair, 0.55);
    (Poor, 0.0);
  ];
  description = "平衡古典与现代，适用于教学和学术研究";
}

(** 大众级现代标准 *)
let popular_modern_standard = {
  standard_name = "大众级现代标准";
  level = Popular;
  school = Modern;
  dimensions = [
    imagery_standard;
    emotional_resonance_standard;
    rhythm_standard;
    rhyme_harmony_standard;
    modern_innovation_standard;
    cultural_depth_standard;
  ];
  overall_weights = [
    (Imagery, 0.25);
    (EmotionalResonance, 0.25);
    (Rhythm, 0.20);
    (RhymeHarmony, 0.15);
    (ModernInnovation, 0.10);
    (CulturalDepth, 0.05);
  ];
  grade_thresholds = [
    (Excellent, 0.80);
    (Good, 0.65);
    (Fair, 0.50);
    (Poor, 0.0);
  ];
  description = "注重现代审美和情感表达，适用于大众欣赏";
}

(** 初学级宽松标准 *)
let beginner_lenient_standard = {
  standard_name = "初学级宽松标准";
  level = Beginner;
  school = Contemporary;
  dimensions = [
    rhyme_harmony_standard;
    imagery_standard;
    emotional_resonance_standard;
    rhythm_standard;
  ];
  overall_weights = [
    (RhymeHarmony, 0.30);
    (Imagery, 0.30);
    (EmotionalResonance, 0.25);
    (Rhythm, 0.15);
  ];
  grade_thresholds = [
    (Excellent, 0.75);
    (Good, 0.60);
    (Fair, 0.45);
    (Poor, 0.0);
  ];
  description = "宽松的入门标准，鼓励创作热情";
}

(** {1 标准管理和访问} *)

(** 所有预定义标准 *)
let all_standards = [
  professional_classical_standard;
  academic_comprehensive_standard;
  popular_modern_standard;
  beginner_lenient_standard;
]

(** 根据级别和流派查找标准 *)
let find_standard level school =
  List.find_opt (fun std -> std.level = level && std.school = school) all_standards

(** 获取默认标准 *)
let get_default_standard () = academic_comprehensive_standard

(** 根据诗体获取推荐标准 *)
let get_recommended_standard_for_form = function
  | WuYanLuShi | QiYanJueJu -> professional_classical_standard
  | SiYanPianTi | SiYanParallelProse -> professional_classical_standard
  | ModernPoetry -> popular_modern_standard
  | CiPaiForm _ -> academic_comprehensive_standard

(** {1 评价计算功能} *)

(** 根据标准计算维度得分 *)
let calculate_dimension_score standard dimension raw_score =
  let dim_std = List.find_opt (fun ds -> ds.dimension = dimension) standard.dimensions in
  match dim_std with
  | Some ds -> 
    if raw_score >= ds.threshold_excellent then 1.0
    else if raw_score >= ds.threshold_good then 0.8
    else if raw_score >= ds.threshold_fair then 0.6
    else 0.4
  | None -> raw_score (* 如果没有标准，使用原始分数 *)

(** 根据标准计算总体评级 *)
let calculate_overall_grade standard dimension_scores =
  let weighted_score = List.fold_left (fun acc (dimension, weight) ->
    match List.assoc_opt dimension dimension_scores with
    | Some score -> acc +. (score *. weight)
    | None -> acc
  ) 0.0 standard.overall_weights in
  
  let thresholds = List.sort (fun (_, t1) (_, t2) -> compare t2 t1) standard.grade_thresholds in
  let rec find_grade = function
    | [] -> Poor
    | (grade, threshold) :: rest ->
      if weighted_score >= threshold then grade
      else find_grade rest
  in
  find_grade thresholds

(** 生成改进建议 *)
let generate_improvement_suggestions standard dimension_scores =
  List.fold_left (fun acc (dimension, score) ->
    let dim_std_opt = List.find_opt (fun ds -> ds.dimension = dimension) standard.dimensions in
    match dim_std_opt with
    | Some dim_std ->
      if score < dim_std.threshold_fair then
        acc @ dim_std.improvement_suggestions
      else acc
    | None -> acc
  ) [] dimension_scores

(** {1 标准定制功能} *)

(** 创建自定义标准 *)
let create_custom_standard name level school dimensions weights thresholds description = {
  standard_name = name;
  level = level;
  school = school;
  dimensions = dimensions;
  overall_weights = weights;
  grade_thresholds = thresholds;
  description = description;
}

(** 调整标准阈值 *)
let adjust_standard_thresholds standard new_thresholds = {
  standard with grade_thresholds = new_thresholds;
}

(** 调整维度权重 *)
let adjust_dimension_weights standard new_weights = {
  standard with overall_weights = new_weights;
}

(** {1 导出和分析功能} *)

(** 导出标准配置 *)
let export_standard_config standard = standard

(** 分析标准特征 *)
let analyze_standard_characteristics standard =
  let dimension_count = List.length standard.dimensions in
  let max_weight = List.fold_left (fun acc (_, w) -> max acc w) 0.0 standard.overall_weights in
  let min_weight = List.fold_left (fun acc (_, w) -> min acc w) 1.0 standard.overall_weights in
  let weight_variance = max_weight -. min_weight in
  
  [
    ("维度数量", string_of_int dimension_count);
    ("权重差异", Printf.sprintf "%.3f" weight_variance);
    ("严格程度", 
      match standard.level with 
      | Professional -> "非常严格"
      | Academic -> "较为严格" 
      | Popular -> "适中"
      | Beginner -> "宽松");
    ("评价风格", 
      match standard.school with
      | Classical -> "传统古典"
      | Modern -> "现代融合"
      | Contemporary -> "当代开放"
      | Comprehensive -> "综合平衡");
  ]

(** {1 向后兼容接口} *)

(** 兼容旧版本的权重配置 *)
module WeightConfig = struct
  let rhyme_weight = 0.25
  let tone_weight = 0.20
  let parallelism_weight = 0.15
  let imagery_weight = 0.15
  let rhythm_weight = 0.15
  let elegance_weight = 0.10
  
  let all_weights = [
    rhyme_weight; tone_weight; parallelism_weight; 
    imagery_weight; rhythm_weight; elegance_weight;
  ]
  
  let calculate_weighted_score report =
    (report.rhyme_score *. rhyme_weight) +.
    (report.tone_score *. tone_weight) +.
    (report.parallelism_score *. parallelism_weight) +.
    (report.imagery_score *. imagery_weight) +.
    (report.rhythm_score *. rhythm_weight) +.
    (report.elegance_score *. elegance_weight)
end

(** 兼容旧版本的评级函数 *)
let legacy_determine_overall_grade scores =
  let weighted_score = WeightConfig.calculate_weighted_score scores in
  if weighted_score >= 0.9 then Excellent
  else if weighted_score >= 0.7 then Good
  else if weighted_score >= 0.5 then Fair
  else Poor