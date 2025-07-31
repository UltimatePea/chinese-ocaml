(** 韵律数据整合模块组1 - Phase 1模块整合
    
    将原始的天、月、风、花韵组数据模块整合为统一的数据集合，
    减少模块数量，提高维护效率，保持功能完整性。
    
    原整合目标:
    - tian_rhyme_data.ml → 整合到此模块
    - yue_rhyme_data.ml → 整合到此模块  
    - feng_rhyme_data.ml → 整合到此模块
    - hua_rhyme_data.ml → 整合到此模块
    
    @author Whisky, Technical Implementation Agent
    @version 1.0 - Poetry模块整合Phase 1
    @since 2025-07-31
    @consolidation_target 4个模块 → 1个模块 *)

open Poetry_core.Rhyme_core_types
open Rhyme_data_core

(** {1 天韵组数据} *)

(** 天韵组平声字列表 *)
let tian_ping_sheng_chars =
  [
    "天";
    "年";
    "先";
    "千";
    "前";
    "边";
    "田";
    "川";
    "全";
    "然";
    "连";
    "延";
    "鲜";
    "船";
    "传";
    "篇";
    "便";
    "县";
    "面";
    "见";
  ]

(** 天韵组仄声字列表 *)
let tian_ze_sheng_chars =
  [
    "变";
    "片";
    "点";
    "面";
    "件";
    "电";
    "现";
    "线";
    "店";
    "典";
  ]

(** 天韵组数据结构 *)
let tian_rhyme_group_data = {
  group_name = TianRhyme;
  group_description = "天韵组 - 以'天'字为代表的韵组，包含平声和仄声字";
  entries = List.map (fun char -> {
    character = char;
    category = PingSheng;
    group = TianRhyme;
    variants = [];
    usage_frequency = 1.0;
  }) tian_ping_sheng_chars @
  List.map (fun char -> {
    character = char;
    category = ZeSheng;
    group = TianRhyme;
    variants = [];
    usage_frequency = 1.0;
  }) tian_ze_sheng_chars;
  example_poems = [
    "天高云淡，望断南飞雁";
    "千里莺啼绿映红";
  ];
}

(** {1 月韵组数据} *)

(** 月韵组平声字列表 *)
let yue_ping_sheng_chars =
  [
    "月";
    "越";
    "说";
    "雪";
    "节";
    "别";
    "切";
    "热";
    "设";
    "结";
    "列";
    "血";
    "铁";
    "页";
    "叶";
  ]

(** 月韵组仄声字列表 *)
let yue_ze_sheng_chars =
  [
    "绝";
    "决";
    "洁";
    "截";
    "杰";
    "彻";
    "竭";
    "接";
  ]

(** 月韵组数据结构 *)
let yue_rhyme_group_data = {
  group_name = YueRhyme;
  group_description = "月韵组 - 以'月'字为代表的韵组，主要收录入声字";
  entries = List.map (fun char -> {
    character = char;
    category = PingSheng;
    group = YueRhyme;
    variants = [];
    usage_frequency = 1.0;
  }) yue_ping_sheng_chars @
  List.map (fun char -> {
    character = char;
    category = ZeSheng;
    group = YueRhyme;
    variants = [];
    usage_frequency = 1.0;
  }) yue_ze_sheng_chars;
  example_poems = [
    "明月松间照，清泉石上流";
    "但愿人长久，千里共婵娟";
  ];
}

(** {1 风韵组数据} *)

(** 风韵组平声字列表 *)
let feng_ping_sheng_chars =
  [
    "风";
    "东";
    "中";
    "空";
    "公";
    "工";
    "红";
    "通";
    "同";
    "终";
    "冲";
    "虫";
    "丰";
    "雄";
    "弓";
    "攻";
    "功";
    "穷";
    "蒙";
    "龙";
  ]

(** 风韵组仄声字列表 *)
let feng_ze_sheng_chars =
  [
    "动";
    "众";
    "重";
    "用";
    "梦";
    "送";
    "中";
    "痛";
  ]

(** 风韵组数据结构 *)
let feng_rhyme_group_data = {
  group_name = FengRhyme;
  group_description = "风韵组 - 以'风'字为代表的韵组，多见于豪放诗词";
  entries = List.map (fun char -> {
    character = char;
    category = PingSheng;
    group = FengRhyme;
    variants = [];
    usage_frequency = 1.0;
  }) feng_ping_sheng_chars @
  List.map (fun char -> {
    character = char;
    category = ZeSheng;
    group = FengRhyme;
    variants = [];
    usage_frequency = 1.0;
  }) feng_ze_sheng_chars;
  example_poems = [
    "大江东去，浪淘尽";
    "千里快哉风";
  ];
}

(** {1 花韵组数据} *)

(** 花韵组平声字列表 *)
let hua_ping_sheng_chars =
  [
    "花";
    "家";
    "茶";
    "纱";
    "沙";
    "霞";
    "华";
    "夸";
    "瓜";
    "娃";
    "蛙";
    "哇";
    "车";
    "奢";
    "赊";
    "斜";
    "邪";
    "嘉";
    "加";
    "佳";
  ]

(** 花韵组仄声字列表 *)
let hua_ze_sheng_chars =
  [
    "下";
    "马";
    "打";
    "话";
    "画";
    "化";
    "雅";
    "假";
  ]

(** 花韵组数据结构 *)
let hua_rhyme_group_data = {
  group_name = HuaRhyme;
  group_description = "花韵组 - 以'花'字为代表的韵组，常用于抒情诗词";
  entries = List.map (fun char -> {
    character = char;
    category = PingSheng;
    group = HuaRhyme;
    variants = [];
    usage_frequency = 1.0;
  }) hua_ping_sheng_chars @
  List.map (fun char -> {
    character = char;
    category = ZeSheng;
    group = HuaRhyme;
    variants = [];
    usage_frequency = 1.0;
  }) hua_ze_sheng_chars;
  example_poems = [
    "落红不是无情物，化作春泥更护花";
    "人面桃花相映红";
  ];
}

(** {1 统一数据访问接口} *)

(** 获取所有整合的韵组数据 *)
let get_all_consolidated_rhyme_groups_1 () =
  [
    tian_rhyme_group_data;
    yue_rhyme_group_data;
    feng_rhyme_group_data;
    hua_rhyme_group_data;
  ]

(** 根据韵组名称获取韵组数据 *)
let get_rhyme_group_by_name = function
  | TianRhyme -> Some tian_rhyme_group_data
  | YueRhyme -> Some yue_rhyme_group_data
  | FengRhyme -> Some feng_rhyme_group_data
  | HuaRhyme -> Some hua_rhyme_group_data
  | _ -> None

(** 获取指定韵组的所有字符 *)
let get_chars_by_rhyme_group rhyme_group =
  match get_rhyme_group_by_name rhyme_group with
  | Some group_data -> 
    List.map (fun entry -> entry.character) group_data.entries
  | None -> []

(** 检查字符是否属于整合的韵组 *)
let is_char_in_consolidated_groups char =
  let all_groups = get_all_consolidated_rhyme_groups_1 () in
  List.exists (fun group ->
    List.exists (fun entry -> 
      String.equal entry.character char
    ) group.entries
  ) all_groups

(** 获取字符所属的韵组 *)
let get_rhyme_group_for_char char =
  let all_groups = get_all_consolidated_rhyme_groups_1 () in
  List.find_opt (fun group ->
    List.exists (fun entry -> 
      String.equal entry.character char
    ) group.entries
  ) all_groups