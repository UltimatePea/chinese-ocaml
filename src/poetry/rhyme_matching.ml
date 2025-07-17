(* 音韵匹配算法模块 - 骆言诗词编程特性
   专司音韵之匹配，辨析字符之韵归。
   盖诗词之美，在于音韵和谐；音韵之工，在于匹配精准。
   此模块实现字符韵母匹配、韵组归类、押韵检测等核心算法。
*)

(* 导入韵母类型定义 *)
open Rhyme_types

(* 寻韵察音：从数据库中查找字符的韵母信息
   如觅珠于海，寻音于典。一字一韵，皆有所归。
*)
let find_rhyme_info char =
  let char_str = String.make 1 char in
  try
    let _, category, group = List.find (fun (ch, _, _) -> ch = char_str) Rhyme_database.rhyme_database in
    Some (category, group)
  with Not_found -> None

(* 辨音识韵：检测字符的韵母分类
   辨别平仄，识别声调，为诗词创作提供音律指导。
*)
let detect_rhyme_category char =
  match find_rhyme_info char with 
  | Some (category, _) -> category 
  | None -> PingSheng (* 默认为平声 *)

let detect_rhyme_category_by_string char_str =
  try
    let _, category, _group = List.find (fun (ch, _, _) -> ch = char_str) Rhyme_database.rhyme_database in
    category
  with Not_found -> PingSheng

(* 归类成组：检测字符的韵组
   同组之字，可以押韵；异组之字，不可混用。
*)
let detect_rhyme_group char =
  match find_rhyme_info char with 
  | Some (_, group) -> group 
  | None -> UnknownRhyme

(* 检查两个字符是否押韵：判断二字是否可以押韵
   同韵可押，异韵不可。简明判断，助力诗词创作。
*)
let chars_rhyme char1 char2 =
  let group1 = detect_rhyme_group char1 in
  let group2 = detect_rhyme_group char2 in
  group1 = group2 && group1 <> UnknownRhyme

(* 建议韵脚字符：根据韵组提供用韵建议
   文思不畅，韵脚难寻？此函可为诗家提供用韵之建议。
*)
let suggest_rhyme_characters target_group =
  let candidates =
    List.filter_map
      (fun (char, _, group) -> if group = target_group then Some char else None)
      Rhyme_database.rhyme_database
  in
  candidates

(* 获取韵组名称：返回韵组的字符串表示
   便于调试和报告生成。
*)
let rhyme_group_to_string = Rhyme_types.rhyme_group_to_string

(* 获取韵类名称：返回韵类的字符串表示
   便于调试和报告生成。
*)
let rhyme_category_to_string = Rhyme_types.rhyme_category_to_string