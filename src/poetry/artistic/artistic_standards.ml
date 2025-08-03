(** 诗词艺术标准定义模块
 *
 * 整合所有艺术标准相关的模块，包括评价标准、诗体规范等。
 * 此模块整合了artistic_standards.ml、poetry_standards.ml等文件。
 *
 * @author Whisky, PR Worker - 诗词艺术评估模块整合实施
 * @version 1.0 - 模块整合版本
 * @since 2025-08-03
 * @fix_issue #2000 Poetry艺术评估模块整合实施
 *)

(** {1 艺术标准类型定义} *)

(** 诗体类型 *)
type poetry_form =
  | LuShi        (* 律诗 *)
  | JueShi       (* 绝句 *)
  | CiPai        (* 词牌 *)
  | GuFeng       (* 古风 *)
  | YueFu        (* 乐府 *)
  | ZiYouShi     (* 自由诗 *)

(** 评价等级 *)
type evaluation_grade =
  | Excellent    (* 优秀 *)
  | Good         (* 良好 *)
  | Average      (* 一般 *)
  | Poor         (* 较差 *)
  | Failed       (* 不合格 *)

(** 艺术维度权重 *)
type dimension_weight = {
  dimension_name : string;
  weight : float;
  min_threshold : float;
  max_score : float;
}

(** 诗体标准 *)
type poetry_standard = {
  form : poetry_form;
  name : string;
  description : string;
  line_count : int;
  character_constraints : int list;
  tone_pattern : string option;
  rhyme_requirements : string list;
  special_rules : string list;
  weight_config : dimension_weight list;
}

(** 评价标准 *)
type evaluation_standard = {
  standard_id : string;
  name : string;
  applicable_forms : poetry_form list;
  dimension_weights : dimension_weight list;
  grade_thresholds : (evaluation_grade * float) list;
  description : string;
}

(** {1 标准诗体定义} *)

(** 五言律诗标准 *)
let wuyan_lvshi_standard = {
  form = LuShi;
  name = "五言律诗";
  description = "五言八句，对仗工整，平仄协调的古典诗体";
  line_count = 8;
  character_constraints = [5; 5; 5; 5; 5; 5; 5; 5];
  tone_pattern = Some "平仄平平仄,仄平仄仄平,仄平平仄仄,平仄仄平平";
  rhyme_requirements = ["二四六八句押韵"; "首句可押可不押"; "用平声韵"];
  special_rules = ["颔联、颈联必须对仗"; "不可重字"; "避免孤平失对"];
  weight_config = [
    { dimension_name = "韵律和谐"; weight = 0.25; min_threshold = 0.6; max_score = 1.0 };
    { dimension_name = "声调平衡"; weight = 0.25; min_threshold = 0.6; max_score = 1.0 };
    { dimension_name = "对仗工整"; weight = 0.20; min_threshold = 0.7; max_score = 1.0 };
    { dimension_name = "意象深度"; weight = 0.15; min_threshold = 0.5; max_score = 1.0 };
    { dimension_name = "形式美感"; weight = 0.15; min_threshold = 0.5; max_score = 1.0 };
  ];
}

(** 七言律诗标准 *)
let qiyan_lvshi_standard = {
  form = LuShi;
  name = "七言律诗";
  description = "七言八句，对仗工整，平仄协调的古典诗体";
  line_count = 8;
  character_constraints = [7; 7; 7; 7; 7; 7; 7; 7];
  tone_pattern = Some "平平仄仄平平仄,仄仄平平仄仄平";
  rhyme_requirements = ["二四六八句押韵"; "首句可押可不押"; "用平声韵"];
  special_rules = ["颔联、颈联必须对仗"; "不可重字"; "避免孤平失对"];
  weight_config = [
    { dimension_name = "韵律和谐"; weight = 0.25; min_threshold = 0.6; max_score = 1.0 };
    { dimension_name = "声调平衡"; weight = 0.25; min_threshold = 0.6; max_score = 1.0 };
    { dimension_name = "对仗工整"; weight = 0.20; min_threshold = 0.7; max_score = 1.0 };
    { dimension_name = "意象深度"; weight = 0.15; min_threshold = 0.5; max_score = 1.0 };
    { dimension_name = "形式美感"; weight = 0.15; min_threshold = 0.5; max_score = 1.0 };
  ];
}

(** 五言绝句标准 *)
let wuyan_jueshi_standard = {
  form = JueShi;
  name = "五言绝句";
  description = "五言四句，短小精悍的古典诗体";
  line_count = 4;
  character_constraints = [5; 5; 5; 5];
  tone_pattern = Some "仄仄平平仄,平平仄仄平";
  rhyme_requirements = ["一三句不押韵"; "二四句押韵"; "用平声韵"];
  special_rules = ["言简意赅"; "意境深远"; "不拘对仗"];
  weight_config = [
    { dimension_name = "意象深度"; weight = 0.30; min_threshold = 0.6; max_score = 1.0 };
    { dimension_name = "韵律和谐"; weight = 0.25; min_threshold = 0.5; max_score = 1.0 };
    { dimension_name = "意境营造"; weight = 0.20; min_threshold = 0.5; max_score = 1.0 };
    { dimension_name = "形式美感"; weight = 0.15; min_threshold = 0.4; max_score = 1.0 };
    { dimension_name = "声调平衡"; weight = 0.10; min_threshold = 0.4; max_score = 1.0 };
  ];
}

(** 自由诗标准 *)
let ziyoushi_standard = {
  form = ZiYouShi;
  name = "自由诗";
  description = "不拘格律，注重意象和情感表达的现代诗体";
  line_count = 0;  (* 不限行数 *)
  character_constraints = [];  (* 不限字数 *)
  tone_pattern = None;
  rhyme_requirements = ["可押韵可不押韵"; "可用各种韵脚"];
  special_rules = ["重视意象营造"; "情感表达真挚"; "语言富有创新性"];
  weight_config = [
    { dimension_name = "意象深度"; weight = 0.35; min_threshold = 0.6; max_score = 1.0 };
    { dimension_name = "情感表达"; weight = 0.25; min_threshold = 0.5; max_score = 1.0 };
    { dimension_name = "创新性"; weight = 0.20; min_threshold = 0.4; max_score = 1.0 };
    { dimension_name = "语言美感"; weight = 0.20; min_threshold = 0.4; max_score = 1.0 };
  ];
}

(** {1 评价标准定义} *)

(** 古典诗词评价标准 *)
let classical_evaluation_standard = {
  standard_id = "classical";
  name = "古典诗词评价标准";
  applicable_forms = [LuShi; JueShi; GuFeng; YueFu];
  dimension_weights = [
    { dimension_name = "韵律和谐"; weight = 0.25; min_threshold = 0.6; max_score = 1.0 };
    { dimension_name = "声调平衡"; weight = 0.25; min_threshold = 0.6; max_score = 1.0 };
    { dimension_name = "对仗工整"; weight = 0.20; min_threshold = 0.5; max_score = 1.0 };
    { dimension_name = "意象深度"; weight = 0.15; min_threshold = 0.5; max_score = 1.0 };
    { dimension_name = "形式美感"; weight = 0.15; min_threshold = 0.5; max_score = 1.0 };
  ];
  grade_thresholds = [
    (Excellent, 0.90);
    (Good, 0.75);
    (Average, 0.60);
    (Poor, 0.40);
    (Failed, 0.0);
  ];
  description = "适用于传统古典诗词的综合评价标准";
}

(** 现代诗词评价标准 *)
let modern_evaluation_standard = {
  standard_id = "modern";
  name = "现代诗词评价标准";
  applicable_forms = [ZiYouShi; CiPai];
  dimension_weights = [
    { dimension_name = "意象深度"; weight = 0.30; min_threshold = 0.5; max_score = 1.0 };
    { dimension_name = "情感表达"; weight = 0.25; min_threshold = 0.5; max_score = 1.0 };
    { dimension_name = "创新性"; weight = 0.20; min_threshold = 0.4; max_score = 1.0 };
    { dimension_name = "语言美感"; weight = 0.15; min_threshold = 0.4; max_score = 1.0 };
    { dimension_name = "韵律感"; weight = 0.10; min_threshold = 0.3; max_score = 1.0 };
  ];
  grade_thresholds = [
    (Excellent, 0.85);
    (Good, 0.70);
    (Average, 0.55);
    (Poor, 0.35);
    (Failed, 0.0);
  ];
  description = "适用于现代诗词的综合评价标准";
}

(** {1 标准数据库} *)

(** 所有诗体标准 *)
let all_poetry_standards = [
  wuyan_lvshi_standard;
  qiyan_lvshi_standard;
  wuyan_jueshi_standard;
  ziyoushi_standard;
]

(** 所有评价标准 *)
let all_evaluation_standards = [
  classical_evaluation_standard;
  modern_evaluation_standard;
]

(** {1 标准查询和应用} *)

(** 根据诗体类型查找标准 *)
let find_poetry_standard (form : poetry_form) : poetry_standard option =
  List.find_opt (fun std -> std.form = form) all_poetry_standards

(** 根据诗体类型查找评价标准 *)
let find_evaluation_standard (form : poetry_form) : evaluation_standard option =
  List.find_opt (fun std -> 
    List.mem form std.applicable_forms
  ) all_evaluation_standards

(** 根据标准ID查找评价标准 *)
let find_evaluation_standard_by_id (standard_id : string) : evaluation_standard option =
  List.find_opt (fun std -> std.standard_id = standard_id) all_evaluation_standards

(** 验证诗句是否符合诗体要求 *)
let validate_poetry_form (verse_lines : string list) (form : poetry_form) : bool * string list =
  match find_poetry_standard form with
  | None -> (false, ["未找到对应诗体标准"])
  | Some standard ->
      let errors = ref [] in
      (* 检查行数 *)
      if standard.line_count > 0 && List.length verse_lines <> standard.line_count then
        errors := Printf.sprintf "行数不符：期望%d行，实际%d行" 
          standard.line_count (List.length verse_lines) :: !errors;
      
      (* 检查字数约束 *)
      if List.length standard.character_constraints > 0 then
        List.iteri (fun i line ->
          if i < List.length standard.character_constraints then
            let expected = List.nth standard.character_constraints i in
            let actual = String.length line in
            if actual <> expected then
              errors := Printf.sprintf "第%d行字数不符：期望%d字，实际%d字" 
                (i+1) expected actual :: !errors
        ) verse_lines;
      
      (List.length !errors = 0, List.rev !errors)

(** 根据分数计算等级 *)
let calculate_grade (score : float) (standard : evaluation_standard) : evaluation_grade =
  let rec find_grade thresholds =
    match thresholds with
    | [] -> Failed
    | (grade, threshold) :: rest ->
        if score >= threshold then grade
        else find_grade rest
  in
  find_grade standard.grade_thresholds

(** 应用评价标准计算加权分数 *)
let apply_evaluation_standard 
    (scores : (string * float) list) 
    (standard : evaluation_standard) : float =
  let weighted_sum = List.fold_left (fun acc weight_config ->
    match List.assoc_opt weight_config.dimension_name scores with
    | Some score -> acc +. (score *. weight_config.weight)
    | None -> acc +. (0.5 *. weight_config.weight)  (* 默认分数 *)
  ) 0.0 standard.dimension_weights in
  weighted_sum

(** 生成评价报告 *)
let generate_evaluation_report 
    (scores : (string * float) list)
    (form : poetry_form)
    (standard_id : string option) : string =
  let used_standard = 
    match standard_id with
    | Some id -> find_evaluation_standard_by_id id
    | None -> find_evaluation_standard form
  in
  match used_standard with
  | None -> "无法找到适用的评价标准"
  | Some standard ->
      let weighted_score = apply_evaluation_standard scores standard in
      let grade = calculate_grade weighted_score standard in
      let grade_text = match grade with
        | Excellent -> "优秀"
        | Good -> "良好"
        | Average -> "一般"
        | Poor -> "较差"
        | Failed -> "不合格"
      in
      Printf.sprintf "评价结果：%s (%.2f分)\n使用标准：%s\n等级：%s" 
        standard.name weighted_score standard.name grade_text

(** {1 标准管理} *)

(** 获取所有可用的诗体类型 *)
let get_available_poetry_forms () : poetry_form list =
  List.map (fun std -> std.form) all_poetry_standards

(** 获取所有评价标准 *)
let get_all_evaluation_standards () : evaluation_standard list =
  all_evaluation_standards

(** 获取诗体的推荐权重配置 *)
let get_recommended_weights (form : poetry_form) : dimension_weight list =
  match find_poetry_standard form with
  | Some standard -> standard.weight_config
  | None -> classical_evaluation_standard.dimension_weights

(** 检查标准兼容性 *)
let check_standard_compatibility (form : poetry_form) (standard_id : string) : bool =
  match find_evaluation_standard_by_id standard_id with
  | Some standard -> List.mem form standard.applicable_forms
  | None -> false