(** 天韵组数据模块 - 骆言诗词编程特性
    
    天韵组包含"年、先、田"等字，天籁之音。
    重构自 rhyme_core_data_original.ml 的天韵组部分。
    
    @author Beta, 代码审查代理
    @version 1.0 - 模块化重构版本
    @since 2025-07-27 *)

open Poetry_core.Rhyme_core_types

(** 创建韵律数据条目的辅助函数 *)
let make_entry char category group ?(variants = []) ?(frequency = 1.0) () =
  { character = char; category; group; variants; usage_frequency = frequency }

(** 创建某个韵组字符列表的辅助函数 *)
let make_group_entries category group chars =
  List.map (fun char -> make_entry char category group ()) chars

(** 天韵组平声字符数据 *)
let ping_sheng_chars = [
  "天"; "年"; "先"; "田"; "边"; "前"; "千"; "线"; "坚"; "全";
  "圆"; "便"; "言"; "烟"; "研"; "燕"; "延"; "权"; "传"; "船";
  "川"; "泉"; "县"; "变"; "团"; "观"; "官"; "端"; "管"; "算";
  "短"; "断"; "乱"; "段"; "判"; "半"; "联"; "连"; "怜"; "莲";
  "廉"; "帘"; "兼"; "尖"; "坚"; "肩"; "坚"; "煎"
]

(** 天韵组平声数据条目 *)
let ping_sheng_data = make_group_entries PingSheng TianRhyme ping_sheng_chars

(** 天韵组所有数据 (仅平声) *)
let all_data = ping_sheng_data

(** 天韵组字符总数 *)
let char_count = List.length all_data

(** 按声韵类别统计字符数 *)
let stats_by_category = [
  (PingSheng, List.length ping_sheng_chars);
]