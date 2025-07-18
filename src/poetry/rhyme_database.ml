(* 音韵数据库模块 - 骆言诗词编程特性
   盖古之诗者，音韵为要。声韵调谐，方称佳构。
   此模块专司音韵数据查询功能，数据已迁移至专门模块。
   依《广韵》、《集韵》等韵书传统，提供查询接口。
   平声清越，仄声沉郁，入声短促，各有所归。
*)

open Rhyme_types

(* 引用专门的韵律数据 *)
let rhyme_database = Rhyme_data.rhyme_database

(* 数据库统计信息类型 *)
type database_stats = {
  total_chars : int;
  ping_sheng_count : int;
  ze_sheng_count : int;
  ru_sheng_count : int;
  group_counts : (string * int) list;
}

(* 数据库查询函数 *)

(* 查找字符的韵母信息 *)
let find_rhyme_info char =
  let char_str = String.make 1 char in
  try
    let _, category, group = List.find (fun (c, _, _) -> c = char_str) rhyme_database in
    Some (category, group)
  with Not_found -> None

(* 数据库统计信息 *)
let get_database_stats () =
  let total_chars = List.length rhyme_database in
  let ping_sheng_count =
    List.length (List.filter (fun (_, cat, _) -> cat = PingSheng) rhyme_database)
  in
  let ze_sheng_count =
    List.length (List.filter (fun (_, cat, _) -> cat = ZeSheng) rhyme_database)
  in
  let ru_sheng_count =
    List.length (List.filter (fun (_, cat, _) -> cat = RuSheng) rhyme_database)
  in
  let group_counts =
    [
      ("安韵", List.length (List.filter (fun (_, _, grp) -> grp = AnRhyme) rhyme_database));
      ("思韵", List.length (List.filter (fun (_, _, grp) -> grp = SiRhyme) rhyme_database));
      ("天韵", List.length (List.filter (fun (_, _, grp) -> grp = TianRhyme) rhyme_database));
      ("望韵", List.length (List.filter (fun (_, _, grp) -> grp = WangRhyme) rhyme_database));
      ("去韵", List.length (List.filter (fun (_, _, grp) -> grp = QuRhyme) rhyme_database));
    ]
  in
  { total_chars; ping_sheng_count; ze_sheng_count; ru_sheng_count; group_counts }

(* 获取指定韵组的所有字符 *)
let get_chars_by_group group =
  List.filter_map (fun (char, _, grp) -> if grp = group then Some char else None) rhyme_database

(* 获取指定韵类的所有字符 *)
let get_chars_by_category category =
  List.filter_map (fun (char, cat, _) -> if cat = category then Some char else None) rhyme_database
