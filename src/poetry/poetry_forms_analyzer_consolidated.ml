(** Poetry Forms Analyzer Consolidated Module - Issue #1999
 * 
 * 诗词格律分析统一模块
 * Author: Whisky, PR Worker
 * 
 * 整合以下模块的功能：
 * - analysis/ 目录下文件
 * - form_evaluators.ml
 * - poetry_forms_evaluation.ml
 * - tone_pattern.ml
 * 
 * 目标：提供全面的诗词格律分析功能
 *)

open Poetry_core_consolidated

(** {1 格律分析类型定义} *)

(** 诗词平仄模式 *)
type ping_ze_pattern = 
  | Ping  (** 平声 *)
  | Ze    (** 仄声 *)

(** 对仗类型 *)
type duizhang_type = 
  | WordClass     (** 词性对仗 *)
  | Meaning       (** 意义对仗 *)
  | Structure     (** 结构对仗 *)
  | Sound         (** 声韵对仗 *)

(** 格律检查结果 *)
type form_check_result = {
  is_valid: bool;
  pattern_match: float;  (* 0.0-1.0 匹配度 *)
  violations: string list;
  suggestions: string list;
}

(** 对仗分析结果 *)
type duizhang_analysis = {
  line1: string;
  line2: string;
  duizhang_types: duizhang_type list;
  quality_score: float;
  details: string list;
}

(** 诗词格律分析结果 *)
type form_analysis_result = {
  poetry_form: poetry_form;
  ping_ze_check: form_check_result;
  duizhang_check: duizhang_analysis list;
  rhythm_score: float;
  overall_form_score: float;
  improvement_suggestions: string list;
}

(** {1 平仄模式数据} *)

(** 五言律诗平仄格式 *)
let wuyan_lushi_patterns = [
  (* 首联 *)
  ([Ping; Ze; Ping; Ping; Ze], [Ze; Ping; Ze; Ze; Ping]);
  (* 颔联 *) 
  ([Ze; Ping; Ping; Ze; Ze], [Ping; Ze; Ze; Ping; Ping]);
  (* 颈联 *)
  ([Ping; Ze; Ping; Ping; Ze], [Ze; Ping; Ze; Ze; Ping]);
  (* 尾联 *)
  ([Ze; Ping; Ping; Ze; Ze], [Ping; Ze; Ze; Ping; Ping]);
]

(** 七言律诗平仄格式 *)
let qiyan_lushi_patterns = [
  (* 首联 *)
  ([Ping; Ping; Ze; Ze; Ping; Ping; Ze], [Ze; Ze; Ping; Ping; Ze; Ze; Ping]);
  (* 颔联 *)
  ([Ze; Ze; Ping; Ping; Ping; Ze; Ze], [Ping; Ping; Ze; Ze; Ze; Ping; Ping]);
  (* 颈联 *)
  ([Ping; Ping; Ze; Ze; Ping; Ping; Ze], [Ze; Ze; Ping; Ping; Ze; Ze; Ping]);
  (* 尾联 *)
  ([Ze; Ze; Ping; Ping; Ping; Ze; Ze], [Ping; Ping; Ze; Ze; Ze; Ping; Ping]);
]

(** 五言绝句平仄格式 *)
let wuyan_jueju_patterns = [
  ([Ping; Ze; Ping; Ping; Ze], [Ze; Ping; Ze; Ze; Ping]);
  ([Ze; Ping; Ping; Ze; Ze], [Ping; Ze; Ze; Ping; Ping]);
]

(** 七言绝句平仄格式 *)
let qiyan_jueju_patterns = [
  ([Ping; Ping; Ze; Ze; Ping; Ping; Ze], [Ze; Ze; Ping; Ping; Ze; Ze; Ping]);
  ([Ze; Ze; Ping; Ping; Ping; Ze; Ze], [Ping; Ping; Ze; Ze; Ze; Ping; Ping]);
]

(** {1 平仄判断工具} *)

(** 判断字符的平仄 *)
let char_to_ping_ze (char: string) : ping_ze_pattern =
  match Poetry_core_consolidated.detect_rhyme_category char with
  | PingSheng -> Ping
  | ShangSheng | QuSheng | RuSheng -> Ze

(** 诗句转平仄模式 *)
let line_to_ping_ze_pattern (line: string) : ping_ze_pattern list =
  let chars = List.init (String.length line) (String.get line) in
  let char_strings = List.map (String.make 1) chars in
  List.map char_to_ping_ze char_strings

(** {1 格律检查引擎} *)

(** 计算平仄模式匹配度 *)
let calculate_pattern_match (actual: ping_ze_pattern list) (expected: ping_ze_pattern list) : float =
  if List.length actual <> List.length expected then 0.0
  else
    let matches = List.fold_left2 (fun acc a e ->
      if a = e then acc + 1 else acc
    ) 0 actual expected in
    float_of_int matches /. float_of_int (List.length expected)

(** 检查五言律诗格律 *)
let check_wuyan_lushi_form (poem_lines: string list) : form_check_result =
  if List.length poem_lines <> 8 then
    { is_valid = false; pattern_match = 0.0; 
      violations = ["五言律诗应为8行"]; suggestions = ["调整为8行诗句"] }
  else
    let line_patterns = List.map line_to_ping_ze_pattern poem_lines in
    let expected_patterns = wuyan_lushi_patterns in
    
    let matches = List.mapi (fun i pattern ->
      let expected_pair = List.nth expected_patterns (i / 2) in
      let expected_pattern = if i mod 2 = 0 then fst expected_pair else snd expected_pair in
      calculate_pattern_match pattern expected_pattern
    ) line_patterns in
    
    let avg_match = List.fold_left (+.) 0.0 matches /. float_of_int (List.length matches) in
    let violations = List.mapi (fun i match_rate ->
      if match_rate < 0.6 then Some (Printf.sprintf "第%d行平仄不符合格律（符合度%.1f%%）" (i+1) (match_rate *. 100.0))
      else None
    ) matches |> List.filter_map (fun x -> x) in
    
    let suggestions = 
      if avg_match < 0.7 then ["调整平仄安排，使其更符合律诗格律"; "重点关注对仗联的平仄要求"]
      else ["格律基本符合要求"]
    in
    
    { is_valid = avg_match >= 0.7; pattern_match = avg_match; violations = violations; suggestions = suggestions }

(** 检查七言律诗格律 *)
let check_qiyan_lushi_form (poem_lines: string list) : form_check_result =
  if List.length poem_lines <> 8 then
    { is_valid = false; pattern_match = 0.0; 
      violations = ["七言律诗应为8行"]; suggestions = ["调整为8行诗句"] }
  else
    let line_patterns = List.map line_to_ping_ze_pattern poem_lines in
    let expected_patterns = qiyan_lushi_patterns in
    
    let matches = List.mapi (fun i pattern ->
      let expected_pair = List.nth expected_patterns (i / 2) in
      let expected_pattern = if i mod 2 = 0 then fst expected_pair else snd expected_pair in
      calculate_pattern_match pattern expected_pattern
    ) line_patterns in
    
    let avg_match = List.fold_left (+.) 0.0 matches /. float_of_int (List.length matches) in
    let violations = List.mapi (fun i match_rate ->
      if match_rate < 0.6 then Some (Printf.sprintf "第%d行平仄不符合格律（符合度%.1f%%）" (i+1) (match_rate *. 100.0))
      else None
    ) matches |> List.filter_map (fun x -> x) in
    
    let suggestions = 
      if avg_match < 0.7 then ["调整平仄安排，使其更符合律诗格律"; "注意粘对关系"]
      else ["格律基本符合要求"]
    in
    
    { is_valid = avg_match >= 0.7; pattern_match = avg_match; violations = violations; suggestions = suggestions }

(** 检查绝句格律 *)
let check_jueju_form (poem_lines: string list) : form_check_result =
  if List.length poem_lines <> 4 then
    { is_valid = false; pattern_match = 0.0; 
      violations = ["绝句应为4行"]; suggestions = ["调整为4行诗句"] }
  else
    let line_lengths = List.map String.length poem_lines in
    let line_patterns = List.map line_to_ping_ze_pattern poem_lines in
    
    (* 判断是五言还是七言 *)
    let avg_length = List.fold_left (+) 0 line_lengths / List.length line_lengths in
    let expected_patterns = 
      if avg_length = 5 then wuyan_jueju_patterns
      else if avg_length = 7 then qiyan_jueju_patterns
      else []
    in
    
    if expected_patterns = [] then
      { is_valid = false; pattern_match = 0.0;
        violations = ["诗句长度不符合绝句要求"]; suggestions = ["调整为五言或七言绝句"] }
    else
      let matches = List.mapi (fun i pattern ->
        let expected_pair = List.nth expected_patterns (i / 2) in
        let expected_pattern = if i mod 2 = 0 then fst expected_pair else snd expected_pair in
        calculate_pattern_match pattern expected_pattern
      ) line_patterns in
      
      let avg_match = List.fold_left (+.) 0.0 matches /. float_of_int (List.length matches) in
      let violations = List.mapi (fun i match_rate ->
        if match_rate < 0.6 then Some (Printf.sprintf "第%d行平仄不符合格律（符合度%.1f%%）" (i+1) (match_rate *. 100.0))
        else None
      ) matches |> List.filter_map (fun x -> x) in
      
      let suggestions = 
        if avg_match < 0.7 then ["调整平仄安排，使其更符合绝句格律"]
        else ["格律基本符合要求"]
      in
      
      { is_valid = avg_match >= 0.7; pattern_match = avg_match; violations = violations; suggestions = suggestions }

(** {1 对仗分析引擎} *)

(** 简单的词性分类 *)
type word_class = 
  | Noun | Verb | Adjective | Number | Direction | Time | Other

(** 简单的词性判断 *)
let classify_word (word: string) : word_class =
  let noun_chars = ["山"; "水"; "花"; "月"; "风"; "雪"; "云"; "日"; "星"; "树"] in
  let verb_chars = ["来"; "去"; "看"; "听"; "想"; "望"; "行"; "住"; "坐"; "立"] in
  let adj_chars = ["美"; "好"; "高"; "大"; "小"; "长"; "短"; "明"; "暗"; "清"] in
  let num_chars = ["一"; "二"; "三"; "四"; "五"; "六"; "七"; "八"; "九"; "十"] in
  let dir_chars = ["东"; "西"; "南"; "北"; "上"; "下"; "左"; "右"; "前"; "后"] in
  let time_chars = ["春"; "夏"; "秋"; "冬"; "朝"; "夕"; "昼"; "夜"; "晨"; "暮"] in
  
  if List.mem word noun_chars then Noun
  else if List.mem word verb_chars then Verb
  else if List.mem word adj_chars then Adjective
  else if List.mem word num_chars then Number
  else if List.mem word dir_chars then Direction
  else if List.mem word time_chars then Time
  else Other

(** 分析对仗质量 *)
let analyze_duizhang (line1: string) (line2: string) : duizhang_analysis =
  let chars1 = List.init (String.length line1) (String.get line1) |> List.map (String.make 1) in
  let chars2 = List.init (String.length line2) (String.get line2) |> List.map (String.make 1) in
  
  if List.length chars1 <> List.length chars2 then
    { line1; line2; duizhang_types = []; quality_score = 0.0; 
      details = ["两行字数不等，无法构成对仗"] }
  else
    let word_pairs = List.combine chars1 chars2 in
    let class_matches = List.map (fun (c1, c2) ->
      let class1 = classify_word c1 in
      let class2 = classify_word c2 in
      class1 = class2
    ) word_pairs in
    
    let sound_matches = List.map (fun (c1, c2) ->
      let ping_ze1 = char_to_ping_ze c1 in
      let ping_ze2 = char_to_ping_ze c2 in
      ping_ze1 <> ping_ze2  (* 对仗要求平仄相对 *)
    ) word_pairs in
    
    let class_match_rate = 
      float_of_int (List.length (List.filter (fun x -> x) class_matches)) /. 
      float_of_int (List.length class_matches) in
    
    let sound_match_rate = 
      float_of_int (List.length (List.filter (fun x -> x) sound_matches)) /. 
      float_of_int (List.length sound_matches) in
    
    let duizhang_types = 
      let types = ref [] in
      if class_match_rate >= 0.6 then types := WordClass :: !types;
      if sound_match_rate >= 0.6 then types := Sound :: !types;
      !types
    in
    
    let quality_score = (class_match_rate +. sound_match_rate) /. 2.0 in
    
    let details = [
      Printf.sprintf "词性对仗符合度: %.1f%%" (class_match_rate *. 100.0);
      Printf.sprintf "声韵对仗符合度: %.1f%%" (sound_match_rate *. 100.0);
    ] in
    
    { line1; line2; duizhang_types; quality_score; details }

(** {1 综合格律分析} *)

(** 自动检测诗词形式 *)
let detect_poetry_form (poem_lines: string list) : poetry_form =
  let line_count = List.length poem_lines in
  let line_lengths = List.map String.length poem_lines in
  let avg_length = 
    if line_count > 0 then
      List.fold_left (+) 0 line_lengths / line_count
    else 0
  in
  
  match (line_count, avg_length) with
  | (4, 5) -> WuYanJueju
  | (4, 7) -> QiYanJueju
  | (8, 5) -> WuYanLushi
  | (8, 7) -> QiYanLushi
  | _ -> Custom (Printf.sprintf "%d行%d字" line_count avg_length)

(** 全面格律分析 *)
let comprehensive_form_analysis (poem_lines: string list) : form_analysis_result =
  let detected_form = detect_poetry_form poem_lines in
  
  (* 平仄检查 *)
  let ping_ze_check = 
    match detected_form with
    | WuYanLushi -> check_wuyan_lushi_form poem_lines
    | QiYanLushi -> check_qiyan_lushi_form poem_lines
    | WuYanJueju | QiYanJueju -> check_jueju_form poem_lines
    | Custom _ -> { is_valid = false; pattern_match = 0.0; 
                   violations = ["无法识别的诗词形式"]; suggestions = ["使用标准诗词格式"] }
  in
  
  (* 对仗检查（仅对律诗） *)
  let duizhang_check = 
    match detected_form with
    | WuYanLushi | QiYanLushi when List.length poem_lines = 8 ->
      (* 颔联（第3-4行）和颈联（第5-6行）需要对仗 *)
      let hancian_duizhang = analyze_duizhang (List.nth poem_lines 2) (List.nth poem_lines 3) in
      let jinglian_duizhang = analyze_duizhang (List.nth poem_lines 4) (List.nth poem_lines 5) in
      [hancian_duizhang; jinglian_duizhang]
    | _ -> []
  in
  
  (* 节律评分 *)
  let rhythm_score = 
    let rhyme_validation = Poetry_rhyme_engine_consolidated.validate_poem_rhyme poem_lines in
    let successful_rhymes = List.filter (fun (_, result) -> result.is_match) rhyme_validation in
    if List.length rhyme_validation > 0 then
      float_of_int (List.length successful_rhymes) /. float_of_int (List.length rhyme_validation)
    else 0.5
  in
  
  (* 综合格律评分 *)
  let duizhang_score = 
    if List.length duizhang_check > 0 then
      let total_score = List.fold_left (fun acc analysis -> acc +. analysis.quality_score) 0.0 duizhang_check in
      total_score /. float_of_int (List.length duizhang_check)
    else 0.8  (* 绝句不要求对仗，给较高分 *)
  in
  
  let overall_form_score = (ping_ze_check.pattern_match +. duizhang_score +. rhythm_score) /. 3.0 in
  
  (* 改进建议 *)
  let improvement_suggestions = 
    ping_ze_check.suggestions @ 
    (List.fold_left (fun acc analysis ->
      if analysis.quality_score < 0.6 then
        (Printf.sprintf "改进 %s 与 %s 的对仗质量" analysis.line1 analysis.line2) :: acc
      else acc
    ) [] duizhang_check) @
    (if rhythm_score < 0.6 then ["改进韵律安排"] else [])
  in
  
  {
    poetry_form = detected_form;
    ping_ze_check = ping_ze_check;
    duizhang_check = duizhang_check;
    rhythm_score = rhythm_score;
    overall_form_score = overall_form_score;
    improvement_suggestions = improvement_suggestions;
  }

(** {1 兼容性接口} *)

(** 简化的格律检查接口 *)
let check_poetry_form_simple (poem_lines: string list) : bool * float * string list =
  let analysis = comprehensive_form_analysis poem_lines in
  (analysis.ping_ze_check.is_valid && analysis.overall_form_score >= 0.7,
   analysis.overall_form_score,
   analysis.improvement_suggestions)

(** 兼容旧的平仄检查接口 *)
let check_ping_ze_compat (poem_lines: string list) : float =
  let analysis = comprehensive_form_analysis poem_lines in
  analysis.ping_ze_check.pattern_match