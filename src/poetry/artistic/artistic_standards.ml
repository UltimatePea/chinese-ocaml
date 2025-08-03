(** 诗词艺术标准统一模块 - Issue #2000 整合实施
 *
 * 此文件整合了以下源文件的功能：
 * - src/poetry/poetry_artistic_standards.ml: 诗词艺术标准
 * - src/poetry/artistic_types.ml: 艺术类型定义
 * - src/poetry/evaluators/evaluator_types.ml: 评估器类型
 *
 * 整合完成后，上述文件将被删除。
 * @consolidation_issue #2000
 * @author Whisky, PR Worker
 *)

(** {1 诗词艺术标准定义} *)

(** 诗词体裁类型 *)
type poetry_form =
  | GuShi      (** 古诗 *)
  | LuShi      (** 律诗 *)
  | JueJu      (** 绝句 *)
  | Ci         (** 词 *)
  | Qu         (** 曲 *)
  | Fu         (** 赋 *)
  | PaiLv      (** 排律 *)

(** 声调类型 *)
type tone_type =
  | Ping       (** 平声 *)
  | Ze         (** 仄声 *)
  | Unknown    (** 未知 *)

(** 韵律要求 *)
type rhyme_requirement = {
  rhyme_scheme : string;       (** 韵律模式，如"ABAB" *)
  tone_pattern : tone_type list;   (** 平仄模式 *)
  required_lines : int;        (** 要求行数 *)
  allow_flexibility : bool;    (** 是否允许灵活性 *)
}

(** 艺术评价标准 *)
type artistic_standard = {
  name : string;                    (** 标准名称 *)
  description : string;             (** 标准描述 *)
  applicable_forms : poetry_form list;  (** 适用诗体 *)
  weight_distribution : (string * float) list;  (** 权重分配 *)
  minimum_score : float;            (** 最低分数要求 *)
  excellence_threshold : float;     (** 优秀分数阈值 *)
}

(** {1 标准诗体规范} *)

(** 五言绝句标准 *)
let wuyan_jueju_standard = {
  name = "五言绝句";
  description = "五言四句，讲究平仄对仗";
  applicable_forms = [JueJu];
  weight_distribution = [
    ("韵律和谐", 0.25);
    ("平仄协调", 0.25);
    ("意境营造", 0.20);
    ("用词精练", 0.15);
    ("结构完整", 0.15);
  ];
  minimum_score = 0.6;
  excellence_threshold = 0.85;
}

(** 七言律诗标准 *)
let qiyan_lushi_standard = {
  name = "七言律诗";
  description = "七言八句，严格平仄，中间两联必须对仗";
  applicable_forms = [LuShi];
  weight_distribution = [
    ("平仄协调", 0.30);
    ("对仗工整", 0.25);
    ("韵律和谐", 0.20);
    ("意境深远", 0.15);
    ("章法严谨", 0.10);
  ];
  minimum_score = 0.7;
  excellence_threshold = 0.9;
}

(** 古体诗标准 *)
let gushi_standard = {
  name = "古体诗";
  description = "形式自由，重在意境和情感表达";
  applicable_forms = [GuShi];
  weight_distribution = [
    ("意境营造", 0.35);
    ("情感表达", 0.25);
    ("语言优美", 0.20);
    ("创意新颖", 0.20);
  ];
  minimum_score = 0.5;
  excellence_threshold = 0.8;
}

(** 词牌标准 *)
let ci_standard = {
  name = "词";
  description = "按词牌填写，注重音律与情感";
  applicable_forms = [Ci];
  weight_distribution = [
    ("音律协调", 0.30);
    ("情感真挚", 0.25);
    ("词牌规范", 0.20);
    ("意象丰富", 0.15);
    ("语言精美", 0.10);
  ];
  minimum_score = 0.65;
  excellence_threshold = 0.85;
}

(** {1 评价等级定义} *)

type evaluation_grade =
  | Excellent   (** 优秀 90-100 *)
  | Good        (** 良好 80-89 *)
  | Fair        (** 中等 70-79 *)
  | Pass        (** 及格 60-69 *)
  | Fail        (** 不及格 0-59 *)

(** 根据分数确定等级 *)
let score_to_grade score =
  if score >= 0.9 then Excellent
  else if score >= 0.8 then Good
  else if score >= 0.7 then Fair
  else if score >= 0.6 then Pass
  else Fail

(** 等级转换为字符串 *)
let grade_to_string = function
  | Excellent -> "优秀"
  | Good -> "良好"
  | Fair -> "中等"
  | Pass -> "及格"
  | Fail -> "不及格"

(** 等级转换为分数范围 *)
let grade_to_score_range = function
  | Excellent -> (0.9, 1.0)
  | Good -> (0.8, 0.89)
  | Fair -> (0.7, 0.79)
  | Pass -> (0.6, 0.69)
  | Fail -> (0.0, 0.59)

(** {1 诗体识别} *)

(** 识别诗词体裁 *)
let identify_poetry_form lines =
  let line_count = List.length lines in
  let line_lengths = List.map String.length lines in
  let typical_length = match line_lengths with
    | [] -> 0
    | lengths -> List.fold_left (+) 0 lengths / List.length lengths
  in
  
  match line_count, typical_length with
  | 4, 5 -> Some JueJu    (* 五言绝句 *)
  | 4, 7 -> Some JueJu    (* 七言绝句 *)
  | 8, 5 -> Some LuShi    (* 五言律诗 *)
  | 8, 7 -> Some LuShi    (* 七言律诗 *)
  | n, _ when n > 8 -> Some GuShi  (* 古体诗 *)
  | n, l when n > 4 && l > 7 -> Some Ci     (* 词 *)
  | _ -> None

(** {1 韵律分析} *)

(** 分析韵脚模式 *)
let analyze_rhyme_pattern lines =
  let get_final_char line =
    let trimmed = String.trim line in
    if String.length trimmed > 0 then
      Some (String.sub trimmed (String.length trimmed - 1) 1)
    else None
  in
  
  let rhyme_chars = List.filter_map get_final_char lines in
  let unique_rhymes = List.sort_uniq String.compare rhyme_chars in
  
  (* 生成韵律模式字符串 *)
  let rhyme_map = List.mapi (fun i rhyme -> (rhyme, Char.chr (65 + i))) unique_rhymes in
  let pattern = List.map (fun char ->
    match List.find_opt (fun (rhyme, _) -> rhyme = char) rhyme_map with
    | Some (_, pattern_char) -> String.make 1 pattern_char
    | None -> "X"
  ) rhyme_chars in
  
  String.concat "" pattern

(** 分析平仄模式 (简化版本) *)
let analyze_tone_pattern lines =
  (* 这是一个简化的平仄分析，实际应该基于真实的声调数据 *)
  List.map (fun line ->
    String.to_seq line
    |> Seq.map (fun char ->
      let code = Char.code char in
      if code mod 2 = 0 then Ping else Ze
    )
    |> List.of_seq
  ) lines

(** {1 标准应用} *)

(** 根据诗体获取相应标准 *)
let get_standard_for_form form =
  match form with
  | JueJu -> Some wuyan_jueju_standard
  | LuShi -> Some qiyan_lushi_standard
  | GuShi -> Some gushi_standard
  | Ci -> Some ci_standard
  | _ -> None

(** 评估诗词是否符合标准 *)
let evaluate_against_standard poem_lines standard =
  let form = identify_poetry_form poem_lines in
  let applies = match form with
    | Some f -> List.mem f standard.applicable_forms
    | None -> false
  in
  
  if not applies then
    (false, 0.0, "不适用该标准")
  else
    let line_count = List.length poem_lines in
    let rhyme_pattern = analyze_rhyme_pattern poem_lines in
    let tone_patterns = analyze_tone_pattern poem_lines in
    
    (* 基础结构评分 *)
    let structure_score = 
      match standard.name with
      | "五言绝句" | "七言绝句" when line_count = 4 -> 1.0
      | "七言律诗" when line_count = 8 -> 1.0
      | "古体诗" -> 0.8  (* 古体诗形式相对自由 *)
      | "词" -> 0.9      (* 词的评价更复杂 *)
      | _ -> 0.6
    in
    
    (* 韵律评分 *)
    let rhyme_score = 
      let unique_rhymes = String.to_seq rhyme_pattern |> Seq.fold_left (fun acc c ->
        if List.mem c acc then acc else c :: acc
      ) [] in
      if List.length unique_rhymes <= 2 then 1.0
      else 1.0 -. (float_of_int (List.length unique_rhymes) -. 2.0) /. 10.0
    in
    
    (* 平仄评分 (简化) *)
    let tone_score = 
      let total_chars = List.fold_left (+) 0 (List.map List.length tone_patterns) in
      let ping_count = List.fold_left (fun acc pattern ->
        acc + List.fold_left (fun acc2 tone -> if tone = Ping then acc2 + 1 else acc2) 0 pattern
      ) 0 tone_patterns in
      let balance_ratio = if total_chars = 0 then 0.5 
                         else float_of_int ping_count /. float_of_int total_chars in
      1.0 -. abs_float (balance_ratio -. 0.5) *. 2.0
    in
    
    (* 综合评分 *)
    let overall_score = (structure_score +. rhyme_score +. tone_score) /. 3.0 in
    let meets_minimum = overall_score >= standard.minimum_score in
    let evaluation_text = Printf.sprintf 
      "结构评分: %.2f, 韵律评分: %.2f, 平仄评分: %.2f, 综合: %.2f" 
      structure_score rhyme_score tone_score overall_score in
    
    (meets_minimum, overall_score, evaluation_text)

(** {1 标准管理} *)

(** 所有预定义标准 *)
let all_standards = [
  wuyan_jueju_standard;
  qiyan_lushi_standard;
  gushi_standard;
  ci_standard;
]

(** 查找标准 *)
let find_standard name =
  List.find_opt (fun std -> std.name = name) all_standards

(** 列出所有标准名称 *)
let list_standard_names () =
  List.map (fun std -> std.name) all_standards

(** 获取标准详情 *)
let get_standard_details name =
  match find_standard name with
  | Some std -> Some (std.description, std.weight_distribution, std.minimum_score)
  | None -> None

(** {1 工具函数} *)

(** 验证权重分配 *)
let validate_weights weights =
  let total = List.fold_left (fun acc (_, weight) -> acc +. weight) 0.0 weights in
  abs_float (total -. 1.0) < 0.001

(** 标准化权重 *)
let normalize_weights weights =
  let total = List.fold_left (fun acc (_, weight) -> acc +. weight) 0.0 weights in
  if total = 0.0 then weights
  else List.map (fun (name, weight) -> (name, weight /. total)) weights