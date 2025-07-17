(* 对仗分析模块 - 骆言诗词编程特性
   夫诗词对仗，乃文学之精华，音韵之美感。
   出句对句，词性相对，声律相谐，意境相宜。
   此模块专司对仗分析，验证对仗工整，评估对仗质量。
   既遵古制，又开新风，为诗词编程提供完整的对仗支持。
*)

open Rhyme_analysis
open Yyocamlc_lib
open Word_class_data

(* 简单的UTF-8字符列表转换函数 *)
let utf8_to_char_list s =
  Utf8_utils.StringUtils.utf8_to_char_list s

(* 词性分类：已移至 Word_class_data 模块 *)

(* 对仗类型：按传统诗词理论分类对仗
   工对正对，宽对邻对，失对无对，各有等级。
*)
type parallelism_type =
  | PerfectParallelism    (* 工对 - 词性声律完全相对 *)
  | GoodParallelism       (* 正对 - 词性相对声律和谐 *)
  | LooseParallelism      (* 宽对 - 词性相近声律可容 *)
  | WeakParallelism       (* 邻对 - 词性相邻声律不完全 *)
  | NoParallelism         (* 无对 - 词性声律皆不相对 *)

(* 对仗位置：标识对仗在诗词中的位置
   首联颔联，颈联尾联，各有对仗要求。
*)
type parallelism_position =
  | FirstCouplet    (* 首联 - 诗词开头联 *)
  | SecondCouplet   (* 颔联 - 诗词第二联 *)
  | ThirdCouplet    (* 颈联 - 诗词第三联 *)
  | LastCouplet     (* 尾联 - 诗词结尾联 *)
  | MiddleCouplet   (* 中联 - 其他位置联 *)

(* 词性数据库：已移至 Word_class_data 模块 *)

(* 检测词性：根据字符判断词性 *)
let detect_word_class char =
  let char_str = String.make 1 char in
  try
    let _, word_class = List.find (fun (ch, _) -> ch = char_str) word_class_database in
    word_class
  with Not_found -> Unknown

let detect_word_class_by_string char_str =
  try
    let _, word_class = List.find (fun (ch, _) -> ch = char_str) word_class_database in
    word_class
  with Not_found -> Unknown

(* 检测词性相对性：判断两个词性是否相对
   工对要求词性完全相同，宽对允许相近词性。
*)
let word_classes_match class1 class2 match_level =
  match match_level with
  | PerfectParallelism -> class1 = class2
  | GoodParallelism -> 
      class1 = class2 || 
      (class1 = Noun && class2 = Pronoun) ||
      (class1 = Pronoun && class2 = Noun) ||
      (class1 = Adjective && class2 = Verb) ||
      (class1 = Verb && class2 = Adjective)
  | LooseParallelism ->
      class1 = class2 ||
      (class1 = Noun && (class2 = Pronoun || class2 = Classifier)) ||
      (class1 = Pronoun && (class2 = Noun || class2 = Classifier)) ||
      (class1 = Classifier && (class2 = Noun || class2 = Pronoun)) ||
      (class1 = Adjective && (class2 = Verb || class2 = Adverb)) ||
      (class1 = Verb && (class2 = Adjective || class2 = Adverb)) ||
      (class1 = Adverb && (class2 = Adjective || class2 = Verb))
  | WeakParallelism ->
      class1 <> Unknown && class2 <> Unknown
  | NoParallelism -> false

(* 分析对仗质量：评估两句诗的对仗程度
   综合考虑词性对仗、声律对仗、意境对仗等因素。
*)
let analyze_parallelism_quality line1 line2 =
  let chars1 = utf8_to_char_list line1 in
  let chars2 = utf8_to_char_list line2 in
  
  if List.length chars1 <> List.length chars2 then
    NoParallelism
  else
    let char_pairs = List.combine chars1 chars2 in
    let word_class_pairs = List.map (fun (c1_str, c2_str) ->
      (detect_word_class_by_string c1_str, detect_word_class_by_string c2_str)
    ) char_pairs in
    
    let rhyme_pairs = List.map (fun (c1_str, c2_str) ->
      (detect_rhyme_category_by_string c1_str, detect_rhyme_category_by_string c2_str)
    ) char_pairs in
    
    let total_pairs = List.length word_class_pairs in
    let perfect_matches = List.length (List.filter (fun (c1, c2) -> 
      word_classes_match c1 c2 PerfectParallelism) word_class_pairs) in
    let good_matches = List.length (List.filter (fun (c1, c2) -> 
      word_classes_match c1 c2 GoodParallelism) word_class_pairs) in
    let loose_matches = List.length (List.filter (fun (c1, c2) -> 
      word_classes_match c1 c2 LooseParallelism) word_class_pairs) in
    let weak_matches = List.length (List.filter (fun (c1, c2) -> 
      word_classes_match c1 c2 WeakParallelism) word_class_pairs) in
    
    let rhyme_matches = List.length (List.filter (fun (r1, r2) -> 
      (r1 = Rhyme_types.PingSheng && r2 = Rhyme_types.ZeSheng) || (r1 = Rhyme_types.ZeSheng && r2 = Rhyme_types.PingSheng)) rhyme_pairs) in
    
    let perfect_ratio = float_of_int perfect_matches /. float_of_int total_pairs in
    let good_ratio = float_of_int good_matches /. float_of_int total_pairs in
    let loose_ratio = float_of_int loose_matches /. float_of_int total_pairs in
    let weak_ratio = float_of_int weak_matches /. float_of_int total_pairs in
    let rhyme_ratio = float_of_int rhyme_matches /. float_of_int total_pairs in
    
    if perfect_ratio >= 0.8 && rhyme_ratio >= 0.6 then PerfectParallelism
    else if good_ratio >= 0.7 && rhyme_ratio >= 0.5 then GoodParallelism
    else if loose_ratio >= 0.6 && rhyme_ratio >= 0.4 then LooseParallelism
    else if weak_ratio >= 0.5 then WeakParallelism
    else NoParallelism

(* 对仗分析报告类型 *)
type parallelism_analysis_report = {
  line1 : string;
  line2 : string;
  parallelism_type : parallelism_type;
  word_class_pairs : (word_class * word_class) list;
  rhyme_pairs : (Rhyme_types.rhyme_category * Rhyme_types.rhyme_category) list;
  perfect_match_ratio : float;
  good_match_ratio : float;
  rhyme_match_ratio : float;
  overall_score : float;
}

(* 生成对仗分析报告：详细分析两句诗的对仗情况 *)
let generate_parallelism_report line1 line2 =
  let chars1 = utf8_to_char_list line1 in
  let chars2 = utf8_to_char_list line2 in
  
  let char_pairs = List.combine chars1 chars2 in
  let word_class_pairs = List.map (fun (c1_str, c2_str) ->
    (detect_word_class_by_string c1_str, detect_word_class_by_string c2_str)
  ) char_pairs in
  
  let rhyme_pairs = List.map (fun (c1_str, c2_str) ->
    (detect_rhyme_category_by_string c1_str, detect_rhyme_category_by_string c2_str)
  ) char_pairs in
  
  let total_pairs = List.length word_class_pairs in
  let perfect_matches = List.length (List.filter (fun (c1, c2) -> 
    word_classes_match c1 c2 PerfectParallelism) word_class_pairs) in
  let good_matches = List.length (List.filter (fun (c1, c2) -> 
    word_classes_match c1 c2 GoodParallelism) word_class_pairs) in
  let rhyme_matches = List.length (List.filter (fun (r1, r2) -> 
    (r1 = Rhyme_types.PingSheng && r2 = Rhyme_types.ZeSheng) || (r1 = Rhyme_types.ZeSheng && r2 = Rhyme_types.PingSheng)) rhyme_pairs) in
  
  let perfect_match_ratio = float_of_int perfect_matches /. float_of_int total_pairs in
  let good_match_ratio = float_of_int good_matches /. float_of_int total_pairs in
  let rhyme_match_ratio = float_of_int rhyme_matches /. float_of_int total_pairs in
  
  let parallelism_type = analyze_parallelism_quality line1 line2 in
  let overall_score = (perfect_match_ratio +. good_match_ratio +. rhyme_match_ratio) /. 3.0 in
  
  {
    line1 = line1;
    line2 = line2;
    parallelism_type = parallelism_type;
    word_class_pairs = word_class_pairs;
    rhyme_pairs = rhyme_pairs;
    perfect_match_ratio = perfect_match_ratio;
    good_match_ratio = good_match_ratio;
    rhyme_match_ratio = rhyme_match_ratio;
    overall_score = overall_score;
  }

(* 检验律诗对仗：检查律诗的对仗规则
   律诗颔联、颈联必须对仗，首联、尾联一般不对仗。
*)
let validate_regulated_verse_parallelism verses =
  if List.length verses <> 8 then
    failwith "律诗必须是八句"
  else
    let lines = Array.of_list verses in
    let second_couplet_report = generate_parallelism_report lines.(2) lines.(3) in
    let third_couplet_report = generate_parallelism_report lines.(4) lines.(5) in
    
    let second_couplet_quality = 
      match second_couplet_report.parallelism_type with
      | PerfectParallelism -> 1.0
      | GoodParallelism -> 0.8
      | LooseParallelism -> 0.6
      | WeakParallelism -> 0.4
      | NoParallelism -> 0.0
    in
    
    let third_couplet_quality = 
      match third_couplet_report.parallelism_type with
      | PerfectParallelism -> 1.0
      | GoodParallelism -> 0.8
      | LooseParallelism -> 0.6
      | WeakParallelism -> 0.4
      | NoParallelism -> 0.0
    in
    
    let overall_quality = (second_couplet_quality +. third_couplet_quality) /. 2.0 in
    
    (second_couplet_report, third_couplet_report, overall_quality)

(* 建议对仗改进：为不工整的对仗提供改进建议
   分析对仗问题，提供相应的词汇建议。
*)
let suggest_parallelism_improvements report =
  let suggestions = ref [] in
  
  (* 分析词性不对问题 *)
  let word_class_mismatches = List.filter (fun (c1, c2) -> 
    not (word_classes_match c1 c2 LooseParallelism)) report.word_class_pairs in
  
  if List.length word_class_mismatches > 0 then
    suggestions := "词性不对，建议调整词性相对的字词" :: !suggestions;
  
  (* 分析声律不对问题 *)
  let rhyme_mismatches = List.filter (fun (r1, r2) -> 
    not ((r1 = Rhyme_types.PingSheng && r2 = Rhyme_types.ZeSheng) || (r1 = Rhyme_types.ZeSheng && r2 = Rhyme_types.PingSheng))) report.rhyme_pairs in
  
  if List.length rhyme_mismatches > 0 then
    suggestions := "声律不对，建议调整平仄相对的字词" :: !suggestions;
  
  (* 总体评价 *)
  let overall_suggestion = 
    match report.parallelism_type with
    | PerfectParallelism -> "对仗工整，无需改进"
    | GoodParallelism -> "对仗良好，可适当调整"
    | LooseParallelism -> "对仗宽松，建议加强"
    | WeakParallelism -> "对仗较弱，需要改进"
    | NoParallelism -> "无对仗，需要重新构思"
  in
  
  overall_suggestion :: !suggestions

(* 导出函数：模块接口导出 *)
let () = ()