open Poetry_core.Rhyme_core_types
(** 去韵组数据模块 - 骆言诗词编程特性 *)

let make_entry char category group ?(variants = []) ?(frequency = 1.0) () =
  { character = char; category; group; variants; usage_frequency = frequency }

let make_group_entries category group chars =
  List.map (fun char -> make_entry char category group ()) chars

let qu_sheng_chars = [ "路"; "度"; "步"; "去"; "趣"; "露"; "顾"; "故"; "古"; "固" ]
let qu_sheng_data = make_group_entries QuSheng QuRhyme qu_sheng_chars
let all_data = qu_sheng_data
let char_count = List.length all_data
let stats_by_category = [ (QuSheng, List.length qu_sheng_chars) ]
