(* 音韵分析模块 - 骆言诗词编程特性 *)

open Yyocamlc_lib

type rhyme_category =
  | PingSheng  (* 平声韵 *)
  | ZeSheng    (* 仄声韵 *)
  | ShangSheng (* 上声韵 *)
  | QuSheng    (* 去声韵 *)
  | RuSheng    (* 入声韵 *)

type rhyme_group = 
  | AnRhyme    (* 安韵组 *)
  | SiRhyme    (* 思韵组 *)
  | TianRhyme  (* 天韵组 *)
  | WangRhyme  (* 望韵组 *)
  | QuRhyme    (* 去韵组 *)
  | UnknownRhyme (* 未知韵组 *)

(* 基础韵母分类数据库 *)
let rhyme_database = [
  (* 平声韵 *)
  ("安", PingSheng, AnRhyme); ("山", PingSheng, AnRhyme); ("间", PingSheng, AnRhyme); ("闲", PingSheng, AnRhyme);
  ("诗", PingSheng, SiRhyme); ("时", PingSheng, SiRhyme); ("知", PingSheng, SiRhyme); ("思", PingSheng, SiRhyme);
  ("天", PingSheng, TianRhyme); ("年", PingSheng, TianRhyme); ("先", PingSheng, TianRhyme); ("田", PingSheng, TianRhyme);
  ("言", PingSheng, TianRhyme); ("然", PingSheng, TianRhyme); ("连", PingSheng, TianRhyme); ("边", PingSheng, TianRhyme);
  
  (* 仄声韵 *)
  ("上", ZeSheng, WangRhyme); ("想", ZeSheng, WangRhyme); ("望", ZeSheng, WangRhyme); ("放", ZeSheng, WangRhyme);
  ("去", ZeSheng, QuRhyme); ("路", ZeSheng, QuRhyme); ("度", ZeSheng, QuRhyme); ("故", ZeSheng, QuRhyme);
  ("步", ZeSheng, QuRhyme); ("处", ZeSheng, QuRhyme); ("住", ZeSheng, QuRhyme); ("数", ZeSheng, QuRhyme);
  
  (* 常用编程相关字符 *)
  ("数", ZeSheng, QuRhyme); ("组", ZeSheng, QuRhyme); ("序", ZeSheng, QuRhyme); ("述", ZeSheng, QuRhyme);
  ("函", PingSheng, AnRhyme); ("参", PingSheng, AnRhyme); ("算", PingSheng, AnRhyme); ("变", PingSheng, TianRhyme);
  ("量", PingSheng, AnRhyme); ("状", PingSheng, AnRhyme); ("常", PingSheng, AnRhyme); ("长", PingSheng, AnRhyme);
  ("程", PingSheng, SiRhyme); ("成", PingSheng, SiRhyme); ("整", PingSheng, SiRhyme); ("清", PingSheng, SiRhyme);
  ("用", ZeSheng, QuRhyme); ("动", ZeSheng, QuRhyme); ("同", PingSheng, SiRhyme); ("中", PingSheng, SiRhyme);
  ("等", ZeSheng, QuRhyme); ("定", ZeSheng, QuRhyme); ("令", ZeSheng, QuRhyme); ("命", ZeSheng, QuRhyme);
  ("类", ZeSheng, QuRhyme); ("比", ZeSheng, QuRhyme); ("值", ZeSheng, QuRhyme); ("置", ZeSheng, QuRhyme);
  ("入", RuSheng, QuRhyme); ("出", RuSheng, QuRhyme); ("得", RuSheng, QuRhyme); ("结", RuSheng, QuRhyme);
  ("法", RuSheng, QuRhyme); ("达", RuSheng, QuRhyme); ("合", RuSheng, QuRhyme); ("接", RuSheng, QuRhyme);
]

(* 从数据库中查找字符的韵母信息 *)
let find_rhyme_info char =
  let char_str = String.make 1 char in
  try
    let (_, category, group) = List.find (fun (ch, _, _) -> ch = char_str) rhyme_database in
    Some (category, group)
  with
  | Not_found -> None

(* 检测字符的韵母分类 *)
let detect_rhyme_category char =
  match find_rhyme_info char with
  | Some (category, _) -> category
  | None -> PingSheng  (* 默认为平声 *)

(* 检测字符的韵组 *)
let detect_rhyme_group char =
  match find_rhyme_info char with
  | Some (_, group) -> group
  | None -> UnknownRhyme

(* 从字符串中提取韵脚字符 *)
let extract_rhyme_ending verse =
  let chars = Utf8_utils.StringUtils.utf8_to_char_list verse in
  match List.rev chars with
  | [] -> None
  | last_char :: _ -> 
    if String.length last_char > 0 then Some last_char.[0] else None

(* 验证韵脚一致性 *)
let validate_rhyme_consistency verses =
  let rhyme_endings = List.filter_map extract_rhyme_ending verses in
  let rhyme_groups = List.map detect_rhyme_group rhyme_endings in
  
  (* 检查是否所有韵脚都属于同一韵组 *)
  match rhyme_groups with
  | [] -> true
  | first_group :: rest -> 
    List.for_all (fun group -> group = first_group || group = UnknownRhyme) rest

(* 验证韵律方案 *)
let validate_rhyme_scheme verses rhyme_pattern =
  let rhyme_endings = List.filter_map extract_rhyme_ending verses in
  let rhyme_groups = List.map detect_rhyme_group rhyme_endings in
  
  (* 简单的韵律方案检查 - 同字母表示同韵 *)
  let rec check_pattern groups pattern =
    match groups, pattern with
    | [], [] -> true
    | g1 :: gs, p1 :: ps ->
      let same_rhyme = List.exists (fun (g2, p2) -> p1 = p2 && g1 = g2) (List.combine gs ps) in
      if p1 = 'A' then same_rhyme || check_pattern gs ps
      else check_pattern gs ps
    | _ -> false
  in
  
  if List.length rhyme_groups = List.length rhyme_pattern then
    check_pattern rhyme_groups rhyme_pattern
  else
    false

(* 分析诗句的韵律信息 *)
let analyze_rhyme_pattern verse =
  let chars = Utf8_utils.StringUtils.utf8_to_char_list verse in
  let rhyme_info = List.map (fun char_str -> 
    let char = if String.length char_str > 0 then char_str.[0] else '?' in
    (char, detect_rhyme_category char, detect_rhyme_group char)
  ) chars in
  rhyme_info

(* 建议韵脚字符 *)
let suggest_rhyme_characters target_group =
  let candidates = List.filter_map (fun (char, _, group) ->
    if group = target_group then Some char else None
  ) rhyme_database in
  candidates

(* 检查两个字符是否押韵 *)
let chars_rhyme char1 char2 =
  let group1 = detect_rhyme_group char1 in
  let group2 = detect_rhyme_group char2 in
  group1 = group2 && group1 <> UnknownRhyme

(* 韵律分析报告 *)
type rhyme_analysis_report = {
  verse : string;
  rhyme_ending : char option;
  rhyme_group : rhyme_group;
  rhyme_category : rhyme_category;
  char_analysis : (char * rhyme_category * rhyme_group) list;
}

(* 生成韵律分析报告 *)
let generate_rhyme_report verse =
  let rhyme_ending = extract_rhyme_ending verse in
  let rhyme_group = match rhyme_ending with
    | Some char -> detect_rhyme_group char
    | None -> UnknownRhyme
  in
  let rhyme_category = match rhyme_ending with
    | Some char -> detect_rhyme_category char
    | None -> PingSheng
  in
  let char_analysis = analyze_rhyme_pattern verse in
  {
    verse;
    rhyme_ending;
    rhyme_group;
    rhyme_category;
    char_analysis;
  }

(* 韵律美化建议 *)
let suggest_rhyme_improvements verse target_rhyme_group =
  let report = generate_rhyme_report verse in
  if report.rhyme_group = target_rhyme_group then
    []  (* 已经符合要求 *)
  else
    let suggestions = suggest_rhyme_characters target_rhyme_group in
    let rec take n lst =
      if n <= 0 then [] else
      match lst with
      | [] -> []
      | h :: t -> h :: take (n - 1) t
    in
    take 5 suggestions  (* 返回前5个建议 *)

(* 导出函数 *)
let () = ()