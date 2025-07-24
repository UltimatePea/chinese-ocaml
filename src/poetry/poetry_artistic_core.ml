(** 骆言诗词艺术性评价核心模块 - 整合版本
    
    此模块整合了原有15+个艺术性评价模块的功能，
    提供统一的诗词艺术性分析、评价、指导接口。
    
    @author 骆言诗词编程团队
    @version 2.0 - 整合版本
    @since 2025-07-24 *)

open Poetry_types_consolidated
open Poetry_rhyme_core

(** {1 内部辅助函数} *)

(** 意象关键词库 - 简化版本 *)
let imagery_keywords = [
  (* 自然意象 *)
  "山"; "水"; "花"; "月"; "风"; "雪"; "云"; "雨"; "春"; "秋";
  "江"; "河"; "湖"; "海"; "天"; "地"; "星"; "日"; "夜"; "晨";
  
  (* 情感意象 *)
  "情"; "爱"; "思"; "梦"; "愁"; "喜"; "悲"; "怒"; "忧"; "乐";
  "离"; "别"; "归"; "来"; "去"; "望"; "盼"; "念"; "想"; "忆";
  
  (* 文化意象 *)
  "诗"; "书"; "画"; "琴"; "棋"; "茶"; "酒"; "香"; "禅"; "道";
  "古"; "今"; "昔"; "时"; "年"; "岁"; "世"; "代"; "朝"; "暮";
]

(** 雅致词汇库 *)
let elegant_words = [
  "雅"; "致"; "清"; "幽"; "静"; "淡"; "素"; "朴"; "简"; "净";
  "美"; "秀"; "丽"; "妙"; "绝"; "奇"; "神"; "仙"; "灵"; "韵";
  "高"; "深"; "远"; "广"; "博"; "厚"; "重"; "轻"; "柔"; "刚";
]

let count_imagery_words verse =
  let count = ref 0 in
  List.iter (fun keyword ->
    if String.contains verse (String.get keyword 0) then
      incr count
  ) imagery_keywords;
  !count

let count_elegant_words verse =
  let count = ref 0 in
  List.iter (fun word ->
    if String.contains verse (String.get word 0) then
      incr count
  ) elegant_words;
  !count

(** {1 单维度艺术性评价函数} *)

let evaluate_rhyme_harmony verse =
  let chars = List.init (String.length verse) (String.get verse) in
  let is_chinese_char c = let code = Char.code c in code >= 0x4e00 && code <= 0x9fff in
  let chinese_chars = List.filter is_chinese_char chars in
  if List.length chinese_chars = 0 then 0.0
  else
    let rhyme_chars = List.filter (fun c -> is_known_rhyme_char c) chinese_chars in
    let known_ratio = float_of_int (List.length rhyme_chars) /. 
                      float_of_int (List.length chinese_chars) in
    
    (* 检查内部韵律和谐度 *)
    let groups = List.map detect_rhyme_group rhyme_chars in
    let unique_groups = List.fold_left (fun acc group ->
      if List.mem group acc then acc else group :: acc
    ) [] groups in
    let group_diversity = float_of_int (List.length unique_groups) /. 
                         max 1.0 (float_of_int (List.length groups)) in
    
    (* 综合评分：已知字符比例 * 0.7 + 适度多样性 * 0.3 *)
    known_ratio *. 0.7 +. (min 1.0 (group_diversity *. 2.0)) *. 0.3

let evaluate_tonal_balance verse expected_pattern =
  let chars = List.init (String.length verse) (String.get verse) in
  let is_chinese_char c = let code = Char.code c in code >= 0x4e00 && code <= 0x9fff in
  let chinese_chars = List.filter is_chinese_char chars in
  
  if List.length chinese_chars = 0 then 0.0
  else
    let tone_pattern = List.map (fun c ->
      is_ping_sheng (detect_rhyme_category c)
    ) chinese_chars in
    
    match expected_pattern with
    | Some expected ->
      let min_len = min (List.length tone_pattern) (List.length expected) in
      let matches = ref 0 in
      for i = 0 to min_len - 1 do
        if List.nth tone_pattern i = List.nth expected i then
          incr matches
      done;
      float_of_int !matches /. float_of_int min_len
    | None ->
      (* 评价平仄交替的自然度 *)
      let alternations = ref 0 in
      let total_pairs = ref 0 in
      for i = 0 to List.length tone_pattern - 2 do
        incr total_pairs;
        if List.nth tone_pattern i <> List.nth tone_pattern (i + 1) then
          incr alternations
      done;
      if !total_pairs = 0 then 0.5
      else float_of_int !alternations /. float_of_int !total_pairs

let evaluate_parallelism left_verse right_verse =
  let left_len = String.length left_verse in
  let right_len = String.length right_verse in
  
  (* 字数对应度 *)
  let length_score = 
    if left_len = right_len then 1.0
    else 1.0 -. abs_float (float_of_int (left_len - right_len)) /. 
                 max (float_of_int left_len) (float_of_int right_len)
  in
  
  (* 声调对应度 - 简化版本 *)
  let left_chars = List.init left_len (String.get left_verse) in
  let right_chars = List.init right_len (String.get right_verse) in
  let min_len = min left_len right_len in
  
  let tone_matches = ref 0 in
  for i = 0 to min_len - 1 do
    let left_tone = detect_rhyme_category (List.nth left_chars i) in
    let right_tone = detect_rhyme_category (List.nth right_chars i) in
    (* 对仗要求平仄相对（相反） *)
    if (is_ping_sheng left_tone && is_ze_sheng right_tone) ||
       (is_ze_sheng left_tone && is_ping_sheng right_tone) then
      incr tone_matches
  done;
  
  let tone_score = if min_len = 0 then 0.0 
                   else float_of_int !tone_matches /. float_of_int min_len in
  
  (* 综合评分 *)
  length_score *. 0.4 +. tone_score *. 0.6

let evaluate_imagery verse =
  let imagery_count = count_imagery_words verse in
  let verse_len = String.length verse in
  if verse_len = 0 then 0.0
  else
    let density = float_of_int imagery_count /. float_of_int verse_len *. 10.0 in
    min 1.0 (density *. 0.5 +. 0.3)

let evaluate_rhythm verse =
  let chars = List.init (String.length verse) (String.get verse) in
  let is_chinese_char c = let code = Char.code c in code >= 0x4e00 && code <= 0x9fff in
  let chinese_chars = List.filter is_chinese_char chars in
  
  if List.length chinese_chars < 2 then 0.5
  else
    let tone_changes = ref 0 in
    let total_pairs = List.length chinese_chars - 1 in
    
    for i = 0 to total_pairs - 1 do
      let curr_tone = detect_rhyme_category (List.nth chinese_chars i) in
      let next_tone = detect_rhyme_category (List.nth chinese_chars (i + 1)) in
      if not (rhyme_category_equal curr_tone next_tone) then
        incr tone_changes
    done;
    
    (* 节奏感来自适度的声调变化 *)
    let change_ratio = float_of_int !tone_changes /. float_of_int total_pairs in
    (* 最佳变化率在0.4-0.6之间 *)
    if change_ratio >= 0.4 && change_ratio <= 0.6 then 1.0
    else 1.0 -. abs_float (change_ratio -. 0.5) *. 2.0

let evaluate_elegance verse =
  let elegant_count = count_elegant_words verse in
  let verse_len = String.length verse in
  if verse_len = 0 then 0.0
  else
    let base_score = min 1.0 (float_of_int elegant_count /. float_of_int verse_len *. 8.0) in
    (* 加上长度适中的奖励 *)
    let length_bonus = 
      if verse_len >= 4 && verse_len <= 14 then 0.1 else 0.0 in
    min 1.0 (base_score +. length_bonus)

(** {1 综合艺术性评价函数} *)

let rec comprehensive_artistic_evaluation verse expected_pattern =
  let rhyme_score = evaluate_rhyme_harmony verse in
  let tone_score = evaluate_tonal_balance verse expected_pattern in
  let parallelism_score = 0.7 in  (* 单句无法评价对仗，给默认分 *)
  let imagery_score = evaluate_imagery verse in
  let rhythm_score = evaluate_rhythm verse in
  let elegance_score = evaluate_elegance verse in
  
  let scores = {
    rhyme_harmony = rhyme_score;
    tonal_balance = tone_score;
    parallelism = parallelism_score;
    imagery = imagery_score;
    rhythm = rhythm_score;
    elegance = elegance_score;
  } in
  
  let overall_grade = determine_overall_grade scores in
  let suggestions = [] in  (* 简化版本暂不实现详细建议 *)
  
  {
    verse;
    rhyme_score;
    tone_score;
    parallelism_score;
    imagery_score;
    rhythm_score;
    elegance_score;
    overall_grade;
    suggestions;
  }

and determine_overall_grade scores =
  let total = scores.rhyme_harmony +. scores.tonal_balance +. scores.parallelism +.
              scores.imagery +. scores.rhythm +. scores.elegance in
  let average = total /. 6.0 in
  if average >= 0.85 then Excellent
  else if average >= 0.70 then Good
  else if average >= 0.55 then Fair
  else Poor

let generate_improvement_suggestions report =
  let suggestions = ref [] in
  
  if report.rhyme_score < 0.6 then
    suggestions := "建议注意韵律和谐度，选择押韵字符" :: !suggestions;
  
  if report.tone_score < 0.6 then
    suggestions := "建议调整平仄搭配，增强声调平衡" :: !suggestions;
    
  if report.parallelism_score < 0.6 then
    suggestions := "建议工整对仗，注意字数和声调对应" :: !suggestions;
    
  if report.imagery_score < 0.6 then
    suggestions := "建议丰富意象，增加自然和情感元素" :: !suggestions;
    
  if report.rhythm_score < 0.6 then
    suggestions := "建议调整节奏感，适度变化声调" :: !suggestions;
    
  if report.elegance_score < 0.6 then
    suggestions := "建议提高雅致程度，使用更文雅的词汇" :: !suggestions;
  
  List.rev !suggestions

(** {1 诗词形式专项评价函数} *)

let evaluate_siyan_parallel_prose verses =
  let verse_count = Array.length verses in
  if verse_count < 2 then
    comprehensive_artistic_evaluation (if verse_count > 0 then verses.(0) else "") None
  else
    (* 四言骈体要求两两对仗 *)
    let total_score = ref 0.0 in
    let pair_count = verse_count / 2 in
    
    for i = 0 to pair_count - 1 do
      let left = verses.(i * 2) in
      let right = if i * 2 + 1 < verse_count then verses.(i * 2 + 1) else "" in
      let parallelism_score = evaluate_parallelism left right in
      total_score := !total_score +. parallelism_score
    done;
    
    let avg_parallelism = !total_score /. float_of_int pair_count in
    let first_verse = verses.(0) in
    let base_report = comprehensive_artistic_evaluation first_verse None in
    
    { base_report with 
      parallelism_score = avg_parallelism;
      overall_grade = determine_overall_grade {
        rhyme_harmony = base_report.rhyme_score;
        tonal_balance = base_report.tone_score;
        parallelism = avg_parallelism;
        imagery = base_report.imagery_score;
        rhythm = base_report.rhythm_score;
        elegance = base_report.elegance_score;
      }
    }

let evaluate_wuyan_lushi verses =
  let verse_count = Array.length verses in
  if verse_count <> 8 then
    comprehensive_artistic_evaluation (if verse_count > 0 then verses.(0) else "") None
  else
    (* 五言律诗：颔联(2,3)和颈联(4,5)必须对仗 *)
    let parallelism_score = 
      let score1 = evaluate_parallelism verses.(2) verses.(3) in
      let score2 = evaluate_parallelism verses.(4) verses.(5) in
      (score1 +. score2) /. 2.0
    in
    
    (* 评价整体韵律 - 取首句为代表 *)
    let base_report = comprehensive_artistic_evaluation verses.(0) None in
    
    { base_report with 
      parallelism_score;
      overall_grade = determine_overall_grade {
        rhyme_harmony = base_report.rhyme_score;
        tonal_balance = base_report.tone_score;
        parallelism = parallelism_score;
        imagery = base_report.imagery_score;
        rhythm = base_report.rhythm_score;
        elegance = base_report.elegance_score;
      }
    }

let evaluate_qiyan_jueju verses =
  let verse_count = Array.length verses in
  if verse_count <> 4 then
    comprehensive_artistic_evaluation (if verse_count > 0 then verses.(0) else "") None
  else
    (* 七言绝句主要评价韵律和意境 *)
    let combined_verse = String.concat "" (Array.to_list verses) in
    comprehensive_artistic_evaluation combined_verse None

let evaluate_poetry_by_form form verses =
  match form with
  | SiYanPianTi | SiYanParallelProse -> evaluate_siyan_parallel_prose verses
  | WuYanLuShi -> evaluate_wuyan_lushi verses
  | QiYanJueJu -> evaluate_qiyan_jueju verses
  | CiPai _ | ModernPoetry -> 
    let combined = String.concat "" (Array.to_list verses) in
    comprehensive_artistic_evaluation combined None

(** {1 传统诗词品评函数} *)

let poetic_critique verse form =
  let base_report = comprehensive_artistic_evaluation verse None in
  let critique_suggestions = match form with
    | SiYanPianTi | SiYanParallelProse ->
      ["骈体之美在于对仗工整，声韵和谐"]
    | WuYanLuShi ->
      ["律诗之妙在于格律严谨，意境深远"]  
    | QiYanJueJu ->
      ["绝句之巧在于起承转合，言简意赅"]
    | _ ->
      ["诗词之道，在于意境与声韵并重"]
  in
  { base_report with suggestions = critique_suggestions }

let poetic_aesthetics_guidance verse form =
  let base_report = comprehensive_artistic_evaluation verse None in
  let guidance = match form with
    | SiYanPianTi | SiYanParallelProse ->
      ["注重对偶工整"; "追求声律和谐"; "用词典雅得体"]
    | WuYanLuShi ->
      ["遵循格律规范"; "中间两联对仗"; "首尾呼应"]
    | QiYanJueJu ->
      ["起句立意"; "承句发展"; "转句生变"; "合句收束"]
    | _ ->
      ["意境为先"; "声韵和谐"; "用词精练"]
  in
  { base_report with suggestions = guidance }

(** {1 高阶艺术性分析函数} *)

let analyze_artistic_progression verses =
  Array.map (fun verse ->
    let report = comprehensive_artistic_evaluation verse None in
    calculate_overall_score report
  ) verses |> Array.to_list

let compare_artistic_quality verse1 verse2 =
  let score1 = let r = comprehensive_artistic_evaluation verse1 None in calculate_overall_score r in
  let score2 = let r = comprehensive_artistic_evaluation verse2 None in calculate_overall_score r in
  if score1 > score2 then 1
  else if score1 < score2 then -1
  else 0

let detect_artistic_flaws verse =
  let report = comprehensive_artistic_evaluation verse None in
  let flaws = ref [] in
  
  if report.rhyme_score < 0.5 then
    flaws := "韵律和谐度不足" :: !flaws;
  if report.tone_score < 0.5 then
    flaws := "平仄搭配不当" :: !flaws;
  if report.imagery_score < 0.5 then
    flaws := "意象贫乏" :: !flaws;
  if report.rhythm_score < 0.5 then
    flaws := "节奏感不强" :: !flaws;
  if report.elegance_score < 0.5 then
    flaws := "用词不够雅致" :: !flaws;
    
  List.rev !flaws

(** {1 评价标准配置} *)

module ArtisticStandards = struct
  let siyan_standards = {
    char_count = 4;
    tone_pattern = [true; false; true; false];  (* 简化的平仄模式 *)
    parallelism_required = true;
    rhythm_weight = 0.3;
  }

  let wuyan_lushi_standards = {
    line_count = 8;
    char_per_line = 5;
    rhyme_scheme = [|false; true; false; true; false; true; false; true|];
    parallelism_required = [|false; false; true; true; true; true; false; false|];
    tone_pattern = [];  (* 简化版本暂不实现详细平仄模式 *)
    rhythm_weight = 0.25;
  }

  let qiyan_jueju_standards = {
    line_count = 4;
    char_per_line = 7;
    rhyme_scheme = [|false; true; false; true|];
    parallelism_required = [|false; false; false; false|];
    tone_pattern = [];
    rhythm_weight = 0.2;
  }

  let get_standards_for_form = function
    | SiYanPianTi | SiYanParallelProse -> [0.2; 0.25; 0.3; 0.1; 0.1; 0.05]
    | WuYanLuShi -> [0.25; 0.25; 0.25; 0.1; 0.1; 0.05]
    | QiYanJueJu -> [0.3; 0.2; 0.1; 0.2; 0.15; 0.05]
    | _ -> [0.2; 0.2; 0.2; 0.2; 0.15; 0.05]  (* 默认权重 *)
end

(** {1 智能评价助手} *)

module IntelligentEvaluator = struct
  let auto_detect_form verses =
    let verse_count = Array.length verses in
    if verse_count = 0 then ModernPoetry
    else
      let first_len = String.length verses.(0) in
      match verse_count, first_len with
      | 4, 7 -> QiYanJueJu
      | 8, 5 -> WuYanLuShi
      | _, 4 -> SiYanPianTi
      | _ -> ModernPoetry

  let adaptive_evaluation verses =
    let form = auto_detect_form verses in
    let report = evaluate_poetry_by_form form verses in
    let combined_verse = String.concat "" (Array.to_list verses) in
    {
      poem_text = Array.to_list verses;
      form;
      verse_summaries = [];  (* 简化版本 *)
      overall_rhyme = analyze_poem_rhyme (Array.to_list verses);
      overall_artistic = {
        rhyme_harmony = report.rhyme_score;
        tonal_balance = report.tone_score;
        parallelism = report.parallelism_score;
        imagery = report.imagery_score;
        rhythm = report.rhythm_score;
        elegance = report.elegance_score;
      };
      final_grade = report.overall_grade;
      critique = match report.overall_grade with
        | Excellent -> "艺术性优秀，达到很高水准"
        | Good -> "艺术性良好，有进一步提升空间"
        | Fair -> "艺术性一般，需要多方面改进"
        | Poor -> "艺术性较差，建议重新创作";
    }

  let smart_suggestions verses =
    let analysis = adaptive_evaluation verses in
    let base_suggestions = match analysis.final_grade with
      | Excellent -> ["已达很高水准，可尝试更复杂的形式"]
      | Good -> ["整体不错，可在意象和用词上进一步提升"]
      | Fair -> ["需要加强韵律和平仄的把握"]
      | Poor -> ["建议从基础格律学起，多读经典作品"]
    in
    
    let form_specific = match analysis.form with
      | SiYanPianTi -> ["注重对仗的工整性"]
      | WuYanLuShi -> ["严格遵循律诗格律"]
      | QiYanJueJu -> ["注意起承转合的结构"]
      | _ -> ["发挥自由创作的优势"]
    in
    
    base_suggestions @ form_specific
end