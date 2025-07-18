(* 韵律模式识别模块 - 骆言诗词编程特性
   专司韵律模式之识别，辨析诗词之结构。
   盖诗词之美，不仅在于用词优雅，更在于韵律工整。
   此模块实现韵脚提取、韵律分析、模式验证等功能。
*)

(* 导入韵母类型定义 *)
open Rhyme_types

(* 简单的UTF-8字符列表转换函数 *)
let utf8_to_char_list s =
  let rec aux acc i =
    if i >= String.length s then List.rev acc else aux (String.make 1 s.[i] :: acc) (i + 1)
  in
  aux [] 0

(* 提取韵脚：从字符串中提取韵脚字符
   句末之字，谓之韵脚。提取韵脚，以验押韵。
*)
let extract_rhyme_ending verse =
  let chars = utf8_to_char_list verse in
  match List.rev chars with
  | [] -> None
  | last_char :: _ -> if String.length last_char > 0 then Some last_char.[0] else None

(* 验证韵脚一致性：检查多句诗词的韵脚是否和谐
   诗词之美，在于韵律。韵脚一致，方显音律之美。
*)
let validate_rhyme_consistency verses =
  let rhyme_endings = List.filter_map extract_rhyme_ending verses in
  let rhyme_groups = List.map Rhyme_matching.detect_rhyme_group rhyme_endings in

  (* 检查是否所有韵脚都属于同一韵组 *)
  match rhyme_groups with
  | [] -> true
  | first_group :: rest ->
      List.for_all (fun group -> group = first_group || group = UnknownRhyme) rest

(* 验证韵律方案：依传统诗词格律检验韵律
   古有韵律，今有方案。按图索骥，验证韵律。
*)
let validate_rhyme_scheme verses rhyme_pattern =
  let rhyme_endings = List.filter_map extract_rhyme_ending verses in
  let rhyme_groups = List.map Rhyme_matching.detect_rhyme_group rhyme_endings in

  (* 韵律方案检查 - 同字母表示同韵，不同字母表示异韵 *)
  let rec check_pattern groups pattern =
    match (groups, pattern) with
    | [], [] -> true
    | g1 :: gs, p1 :: ps ->
        let same_rhyme = List.exists (fun (g2, p2) -> p1 = p2 && g1 = g2) (List.combine gs ps) in
        if p1 = 'A' then same_rhyme || check_pattern gs ps else check_pattern gs ps
    | _ -> false
  in

  if List.length rhyme_groups = List.length rhyme_pattern then
    check_pattern rhyme_groups rhyme_pattern
  else false

(* 分析诗句的韵律信息：逐字分析，察其音韵
   一字一音，一音一韵。细致分析，方知诗词之妙。
*)
let analyze_rhyme_pattern verse =
  let chars = utf8_to_char_list verse in
  let rhyme_info =
    List.map
      (fun char_str ->
        let char = if String.length char_str > 0 then char_str.[0] else '?' in
        (char, Rhyme_matching.detect_rhyme_category char, Rhyme_matching.detect_rhyme_group char))
      chars
  in
  rhyme_info

(* 韵律分析报告类型 *)
type rhyme_analysis_report = {
  verse : string;
  rhyme_ending : char option;
  rhyme_group : rhyme_group;
  rhyme_category : rhyme_category;
  char_analysis : (char * rhyme_category * rhyme_group) list;
}

(* 生成韵律分析报告：为诗句提供全面的音韵分析
   如医者诊脉，如师者评文。细致分析，指导创作。
*)
let generate_rhyme_report verse =
  let rhyme_ending = extract_rhyme_ending verse in
  let rhyme_group =
    match rhyme_ending with
    | Some char -> Rhyme_matching.detect_rhyme_group char
    | None -> UnknownRhyme
  in
  let rhyme_category =
    match rhyme_ending with
    | Some char -> Rhyme_matching.detect_rhyme_category char
    | None -> PingSheng
  in
  let chars = utf8_to_char_list verse in
  let char_analysis =
    List.map
      (fun char_str ->
        let char = if String.length char_str > 0 then char_str.[0] else '?' in
        (char, Rhyme_matching.detect_rhyme_category char, Rhyme_matching.detect_rhyme_group char))
      chars
  in
  { verse; rhyme_ending; rhyme_group; rhyme_category; char_analysis }

(* 整体韵律分析报告类型 *)
type poem_rhyme_analysis = {
  verses : string list;
  verse_reports : rhyme_analysis_report list;
  rhyme_groups : rhyme_group list;
  rhyme_categories : rhyme_category list;
  rhyme_quality : float;
  rhyme_consistency : bool;
}

(* 分析诗词整体韵律：分析整首诗的韵律结构
   整首诗词，韵律有法。此函分析整体韵律结构。
*)
let analyze_poem_rhyme verses =
  let verse_reports = List.map generate_rhyme_report verses in
  let rhyme_groups = List.map (fun report -> report.rhyme_group) verse_reports in
  let rhyme_categories = List.map (fun report -> report.rhyme_category) verse_reports in

  let rhyme_quality = 0.0 in
  (* Will be calculated separately *)
  let rhyme_consistency = validate_rhyme_consistency verses in

  { verses; verse_reports; rhyme_groups; rhyme_categories; rhyme_quality; rhyme_consistency }

(* 韵律美化建议：为诗句提供音韵改进之建议
   文章不厌百回改，韵律调谐需精思。此函提供改进之策。
*)
let suggest_rhyme_improvements verse target_rhyme_group =
  let report = generate_rhyme_report verse in
  if report.rhyme_group = target_rhyme_group then [] (* 已经符合要求 *)
  else
    let suggestions = Rhyme_matching.suggest_rhyme_characters target_rhyme_group in
    let rec take n lst =
      if n <= 0 then [] else match lst with [] -> [] | h :: t -> h :: take (n - 1) t
    in
    take 5 suggestions (* 返回前5个建议 *)

(* 检测韵律模式：分析诗词的韵律结构模式
   如ABAB、AABB等不同韵律模式。
*)
let detect_rhyme_pattern verses =
  let rhyme_endings = List.filter_map extract_rhyme_ending verses in
  let rhyme_groups = List.map Rhyme_matching.detect_rhyme_group rhyme_endings in

  (* 为每个韵组分配字母标记 *)
  let rec assign_letters groups seen_groups current_letter =
    match groups with
    | [] -> []
    | group :: rest ->
        let letter = try List.assoc group seen_groups with Not_found -> current_letter in
        let new_seen =
          if List.mem_assoc group seen_groups then seen_groups
          else (group, current_letter) :: seen_groups
        in
        let next_letter =
          if List.mem_assoc group seen_groups then current_letter
          else char_of_int (int_of_char current_letter + 1)
        in
        letter :: assign_letters rest new_seen next_letter
  in

  assign_letters rhyme_groups [] 'A'

(* 验证特定韵律模式：检查诗词是否符合特定韵律模式
   如律诗、绝句等传统诗词格律。
*)
let validate_specific_pattern verses expected_pattern =
  let detected_pattern = detect_rhyme_pattern verses in
  detected_pattern = expected_pattern

(* 常见韵律模式定义 *)
let common_patterns =
  [
    ("绝句", [ 'A'; 'B'; 'A'; 'B' ]);
    ("律诗", [ 'A'; 'B'; 'A'; 'B'; 'C'; 'D'; 'C'; 'D' ]);
    ("五言律诗", [ 'A'; 'B'; 'A'; 'B'; 'C'; 'D'; 'C'; 'D' ]);
    ("七言律诗", [ 'A'; 'B'; 'A'; 'B'; 'C'; 'D'; 'C'; 'D' ]);
    ("排律", [ 'A'; 'B'; 'A'; 'B'; 'C'; 'D'; 'C'; 'D'; 'E'; 'F'; 'E'; 'F' ]);
  ]

(* 识别韵律模式类型：根据检测到的韵律模式识别诗词类型 *)
let identify_pattern_type verses =
  let detected_pattern = detect_rhyme_pattern verses in
  List.find_map
    (fun (name, pattern) -> if detected_pattern = pattern then Some name else None)
    common_patterns
