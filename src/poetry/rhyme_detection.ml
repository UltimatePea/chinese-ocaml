(* 音韵检测模块 - 骆言诗词编程特性
   盖古之诗者，音韵为要。声韵调谐，方称佳构。
   此模块专司音韵检测，察韵脚之归属，辨声律之分类。
   凡诗词编程，必先通音韵，后成文章。
   
   性能优化：使用哈希表缓存韵律数据，从O(n)线性搜索优化至O(1)常数时间查找
*)

open Rhyme_types
open Rhyme_database
open Rhyme_utils

(* 性能优化：构建哈希表缓存以提升查找效率
   将O(n)的线性搜索优化为O(1)的哈希查找
*)
let rhyme_cache = lazy (
  let cache = Hashtbl.create 1024 in
  List.iter (fun (char, category, group) ->
    Hashtbl.replace cache char (category, group)
  ) rhyme_database;
  cache
)

(* 优化版本：从缓存哈希表中查找韵律信息 *)
let find_rhyme_info_cached char_str =
  try
    let category, group = Hashtbl.find (Lazy.force rhyme_cache) char_str in
    Some (category, group)
  with Not_found -> None

(* 寻韵察音：从数据库中查找字符的韵母信息
   如觅珠于海，寻音于典。一字一韵，皆有所归。
*)
let find_rhyme_info char =
  let char_str = String.make 1 char in
  find_rhyme_info_cached char_str

(* 按字符串查找韵母信息 *)
let find_rhyme_info_by_string char_str =
  find_rhyme_info_cached char_str

(* 辨音识韵：检测字符的韵母分类
   辨别平仄，识别声调，为诗词创作提供音律指导。
*)
let detect_rhyme_category char =
  match find_rhyme_info char with Some (category, _) -> category | None -> PingSheng (* 默认为平声 *)

(* 按字符串检测韵母分类 *)
let detect_rhyme_category_by_string char_str =
  match find_rhyme_info_cached char_str with
  | Some (category, _) -> category
  | None -> PingSheng

(* 归类成组：检测字符的韵组
   同组之字，可以押韵；异组之字，不可混用。
*)
let detect_rhyme_group char =
  match find_rhyme_info char with Some (_, group) -> group | None -> UnknownRhyme

(* 按字符串检测韵组 *)
let detect_rhyme_group_by_string char_str =
  match find_rhyme_info_cached char_str with
  | Some (_, group) -> group
  | None -> UnknownRhyme

(* 提取韵脚：从字符串中提取韵脚字符
   句末之字，谓之韵脚。提取韵脚，以验押韵。
*)
let extract_rhyme_ending verse =
  let chars = utf8_to_char_list verse in
  match List.rev chars with
  | [] -> None
  | last_char :: _ -> if String.length last_char > 0 then Some last_char.[0] else None

(* 提取韵脚字符串 *)
let extract_rhyme_ending_string verse =
  let chars = utf8_to_char_list verse in
  match List.rev chars with
  | [] -> None
  | last_char :: _ -> if String.length last_char > 0 then Some last_char else None

(* 检测诗句的韵脚信息 *)
let detect_verse_rhyme_info verse =
  match extract_rhyme_ending verse with
  | None -> None
  | Some ending_char -> (
      match find_rhyme_info ending_char with
      | Some (category, group) -> Some (ending_char, category, group)
      | None -> None)

(* 检测诗句是否为平声韵 *)
let is_ping_sheng_verse verse =
  match extract_rhyme_ending verse with
  | None -> false
  | Some ending_char -> (
      match detect_rhyme_category ending_char with PingSheng -> true | _ -> false)

(* 检测诗句是否为仄声韵 *)
let is_ze_sheng_verse verse =
  match extract_rhyme_ending verse with
  | None -> false
  | Some ending_char -> (
      match detect_rhyme_category ending_char with
      | ZeSheng | ShangSheng | QuSheng | RuSheng -> true
      | _ -> false)

(* 检测两个字符是否同韵组 *)
let same_rhyme_group char1 char2 =
  match (find_rhyme_info char1, find_rhyme_info char2) with
  | Some (_, group1), Some (_, group2) -> rhyme_group_equal group1 group2
  | _, _ -> false

(* 检测两个字符串是否同韵组 *)
let same_rhyme_group_string str1 str2 =
  match (find_rhyme_info_by_string str1, find_rhyme_info_by_string str2) with
  | Some (_, group1), Some (_, group2) -> rhyme_group_equal group1 group2
  | _, _ -> false

(* 检测两个诗句是否押韵 *)
let verses_rhyme verse1 verse2 =
  match (extract_rhyme_ending verse1, extract_rhyme_ending verse2) with
  | Some char1, Some char2 -> same_rhyme_group char1 char2
  | _, _ -> false

(* 分析诗句中所有字符的韵律信息 *)
let analyze_verse_chars verse =
  let chars = utf8_to_char_list verse in
  List.filter_map
    (fun char_str ->
      if String.length char_str > 0 then
        let char = char_str.[0] in
        match find_rhyme_info char with
        | Some (category, group) -> Some (char, category, group)
        | None -> None
      else None)
    chars

(* 检测诗句的韵律模式 *)
let detect_verse_pattern verse =
  let char_analysis = analyze_verse_chars verse in
  List.map (fun (char, category, _) -> (char, is_ping_sheng category)) char_analysis

(* 韵律摘要类型 *)
type verse_summary = {
  verse : string;
  ending_info : (char * rhyme_category * rhyme_group) option;
  char_analysis : (char * rhyme_category * rhyme_group) list;
  is_ping_sheng : bool;
  is_ze_sheng : bool;
  char_count : int;
}

(* 生成诗句的韵律摘要 *)
let generate_verse_summary verse =
  let normalized_verse = normalize_verse verse in
  let ending_info = detect_verse_rhyme_info normalized_verse in
  let char_analysis = analyze_verse_chars normalized_verse in
  let is_ping = is_ping_sheng_verse normalized_verse in
  let is_ze = is_ze_sheng_verse normalized_verse in
  {
    verse = normalized_verse;
    ending_info;
    char_analysis;
    is_ping_sheng = is_ping;
    is_ze_sheng = is_ze;
    char_count = List.length char_analysis;
  }
