(* 音韵验证模块 - 骆言诗词编程特性
   盖古之诗者，音韵为要。声韵调谐，方称佳构。
   此模块专司音韵验证，检查韵脚一致性，评估韵律质量。
   凡诗词编程，必先验韵律，后成佳作。
*)

open Rhyme_types
open Rhyme_detection
open Rhyme_utils

(* 辅助函数：提取诗句的韵脚和韵组信息 *)
let extract_verse_rhyme_info verses =
  let rhyme_endings = List.filter_map extract_rhyme_ending verses in
  let rhyme_groups = List.map detect_rhyme_group rhyme_endings in
  (rhyme_endings, rhyme_groups)

(* 辅助函数：只提取韵组信息 *)
let extract_verse_rhyme_groups verses =
  let rhyme_endings = List.filter_map extract_rhyme_ending verses in
  List.map detect_rhyme_group rhyme_endings

(* 诗词结构验证结果类型 *)
type poem_structure_result = {
  verse_count : int;
  rhyme_consistency : bool;
  rhyme_quality : float;
  tone_balance : float;
  overall_score : float;
}

(* 检查两个字符是否押韵：判断二字是否可以押韵
   同韵可押，异韵不可。简明判断，助力诗词创作。
*)
let chars_rhyme char1 char2 =
  let group1 = detect_rhyme_group char1 in
  let group2 = detect_rhyme_group char2 in
  rhyme_group_equal group1 group2 && group1 <> UnknownRhyme

(* 检查两个字符串是否押韵 *)
let strings_rhyme str1 str2 =
  let group1 = detect_rhyme_group_by_string str1 in
  let group2 = detect_rhyme_group_by_string str2 in
  rhyme_group_equal group1 group2 && group1 <> UnknownRhyme

(* 验证韵脚一致性：检查多句诗词的韵脚是否和谐
   诗词之美，在于韵律。韵脚一致，方显音律之美。
*)
let validate_rhyme_consistency verses =
  let rhyme_groups = extract_verse_rhyme_groups verses in

  (* 检查是否所有韵脚都属于同一韵组 *)
  match rhyme_groups with
  | [] -> true
  | first_group :: rest ->
      List.for_all (fun group -> rhyme_group_equal group first_group || group = UnknownRhyme) rest

(* 验证韵律方案：依传统诗词格律检验韵律
   古有韵律，今有方案。按图索骥，验证韵律。
*)
let validate_rhyme_scheme verses rhyme_pattern =
  let rhyme_groups = extract_verse_rhyme_groups verses in

  (* 韵律方案检查 - 同字母表示同韵，不同字母表示异韵 *)
  let rec check_pattern groups pattern =
    match (groups, pattern) with
    | [], [] -> true
    | g1 :: gs, p1 :: ps ->
        let same_rhyme =
          List.exists (fun (g2, p2) -> p1 = p2 && rhyme_group_equal g1 g2) (List.combine gs ps)
        in
        if p1 = 'A' then same_rhyme || check_pattern gs ps else check_pattern gs ps
    | _ -> false
  in

  if List.length rhyme_groups = List.length rhyme_pattern then
    check_pattern rhyme_groups rhyme_pattern
  else false

(* 检测押韵质量：评估韵脚的和谐程度
   押韵有工拙之分，此函评估韵脚和谐程度。
*)
let evaluate_rhyme_quality verses =
  let rhyme_endings, rhyme_groups = extract_verse_rhyme_info verses in
  let rhyme_categories = List.map detect_rhyme_category rhyme_endings in

  let unique_groups = unique_list rhyme_groups in
  let unique_categories = unique_list rhyme_categories in

  let group_consistency =
    if List.length unique_groups <= 1 then 1.0
    else if List.length unique_groups = 2 then 0.7
    else 0.4
  in

  let category_consistency =
    if List.length unique_categories <= 1 then 1.0
    else if List.length unique_categories = 2 then 0.8
    else 0.5
  in

  (* 综合评分 *)
  (group_consistency +. category_consistency) /. 2.0

(* 验证平仄格律：检查诗句的平仄是否符合要求 *)
let validate_ping_ze_pattern verse expected_pattern =
  let char_analysis = analyze_verse_chars verse in
  let actual_pattern = List.map (fun (_, category, _) -> is_ping_sheng category) char_analysis in

  if List.length actual_pattern = List.length expected_pattern then
    List.for_all2 (fun actual expected -> actual = expected) actual_pattern expected_pattern
  else false

(* 检查诗句的声调平衡 *)
let check_tone_balance verse =
  let char_analysis = analyze_verse_chars verse in
  let ping_count, ze_count, total_count =
    List.fold_left
      (fun (ping, ze, total) (_, category, _) ->
        let new_ping = if is_ping_sheng category then ping + 1 else ping in
        let new_ze = if is_ze_sheng category then ze + 1 else ze in
        (new_ping, new_ze, total + 1))
      (0, 0, 0) char_analysis
  in

  if total_count = 0 then 0.0
  else
    let ping_ratio = float_of_int ping_count /. float_of_int total_count in
    let ze_ratio = float_of_int ze_count /. float_of_int total_count in
    let balance_score = 1.0 -. abs_float (ping_ratio -. ze_ratio) in
    balance_score

(* 验证诗词整体结构 *)
let validate_poem_structure verses =
  let verse_count = List.length verses in
  let rhyme_consistency = validate_rhyme_consistency verses in
  let avg_quality = evaluate_rhyme_quality verses in
  let tone_balance = List.map check_tone_balance verses in
  let avg_tone_balance =
    if List.length tone_balance = 0 then 0.0
    else List.fold_left ( +. ) 0.0 tone_balance /. float_of_int (List.length tone_balance)
  in

  {
    verse_count;
    rhyme_consistency;
    rhyme_quality = avg_quality;
    tone_balance = avg_tone_balance;
    overall_score = (avg_quality +. avg_tone_balance) /. 2.0;
  }

(* 检查韵律错误 *)
let check_rhyme_errors verses =
  let errors = ref [] in
  let rhyme_endings = List.filter_map extract_rhyme_ending verses in
  let rhyme_groups = List.map detect_rhyme_group rhyme_endings in

  (* 检查韵组不一致 *)
  let unique_groups = unique_list rhyme_groups in
  if List.length unique_groups > 1 then errors := "韵组不一致，存在多个韵组" :: !errors;

  (* 检查未知韵组 *)
  let unknown_count = List.length (List.filter (fun g -> g = UnknownRhyme) rhyme_groups) in
  if unknown_count > 0 then
    errors :=
      Yyocamlc_lib.Unified_formatter.PoetryFormatting.format_rhyme_validation_error unknown_count
        "未知韵组的字符"
      :: !errors;

  (* 检查空韵脚 *)
  let empty_endings = List.length verses - List.length rhyme_endings in
  if empty_endings > 0 then
    errors :=
      Yyocamlc_lib.Unified_formatter.PoetryFormatting.format_rhyme_validation_error empty_endings
        "空韵脚"
      :: !errors;

  List.rev !errors

(* 生成韵律建议 *)
let generate_rhyme_suggestions verses =
  let suggestions = ref [] in
  let rhyme_consistency = validate_rhyme_consistency verses in
  let rhyme_quality = evaluate_rhyme_quality verses in

  if not rhyme_consistency then suggestions := "建议统一韵组，确保所有韵脚属于同一韵组" :: !suggestions;

  if rhyme_quality < 0.7 then suggestions := "建议提高韵律质量，选择声调更一致的字符" :: !suggestions;

  if List.length verses < 2 then suggestions := "建议增加诗句数量，形成完整的韵律结构" :: !suggestions;

  let avg_tone_balance =
    let tone_balances = List.map check_tone_balance verses in
    if List.length tone_balances = 0 then 0.0
    else List.fold_left ( +. ) 0.0 tone_balances /. float_of_int (List.length tone_balances)
  in

  if avg_tone_balance < 0.5 then suggestions := "建议平衡平仄声调，避免过度偏向平声或仄声" :: !suggestions;

  List.rev !suggestions
