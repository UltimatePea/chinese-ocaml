(** 韵律数据整合模块组3 - Phase 1模块整合
    
    将原始的余、江、安韵组数据模块整合为统一的数据集合，
    这是Poetry模块整合Phase 1的第三个整合组，完成剩余韵组的整合。
    
    原整合目标:
    - yu_rhyme_data.ml → 整合到此模块
    - jiang_rhyme_data.ml → 整合到此模块  
    - an_rhyme_data.ml → 整合到此模块
    
    @author Whisky, Technical Implementation Agent
    @version 1.0 - Poetry模块整合Phase 1
    @since 2025-07-31
    @consolidation_target 3个模块 → 1个模块 *)

open Poetry_core.Rhyme_core_types
open Rhyme_data_core

(** {1 余韵组数据} *)

(** 余韵组平声字列表 *)
let yu_ping_sheng_chars =
  [
    "余";
    "鱼";
    "书";
    "如";
    "居";
    "渠";
    "舒";
    "初";
    "除";
    "虚";
    "需";
    "须";
    "诸";
    "朱";
    "珠";
    "株";
    "猪";
    "驻";
    "储";
    "厨";
  ]

(** 余韵组仄声字列表 *)
let yu_ze_sheng_chars =
  [
    "语";
    "雨";
    "与";
    "举";
    "许";
    "处";
    "序";
    "绪";
  ]

(** 余韵组数据结构 *)
let yu_rhyme_group_data = {
  group_name = YuRhyme;
  group_description = "余韵组 - 以'余'字为代表的韵组，韵母为-u";
  entries = List.map (fun char -> {
    character = char;
    category = PingSheng;
    group = YuRhyme;
    variants = [];
    usage_frequency = 1.0;
  }) yu_ping_sheng_chars @
  List.map (fun char -> {
    character = char;
    category = ZeSheng;
    group = YuRhyme;
    variants = [];
    usage_frequency = 1.0;
  }) yu_ze_sheng_chars;
  example_poems = [
    "山重水复疑无路，柳暗花明又一村";
    "独钓寒江雪";
  ];
}

(** {1 江韵组数据} *)

(** 江韵组平声字列表 *)
let jiang_ping_sheng_chars =
  [
    "江";
    "降";
    "双";
    "庞";
    "窗";
    "撞";
    "桩";
    "创";
    "霜";
    "孀";
    "爽";
    "鸣";
    "绑";
    "帮";
    "邦";
    "傍";
    "旁";
    "芒";
    "忙";
    "茫";
  ]

(** 江韵组仄声字列表 *)
let jiang_ze_sheng_chars =
  [
    "讲";
    "响";
    "想";
    "象";
    "像";
    "向";
    "亮";
    "量";
  ]

(** 江韵组数据结构 *)
let jiang_rhyme_group_data = {
  group_name = JiangRhyme;
  group_description = "江韵组 - 以'江'字为代表的韵组，阳声韵母-ang";
  entries = List.map (fun char -> {
    character = char;
    category = PingSheng;
    group = JiangRhyme;
    variants = [];
    usage_frequency = 1.0;
  }) jiang_ping_sheng_chars @
  List.map (fun char -> {
    character = char;
    category = ZeSheng;
    group = JiangRhyme;
    variants = [];
    usage_frequency = 1.0;
  }) jiang_ze_sheng_chars;
  example_poems = [
    "大江东去，浪淘尽，千古风流人物";
    "孤帆远影碧空尽，唯见长江天际流";
  ];
}

(** {1 安韵组数据} *)

(** 安韵组平声字列表 *)
let an_ping_sheng_chars =
  [
    "安";
    "山";
    "间";
    "闲";
    "关";
    "还";
    "环";
    "圆";
    "园";
    "元";
    "原";
    "源";
    "言";
    "研";
    "延";
    "严";
    "岩";
    "盐";
    "炎";
    "然";
  ]

(** 安韵组仄声字列表 *)
let an_ze_sheng_chars =
  [
    "短";
    "断";
    "满";
    "算";
    "乱";
    "看";
    "难";
    "半";
  ]

(** 安韵组数据结构 *)
let an_rhyme_group_data = {
  group_name = AnRhyme;
  group_description = "安韵组 - 以'安'字为代表的韵组，韵母为-an";
  entries = List.map (fun char -> {
    character = char;
    category = PingSheng;
    group = AnRhyme;
    variants = [];
    usage_frequency = 1.0;
  }) an_ping_sheng_chars @
  List.map (fun char -> {
    character = char;
    category = ZeSheng;
    group = AnRhyme;
    variants = [];
    usage_frequency = 1.0;
  }) an_ze_sheng_chars;
  example_poems = [
    "会当凌绝顶，一览众山小";
    "春眠不觉晓，处处闻啼鸟";
  ];
}

(** {1 统一数据访问接口} *)

(** 获取所有第三组整合的韵组数据 *)
let get_all_consolidated_rhyme_groups_3 () =
  [
    yu_rhyme_group_data;
    jiang_rhyme_group_data;
    an_rhyme_group_data;
  ]

(** 根据韵组名称获取韵组数据 *)
let get_rhyme_group_by_name_3 = function
  | YuRhyme -> Some yu_rhyme_group_data
  | JiangRhyme -> Some jiang_rhyme_group_data
  | AnRhyme -> Some an_rhyme_group_data
  | _ -> None

(** 获取指定韵组的所有字符 *)
let get_chars_by_rhyme_group_3 rhyme_group =
  match get_rhyme_group_by_name_3 rhyme_group with
  | Some group_data -> 
    List.map (fun entry -> entry.character) group_data.entries
  | None -> []

(** 检查字符是否属于第三组整合的韵组 *)
let is_char_in_consolidated_groups_3 char =
  let all_groups = get_all_consolidated_rhyme_groups_3 () in
  List.exists (fun group ->
    List.exists (fun entry -> 
      String.equal entry.character char
    ) group.entries
  ) all_groups

(** 获取字符所属的韵组 *)
let get_rhyme_group_for_char_3 char =
  let all_groups = get_all_consolidated_rhyme_groups_3 () in
  List.find_opt (fun group ->
    List.exists (fun entry -> 
      String.equal entry.character char
    ) group.entries
  ) all_groups