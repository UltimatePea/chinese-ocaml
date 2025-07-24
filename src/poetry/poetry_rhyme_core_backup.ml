(** 骆言诗词韵律核心模块 - 整合版本
    
    此模块整合了原有20+个韵律相关模块的核心功能，
    提供统一的韵律检测、分析、验证和评分接口。
    
    技术债务改进：将find_rhyme_info等核心函数从13+个模块中整合，
    消除重复代码，提供统一的API接口。
    
    @author 骆言诗词编程团队
    @version 2.0 - 整合版本
    @since 2025-07-24 *)

open Poetry_types_consolidated

(** {1 内部韵律数据} *)

(** 简化的韵律数据库 - 整合核心数据，避免过度依赖外部模块 *)
let rhyme_database = [
  (* 安韵组 - 平声 *)
  ('\u5c71', PingSheng, AnRhyme); ('\u95f4', PingSheng, AnRhyme); ('\u95f2', PingSheng, AnRhyme);
  ('关', PingSheng, AnRhyme); ('还', PingSheng, AnRhyme); ('班', PingSheng, AnRhyme);
  ('颜', PingSheng, AnRhyme); ('天', PingSheng, TianRhyme); ('年', PingSheng, TianRhyme);
  ('先', PingSheng, TianRhyme); ('田', PingSheng, TianRhyme); ('边', PingSheng, TianRhyme);
  
  (* 思韵组 - 平声 *)
  ('诗', PingSheng, SiRhyme); ('时', PingSheng, SiRhyme); ('知', PingSheng, SiRhyme);
  ('思', PingSheng, SiRhyme); ('来', PingSheng, SiRhyme); ('才', PingSheng, SiRhyme);
  
  (* 仄声韵组 *)
  ('望', ZeSheng, WangRhyme); ('放', ZeSheng, WangRhyme); ('向', ZeSheng, WangRhyme);
  ('去', ZeSheng, QuRhyme); ('路', ZeSheng, QuRhyme); ('度', ZeSheng, QuRhyme);
  ('步', ZeSheng, QuRhyme); ('暮', ZeSheng, QuRhyme);
  
  (* 鱼韵组 *)
  ('鱼', PingSheng, YuRhyme); ('书', PingSheng, YuRhyme); ('居', PingSheng, YuRhyme);
  ('虚', PingSheng, YuRhyme); ('余', PingSheng, YuRhyme);
  
  (* 花韵组 *)
  ('花', PingSheng, HuaRhyme); ('霞', PingSheng, HuaRhyme); ('家', PingSheng, HuaRhyme);
  ('茶', PingSheng, HuaRhyme); ('沙', PingSheng, HuaRhyme);
  
  (* 风韵组 *)
  ('风', PingSheng, FengRhyme); ('中', PingSheng, FengRhyme); ('东', PingSheng, FengRhyme);
  ('终', PingSheng, FengRhyme); ('钟', PingSheng, FengRhyme);
  
  (* 月韵组 - 入声 *)
  ('月', RuSheng, YueRhyme); ('雪', RuSheng, YueRhyme); ('节', RuSheng, YueRhyme);
  ('别', RuSheng, YueRhyme); ('切', RuSheng, YueRhyme);
  
  (* 江韵组 *)
  ('江', PingSheng, JiangRhyme); ('窗', PingSheng, JiangRhyme); ('双', PingSheng, JiangRhyme);
  ('庄', PingSheng, JiangRhyme); ('霜', PingSheng, JiangRhyme);
  
  (* 灰韵组 *)
  ('灰', PingSheng, HuiRhyme); ('回', PingSheng, HuiRhyme); ('推', PingSheng, HuiRhyme);
  ('杯', PingSheng, HuiRhyme); ('开', PingSheng, HuiRhyme);
]

(** 韵律数据哈希表，用于快速查询 *)
let rhyme_table = 
  let tbl = Hashtbl.create 256 in
  List.iter (fun (char, category, group) -> 
    Hashtbl.add tbl char (category, group)
  ) rhyme_database;
  tbl

(** {1 核心韵律检测函数} *)

let find_rhyme_info char =
  try
    Some (Hashtbl.find rhyme_table char)
  with Not_found -> None

let find_rhyme_info_string str =
  if String.length str > 0 then
    find_rhyme_info str.[0]
  else None

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

let verses_rhyme verse1 verse2 =
  let ending1 = extract_rhyme_ending verse1 in
  let ending2 = extract_rhyme_ending verse2 in
  match ending1, ending2 with
  | Some c1, Some c2 -> chars_rhyme c1 c2
  | _ -> false

(** {1 韵律模式分析函数} *)

and extract_rhyme_ending verse =
  let len = String.length verse in
  if len > 0 then
    let rec find_last_char i =
      if i < 0 then None
      else
        let char = verse.[i] in
        if char >= '\u4e00' && char <= '\u9fff' then  (* 检查是否为汉字 *)
          Some char
        else find_last_char (i - 1)
    in
    find_last_char (len - 1)
  else None

let analyze_rhyme_pattern verse =
  let chars = ref [] in
  String.iteri (fun _ char ->
    if char >= '\u4e00' && char <= '\u9fff' then
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

(** {1 韵律评分函数} *)

and evaluate_rhyme_quality verses =
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
  if List.length endings = 0 then 0.0
  else (float_of_int (List.length valid_rhymes)) /. (float_of_int (List.length endings))

and evaluate_rhyme_diversity verses =
  let endings = detect_rhyme_pattern verses in
  let groups = List.map detect_rhyme_group endings in
  let unique_groups = List.fold_left (fun acc group ->
    if List.mem group acc then acc else group :: acc
  ) [] groups in
  let known_groups = List.filter (fun g -> g <> UnknownRhyme) unique_groups in
  if List.length groups = 0 then 0.0
  else 
    let diversity = float_of_int (List.length known_groups) in
    let total = float_of_int (List.length groups) in
    min 1.0 (diversity /. total *. 2.0)  (* 适度多样性评分 *)

let evaluate_rhyme_regularity verses =
  let pattern = detect_rhyme_pattern verses in
  let expected_pattern_length = List.length verses in
  let actual_pattern_length = List.length pattern in
  if expected_pattern_length = 0 then 0.0
  else (float_of_int actual_pattern_length) /. (float_of_int expected_pattern_length)

(** {1 韵律工具函数} *)

let get_rhyme_characters group =
  List.fold_left (fun acc (char, _, g) ->
    if rhyme_group_equal g group then (String.make 1 char) :: acc
    else acc
  ) [] rhyme_database

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

let quick_rhyme_diagnosis verses =
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
  let suggestions = 
    if not diagnosis.consistency then
      ["建议统一韵脚，确保同韵组押韵"]
    else
      ["韵律较好，可考虑增加音韵变化"]
  in
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
  ("七言绝句", ['山'; '花'; '家'; '霞']);
  ("五言绝句", ['来'; '才'; '开']);
  ("律诗首联", ['风'; '中'; '终'; '钟']);
]

and identify_pattern_type verses =
  let verse_count = List.length verses in
  match verse_count with
  | 4 -> Some "绝句"
  | 8 -> Some "律诗" 
  | 2 -> Some "对联"
  | _ -> Some "自由诗"