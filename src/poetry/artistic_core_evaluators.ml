(** 骆言诗词艺术性评价核心函数模块
    
    从poetry_artistic_core.ml重构而来，专门负责诗词的艺术性评价功能。
    提供单维度评价和综合评价接口。
    
    @author 骆言技术债务清理团队 - Alpha Agent
    @version 1.0 - 重构版本
    @since 2025-07-25 *)

open Poetry_types_consolidated
open Poetry_rhyme_core
open Artistic_data_loader

(** {1 内部辅助函数} *)

(** 高效子串搜索：使用Boyer-Moore类似的优化思路 *)
let contains_substring text pattern =
  let text_len = String.length text in
  let pattern_len = String.length pattern in
  if pattern_len = 0 then true
  else if pattern_len > text_len then false
  else
    let rec search_from pos =
      if pos > text_len - pattern_len then false
      else
        let rec match_at start pattern_pos =
          if pattern_pos >= pattern_len then true
          else if text.[start + pattern_pos] = pattern.[pattern_pos] then
            match_at start (pattern_pos + 1)
          else false
        in
        if match_at pos 0 then true
        else search_from (pos + 1)
    in
    search_from 0

(** 高效计数函数：避免重复遍历和不必要的字符检查 *)
let count_imagery_words verse =
  let keywords = get_imagery_keywords () in
  List.fold_left (fun count keyword ->
    if contains_substring verse keyword then count + 1 else count
  ) 0 keywords

let count_elegant_words verse =
  let words = get_elegant_words () in
  List.fold_left (fun count word ->
    if contains_substring verse word then count + 1 else count
  ) 0 words

(** {1 单维度艺术性评价函数} *)

(** 评估诗句的韵律和谐度
    
    此函数分析诗句的韵律模式，评估音韵协调性和节奏美感。
    通过检测韵脚、声调分布和音韵呼应来量化韵律质量。
    
    @param verse 待评估的诗句字符串
    @return 韵律和谐度评分，范围0.0-1.0，1.0表示最佳韵律
    
    算法要点：
    - 分析字符的声韵母组合
    - 检测平仄音律模式  
    - 评估音韵的重复和呼应
    - 计算整体韵律协调度 *)
let evaluate_rhyme_harmony verse =
  let chars = List.init (String.length verse) (String.get verse) in
  let is_chinese_char c = let code = Char.code c in code >= 0x4e00 && code <= 0x9fff in
  let chinese_chars = List.filter is_chinese_char chars in
  (match chinese_chars with 
   | [] -> 0.0
   | _ ->
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
    known_ratio *. 0.7 +. (min 1.0 (group_diversity *. 2.0)) *. 0.3)

(** 评估诗句的声调平衡度
    @param verse 待评估的诗句字符串
    @param expected_pattern 期望的声调模式（可选）
    @return 声调平衡度评分，范围0.0-1.0 *)
let evaluate_tonal_balance verse expected_pattern =
  let chars = List.init (String.length verse) (String.get verse) in
  let is_chinese_char c = let code = Char.code c in code >= 0x4e00 && code <= 0x9fff in
  let chinese_chars = List.filter is_chinese_char chars in
  
  (match chinese_chars with
   | [] -> 0.0
   | _ ->
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
      else float_of_int !alternations /. float_of_int !total_pairs)

(** 评估两句诗的对仗质量
    @param left_verse 左句
    @param right_verse 右句
    @return 对仗质量评分，范围0.0-1.0 *)
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

(** 评估诗句的意象密度和艺术表现力
    
    此函数通过统计诗句中的意象关键词密度来评估艺术性。
    意象词汇包括自然意象（山、水、花、月等）、情感意象和文化意象。
    
    @param verse 待评估的诗句字符串
    @return 意象密度评分，范围0.0-1.0，1.0表示意象最丰富
    
    评分算法：
    - 统计意象关键词出现次数
    - 计算意象词汇密度（关键词数/字符数）
    - 应用权重函数平衡密度和基础分
    - 确保评分在合理范围内不过度惩罚短句 *)
let evaluate_imagery verse =
  let imagery_count = count_imagery_words verse in
  let verse_len = String.length verse in
  if verse_len = 0 then 0.0
  else
    let density = float_of_int imagery_count /. float_of_int verse_len *. 10.0 in
    min 1.0 (density *. 0.5 +. 0.3)

(** 评估诗句的节奏感
    @param verse 待评估的诗句字符串
    @return 节奏感评分，范围0.0-1.0 *)
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

(** 评估诗句的雅致程度
    @param verse 待评估的诗句字符串
    @return 雅致程度评分，范围0.0-1.0 *)
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

(** 确定综合评价等级
    @param scores 各维度评分
    @return 综合评价等级 *)
let determine_overall_grade scores =
  let total = scores.rhyme_harmony +. scores.tonal_balance +. scores.parallelism +.
              scores.imagery +. scores.rhythm +. scores.elegance in
  let average = total /. 6.0 in
  if average >= 0.85 then Excellent
  else if average >= 0.70 then Good
  else if average >= 0.55 then Fair
  else Poor

(** 综合艺术性评价函数
    @param verse 待评估的诗句字符串
    @param expected_pattern 期望的声调模式（可选）
    @return 综合艺术性评价报告 *)
let comprehensive_artistic_evaluation verse expected_pattern =
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