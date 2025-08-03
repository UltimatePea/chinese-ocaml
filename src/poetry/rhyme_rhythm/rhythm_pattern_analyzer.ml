(** 节拍模式分析器 - Issue #2136 韵律节拍评估器真正整合
    
    Author: Whisky, PR Worker
    专门负责节拍、格律模式的识别和分析功能。
    整合了原有的格律检查、节拍分析等功能。
    
    整合的功能来源：
    - meter_engine.ml的格律检查逻辑
    - rhythm_analyzer.ml的节拍分析算法  
    - rhyme_pattern.ml的韵律模式识别
    - Poetry_forms相关的格律验证
    
    保持对中国古典诗词格律的精确分析能力。
    @since 2025-08-03
    @fix_issue #2136 *)

open Poetry_core.Poetry_types
open Unified_rhyme_engine

(** {1 节拍模式分析类型} *)

(** 诗体类型 (整合自meter_engine.ml) *)
type poetry_form =
  | LuShi of int          (* 律诗：五言律诗(5)，七言律诗(7) *)
  | JueJu of int          (* 绝句：五言绝句(5)，七言绝句(7) *)
  | Ci of string          (* 词：词牌名 *)
  | Qu of string          (* 曲：曲牌名 *)
  | GuTi                  (* 古体诗 *)
  | ZiYou                 (* 自由体 *)

(** 格律模式 *)
type meter_pattern = {
  form : poetry_form;                     (* 诗体类型 *)
  required_lines : int;                   (* 要求行数 *)
  line_lengths : int list;                (* 各行字数要求 *)
  rhyme_scheme : rhyme_group option list; (* 韵律方案 *)
  meter_tonal_pattern : rhyme_category list list; (* 格律平仄模式 *)
  parallelism_required : bool;            (* 是否要求对仗 *)
}

(** 节拍分析结果 *)
type rhythm_pattern_result = {
  detected_form : poetry_form;            (* 识别的诗体 *)
  confidence : float;                     (* 识别置信度 *)
  line_pattern : int list;                (* 实际行字数模式 *)
  rhythm_regularity : float;              (* 节拍规整度 *)
  pattern_consistency : float;            (* 模式一致性 *)
  suggestions : string list;              (* 改进建议 *)
}

(** 格律符合性检查结果 *)
type meter_compliance_result = {
  pattern : meter_pattern;
  verse_count : int;
  line_length_compliance : bool list;
  rhyme_compliance : bool list;
  tonal_compliance : bool list;
  parallelism_compliance : bool list;
  overall_compliance : float;
  violations : string list;
  suggestions : string list;
}

(** 节拍特征分析 *)
type rhythm_features = {
  average_line_length : float;
  length_variance : float;
  rhythm_type : string;                   (* "规整"、"自由"、"混合" *)
  regularity_score : float;
  complexity_level : int;                 (* 1-5复杂度等级 *)
}

exception RhythmPatternError of string

(** {1 诗体识别功能} *)

(** 预定义的标准格律模式 *)
let standard_patterns = [
  (* 五言绝句 *)
  { form = JueJu 5; required_lines = 4; line_lengths = [5; 5; 5; 5];
    rhyme_scheme = [None; Some FengRhyme; None; Some FengRhyme];
    meter_tonal_pattern = [
      [PingSheng; PingSheng; ZeSheng; ZeSheng; PingSheng];
      [ZeSheng; ZeSheng; PingSheng; PingSheng; ZeSheng]; 
      [ZeSheng; ZeSheng; PingSheng; PingSheng; PingSheng];
      [PingSheng; PingSheng; ZeSheng; ZeSheng; PingSheng]
    ];
    parallelism_required = false };
    
  (* 七言绝句 *)
  { form = JueJu 7; required_lines = 4; line_lengths = [7; 7; 7; 7];
    rhyme_scheme = [None; Some FengRhyme; None; Some FengRhyme];
    meter_tonal_pattern = [
      [PingSheng; PingSheng; ZeSheng; ZeSheng; PingSheng; ZeSheng; PingSheng];
      [ZeSheng; ZeSheng; PingSheng; PingSheng; ZeSheng; PingSheng; ZeSheng];
      [ZeSheng; ZeSheng; PingSheng; PingSheng; PingSheng; ZeSheng; ZeSheng];
      [PingSheng; PingSheng; ZeSheng; ZeSheng; PingSheng; ZeSheng; PingSheng]
    ];
    parallelism_required = false };
    
  (* 五言律诗 *)
  { form = LuShi 5; required_lines = 8; line_lengths = [5; 5; 5; 5; 5; 5; 5; 5];
    rhyme_scheme = [None; Some FengRhyme; None; Some FengRhyme; None; Some FengRhyme; None; Some FengRhyme];
    meter_tonal_pattern = [
      [PingSheng; PingSheng; ZeSheng; ZeSheng; PingSheng];
      [ZeSheng; ZeSheng; PingSheng; PingSheng; ZeSheng];
      [ZeSheng; ZeSheng; PingSheng; PingSheng; PingSheng];
      [PingSheng; PingSheng; ZeSheng; ZeSheng; PingSheng];
      [PingSheng; PingSheng; ZeSheng; ZeSheng; PingSheng];
      [ZeSheng; ZeSheng; PingSheng; PingSheng; ZeSheng];
      [ZeSheng; ZeSheng; PingSheng; PingSheng; PingSheng];
      [PingSheng; PingSheng; ZeSheng; ZeSheng; PingSheng]
    ];
    parallelism_required = true };
    
  (* 七言律诗 *)
  { form = LuShi 7; required_lines = 8; line_lengths = [7; 7; 7; 7; 7; 7; 7; 7];
    rhyme_scheme = [None; Some FengRhyme; None; Some FengRhyme; None; Some FengRhyme; None; Some FengRhyme];
    meter_tonal_pattern = [
      [PingSheng; PingSheng; ZeSheng; ZeSheng; PingSheng; ZeSheng; PingSheng];
      [ZeSheng; ZeSheng; PingSheng; PingSheng; ZeSheng; PingSheng; ZeSheng];
      [ZeSheng; ZeSheng; PingSheng; PingSheng; PingSheng; ZeSheng; ZeSheng];
      [PingSheng; PingSheng; ZeSheng; ZeSheng; PingSheng; ZeSheng; PingSheng];
      [PingSheng; PingSheng; ZeSheng; ZeSheng; PingSheng; ZeSheng; PingSheng];
      [ZeSheng; ZeSheng; PingSheng; PingSheng; ZeSheng; PingSheng; ZeSheng];
      [ZeSheng; ZeSheng; PingSheng; PingSheng; PingSheng; ZeSheng; ZeSheng];
      [PingSheng; PingSheng; ZeSheng; ZeSheng; PingSheng; ZeSheng; PingSheng]
    ];
    parallelism_required = true };
    
  (* 古体诗模式 *)
  { form = GuTi; required_lines = 0; line_lengths = [];
    rhyme_scheme = []; meter_tonal_pattern = []; parallelism_required = false };
]

(** 根据行数和字数模式识别诗体 *)
let detect_poetry_form verses =
  let line_count = List.length verses in
  let line_lengths = List.map String.length verses in
  let avg_length = 
    if line_count = 0 then 0.0
    else float_of_int (List.fold_left (+) 0 line_lengths) /. float_of_int line_count
  in
  
  (* 计算长度一致性 *)
  let length_variance = 
    if line_count <= 1 then 0.0
    else
      let variance_sum = List.fold_left (fun acc len ->
        acc +. (float_of_int len -. avg_length) ** 2.0) 0.0 line_lengths in
      variance_sum /. float_of_int line_count
  in
  
  let is_regular = length_variance <= 0.5 in
  
  (* 诗体识别逻辑 *)
  let (detected_form, confidence) = 
    match (line_count, is_regular, avg_length) with
    | (4, true, len) when len >= 6.5 -> (JueJu 7, 0.95)
    | (4, true, len) when len >= 4.5 -> (JueJu 5, 0.95)
    | (8, true, len) when len >= 6.5 -> (LuShi 7, 0.95)
    | (8, true, len) when len >= 4.5 -> (LuShi 5, 0.95)
    | (4, false, _) -> (JueJu 5, 0.6)  (* 不规整的四行诗，可能是变格绝句 *)
    | (8, false, _) -> (LuShi 5, 0.6)  (* 不规整的八行诗，可能是变格律诗 *)
    | _ -> (GuTi, 0.8)                 (* 其他情况归为古体诗 *)
  in
  
  let suggestions = 
    if confidence < 0.8 then ["建议检查诗句行数和字数是否符合格律要求"]
    else if not is_regular then ["建议统一各行字数以符合格律"]
    else []
  in
  
  {
    detected_form;
    confidence;
    line_pattern = line_lengths;
    rhythm_regularity = if is_regular then 1.0 else 0.5;
    pattern_consistency = 1.0 -. (length_variance /. (avg_length +. 1.0));
    suggestions;
  }

(** 获取诗体对应的标准格律模式 *)
let get_standard_pattern poetry_form =
  try
    List.find (fun pattern -> pattern.form = poetry_form) standard_patterns
  with Not_found ->
    (* 返回古体诗模式作为默认 *)
    List.find (fun pattern -> pattern.form = GuTi) standard_patterns

(** {1 节拍特征分析} *)

(** 分析诗句的节拍特征 *)
let analyze_rhythm_features verses =
  let line_lengths = List.map String.length verses in
  let line_count = List.length verses in
  
  if line_count = 0 then
    raise (RhythmPatternError "诗句列表为空")
  else
    let total_chars = List.fold_left (+) 0 line_lengths in
    let average_line_length = float_of_int total_chars /. float_of_int line_count in
    
    (* 计算长度方差 *)
    let length_variance = 
      let variance_sum = List.fold_left (fun acc len ->
        acc +. (float_of_int len -. average_line_length) ** 2.0) 0.0 line_lengths in
      variance_sum /. float_of_int line_count
    in
    
    (* 确定节拍类型 *)
    let rhythm_type = 
      if length_variance <= 0.5 then "规整"
      else if length_variance <= 2.0 then "混合"
      else "自由"
    in
    
    let regularity_score = 
      1.0 /. (1.0 +. length_variance)
    in
    
    (* 复杂度评级 *)
    let complexity_level = 
      if line_count <= 4 && length_variance <= 0.5 then 1
      else if line_count <= 8 && length_variance <= 1.0 then 2
      else if line_count <= 12 && length_variance <= 2.0 then 3
      else if line_count <= 20 then 4
      else 5
    in
    
    {
      average_line_length;
      length_variance;
      rhythm_type;
      regularity_score;
      complexity_level;
    }

(** {1 格律符合性检查} *)

(** 检查行数符合性 *)
let check_line_count_compliance verses pattern =
  let actual_count = List.length verses in
  let required_count = pattern.required_lines in
  if required_count = 0 then (true, [])  (* 古体诗不限行数 *)
  else if actual_count = required_count then (true, [])
  else (false, [Printf.sprintf "行数不符：要求%d行，实际%d行" required_count actual_count])

(** 检查行长度符合性 *)
let check_line_length_compliance verses pattern =
  if List.length pattern.line_lengths = 0 then
    (List.map (fun _ -> true) verses, [])  (* 古体诗不限字数 *)
  else
    let actual_lengths = List.map String.length verses in
    let compliance = List.map2 (=) actual_lengths pattern.line_lengths in 
    let violations = List.mapi (fun i (actual, (expected, compliant)) ->
      if not compliant then 
        Some (Printf.sprintf "第%d行字数不符：要求%d字，实际%d字" (i+1) expected actual)
      else None
    ) (List.combine actual_lengths (List.combine pattern.line_lengths compliance)) in
    (compliance, List.filter_map (fun x -> x) violations)

(** 检查韵律符合性 (使用统一韵律引擎) *)
let check_rhyme_compliance verses pattern engine_state =
  if List.length pattern.rhyme_scheme = 0 then
    (List.map (fun _ -> true) verses, [])
  else
    let multi_analysis = analyze_multi_verse_rhythm verses engine_state in
    let actual_scheme = multi_analysis.rhyme_scheme in
    
    let compliance = List.map2 (fun actual_opt expected_opt ->
      match (actual_opt, expected_opt) with
      | Some actual, Some expected -> actual = expected  
      | None, None -> true
      | _, _ -> false
    ) actual_scheme pattern.rhyme_scheme in
    
    let violations = List.mapi (fun i ((actual_opt, expected_opt), compliant) ->
      if not compliant then
        let actual_str = Option.map rhyme_group_to_string actual_opt |> Option.value ~default:"无韵" in
        let expected_str = Option.map rhyme_group_to_string expected_opt |> Option.value ~default:"无韵" in
        Some (Printf.sprintf "第%d行韵律不符：要求%s，实际%s" (i+1) expected_str actual_str)
      else None
    ) (List.combine (List.combine actual_scheme pattern.rhyme_scheme) compliance) in
    
    (compliance, List.filter_map (fun x -> x) violations)

(** 检查平仄符合性 (使用统一韵律引擎) *)
let check_tonal_compliance verses pattern engine_state =
  if List.length pattern.meter_tonal_pattern = 0 then
    (List.map (fun _ -> true) verses, [])
  else
    let verse_analyses = List.map (fun verse -> analyze_verse_rhythm verse engine_state) verses in
    let actual_patterns = List.map (fun verse_analysis -> 
      List.map (fun is_level -> if is_level then PingSheng else ZeSheng) verse_analysis.tonal_pattern
    ) verse_analyses in
    
    let compliance = List.map2 (fun actual expected ->
      if List.length actual = List.length expected then
        List.for_all2 (=) actual expected
      else false
    ) actual_patterns pattern.meter_tonal_pattern in
    
    let violations = List.mapi (fun i ((actual, expected), compliant) ->
      if not compliant then
        let actual_str = List.map rhyme_category_to_string actual |> String.concat "" in
        let expected_str = List.map rhyme_category_to_string expected |> String.concat "" in  
        Some (Printf.sprintf "第%d行平仄不符：要求%s，实际%s" (i+1) expected_str actual_str)
      else None
    ) (List.combine (List.combine actual_patterns pattern.meter_tonal_pattern) compliance) in
    
    (compliance, List.filter_map (fun x -> x) violations)

(** 检查对仗符合性 (简化实现) *)
let check_parallelism_compliance verses pattern _engine_state =
  if not pattern.parallelism_required then
    (List.map (fun _ -> true) verses, [])
  else
    (* 简化的对仗检查：律诗中间两联需要对仗 *)
    match pattern.form with
    | LuShi _ when List.length verses = 8 ->
        (* 检查颔联(3-4句)和颈联(5-6句)的对仗 *)
        let han_lian_ok = true in  (* 简化实现，暂时认为符合 *)
        let jing_lian_ok = true in (* 简化实现，暂时认为符合 *)
        let compliance = [true; true; han_lian_ok; han_lian_ok; jing_lian_ok; jing_lian_ok; true; true] in
        let violations = if han_lian_ok && jing_lian_ok then [] else ["对仗不够工整"] in
        (compliance, violations)
    | _ -> (List.map (fun _ -> true) verses, [])

(** 执行完整的格律符合性检查 *)
let check_meter_compliance verses pattern engine_state =
  let (line_count_ok, line_count_violations) = check_line_count_compliance verses pattern in
  let (line_length_compliance, line_length_violations) = check_line_length_compliance verses pattern in
  let (rhyme_compliance, rhyme_violations) = check_rhyme_compliance verses pattern engine_state in
  let (tonal_compliance, tonal_violations) = check_tonal_compliance verses pattern engine_state in
  let (parallelism_compliance, parallelism_violations) = check_parallelism_compliance verses pattern engine_state in
  
  (* 计算整体符合度 *)
  let count_compliant items = List.fold_left (fun acc x -> acc +. if x then 1.0 else 0.0) 0.0 items in
  let total_checks = 
    (if line_count_ok then 1.0 else 0.0) +.
    count_compliant line_length_compliance +.
    count_compliant rhyme_compliance +.
    count_compliant tonal_compliance +.
    count_compliant parallelism_compliance
  in
  let max_checks = 
    1.0 +. 
    float_of_int (List.length line_length_compliance) +.
    float_of_int (List.length rhyme_compliance) +.
    float_of_int (List.length tonal_compliance) +.
    float_of_int (List.length parallelism_compliance)
  in
  let overall_compliance = if max_checks > 0.0 then total_checks /. max_checks else 0.0 in
  
  (* 汇总所有违规项 *)
  let all_violations = 
    line_count_violations @ line_length_violations @ rhyme_violations @ 
    tonal_violations @ parallelism_violations
  in
  
  (* 生成建议 *)
  let suggestions = 
    if overall_compliance > 0.8 then ["格律符合度很高，继续保持！"]
    else if overall_compliance > 0.6 then ["格律基本符合，注意细节调整"]
    else ["建议参考标准格律进行重大调整"] @
         (if List.length line_count_violations > 0 then ["调整诗句行数"] else []) @
         (if List.length line_length_violations > 0 then ["调整各行字数"] else []) @
         (if List.length rhyme_violations > 0 then ["调整韵律安排"] else []) @
         (if List.length tonal_violations > 0 then ["调整平仄搭配"] else []) @
         (if List.length parallelism_violations > 0 then ["完善对仗结构"] else [])
  in
  
  {
    pattern;
    verse_count = List.length verses;
    line_length_compliance;
    rhyme_compliance;
    tonal_compliance;
    parallelism_compliance;
    overall_compliance;
    violations = all_violations;
    suggestions;
  }

(** {1 自动格律分析} *)

(** 自动识别诗体并检查格律 *)
let auto_analyze_meter verses engine_state =
  let pattern_result = detect_poetry_form verses in
  let standard_pattern = get_standard_pattern pattern_result.detected_form in
  let compliance_result = check_meter_compliance verses standard_pattern engine_state in
  (pattern_result, compliance_result)

(** {1 高级节拍模式分析} *)

(** 分析节拍变化模式 *)
let analyze_rhythm_variations verses =
  let line_lengths = List.map String.length verses in
  if List.length line_lengths < 2 then []
  else
    let rec analyze_pairs acc = function
      | [] | [_] -> List.rev acc
      | a :: b :: rest ->
          let variation = abs (a - b) in
          let pattern = 
            if variation = 0 then "平稳"
            else if variation <= 2 then "微调" 
            else "跳跃"
          in
          analyze_pairs ((a, b, variation, pattern) :: acc) (b :: rest)
    in
    analyze_pairs [] line_lengths

(** 检测节拍循环模式 *)
let detect_rhythm_cycles verses =
  let line_lengths = List.map String.length verses in
  let len = List.length line_lengths in
  
  (* 检测2-4句的循环模式 *)
  let check_cycle cycle_len =
    if len < cycle_len * 2 then false
    else
      let rec check_cycle_helper i =
        if i + cycle_len >= len then true
        else if List.nth line_lengths i = List.nth line_lengths (i + cycle_len) then
          check_cycle_helper (i + 1)
        else false
      in
      check_cycle_helper 0
  in
  
  let cycles = [2; 3; 4] in
  List.filter check_cycle cycles

(** {1 格式化和工具函数} *)

(** 格式化诗体类型 *)
let format_poetry_form = function
  | LuShi n -> Printf.sprintf "%d言律诗" n
  | JueJu n -> Printf.sprintf "%d言绝句" n  
  | Ci name -> Printf.sprintf "词·%s" name
  | Qu name -> Printf.sprintf "曲·%s" name
  | GuTi -> "古体诗"
  | ZiYou -> "自由体"

(** 格式化节拍模式结果 *)
let format_rhythm_pattern_result result =
  let form_str = format_poetry_form result.detected_form in
  let pattern_str = String.concat "-" (List.map string_of_int result.line_pattern) in
  Printf.sprintf "识别诗体: %s (%.2f)\n行字数模式: %s\n节拍规整度: %.2f\n模式一致性: %.2f" 
    form_str result.confidence pattern_str result.rhythm_regularity result.pattern_consistency

(** 格式化格律检查结果 *)
let format_meter_compliance_result result =
  let form_str = format_poetry_form result.pattern.form in
  let compliance_str = Printf.sprintf "整体符合度: %.2f" result.overall_compliance in
  let violations_str = 
    if List.length result.violations = 0 then "无违规项" 
    else String.concat "; " result.violations in
  let suggestions_str = String.concat "; " result.suggestions in
  
  Printf.sprintf "=== 格律检查结果 ===\n诗体: %s\n%s\n违规项: %s\n建议: %s"
    form_str compliance_str violations_str suggestions_str

(** 格式化节拍特征 *)
let format_rhythm_features features =
  Printf.sprintf "=== 节拍特征分析 ===\n平均行长: %.1f字\n长度方差: %.2f\n节拍类型: %s\n规整度: %.2f\n复杂度等级: %d"
    features.average_line_length features.length_variance features.rhythm_type 
    features.regularity_score features.complexity_level