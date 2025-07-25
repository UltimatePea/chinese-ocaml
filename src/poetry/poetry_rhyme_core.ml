(** 骆言诗词韵律核心模块 - 整合版本（简化实现）
    
    此模块整合了原有20+个韵律相关模块的核心功能，
    提供统一的韵律检测、分析、验证和评分接口。
    
    @author 骆言诗词编程团队
    @version 2.0 - 整合版本
    @since 2025-07-24 *)

open Poetry_types_consolidated

(** {1 数据访问} *)
(* 使用poetry_rhyme_data模块的统一数据源 *)
open Poetry_rhyme_data

(** {1 核心韵律检测函数} *)

(** 从字符串查找韵律信息 *)
let find_rhyme_info_string str =
  (* 通过poetry_rhyme_data模块查找 *)
  try
    let data_list = get_all_rhyme_data () in
    let result = List.find (fun (char_str, _, _) -> String.equal char_str str) data_list in
    let (_, category, group) = result in
    Some (category, group)
  with Not_found -> None

(** 从字符查找韵律信息 - 需要通过字符串方式查找 *)
let find_rhyme_info char =
  (* 对于单字节字符（ASCII），尝试作为字符串查找 *)
  let char_str = String.make 1 char in
  find_rhyme_info_string char_str

let detect_rhyme_category char =
  match find_rhyme_info char with
  | Some (category, _) -> category
  | None -> PingSheng  (* 默认为平声 *)

let detect_rhyme_group char =
  match find_rhyme_info char with
  | Some (_, group) -> group
  | None -> UnknownRhyme

let chars_rhyme char1 char2 =
  let group1 = detect_rhyme_group char1 in
  let group2 = detect_rhyme_group char2 in
  rhyme_group_equal group1 group2 && group1 <> UnknownRhyme

let strings_rhyme str1 str2 =
  match find_rhyme_info_string str1, find_rhyme_info_string str2 with
  | Some (_, group1), Some (_, group2) -> 
    rhyme_group_equal group1 group2 && group1 <> UnknownRhyme
  | _ -> false

let is_chinese_char c =
  let code = Char.code c in
  code >= 0x4e00 && code <= 0x9fff

let extract_rhyme_ending verse =
  let len = String.length verse in
  if len > 0 then
    let rec find_last_char i =
      if i < 0 then None
      else
        let char = verse.[i] in
        if is_chinese_char char then
          Some char
        else find_last_char (i - 1)
    in
    find_last_char (len - 1)
  else None

let verses_rhyme verse1 verse2 =
  let ending1 = extract_rhyme_ending verse1 in
  let ending2 = extract_rhyme_ending verse2 in
  match ending1, ending2 with
  | Some c1, Some c2 -> chars_rhyme c1 c2
  | _ -> false

(** {1 韵律模式分析函数} *)

let analyze_rhyme_pattern verse =
  let chars = ref [] in
  String.iteri (fun _ char ->
    if is_chinese_char char then
      let category = detect_rhyme_category char in
      let group = detect_rhyme_group char in
      chars := (char, category, group) :: !chars
  ) verse;
  List.rev !chars

let detect_rhyme_pattern verses =
  List.filter_map extract_rhyme_ending verses

(** {1 韵律验证函数} *)

let validate_rhyme_consistency verses =
  let endings = detect_rhyme_pattern verses in
  match endings with
  | [] -> false
  | first :: rest ->
    let first_group = detect_rhyme_group first in
    first_group <> UnknownRhyme &&
    List.for_all (fun char -> 
      rhyme_group_equal (detect_rhyme_group char) first_group
    ) rest

let validate_rhyme_scheme verses expected_pattern =
  let actual_pattern = detect_rhyme_pattern verses in
  List.length actual_pattern = List.length expected_pattern &&
  List.for_all2 (=) actual_pattern expected_pattern

let validate_specific_pattern verses pattern =
  validate_rhyme_scheme verses pattern

(** {1 韵律分析报告函数} *)

let generate_rhyme_report verse =
  let ending = extract_rhyme_ending verse in
  let category = match ending with
    | Some char -> detect_rhyme_category char
    | None -> PingSheng
  in
  let group = match ending with
    | Some char -> detect_rhyme_group char
    | None -> UnknownRhyme
  in
  let char_analysis = analyze_rhyme_pattern verse in
  {
    verse;
    rhyme_ending = ending;
    rhyme_group = group;
    rhyme_category = category;
    char_analysis;
  }

(** {1 韵律评分函数} *)

let rec evaluate_rhyme_quality verses =
  if List.length verses < 2 then 0.0
  else
    let consistency_score = if validate_rhyme_consistency verses then 0.5 else 0.0 in
    let diversity_score = evaluate_rhyme_diversity verses in
    let harmony_score = evaluate_rhyme_harmony verses in
    (consistency_score +. diversity_score +. harmony_score) /. 3.0

and evaluate_rhyme_harmony verses =
  let endings = detect_rhyme_pattern verses in
  let valid_rhymes = List.filter (fun char -> 
    detect_rhyme_group char <> UnknownRhyme
  ) endings in
  (match endings with 
   | [] -> 0.0 
   | _ -> (float_of_int (List.length valid_rhymes)) /. (float_of_int (List.length endings)))

and evaluate_rhyme_diversity verses =
  let endings = detect_rhyme_pattern verses in
  let groups = List.map detect_rhyme_group endings in
  let unique_groups = List.fold_left (fun acc group ->
    if List.mem group acc then acc else group :: acc
  ) [] groups in
  let known_groups = List.filter (fun g -> g <> UnknownRhyme) unique_groups in
  (match groups with 
   | [] -> 0.0 
   | _ -> 
    let diversity = float_of_int (List.length known_groups) in
    let total = float_of_int (List.length groups) in
    min 1.0 (diversity /. total *. 2.0))  (* 适度多样性评分 *)

let evaluate_rhyme_regularity verses =
  let pattern = detect_rhyme_pattern verses in
  let expected_pattern_length = List.length verses in
  let actual_pattern_length = List.length pattern in
  if expected_pattern_length = 0 then 0.0
  else (float_of_int actual_pattern_length) /. (float_of_int expected_pattern_length)

(** {1 韵律工具函数} *)

let get_rhyme_characters group =
  let data_list = get_all_rhyme_data () in
  List.fold_left (fun acc (str, _, g) ->
    if rhyme_group_equal g group then str :: acc
    else acc
  ) [] data_list

let suggest_rhyme_characters group =
  get_rhyme_characters group

let find_rhyming_characters char =
  let group = detect_rhyme_group char in
  get_rhyme_characters group

let is_known_rhyme_char char =
  detect_rhyme_group char <> UnknownRhyme

let get_rhyme_description char =
  match find_rhyme_info char with
  | Some (category, group) ->
    let cat_str = rhyme_category_to_string category in
    let group_str = rhyme_group_to_string group in
    Printf.sprintf "%c字属%s·%s" char cat_str group_str
  | None -> Printf.sprintf "%c字韵律未知" char

(** {1 高级分析函数} *)

type quick_diagnosis = {
  consistency : bool;
  quality_score : float;
  quality_grade : string;
  pattern_type : string option;
  diagnosis : string;
}

let identify_pattern_type verses =
  let verse_count = List.length verses in
  match verse_count with
  | 4 -> Some "绝句"
  | 8 -> Some "律诗" 
  | 2 -> Some "对联"
  | _ -> Some "自由诗"

let analyze_poem_rhyme verses =
  let verse_reports = List.map generate_rhyme_report verses in
  let rhyme_groups = List.fold_left (fun acc report ->
    if List.mem report.rhyme_group acc then acc
    else report.rhyme_group :: acc
  ) [] verse_reports in
  let rhyme_categories = List.fold_left (fun acc report ->
    if List.mem report.rhyme_category acc then acc
    else report.rhyme_category :: acc
  ) [] verse_reports in
  let consistency = validate_rhyme_consistency verses in
  let quality = evaluate_rhyme_quality verses in
  {
    verses;
    verse_reports;
    rhyme_groups = List.rev rhyme_groups;
    rhyme_categories = List.rev rhyme_categories;
    rhyme_quality = quality;
    rhyme_consistency = consistency;
  }

let rec quick_rhyme_diagnosis verses =
  let consistency = validate_rhyme_consistency verses in
  let quality_score = evaluate_rhyme_quality verses in
  let quality_grade = 
    if quality_score >= 0.8 then "优秀"
    else if quality_score >= 0.6 then "良好"
    else if quality_score >= 0.4 then "一般"
    else "较差"
  in
  let pattern_type = identify_pattern_type verses in
  let diagnosis = 
    if consistency then "韵律一致，押韵规范"
    else "韵律不一致，建议调整韵脚"
  in
  { consistency; quality_score; quality_grade; pattern_type; diagnosis }

and comprehensive_rhyme_analysis verses =
  let rhyme_analysis = analyze_poem_rhyme verses in
  let diagnosis = quick_rhyme_diagnosis verses in
  {
    poem_text = verses;
    form = if List.length verses = 4 then QiYanJueJu else ModernPoetry;
    verse_summaries = [];  (* 简化版本暂不实现 *)
    overall_rhyme = rhyme_analysis;
    overall_artistic = {
      rhyme_harmony = diagnosis.quality_score;
      tonal_balance = 0.7;  (* 暂时默认值 *)
      parallelism = 0.6;
      imagery = 0.8;
      rhythm = 0.7;
      elegance = 0.75;
    };
    final_grade = if diagnosis.quality_score >= 0.8 then Excellent else Good;
    critique = diagnosis.diagnosis;
  }

(** {1 韵律模式常量} *)

let common_patterns = [
  ("七言绝句", ['s'; 'h'; 'j'; 'x']);
  ("五言绝句", ['l'; 'c'; 'k']);
  ("律诗首联", ['f'; 'z'; 'z'; 'z']);
]