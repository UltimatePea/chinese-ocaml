open Poetry_core.Poetry_types
(** 风韵组数据模块 - 骆言诗词编程特性 *)

let make_entry char category group ?(variants = []) ?(frequency = 1.0) () =
  { character = char; category; group; variants; usage_frequency = frequency }

let make_group_entries category group chars =
  List.map (fun char -> make_entry char category group ()) chars

let ping_sheng_chars = [ "风"; "送"; "中"; "空"; "东"; "红"; "公"; "功"; "工"; "弓" ]
let ping_sheng_data = make_group_entries PingSheng FengRhyme ping_sheng_chars
let all_data = ping_sheng_data
let char_count = List.length all_data
let stats_by_category = [ (PingSheng, List.length ping_sheng_chars) ]
