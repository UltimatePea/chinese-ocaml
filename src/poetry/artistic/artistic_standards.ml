(** 诗词艺术评估标准模块实现
 *
 * 此模块定义和管理诗词艺术评估的各种标准和规范。
 *
 * Author: Whisky, PR Worker - Critical Build Fix
 *)

(** {1 标准类型定义} *)

(** 诗词形式标准 *)
type poetry_form_standard = {
  name : string;                    (** 标准名称 *)
  verse_count : int option;         (** 诗句数量要求 *)
  syllable_pattern : int list option; (** 音节模式 *)
  rhyme_scheme : string option;     (** 韵律方案 *)
  tonal_pattern : string option;    (** 声调模式 *)
  parallelism_required : bool;      (** 是否要求对仗 *)
  special_rules : string list;      (** 特殊规则 *)
}

(** 质量等级标准 *)
type quality_grade_standard = {
  grade_name : string;              (** 等级名称 *)
  min_score : float;                (** 最低分数 *)
  max_score : float;                (** 最高分数 *)
  criteria : string list;           (** 评判标准 *)
  examples : string list;           (** 示例作品 *)
}

(** 评价维度标准 *)
type dimension_standard = {
  dimension_name : string;          (** 维度名称 *)
  weight : float;                   (** 权重 *)
  evaluation_criteria : string list; (** 评价标准 *)
  scoring_rubric : (float * string) list; (** 评分标准 *)
}

(** 综合评价标准 *)
type comprehensive_standard = {
  standard_name : string;           (** 标准名称 *)
  version : string;                 (** 版本号 *)
  poetry_forms : poetry_form_standard list; (** 诗词形式标准 *)
  quality_grades : quality_grade_standard list; (** 质量等级标准 *)
  dimensions : dimension_standard list; (** 评价维度标准 *)
  created_date : float;             (** 创建日期 *)
  description : string;             (** 标准描述 *)
}

(** 全局标准存储 *)
let custom_standards = ref []
let standard_versions = ref []
(* Statistical data - reserved for future implementation *)
(* let usage_statistics = ref [] *)

(** {1 标准管理} *)

(** 创建诗词形式标准 *)
let create_poetry_form_standard name verse_count syllable_pattern rhyme_scheme =
  {
    name;
    verse_count;
    syllable_pattern;
    rhyme_scheme;
    tonal_pattern = None;
    parallelism_required = false;
    special_rules = [];
  }

(** 创建质量等级标准 *)
let create_quality_grade_standard grade_name min_score max_score criteria =
  {
    grade_name;
    min_score;
    max_score;
    criteria;
    examples = [];
  }

(** 创建维度评价标准 *)
let create_dimension_standard dimension_name weight criteria =
  {
    dimension_name;
    weight;
    evaluation_criteria = criteria;
    scoring_rubric = [(1.0, "优秀"); (0.8, "良好"); (0.6, "及格"); (0.4, "较差")];
  }

(** {1 预定义标准} *)

(** 获取古典诗词标准 *)
let get_classical_poetry_standard () =
  let poetry_forms = [
    create_poetry_form_standard "七言绝句" (Some 4) (Some [7; 7; 7; 7]) (Some "ABAB");
    create_poetry_form_standard "五言绝句" (Some 4) (Some [5; 5; 5; 5]) (Some "ABAB");
    create_poetry_form_standard "七言律诗" (Some 8) (Some [7; 7; 7; 7; 7; 7; 7; 7]) (Some "ABABCDCD");
  ] in
  let quality_grades = [
    create_quality_grade_standard "优秀" 0.9 1.0 ["韵律工整"; "意境深远"; "辞藻华美"];
    create_quality_grade_standard "良好" 0.8 0.9 ["韵律较好"; "意境清晰"; "辞藻得当"];
    create_quality_grade_standard "及格" 0.6 0.8 ["基本合律"; "意境一般"; "辞藻平实"];
    create_quality_grade_standard "较差" 0.0 0.6 ["韵律欠佳"; "意境模糊"; "辞藻生硬"];
  ] in
  let dimensions = [
    create_dimension_standard "韵律" 0.3 ["押韵准确"; "音律和谐"];
    create_dimension_standard "对仗" 0.2 ["对仗工整"; "词性对应"];
    create_dimension_standard "意境" 0.3 ["意境深远"; "情景交融"];
    create_dimension_standard "格律" 0.2 ["格律严谨"; "平仄协调"];
  ] in
  {
    standard_name = "古典诗词标准";
    version = "1.0";
    poetry_forms;
    quality_grades;
    dimensions;
    created_date = Unix.time ();
    description = "传统古典诗词评价标准";
  }

(** 获取现代诗词标准 *)
let get_modern_poetry_standard () =
  let poetry_forms = [
    create_poetry_form_standard "自由诗" None None None;
    create_poetry_form_standard "新格律诗" None None (Some "自由韵");
  ] in
  let quality_grades = [
    create_quality_grade_standard "优秀" 0.9 1.0 ["创意新颖"; "情感真挚"; "语言优美"];
    create_quality_grade_standard "良好" 0.8 0.9 ["创意较好"; "情感较真"; "语言较美"];
    create_quality_grade_standard "及格" 0.6 0.8 ["创意一般"; "情感平实"; "语言平常"];
    create_quality_grade_standard "较差" 0.0 0.6 ["缺乏创意"; "情感淡薄"; "语言生硬"];
  ] in
  let dimensions = [
    create_dimension_standard "创新性" 0.3 ["创意独特"; "表现手法新颖"];
    create_dimension_standard "情感表达" 0.3 ["情感真挚"; "感情丰富"];
    create_dimension_standard "语言美感" 0.2 ["语言优美"; "词汇丰富"];
    create_dimension_standard "意象营造" 0.2 ["意象鲜明"; "想象力丰富"];
  ] in
  {
    standard_name = "现代诗词标准";
    version = "1.0";
    poetry_forms;
    quality_grades;
    dimensions;
    created_date = Unix.time ();
    description = "现代诗词创作评价标准";
  }

(** 获取绝句标准 *)
let get_jueju_standard () =
  {
    name = "绝句标准";
    verse_count = Some 4;
    syllable_pattern = Some [5; 5; 5; 5];  (* 或 [7; 7; 7; 7] *)
    rhyme_scheme = Some "ABAB";
    tonal_pattern = Some "平仄平仄";
    parallelism_required = false;
    special_rules = ["首句可入韵可不入韵"; "对仗要求较低"];
  }

(** 获取律诗标准 *)
let get_lushi_standard () =
  {
    name = "律诗标准";
    verse_count = Some 8;
    syllable_pattern = Some [5; 5; 5; 5; 5; 5; 5; 5];  (* 或七言 *)
    rhyme_scheme = Some "ABABCDCD";
    tonal_pattern = Some "严格平仄规律";
    parallelism_required = true;
    special_rules = ["颔联颈联必须对仗"; "首句可入韵"; "中二联避免合掌"];
  }

(** 获取词牌标准 *)
let get_ci_pai_standard ci_pai_name =
  match ci_pai_name with
  | "水调歌头" -> Some {
      name = "水调歌头";
      verse_count = Some 10;
      syllable_pattern = Some [4; 6; 8; 6; 4; 6; 8; 6; 4; 7];
      rhyme_scheme = Some "ABABCDCDEE";
      tonal_pattern = Some "词牌固定格律";
      parallelism_required = false;
      special_rules = ["双调九十五字"; "前阕九句"; "后阕十句"];
    }
  | "满江红" -> Some {
      name = "满江红";
      verse_count = Some 16;
      syllable_pattern = Some [4; 3; 5; 4; 4; 6; 6; 4; 4; 3; 5; 4; 4; 6; 6; 4];
      rhyme_scheme = Some "复杂韵律";
      tonal_pattern = Some "词牌固定格律";
      parallelism_required = false;
      special_rules = ["双调九十三字"; "前后阕各八句"];
    }
  | _ -> None

(** {1 标准验证} *)

(** 验证诗词符合标准 *)
let validate_poetry_against_standard poem_text standard =
  let lines = String.split_on_char '\n' poem_text in
  let violations = ref [] in
  
  (* 检查诗句数量 *)
  (match standard.verse_count with
   | Some expected_count when List.length lines <> expected_count ->
     violations := Printf.sprintf "诗句数量不符（期望%d句，实际%d句）" expected_count (List.length lines) :: !violations
   | _ -> ());
  
  (* 检查音节模式 *)
  (match standard.syllable_pattern with
   | Some pattern ->
     List.iteri (fun i line ->
       if i < List.length pattern then
         let expected_len = List.nth pattern i in
         let actual_len = String.length line in
         if actual_len <> expected_len then
           violations := Printf.sprintf "第%d句音节数不符（期望%d，实际%d）" (i+1) expected_len actual_len :: !violations
     ) lines
   | None -> ());
  
  (List.length !violations = 0, !violations)

(** 检查质量等级 *)
let check_quality_grade score standards =
  List.find_opt (fun grade -> 
    score >= grade.min_score && score <= grade.max_score
  ) standards |> function
  | Some grade -> Some grade.grade_name
  | None -> None

(** 评估维度符合度 *)
let assess_dimension_compliance dimension_score standard =
  (* 简化实现：基于分数和权重计算符合度 *)
  dimension_score *. standard.weight

(** {1 标准比较} *)

(** 比较两个标准 *)
let compare_standards standard1 standard2 =
  [
    ("名称差异", Printf.sprintf "%s vs %s" standard1.standard_name standard2.standard_name);
    ("版本差异", Printf.sprintf "%s vs %s" standard1.version standard2.version);
    ("形式数量", Printf.sprintf "%d vs %d" (List.length standard1.poetry_forms) (List.length standard2.poetry_forms));
    ("等级数量", Printf.sprintf "%d vs %d" (List.length standard1.quality_grades) (List.length standard2.quality_grades));
    ("维度数量", Printf.sprintf "%d vs %d" (List.length standard1.dimensions) (List.length standard2.dimensions));
  ]

(** 分析标准差异 *)
let analyze_standard_differences standards =
  match standards with
  | [] -> []
  | [_] -> [("单一标准", ["无差异可分析"])]
  | first :: rest ->
    List.map (fun std ->
      let comparison = compare_standards first std in
      (std.standard_name, List.map snd comparison)
    ) rest

(** {1 自定义标准} *)

(** 注册自定义标准 *)
let register_custom_standard standard =
  custom_standards := standard :: !custom_standards

(** 获取自定义标准 *)
let get_custom_standard standard_name =
  List.find_opt (fun std -> std.standard_name = standard_name) !custom_standards

(** 列出所有自定义标准 *)
let list_custom_standards () =
  List.map (fun std -> std.standard_name) !custom_standards

(** 删除自定义标准 *)
let remove_custom_standard standard_name =
  let original_count = List.length !custom_standards in
  custom_standards := List.filter (fun std -> std.standard_name <> standard_name) !custom_standards;
  List.length !custom_standards < original_count

(** {1 标准应用} *)

(** 应用综合标准进行评价 *)
let apply_comprehensive_standard poem_text standard =
  (* 创建基础评价结果 - 简化实现 *)
  let dimension_scores = List.map (fun dim ->
    let score = 0.75 +. (Random.float 0.2) -. 0.1 in  (* 0.65-0.85随机分数 *)
    {
      Artistic_core.dimension = (match dim.dimension_name with
       | "韵律" -> Artistic_core.RhymeHarmony
       | "对仗" -> Artistic_core.Parallelism  
       | "意境" -> Artistic_core.Imagery
       | "格律" -> Artistic_core.FormBeauty
       | _ -> Artistic_core.Elegance);
      score = score;
      max_possible = 1.0;
      confidence = 0.8;
      details = Some "基于标准评价";
      suggestions = ["根据标准的改进建议"];
    }
  ) standard.dimensions in
  
  let comprehensive_score = List.fold_left (fun acc ds -> acc +. ds.Artistic_core.score) 0.0 dimension_scores
                           /. float_of_int (List.length dimension_scores) in
  
  let quality_grade = match check_quality_grade comprehensive_score standard.quality_grades with
    | Some grade -> (match grade with
        | "优秀" -> `Excellent
        | "良好" -> `Good
        | "及格" -> `Fair
        | _ -> `Poor)
    | None -> `Fair in
  
  {
    Artistic_core.overall_score = comprehensive_score;
    dimension_scores = dimension_scores;
    strengths = ["基于标准的优势"];
    weaknesses = ["基于标准的劣势"]; 
    improvement_suggestions = ["基于标准评价的建议"];
    artistic_level = `Intermediate;
    quality_grade = quality_grade;
    evaluation_metadata = [("poem_text", poem_text); ("standard", standard.standard_name)];
  }

(** 根据标准计算加权分数 *)
let calculate_weighted_score_by_standard dimension_scores standard =
  let total_weight = List.fold_left (fun acc dim -> acc +. dim.weight) 0.0 standard.dimensions in
  if total_weight = 0.0 then 0.0 else
  let weighted_sum = List.fold_left (fun acc (dim_name, score) ->
    match List.find_opt (fun dim -> dim.dimension_name = dim_name) standard.dimensions with
    | Some dim -> acc +. (score *. dim.weight)
    | None -> acc
  ) 0.0 dimension_scores in
  weighted_sum /. total_weight

(** {1 标准统计} *)

(** 统计标准使用情况 *)
let get_standard_usage_statistics _standard_name =
  (* 简化实现：返回模拟统计数据 *)
  [
    ("使用次数", 150);
    ("评价项目数", 1200);
    ("平均评分", 75);  (* 百分制 *)
    ("优秀比例", 25);  (* 百分比 *)
  ]

(** 分析标准效果 *)
let analyze_standard_effectiveness _standard test_cases =
  let case_count = List.length test_cases in
  let avg_score = 0.75 in  (* 简化：固定平均分 *)
  let consistency = 0.85 in  (* 简化：固定一致性 *)
  [
    ("测试案例数量", float_of_int case_count);
    ("平均评分", avg_score);
    ("评分一致性", consistency);
    ("标准适用性", 0.9);
    ("用户满意度", 0.8);
  ]

(** {1 标准导出导入} *)

(** 导出标准为JSON *)
let export_standard_to_json standard =
  Printf.sprintf 
    "{\"name\":\"%s\",\"version\":\"%s\",\"poetry_forms\":%d,\"quality_grades\":%d,\"dimensions\":%d,\"description\":\"%s\"}"
    standard.standard_name
    standard.version
    (List.length standard.poetry_forms)
    (List.length standard.quality_grades)
    (List.length standard.dimensions)
    standard.description

(** 从JSON导入标准 *)
let import_standard_from_json json_string =
  (* 简化实现：返回默认标准 *)
  if String.length json_string > 0 then
    Some (get_classical_poetry_standard ())
  else
    None

(** 导出标准为文本 *)
let export_standard_to_text standard =
  Printf.sprintf "=== %s (版本: %s) ===\n描述: %s\n诗词形式: %d种\n质量等级: %d级\n评价维度: %d个\n创建日期: %.0f"
    standard.standard_name
    standard.version
    standard.description
    (List.length standard.poetry_forms)
    (List.length standard.quality_grades)
    (List.length standard.dimensions)
    standard.created_date

(** {1 标准版本管理} *)

(** 创建标准版本 *)
let create_standard_version base_standard version changes =
  let new_standard = { base_standard with 
    version; 
    created_date = Unix.time ();
    description = base_standard.description ^ " - " ^ String.concat "; " changes;
  } in
  standard_versions := new_standard :: !standard_versions;
  new_standard

(** 获取标准历史版本 *)
let get_standard_versions standard_name =
  List.filter (fun std -> std.standard_name = standard_name) !standard_versions

(** 比较标准版本 *)
let compare_standard_versions old_version new_version =
  [
    ("版本号变化", Printf.sprintf "%s → %s" old_version.version new_version.version);
    ("创建时间", Printf.sprintf "%.0f → %.0f" old_version.created_date new_version.created_date);
    ("描述变化", Printf.sprintf "%s → %s" old_version.description new_version.description);
    ("形式数量变化", Printf.sprintf "%d → %d" (List.length old_version.poetry_forms) (List.length new_version.poetry_forms));
    ("维度数量变化", Printf.sprintf "%d → %d" (List.length old_version.dimensions) (List.length new_version.dimensions));
  ]