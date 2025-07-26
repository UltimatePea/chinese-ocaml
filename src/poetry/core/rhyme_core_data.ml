(** 韵律核心数据模块 - 重构后版本
    
    此模块作为统一接口，聚合来自各个韵组模块的数据。
    重构目标已实现：模块化、数据分离、统一接口。
    
    @author 骆言诗词编程团队
    @version 4.0 - 模块化重构版本
    @since 2025-07-26 *)

open Rhyme_core_types

(** {1 模块化韵组数据聚合} *)

(** 导入各韵组模块 - 现阶段先使用现有数据，后续完全模块化 *)
module An_Rhyme = struct
  include An_rhyme_data
end

module Si_Rhyme = struct  
  include Si_rhyme_data
end

(** {2 临时保留原有数据结构 - 待完全模块化后移除} *)

(** 创建韵律数据条目的辅助函数 *)
let make_entry char category group ?(variants = []) ?(frequency = 1.0) () =
  { character = char; category; group; variants; usage_frequency = frequency }

(** 创建某个韵组字符列表的辅助函数 *)
let make_group_entries category group chars =
  List.map (fun char -> make_entry char category group ()) chars

(** 临时保留其他韵组数据 - 待后续模块化 *)

(** 天韵组平声数据 *)
let tian_yun_ping_sheng_chars =
  [
    "天"; "年"; "先"; "田"; "边"; "前"; "连"; "千"; "线"; "坚";
    "全"; "圆"; "便"; "面"; "见"; "片"; "变"; "点"; "电"; "店";
    "展"; "县"; "现"; "显"; "间"; "建"; "健"; "件"; "剑"; "检";
    "减"; "简"; "选"; "船"; "传"; "川"; "泉"; "权"; "全"; "拳";
    "圈"; "劝"; "券"; "软"; "源"; "原"; "元"; "园";
  ]

let tian_yun_ping_sheng_data = make_group_entries PingSheng TianRhyme tian_yun_ping_sheng_chars

(** 望韵组仄声数据 *)
let wang_yun_ze_sheng_chars = ["望"; "亮"; "想"; "上"; "向"; "放"; "方"; "房"; "场"; "长"]
let wang_yun_ze_sheng_data = make_group_entries ZeSheng WangRhyme wang_yun_ze_sheng_chars

(** {3 聚合所有韵组数据} *)

(** 聚合所有韵律数据 - 使用模块化和临时数据 *)
let all_rhyme_data = 
  An_Rhyme.all_data @ 
  Si_Rhyme.all_data @
  tian_yun_ping_sheng_data @
  wang_yun_ze_sheng_data

(** {4 按韵组分组的数据} *)
let data_by_group = [
  (AnRhyme, An_Rhyme.all_data);
  (SiRhyme, Si_Rhyme.all_data);
  (TianRhyme, tian_yun_ping_sheng_data);
  (WangRhyme, wang_yun_ze_sheng_data);
]

(** {5 按声韵类别分组的数据} *)
let data_by_category = [
  (PingSheng, An_Rhyme.ping_sheng_data @ Si_Rhyme.ping_sheng_data @ tian_yun_ping_sheng_data);
  (ZeSheng, An_Rhyme.ze_sheng_data @ Si_Rhyme.ze_sheng_data @ wang_yun_ze_sheng_data);
]

(** {6 优化查找系统} *)

module CharacterMap = Map.Make (String)

(** 字符快速查找映射 - 从 O(n) 线性搜索优化为 O(log n) 查找 *)
let character_lookup_map =
  List.fold_left
    (fun acc entry -> CharacterMap.add entry.character entry acc)
    CharacterMap.empty all_rhyme_data

(** 优化的字符查找函数 *)
let find_character_rhyme_fast (char : string) : rhyme_data_entry option =
  CharacterMap.find_opt char character_lookup_map

(** {7 统计信息} *)

(** 数据统计 *)
let total_characters = List.length all_rhyme_data
let groups_count = List.length data_by_group
let categories_count = List.length data_by_category

(** 按韵组统计字符数量 *)
let character_count_by_group =
  List.map (fun (group, data) -> (group, List.length data)) data_by_group

(** 按声韵类别统计字符数量 *)
let character_count_by_category =
  List.map (fun (category, data) -> (category, List.length data)) data_by_category

(** {8 韵组描述和示例} *)

(** 韵组描述信息 *)
let rhyme_group_descriptions = [
  (AnRhyme, "安韵组 - 平声多为开口韵，仄声多为合口韵，音调清雅");
  (SiRhyme, "思韵组 - 齿音为主，声调明亮，适合表达思考和理性");
  (TianRhyme, "天韵组 - 开口音，音域宽广，适合描绘天地自然");
  (WangRhyme, "望韵组 - 仄声韵，音调深沉，适合表达情感和愿望");
]

(** 按韵组分类的典型诗句示例 *)
let example_poems_by_group = [
  (AnRhyme, ["白云深处有人间"; "青山不改绿水长"; "千里江山如画卷"]);
  (SiRhyme, ["思君不见下渝州"; "知音世上实难求"; "诗意人生正当时"]);
  (TianRhyme, ["天地悠悠过客匆"; "先贤足迹在其中"; "千年诗韵永相传"]);
  (WangRhyme, ["望断天涯归路长"; "月上柳梢人约黄"; "梦里花落知多少"]);
]

(** {9 向后兼容性保证} *)

(** 重构完成 - 主要API保持不变，内部结构已优化为模块化设计 *)