(* 诗词艺术性评价器模块 - 核心评价算法
   包含各种诗词艺术性评价的核心算法实现
   从artistic_evaluation.ml中提取的评价器函数
*)

open Yyocamlc_lib
open Rhyme_analysis
open Tone_pattern
open Artistic_evaluator
open Artistic_types
open Poetry_standards

(** 评价韵律和谐度：检查诗句的音韵是否和谐
    
    @param verse 待评价的诗句
    @return 韵律和谐度分数 (0.0-1.0)
    
    通过分析诗句的韵母组合和音韵搭配，评价整体韵律的和谐程度。
    考虑韵母的协调性、音调的起伏以及整体的音韵美感。
*)
let evaluate_rhyme_harmony verse =
  let rhyme_report = generate_rhyme_report verse in
  let rhyme_group = rhyme_report.rhyme_group in

  (* 基础韵律得分 *)
  let base_score =
    match rhyme_group with UnknownRhyme -> 0.4 (* 未知韵组，得分较低 *) | _ -> 0.8 (* 已知韵组，基础得分 *)
  in

  (* 韵脚质量评价 *)
  let rhyme_quality = match rhyme_report.rhyme_ending with None -> 0.0 | Some _ -> 0.2 in

  base_score +. rhyme_quality

(** 评价声调平衡度：检查平仄搭配是否合理
    
    @param verse 待评价的诗句
    @param expected_pattern 期望的平仄模式
    @return 声调平衡度分数 (0.0-1.0)
    
    根据古典诗词平仄格律要求，评价诗句声调搭配的合理性。
    平仄相间，错落有致，方为上乘。
*)
let evaluate_tonal_balance verse expected_pattern =
  let pattern = match expected_pattern with Some p -> p | None -> [] in
  let tone_report = generate_tone_report verse pattern in
  let pattern_match = tone_report.pattern_match in

  (* 基础声调得分 *)
  let base_score = if pattern_match then 0.8 else 0.4 in

  (* 声调多样性评价 *)
  let tone_diversity =
    let level_count = List.length (List.filter (fun x -> x) tone_report.simple_pattern) in
    let total_count = List.length tone_report.simple_pattern in
    let oblique_count = total_count - level_count in
    let diversity = min level_count oblique_count in
    float_of_int diversity /. float_of_int total_count *. 0.2
  in

  base_score +. tone_diversity

(** 评价对仗工整度：检查对仗的工整程度 *)
let evaluate_parallelism left_verse right_verse =
  let left_chars = Parser_poetry.count_chinese_chars left_verse in
  let right_chars = Parser_poetry.count_chinese_chars right_verse in

  (* 字数对应 *)
  let char_balance = if left_chars = right_chars then 0.4 else 0.0 in

  (* 声调对应 *)
  let left_pattern = analyze_simple_tone_pattern left_verse in
  let right_pattern = analyze_simple_tone_pattern right_verse in

  let tone_correspondence =
    if List.length left_pattern = List.length right_pattern then
      let pairs = List.combine left_pattern right_pattern in
      let opposite_pairs = List.filter (fun (l, r) -> l <> r) pairs in
      let correspondence_ratio =
        float_of_int (List.length opposite_pairs) /. float_of_int (List.length pairs)
      in
      correspondence_ratio *. 0.4
    else 0.0
  in

  (* 韵律对应 *)
  let get_last_char s = if String.length s > 0 then String.get s (String.length s - 1) else '?' in
  let left_rhyme_group = detect_rhyme_group (get_last_char left_verse) in
  let right_rhyme_group = detect_rhyme_group (get_last_char right_verse) in
  let rhyme_correspondence = if left_rhyme_group <> right_rhyme_group then 0.2 else 0.0 in

  char_balance +. tone_correspondence +. rhyme_correspondence

(** 评价意象深度：通过关键词分析评价意象的深度 *)
let evaluate_imagery verse =
  (* 简化的意象评价：基于诗句长度和复杂度 *)
  let char_count = Parser_poetry.count_chinese_chars verse in
  let complexity_score = min (float_of_int char_count) 10.0 /. 10.0 in

  (* 检查是否包含常见诗词意象 *)
  let common_imagery =
    [
      "山";
      "水";
      "月";
      "风";
      "花";
      "鸟";
      "云";
      "雨";
      "雪";
      "霜";
      "春";
      "夏";
      "秋";
      "冬";
      "朝";
      "暮";
      "日";
      "星";
      "天";
      "地";
      "江";
      "河";
      "湖";
      "海";
      "松";
      "竹";
      "梅";
      "兰";
      "菊";
      "莲";
    ]
  in

  let imagery_count =
    List.fold_left
      (fun acc imagery -> if String.contains verse (String.get imagery 0) then acc + 1 else acc)
      0 common_imagery
  in

  let imagery_score = min (float_of_int imagery_count) 3.0 /. 3.0 *. 0.5 in

  (complexity_score *. 0.5) +. imagery_score

(** 评价节奏感：基于字数和声调变化评价节奏 *)
let evaluate_rhythm verse =
  let tone_sequence = analyze_tone_sequence verse in
  let char_count = List.length tone_sequence in

  (* 基础节奏得分 *)
  let base_rhythm =
    match char_count with
    | 4 -> 0.8 (* 四言节奏明快 *)
    | 5 -> 0.9 (* 五言节奏优美 *)
    | 7 -> 0.7 (* 七言节奏稍缓 *)
    | _ -> 0.5 (* 其他长度 *)
  in

  (* 声调变化评价 *)
  let tone_changes = ref 0 in
  let rec count_changes = function
    | [] | [ _ ] -> ()
    | a :: (b :: _ as rest) ->
        if a <> b then incr tone_changes;
        count_changes rest
  in
  count_changes tone_sequence;

  let change_score = min (float_of_int !tone_changes) 3.0 /. 3.0 *. 0.2 in

  base_rhythm +. change_score

(** 评价雅致程度：基于用词和意境的雅致程度 *)
let evaluate_elegance verse =
  (* 简化的雅致度评价 *)
  let _char_count = Parser_poetry.count_chinese_chars verse in

  (* 检查是否包含雅致用词 *)
  let elegant_words =
    [
      "之";
      "者";
      "也";
      "矣";
      "乎";
      "哉";
      "焉";
      "夫";
      "其";
      "若";
      "兮";
      "惟";
      "唯";
      "斯";
      "是";
      "谓";
      "盖";
      "且";
      "犹";
      "尚";
      "方";
      "将";
      "能";
      "可";
      "足";
      "得";
      "所";
      "于";
      "以";
      "为";
      "而";
      "与";
      "从";
      "自";
      "由";
    ]
  in

  let elegance_count =
    List.fold_left
      (fun acc word -> if String.contains verse (String.get word 0) then acc + 1 else acc)
      0 elegant_words
  in

  let elegance_score = min (float_of_int elegance_count) 3.0 /. 3.0 in

  elegance_score

(** 确定整体评级：根据各项得分确定整体等级 *)
let determine_overall_grade scores =
  let total_score =
    scores.rhyme_harmony +. scores.tonal_balance +. scores.parallelism +. scores.imagery +. scores.rhythm
    +. scores.elegance
  in
  let average_score = total_score /. 6.0 in

  if average_score >= 0.8 then Excellent
  else if average_score >= 0.7 then Good
  else if average_score >= 0.6 then Fair
  else Poor