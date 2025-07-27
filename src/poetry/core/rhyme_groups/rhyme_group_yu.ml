(** 鱼韵组数据模块 - 骆言诗词编程特性 *)
open Poetry_core.Rhyme_core_types
let make_entry char category group ?(variants = []) ?(frequency = 1.0) () = { character = char; category; group; variants; usage_frequency = frequency }
let make_group_entries category group chars = List.map (fun char -> make_entry char category group ()) chars
let ping_sheng_chars = ["鱼"; "书"; "居"; "余"; "渠"; "虚"; "徐"; "庐"; "除"; "如"]
let ping_sheng_data = make_group_entries PingSheng YuRhyme ping_sheng_chars
let all_data = ping_sheng_data
let char_count = List.length all_data
let stats_by_category = [(PingSheng, List.length ping_sheng_chars)]