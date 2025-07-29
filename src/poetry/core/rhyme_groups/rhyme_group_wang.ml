open Poetry_core.Poetry_types
(** 望韵组数据模块 - 骆言诗词编程特性 *)

let make_entry char category group ?(variants = []) ?(frequency = 1.0) () =
  { character = char; category; group; variants; usage_frequency = frequency }

let make_group_entries category group chars =
  List.map (fun char -> make_entry char category group ()) chars

let ze_sheng_chars = [ "放"; "向"; "响"; "望"; "房"; "方"; "防"; "访"; "妨"; "仿" ]
let ze_sheng_data = make_group_entries ZeSheng WangRhyme ze_sheng_chars
let all_data = ze_sheng_data
let char_count = List.length all_data
let stats_by_category = [ (ZeSheng, List.length ze_sheng_chars) ]
