(* 诗词艺术性评价模块 - 骆言诗词编程特性
   古之诗者，不仅求格律之正，更求意境之美。音韵和谐，对仗工整，方为佳作。
   此模块专司诗词艺术性评价，综合音韵、对仗、意境等因素，为诗词创作提供全面指导。
   既遵古制，又开新风，助力程序员书写诗意代码。
*)

open Yyocamlc_lib
open Rhyme_analysis
open Tone_pattern

(* 中文字符计数函数：使用统一的UTF-8工具模块 *)
let count_chinese_chars text =
  (* 使用统一的UTF-8工具模块，消除代码重复 *)
  Utf8_utils.StringUtils.utf8_length text

(* 艺术性评价维度 *)
type artistic_dimension =
  | RhymeHarmony    (* 韵律和谐 *)
  | TonalBalance    (* 声调平衡 *)
  | Parallelism     (* 对仗工整 *)
  | Imagery         (* 意象深度 *)
  | Rhythm          (* 节奏感 *)
  | Elegance        (* 雅致程度 *)

(* 评价等级：依传统诗词品评标准 *)
type evaluation_grade =
  | Excellent       (* 上品 - 意境高远，韵律和谐，可称佳作 *)
  | Good            (* 中品 - 格律工整，音韵协调，颇具水准 *)
  | Fair            (* 下品 - 基本合格，略有瑕疵，尚可改进 *)
  | Poor            (* 不入流 - 格律错乱，音韵不谐，需重修 *)

(* 艺术性评价报告：全面分析诗词的艺术特征 *)
type artistic_report = {
  verse : string;                           (* 原诗句 *)
  rhyme_score : float;                      (* 韵律得分 *)
  tone_score : float;                       (* 声调得分 *)
  parallelism_score : float;                (* 对仗得分 *)
  imagery_score : float;                    (* 意象得分 *)
  rhythm_score : float;                     (* 节奏得分 *)
  elegance_score : float;                   (* 雅致得分 *)
  overall_grade : evaluation_grade;         (* 总体评价 *)
  suggestions : string list;                (* 改进建议 *)
}

(* 四言骈体艺术性评价标准 *)
type siyan_artistic_standards = {
  char_count : int;                         (* 字数标准：每句四字 *)
  tone_pattern : bool list;                 (* 声调模式：平仄相对 *)
  parallelism_required : bool;              (* 是否要求对仗 *)
  rhythm_weight : float;                    (* 节奏权重 *)
}

(* 四言骈体标准 *)
let siyan_standards = {
  char_count = 4;
  tone_pattern = [true; true; false; false];
  parallelism_required = true;
  rhythm_weight = 0.3;
}

(* 评价韵律和谐度：检查诗句的音韵是否和谐 *)
let evaluate_rhyme_harmony verse =
  let rhyme_report = generate_rhyme_report verse in
  let rhyme_group = rhyme_report.rhyme_group in
  
  (* 基础韵律得分 *)
  let base_score = match rhyme_group with
    | UnknownRhyme -> 0.4  (* 未知韵组，得分较低 *)
    | _ -> 0.8             (* 已知韵组，基础得分 *)
  in
  
  (* 韵脚质量评价 *)
  let rhyme_quality = match rhyme_report.rhyme_ending with
    | None -> 0.0
    | Some _ -> 0.2
  in
  
  base_score +. rhyme_quality

(* 评价声调平衡度：检查平仄搭配是否合理 *)
let evaluate_tonal_balance verse expected_pattern =
  let tone_report = generate_tone_report verse expected_pattern in
  let pattern_match = tone_report.pattern_match in
  
  (* 基础声调得分 *)
  let base_score = if pattern_match then 0.8 else 0.4 in
  
  (* 声调多样性评价 *)
  let tone_diversity = 
    let level_count = List.length (List.filter (fun x -> x) tone_report.simple_pattern) in
    let total_count = List.length tone_report.simple_pattern in
    let oblique_count = total_count - level_count in
    let diversity = min level_count oblique_count in
    (float_of_int diversity) /. (float_of_int total_count) *. 0.2
  in
  
  base_score +. tone_diversity

(* 评价对仗工整度：检查对仗的工整程度 *)
let evaluate_parallelism left_verse right_verse =
  let left_chars = count_chinese_chars left_verse in
  let right_chars = count_chinese_chars right_verse in
  
  (* 字数对应 *)
  let char_balance = if left_chars = right_chars then 0.4 else 0.0 in
  
  (* 声调对应 *)
  let left_pattern = analyze_simple_tone_pattern left_verse in
  let right_pattern = analyze_simple_tone_pattern right_verse in
  
  let tone_correspondence = 
    if List.length left_pattern = List.length right_pattern then
      let pairs = List.combine left_pattern right_pattern in
      let opposite_pairs = List.filter (fun (l, r) -> l <> r) pairs in
      let correspondence_ratio = (float_of_int (List.length opposite_pairs)) /. 
                               (float_of_int (List.length pairs)) in
      correspondence_ratio *. 0.4
    else 0.0
  in
  
  (* 韵律对应 *)
  let get_last_char s =
    if String.length s > 0 then String.get s (String.length s - 1) else '?'
  in
  let left_rhyme_group = detect_rhyme_group (get_last_char left_verse) in
  let right_rhyme_group = detect_rhyme_group (get_last_char right_verse) in
  let rhyme_correspondence = if left_rhyme_group <> right_rhyme_group then 0.2 else 0.0 in
  
  char_balance +. tone_correspondence +. rhyme_correspondence

(* 评价意象深度：通过关键词分析评价意象的深度 *)
let evaluate_imagery verse =
  (* 简化的意象评价：基于诗句长度和复杂度 *)
  let char_count = count_chinese_chars verse in
  let complexity_score = min (float_of_int char_count) 10.0 /. 10.0 in
  
  (* 检查是否包含常见诗词意象 *)
  let common_imagery = [
    "山"; "水"; "月"; "风"; "花"; "鸟"; "云"; "雨"; "雪"; "霜";
    "春"; "夏"; "秋"; "冬"; "朝"; "暮"; "日"; "星"; "天"; "地";
    "江"; "河"; "湖"; "海"; "松"; "竹"; "梅"; "兰"; "菊"; "莲"
  ] in
  
  let imagery_count = List.fold_left (fun acc imagery ->
    if String.contains verse (String.get imagery 0) then acc + 1 else acc
  ) 0 common_imagery in
  
  let imagery_score = min (float_of_int imagery_count) 3.0 /. 3.0 *. 0.5 in
  
  complexity_score *. 0.5 +. imagery_score

(* 评价节奏感：基于字数和声调变化评价节奏 *)
let evaluate_rhythm verse =
  let tone_sequence = analyze_tone_sequence verse in
  let char_count = List.length tone_sequence in
  
  (* 基础节奏得分 *)
  let base_rhythm = match char_count with
    | 4 -> 0.8  (* 四言节奏明快 *)
    | 5 -> 0.9  (* 五言节奏优美 *)
    | 7 -> 0.7  (* 七言节奏稍缓 *)
    | _ -> 0.5  (* 其他长度 *)
  in
  
  (* 声调变化评价 *)
  let tone_changes = ref 0 in
  let rec count_changes = function
    | [] | [_] -> ()
    | a :: (b :: _ as rest) ->
        if a <> b then incr tone_changes;
        count_changes rest
  in
  count_changes tone_sequence;
  
  let change_score = min (float_of_int !tone_changes) 3.0 /. 3.0 *. 0.2 in
  
  base_rhythm +. change_score

(* 评价雅致程度：基于用词和意境的雅致程度 *)
let evaluate_elegance verse =
  (* 简化的雅致度评价 *)
  let _char_count = count_chinese_chars verse in
  
  (* 检查是否包含雅致用词 *)
  let elegant_words = [
    "之"; "者"; "也"; "矣"; "乎"; "哉"; "焉"; "夫"; "盖"; "是";
    "以"; "而"; "与"; "于"; "其"; "为"; "若"; "如"; "或"; "且"
  ] in
  
  let elegant_count = List.fold_left (fun acc word ->
    if String.contains verse (String.get word 0) then acc + 1 else acc
  ) 0 elegant_words in
  
  let elegance_ratio = min (float_of_int elegant_count) 2.0 /. 2.0 in
  
  (* 基础雅致得分 *)
  let base_elegance = 0.6 in
  
  base_elegance +. elegance_ratio *. 0.4

(* 综合评价等级：根据各项得分确定总体评价等级 *)
let determine_overall_grade scores =
  let total_score = scores.rhyme_score +. scores.tone_score +. 
                   scores.parallelism_score +. scores.imagery_score +. 
                   scores.rhythm_score +. scores.elegance_score in
  let average_score = total_score /. 6.0 in
  
  if average_score >= 0.8 then Excellent
  else if average_score >= 0.6 then Good
  else if average_score >= 0.4 then Fair
  else Poor

(* 生成改进建议：根据评价结果提供具体的改进建议 *)
let generate_improvement_suggestions report =
  let suggestions = ref [] in
  
  if report.rhyme_score < 0.6 then
    suggestions := "建议调整韵脚，使音韵更加和谐" :: !suggestions;
  
  if report.tone_score < 0.6 then
    suggestions := "建议调整平仄搭配，使声调更加平衡" :: !suggestions;
  
  if report.parallelism_score < 0.6 then
    suggestions := "建议加强对仗工整度，使结构更加对称" :: !suggestions;
  
  if report.imagery_score < 0.6 then
    suggestions := "建议丰富意象表达，使诗句更有深度" :: !suggestions;
  
  if report.rhythm_score < 0.6 then
    suggestions := "建议调整节奏感，使诗句更有韵律美" :: !suggestions;
  
  if report.elegance_score < 0.6 then
    suggestions := "建议使用更雅致的词汇，提升诗句品味" :: !suggestions;
  
  if !suggestions = [] then
    ["诗句已达较高水准，可在细节上继续打磨"]
  else
    List.rev !suggestions

(* 全面艺术性评价：为诗句提供全面的艺术性分析 *)
let comprehensive_artistic_evaluation verse expected_pattern =
  let rhyme_score = evaluate_rhyme_harmony verse in
  let tone_score = evaluate_tonal_balance verse expected_pattern in
  let parallelism_score = 0.7 in  (* 单句评价，暂设默认值 *)
  let imagery_score = evaluate_imagery verse in
  let rhythm_score = evaluate_rhythm verse in
  let elegance_score = evaluate_elegance verse in
  
  let initial_report = {
    verse;
    rhyme_score;
    tone_score;
    parallelism_score;
    imagery_score;
    rhythm_score;
    elegance_score;
    overall_grade = Good;  (* 临时值，后续更新 *)
    suggestions = [];
  } in
  
  let overall_grade = determine_overall_grade initial_report in
  let suggestions = generate_improvement_suggestions initial_report in
  
  { initial_report with overall_grade; suggestions }

(* 四言骈体专项评价：专门针对四言骈体的艺术性评价 *)
let evaluate_siyan_parallel_prose verses =
  let evaluations = List.map (fun verse ->
    comprehensive_artistic_evaluation verse siyan_standards.tone_pattern
  ) verses in
  
  (* 计算整体得分 *)
  let total_scores = List.fold_left (fun acc eval ->
    {
      verse = acc.verse ^ "\n" ^ eval.verse;
      rhyme_score = acc.rhyme_score +. eval.rhyme_score;
      tone_score = acc.tone_score +. eval.tone_score;
      parallelism_score = acc.parallelism_score +. eval.parallelism_score;
      imagery_score = acc.imagery_score +. eval.imagery_score;
      rhythm_score = acc.rhythm_score +. eval.rhythm_score;
      elegance_score = acc.elegance_score +. eval.elegance_score;
      overall_grade = acc.overall_grade;
      suggestions = acc.suggestions @ eval.suggestions;
    }
  ) {
    verse = "";
    rhyme_score = 0.0;
    tone_score = 0.0;
    parallelism_score = 0.0;
    imagery_score = 0.0;
    rhythm_score = 0.0;
    elegance_score = 0.0;
    overall_grade = Poor;
    suggestions = [];
  } evaluations in
  
  let verse_count = float_of_int (List.length verses) in
  let average_report = {
    verse = String.trim total_scores.verse;
    rhyme_score = total_scores.rhyme_score /. verse_count;
    tone_score = total_scores.tone_score /. verse_count;
    parallelism_score = total_scores.parallelism_score /. verse_count;
    imagery_score = total_scores.imagery_score /. verse_count;
    rhythm_score = total_scores.rhythm_score /. verse_count;
    elegance_score = total_scores.elegance_score /. verse_count;
    overall_grade = Good;
    suggestions = [];
  } in
  
  let overall_grade = determine_overall_grade average_report in
  let suggestions = generate_improvement_suggestions average_report in
  
  { average_report with overall_grade; suggestions }

(* 诗词品评：传统诗词品评方式的现代实现 *)
let poetic_critique verse poetry_type =
  let critique_intro = match poetry_type with
    | "四言骈体" -> "观此四言骈体，句式简练，"
    | "五言律诗" -> "品此五言律诗，格律工整，"
    | "七言绝句" -> "赏此七言绝句，起承转合，"
    | _ -> "评此诗句，"
  in
  
  let evaluation = comprehensive_artistic_evaluation verse [true; true; false; false] in
  
  let grade_comment = match evaluation.overall_grade with
    | Excellent -> "意境深远，音韵和谐，可称佳作也。"
    | Good -> "颇具功力，音律协调，尚属佳品。"
    | Fair -> "基本合格，略有瑕疵，尚可雕琢。"
    | Poor -> "格律未谐，音韵失调，需重修改。"
  in
  
  critique_intro ^ grade_comment

(* 导出函数：模块接口导出 *)
let () = ()