open Poetry_core.Rhyme_core_types
(** 月韵组数据模块 - 骆言诗词编程特性 *)

let make_entry char category group ?(variants = []) ?(frequency = 1.0) () =
  { character = char; category; group; variants; usage_frequency = frequency }

let make_group_entries category group chars =
  List.map (fun char -> make_entry char category group ()) chars

let ze_sheng_chars = [ "月"; "雪"; "节"; "切"; "热"; "列"; "别"; "铁"; "血"; "设" ]
let ze_sheng_data = make_group_entries ZeSheng YueRhyme ze_sheng_chars
let all_data = ze_sheng_data
let char_count = List.length all_data
let stats_by_category = [ (ZeSheng, List.length ze_sheng_chars) ]
