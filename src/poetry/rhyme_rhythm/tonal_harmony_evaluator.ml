(** 声调和谐评估器 - Issue #2136 韵律节拍评估器真正整合
    
    Author: Whisky, PR Worker  
    专门负责平仄搭配、声调和谐度的评估功能。
    整合了原有平仄检测、声调分析等复杂算法。
    
    整合的功能来源：
    - tonal_checker.ml的平仄检查逻辑
    - tone_pattern.ml的声调检测算法
    - tone_data.ml的声调数据处理
    - rhyme_scoring.ml的声调评分功能
    
    保持对中国古典诗词声调分析的高精度和复杂度。
    @since 2025-08-03  
    @fix_issue #2136 *)

open Unified_rhyme_engine

(** {1 声调和谐评估类型} *)

(** 平仄分析结果 *)
type tonal_analysis_result = {
  verse : string;                        (* 原诗句 *)
  character_tones : (string * tone_type) list; (* 逐字声调 *)
  tonal_pattern : bool list;             (* 平仄模式 (true=平, false=仄) *)
  pattern_type : string;                 (* 模式类型描述 *)
  alternation_score : float;             (* 平仄交替度 *)
  balance_score : float;                 (* 平仄平衡度 *)
  harmony_score : float;                 (* 整体和谐度 *)
}

(** 多句声调和谐分析 *)
type multi_tonal_harmony = {
  verses : string list;                  (* 原诗句列表 *)
  verse_analyses : tonal_analysis_result list; (* 各句分析结果 *)
  overall_alternation : float;           (* 整体交替度 *)
  overall_balance : float;               (* 整体平衡度 *)
  pattern_consistency : float;           (* 模式一致性 *)
  harmony_quality : [`Excellent | `Good | `Average | `Poor]; (* 和谐质量等级 *)
  improvement_suggestions : string list; (* 改进建议 *)
}

(** 声调搭配评估 *)
type tonal_pairing_evaluation = {
  pair_position : int * int;             (* 配对位置 *)
  char1 : string * tone_type;           (* 第一字及声调 *)
  char2 : string * tone_type;           (* 第二字及声调 *)
  pairing_type : [`Contrast | `Similar | `Identical]; (* 搭配类型 *)
  harmony_level : float;                 (* 和谐程度 0.0-1.0 *)
  suggestion : string option;           (* 改进建议 *)
}

(** 传统格律平仄模式 *)
type classical_tonal_pattern = {
  pattern_name : string;                 (* 格律名称 *)
  line_patterns : bool list list;       (* 各行平仄模式 *)
  strict_rules : (int * bool) list;     (* 严格位置要求 (位置, 平仄) *)
  flexible_positions : int list;        (* 可灵活变通的位置 *)
  description : string;                  (* 格律描述 *)
}

exception TonalHarmonyError of string

(** {1 传统格律平仄模式定义} *)

(** 七言绝句标准平仄模式 (整合自tone_pattern.ml) *)
let qijue_tonal_patterns = {
  pattern_name = "七言绝句";
  line_patterns = [
    [true; true; false; false; true; false; true];   (* 平平仄仄平仄平 *)
    [false; false; true; true; false; true; false];  (* 仄仄平平仄平仄 *)
    [false; false; true; true; true; false; false];  (* 仄仄平平平仄仄 *)
    [true; true; false; false; true; false; true];   (* 平平仄仄平仄平 *)
  ];
  strict_rules = [(1, true); (3, false); (5, true); (7, true)];  (* 1357不论246分明 *)
  flexible_positions = [1; 3; 5];
  description = "七绝首句平起入韵式，遵循粘对规律";
}

(** 五言律诗标准平仄模式 (整合自tone_pattern.ml) *)
let wuyan_lushi_patterns = {  
  pattern_name = "五言律诗";
  line_patterns = [
    [true; true; false; false; true];    (* 平平仄仄平 *)
    [false; false; true; true; false];   (* 仄仄平平仄 *)
    [false; false; true; true; true];    (* 仄仄平平平 *)
    [true; true; false; false; true];    (* 平平仄仄平 *)
    [true; true; false; false; true];    (* 平平仄仄平 *)
    [false; false; true; true; false];   (* 仄仄平平仄 *)
    [false; false; true; true; true];    (* 仄仄平平平 *)
    [true; true; false; false; true];    (* 平平仄仄平 *)
  ];
  strict_rules = [(1, true); (3, false); (5, true)];  (* 135不论24分明 *)
  flexible_positions = [1; 3];
  description = "五律首句平起不入韵式，中间两联对仗";
}

(** 词牌《沁园春》平仄模式示例 *)
let qinyuanchun_patterns = {
  pattern_name = "沁园春";
  line_patterns = [
    [false; false; true; true; false; false; true]; (* 仄仄平平仄仄平 *)
    [false; false; true; false; true];              (* 仄仄平仄平 *)
    [false; false; true; true; false; false; true]; (* 仄仄平平仄仄平 *)
    (* 更多行的模式... *)
  ];
  strict_rules = [(7, true); (5, true)];
  flexible_positions = [1; 2; 3];
  description = "词牌沁园春，平仄相间，豪放壮阔";
}

let standard_classical_patterns = [
  qijue_tonal_patterns;
  wuyan_lushi_patterns; 
  qinyuanchun_patterns;
]

(** {1 声调分析核心功能} *)

(** 分析单句的声调模式 (整合复杂的声调检测算法) *)
let analyze_verse_tonal_pattern verse engine_state =
  let verse_analysis = analyze_verse_rhythm verse engine_state in
  let character_tones = List.map (fun result ->
    let tone_type = Option.value result.tone_type ~default:LevelTone in
    (result.character, tone_type)
  ) verse_analysis.rhythm_results in
  
  let tonal_pattern = verse_analysis.tonal_pattern in
  
  (* 计算平仄交替度 (整合自tonal_checker.ml的复杂算法) *)
  let alternation_score = 
    if List.length tonal_pattern <= 1 then 1.0
    else
      let alternations = ref 0 in
      let rec count_alternations = function
        | [] | [_] -> ()
        | a :: b :: rest ->
            if a <> b then incr alternations;
            count_alternations (b :: rest)
      in
      count_alternations tonal_pattern;
      float_of_int !alternations /. float_of_int (List.length tonal_pattern - 1)
  in
  
  (* 计算平仄平衡度 *)
  let ping_count = List.fold_left (fun acc is_ping -> if is_ping then acc + 1 else acc) 0 tonal_pattern in
  let ze_count = List.length tonal_pattern - ping_count in
  let balance_score = 
    if List.length tonal_pattern = 0 then 1.0
    else
      1.0 -. abs_float (float_of_int ping_count -. float_of_int ze_count) /. float_of_int (List.length tonal_pattern)
  in
  
  (* 计算整体和谐度 *)
  let harmony_score = (alternation_score +. balance_score) /. 2.0 in
  
  (* 确定模式类型 *)
  let pattern_type = 
    if alternation_score >= 0.8 then "高度交替型"
    else if alternation_score >= 0.6 then "适度交替型"
    else if alternation_score >= 0.4 then "低度交替型"
    else "单调型"
  in
  
  {
    verse;
    character_tones;
    tonal_pattern;
    pattern_type;
    alternation_score;
    balance_score;
    harmony_score;
  }

(** 分析多句诗词的声调和谐性 *)
let analyze_multi_tonal_harmony verses engine_state =
  let verse_analyses = List.map (fun verse -> analyze_verse_tonal_pattern verse engine_state) verses in
  
  (* 计算整体交替度 *)
  let overall_alternation = 
    let total_alternation = List.fold_left (fun acc analysis -> acc +. analysis.alternation_score) 0.0 verse_analyses in
    if List.length verse_analyses = 0 then 0.0 
    else total_alternation /. float_of_int (List.length verse_analyses)
  in
  
  (* 计算整体平衡度 *)
  let overall_balance = 
    let total_balance = List.fold_left (fun acc analysis -> acc +. analysis.balance_score) 0.0 verse_analyses in
    if List.length verse_analyses = 0 then 0.0
    else total_balance /. float_of_int (List.length verse_analyses)
  in
  
  (* 计算模式一致性 *)
  let pattern_consistency = 
    if List.length verse_analyses <= 1 then 1.0
    else
      let pattern_types = List.map (fun analysis -> analysis.pattern_type) verse_analyses in
      let unique_types = List.sort_uniq String.compare pattern_types in
      1.0 -. (float_of_int (List.length unique_types - 1) /. float_of_int (List.length verse_analyses))
  in
  
  (* 评估整体和谐质量 *)
  let overall_score = (overall_alternation +. overall_balance +. pattern_consistency) /. 3.0 in
  let harmony_quality = 
    if overall_score >= 0.9 then `Excellent
    else if overall_score >= 0.75 then `Good
    else if overall_score >= 0.6 then `Average
    else `Poor
  in
  
  (* 生成改进建议 *)
  let improvement_suggestions = 
    let suggestions = ref [] in
    if overall_alternation < 0.6 then 
      suggestions := "增加平仄交替，避免连续多个同声调字" :: !suggestions;
    if overall_balance < 0.6 then
      suggestions := "调整平仄比例，使平声与仄声相对均衡" :: !suggestions;
    if pattern_consistency < 0.7 then
      suggestions := "统一各句的声调模式，保持整体一致性" :: !suggestions;
    if overall_score < 0.5 then
      suggestions := "建议参考传统格律，重新安排声调搭配" :: !suggestions;
    List.rev !suggestions
  in
  
  {
    verses;
    verse_analyses;
    overall_alternation;
    overall_balance;
    pattern_consistency;
    harmony_quality;
    improvement_suggestions;
  }

(** {1 传统格律验证} *)

(** 验证诗句是否符合指定的传统格律模式 *)
let validate_classical_pattern verse expected_pattern_record engine_state =
  let analysis = analyze_verse_tonal_pattern verse engine_state in
  let actual_pattern = analysis.tonal_pattern in
  
  (* 使用模式的第一行作为期望模式 *)
  let expected_pattern = List.hd expected_pattern_record.line_patterns in
  
  if List.length actual_pattern <> List.length expected_pattern then
    (false, 0.0, ["行长度不匹配"])
  else
    let matches = List.map2 (=) actual_pattern expected_pattern in
    let strict_violations = ref [] in
    let flexible_adjustments = ref [] in
    
    (* 检查严格位置的要求 *)
    List.iter (fun (pos, required_tone) ->
      if pos <= List.length actual_pattern then
        let actual_tone = List.nth actual_pattern (pos - 1) in
        if actual_tone <> required_tone then
          let tone_str = if required_tone then "平" else "仄" in
          strict_violations := Printf.sprintf "第%d字必须为%s声" pos tone_str :: !strict_violations
    ) expected_pattern_record.strict_rules;
    
    (* 检查灵活位置的建议 *)
    List.iter (fun pos ->
      if pos <= List.length actual_pattern then
        flexible_adjustments := Printf.sprintf "第%d字可灵活调整" pos :: !flexible_adjustments
    ) expected_pattern_record.flexible_positions;
    
    let correct_count = List.fold_left (fun acc match_result -> if match_result then acc + 1 else acc) 0 matches in
    let accuracy = float_of_int correct_count /. float_of_int (List.length matches) in
    let is_compliant = accuracy >= 0.8 && List.length !strict_violations = 0 in
    
    let suggestions = !strict_violations @ !flexible_adjustments in
    (is_compliant, accuracy, suggestions)

(** 找到最匹配的传统格律模式 *)
let find_best_matching_pattern verses engine_state =
  let verse_count = List.length verses in
  let candidate_patterns = List.filter (fun pattern -> 
    List.length pattern.line_patterns = verse_count
  ) standard_classical_patterns in
  
  if List.length candidate_patterns = 0 then
    (None, 0.0, ["未找到匹配的传统格律模式"])
  else
    let pattern_scores = List.map (fun pattern ->
      let line_scores = List.map (fun verse ->
        let (_, accuracy, _) = validate_classical_pattern verse pattern engine_state in
        accuracy
      ) verses in
      let avg_score = List.fold_left (+.) 0.0 line_scores /. float_of_int (List.length line_scores) in
      (pattern, avg_score)
    ) candidate_patterns in
    
    let best_pattern, best_score = List.fold_left (fun (best_pat, best_sc) (pat, sc) ->
      if sc > best_sc then (pat, sc) else (best_pat, best_sc)
    ) (List.hd candidate_patterns, 0.0) pattern_scores in
    
    let suggestions = if best_score < 0.7 then ["建议参考" ^ best_pattern.pattern_name ^ "格律进行调整"] else [] in
    (Some best_pattern, best_score, suggestions)

(** {1 声调搭配分析} *)

(** 分析相邻字符的声调搭配 *)
let analyze_adjacent_tonal_pairings verse engine_state =
  let analysis = analyze_verse_tonal_pattern verse engine_state in
  let char_tones = analysis.character_tones in
  
  let rec analyze_pairs acc i = function
    | [] | [_] -> List.rev acc
    | (char1, tone1) :: ((char2, tone2) :: _ as rest) ->
        let pairing_type = 
          if tone1 = tone2 then `Identical
          else match (tone1, tone2) with
            | (LevelTone, (RisingTone | DepartingTone | EnteringTone | FallingTone)) 
            | ((RisingTone | DepartingTone | EnteringTone | FallingTone), LevelTone) -> `Contrast
            | _ -> `Similar
        in
        
        let harmony_level = match pairing_type with
          | `Contrast -> 1.0
          | `Similar -> 0.7
          | `Identical -> 0.3
        in
        
        let suggestion = 
          if harmony_level < 0.5 then 
            Some ("建议调整第" ^ string_of_int (i + 1) ^ "字或第" ^ string_of_int (i + 2) ^ "字的声调")
          else None
        in
        
        let pairing = {
          pair_position = (i + 1, i + 2);
          char1 = (char1, tone1);
          char2 = (char2, tone2);
          pairing_type;
          harmony_level;
          suggestion;
        } in
        
        analyze_pairs (pairing :: acc) (i + 1) rest
  in
  
  analyze_pairs [] 0 char_tones

(** 分析诗句间的声调呼应 *)
let analyze_inter_verse_tonal_correspondence verses engine_state =
  let verse_analyses = List.map (fun verse -> analyze_verse_tonal_pattern verse engine_state) verses in
  
  (* 分析韵脚声调呼应 *)
  let rhyme_tone_correspondence = 
    let rhyme_tones = List.filter_map (fun analysis ->
      if List.length analysis.character_tones > 0 then
        let (_, last_tone) = List.hd (List.rev analysis.character_tones) in
        Some last_tone
      else None
    ) verse_analyses in
    
    let unique_rhyme_tones = List.sort_uniq compare rhyme_tones in
    let correspondence_score = 
      if List.length rhyme_tones <= 1 then 1.0
      else float_of_int (6 - List.length unique_rhyme_tones) /. 5.0
    in
    (correspondence_score, unique_rhyme_tones)
  in
  
  (* 分析句首声调模式 *)
  let first_tone_pattern = List.map (fun analysis ->
    if List.length analysis.character_tones > 0 then
      let (_, first_tone) = List.hd analysis.character_tones in
      Some first_tone
    else None
  ) verse_analyses in
  
  (rhyme_tone_correspondence, first_tone_pattern)

(** {1 高级声调分析} *)

(** 计算声调复杂度指数 *)
let calculate_tonal_complexity_index verses engine_state =
  let multi_analysis = analyze_multi_tonal_harmony verses engine_state in
  
  (* 声调变化复杂度 *)
  let variation_complexity = 1.0 -. multi_analysis.pattern_consistency in
  
  (* 交替复杂度 *)
  let alternation_complexity = multi_analysis.overall_alternation in
  
  (* 平衡复杂度 *)
  let balance_complexity = multi_analysis.overall_balance in
  
  (* 综合复杂度指数 *)
  let complexity_index = (variation_complexity +. alternation_complexity +. balance_complexity) /. 3.0 in
  
  let complexity_level = 
    if complexity_index >= 0.8 then "高度复杂"
    else if complexity_index >= 0.6 then "中等复杂"
    else if complexity_index >= 0.4 then "相对简单"
    else "单一简单"
  in
  
  (complexity_index, complexity_level)

(** 检测声调异常模式 *)
let detect_tonal_anomalies verses engine_state =
  let verse_analyses = List.map (fun verse -> analyze_verse_tonal_pattern verse engine_state) verses in
  let anomalies = ref [] in
  
  List.iteri (fun i analysis ->
    (* 检测连续同声调 *)
    let rec check_consecutive_tones count current_tone = function
      | [] -> if count >= 3 then 
          anomalies := Printf.sprintf "第%d句：连续%d个%s声字" (i+1) count 
            (match current_tone with true -> "平" | false -> "仄") :: !anomalies
      | tone :: rest -> 
          if tone = current_tone then
            check_consecutive_tones (count + 1) current_tone rest
          else (
            if count >= 3 then
              anomalies := Printf.sprintf "第%d句：连续%d个%s声字" (i+1) count 
                (match current_tone with true -> "平" | false -> "仄") :: !anomalies;
            check_consecutive_tones 1 tone rest
          )
    in
    
    match analysis.tonal_pattern with
    | [] -> ()
    | first_tone :: rest -> check_consecutive_tones 1 first_tone rest;
    
    (* 检测极度不平衡 *)
    if analysis.balance_score < 0.2 then
      anomalies := Printf.sprintf "第%d句：平仄极度不平衡" (i+1) :: !anomalies;
      
    (* 检测完全无交替 *)
    if analysis.alternation_score = 0.0 && List.length analysis.tonal_pattern > 1 then
      anomalies := Printf.sprintf "第%d句：完全无平仄交替" (i+1) :: !anomalies;
  ) verse_analyses;
  
  List.rev !anomalies

(** {1 格式化和工具函数} *)

(** 格式化声调类型 *)
let format_tone_type = function
  | LevelTone -> "平"
  | RisingTone -> "上" 
  | DepartingTone -> "去"
  | EnteringTone -> "入"
  | FallingTone -> "仄"

(** 格式化声调分析结果 *)
let format_tonal_analysis_result result =
  let char_tone_str = List.map (fun (char, tone) -> 
    char ^ "(" ^ format_tone_type tone ^ ")"
  ) result.character_tones |> String.concat " " in
  
  let pattern_str = List.map (fun is_ping -> if is_ping then "平" else "仄") result.tonal_pattern |> String.concat "" in
  
  Printf.sprintf "=== 声调分析 ===\n诗句: %s\n逐字声调: %s\n平仄模式: %s\n模式类型: %s\n交替度: %.2f\n平衡度: %.2f\n和谐度: %.2f"
    result.verse char_tone_str pattern_str result.pattern_type 
    result.alternation_score result.balance_score result.harmony_score

(** 格式化多句声调和谐分析 *)
let format_multi_tonal_harmony analysis =
  let quality_str = match analysis.harmony_quality with
    | `Excellent -> "优秀"
    | `Good -> "良好"
    | `Average -> "一般"
    | `Poor -> "较差"
  in
  
  let suggestions_str = String.concat "; " analysis.improvement_suggestions in
  
  Printf.sprintf "=== 整体声调和谐分析 ===\n整体交替度: %.2f\n整体平衡度: %.2f\n模式一致性: %.2f\n和谐质量: %s\n改进建议: %s"
    analysis.overall_alternation analysis.overall_balance analysis.pattern_consistency 
    quality_str suggestions_str

(** 格式化声调搭配评估 *)
let format_tonal_pairing_evaluation pairing =
  let (pos1, pos2) = pairing.pair_position in
  let (char1, tone1) = pairing.char1 in
  let (char2, tone2) = pairing.char2 in
  let pairing_type_str = match pairing.pairing_type with
    | `Contrast -> "对比"
    | `Similar -> "相似"
    | `Identical -> "相同"
  in
  let suggestion_str = Option.value pairing.suggestion ~default:"无建议" in
  
  Printf.sprintf "位置%d-%d: %s(%s)-%s(%s) [%s] 和谐度:%.2f %s"
    pos1 pos2 char1 (format_tone_type tone1) char2 (format_tone_type tone2)
    pairing_type_str pairing.harmony_level suggestion_str