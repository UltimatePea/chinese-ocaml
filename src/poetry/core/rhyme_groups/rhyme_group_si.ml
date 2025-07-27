(** 思韵组数据模块 - 骆言诗词编程特性
    
    思韵组包含"时、诗、知"等字，情思绵绵。
    重构自 rhyme_core_data_original.ml 的思韵组部分。
    
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

(** 思韵组平声字符数据 *)
let ping_sheng_chars = [
  "时"; "诗"; "知"; "之"; "师"; "支"; "枝"; "池"; "施"; "资";
  "思"; "词"; "辞"; "丝"; "私"; "慈"; "磁"; "茨"; "棋"; "期";
  "奇"; "其"; "基"; "机"; "饥"; "肌"; "几"; "姬"; "矶"; "鸡";
  "题"; "蹄"; "啼"; "提"; "梯"; "低"; "泥"; "西"; "栖"; "妻";
  "凄"; "齐"; "迷"; "批"; "皮"; "疲"; "脾"; "儿"; "而"; "二";
]

(** 思韵组仄声字符数据 *)
let ze_sheng_chars = [
  "史"; "使"; "始"; "止"; "纸"; "指"; "只"; "至"; "志"; "治";
  "置"; "智"; "制"; "致"; "炽"; "痴"; "迟"; "持"; "池"; "尺";
  "赤"; "翅"; "耻"; "齿"; "次"; "刺"; "此"; "寺"; "四"; "似";
  "伺"; "嗣"; "思"; "死"; "寺"; "刺"; "次"; "伺"; "饲"
]

(** 思韵组平声数据条目 *)
let ping_sheng_data = make_group_entries PingSheng SiRhyme ping_sheng_chars

(** 思韵组仄声数据条目 *)
let ze_sheng_data = make_group_entries ZeSheng SiRhyme ze_sheng_chars

(** 思韵组所有数据 *)
let all_data = ping_sheng_data @ ze_sheng_data

(** 思韵组字符总数 *)
let char_count = List.length all_data

(** 按声韵类别统计字符数 *)
let stats_by_category = [
  (PingSheng, List.length ping_sheng_chars);
  (ZeSheng, List.length ze_sheng_chars);
]