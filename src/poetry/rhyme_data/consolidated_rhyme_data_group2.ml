(** 韵律数据整合模块组2 - Phase 1模块整合
    
    将原始的曲、王、辉、四韵组数据模块整合为统一的数据集合，
    这是Poetry模块整合Phase 1的第二个整合组。
    
    原整合目标:
    - qu_rhyme_data.ml → 整合到此模块
    - wang_rhyme_data.ml → 整合到此模块  
    - hui_rhyme_data.ml → 整合到此模块
    - si_rhyme_data.ml → 整合到此模块
    
    @author Whisky, Technical Implementation Agent
    @version 1.0 - Poetry模块整合Phase 1
    @since 2025-07-31
    @consolidation_target 4个模块 → 1个模块 *)

open Poetry_core.Rhyme_core_types
open Rhyme_data_core

(** {1 曲韵组数据} *)

(** 曲韵组平声字列表 *)
let qu_ping_sheng_chars =
  [
    "曲";
    "屈";
    "局";
    "竹";
    "足";
    "木";
    "目";
    "读";
    "独";
    "福";
    "复";
    "服";
    "卜";
    "谷";
    "肃";
    "族";
    "束";
    "续";
    "宿";
    "速";
  ]

(** 曲韵组仄声字列表 *)
let qu_ze_sheng_chars =
  [
    "触";
    "促";
    "副";
    "负";
    "雾";
    "路";
    "露";
    "度";
  ]

(** 曲韵组数据结构 *)
let qu_rhyme_group_data = {
  group_name = QuRhyme;
  group_description = "曲韵组 - 以'曲'字为代表的韵组，多为入声字";
  entries = List.map (fun char -> {
    character = char;
    category = PingSheng;
    group = QuRhyme;
    variants = [];
    usage_frequency = 1.0;
  }) qu_ping_sheng_chars @
  List.map (fun char -> {
    character = char;
    category = ZeSheng;
    group = QuRhyme;
    variants = [];
    usage_frequency = 1.0;
  }) qu_ze_sheng_chars;
  example_poems = [
    "曲径通幽处，禅房花木深";
    "独在异乡为异客";
  ];
}

(** {1 王韵组数据} *)

(** 王韵组平声字列表 *)
let wang_ping_sheng_chars =
  [
    "王";
    "央";
    "方";
    "房";
    "防";
    "芳";
    "香";
    "乡";
    "iang";
    "长";
    "场";
    "常";
    "堂";
    "当";
    "党";
    "装";
    "庄";
    "强";
    "墙";
    "黄";
  ]

(** 王韵组仄声字列表 *)
let wang_ze_sheng_chars =
  [
    "上";
    "往";
    "网";
    "望";
    "忘";
    "放";
    "访";
    "向";
  ]

(** 王韵组数据结构 *)
let wang_rhyme_group_data = {
  group_name = WangRhyme;
  group_description = "王韵组 - 以'王'字为代表的韵组，阳声韵母";
  entries = List.map (fun char -> {
    character = char;
    category = PingSheng;
    group = WangRhyme;
    variants = [];
    usage_frequency = 1.0;
  }) wang_ping_sheng_chars @
  List.map (fun char -> {
    character = char;
    category = ZeSheng;
    group = WangRhyme;
    variants = [];
    usage_frequency = 1.0;
  }) wang_ze_sheng_chars;
  example_poems = [
    "黄河远上白云间";
    "王师北定中原日";
  ];
}

(** {1 辉韵组数据} *)

(** 辉韵组平声字列表 *)
let hui_ping_sheng_chars =
  [
    "辉";
    "回";
    "灰";
    "杯";
    "陪";
    "培";
    "梅";
    "媒";
    "煤";
    "雷";
    "堆";
    "推";
    "摧";
    "催";
    "追";
    "锤";
    "垂";
    "吹";
    "炊";
    "眉";
  ]

(** 辉韵组仄声字列表 *)
let hui_ze_sheng_chars =
  [
    "悔";
    "内";
    "罪";
    "醉";
    "退";
    "类";
    "泪";
    "碎";
  ]

(** 辉韵组数据结构 *)
let hui_rhyme_group_data = {
  group_name = HuiRhyme;
  group_description = "辉韵组 - 以'辉'字为代表的韵组，韵母为-ui";
  entries = List.map (fun char -> {
    character = char;
    category = PingSheng;
    group = HuiRhyme;
    variants = [];
    usage_frequency = 1.0;
  }) hui_ping_sheng_chars @
  List.map (fun char -> {
    character = char;
    category = ZeSheng;
    group = HuiRhyme;
    variants = [];
    usage_frequency = 1.0;
  }) hui_ze_sheng_chars;
  example_poems = [
    "日照香炉生紫烟";
    "相看两不厌，只有敬亭山";
  ];
}

(** {1 四韵组数据} *)

(** 四韵组平声字列表 *)
let si_ping_sheng_chars =
  [
    "四";
    "字";
    "寺";
    "似";
    "次";
    "此";
    "市";
    "试";
    "史";
    "使";
    "是";
    "事";
    "示";
    "视";
    "识";
    "志";
    "致";
    "治";
    "智";
    "制";
  ]

(** 四韵组仄声字列表 *)  
let si_ze_sheng_chars =
  [
    "意";
    "议";
    "义";
    "艺";
    "异";
    "易";
    "益";
    "忆";
  ]

(** 四韵组数据结构 *)
let si_rhyme_group_data = {
  group_name = SiRhyme;
  group_description = "四韵组 - 以'四'字为代表的韵组，去声字居多";
  entries = List.map (fun char -> {
    character = char;
    category = PingSheng;
    group = SiRhyme;
    variants = [];
    usage_frequency = 1.0;
  }) si_ping_sheng_chars @
  List.map (fun char -> {
    character = char;
    category = ZeSheng;
    group = SiRhyme;
    variants = [];
    usage_frequency = 1.0;
  }) si_ze_sheng_chars;
  example_poems = [
    "问渠那得清如许，为有源头活水来";
    "知否？知否？应是绿肥红瘦";
  ];
}

(** {1 统一数据访问接口} *)

(** 获取所有第二组整合的韵组数据 *)
let get_all_consolidated_rhyme_groups_2 () =
  [
    qu_rhyme_group_data;
    wang_rhyme_group_data;
    hui_rhyme_group_data;
    si_rhyme_group_data;
  ]

(** 根据韵组名称获取韵组数据 *)
let get_rhyme_group_by_name_2 = function
  | QuRhyme -> Some qu_rhyme_group_data
  | WangRhyme -> Some wang_rhyme_group_data
  | HuiRhyme -> Some hui_rhyme_group_data
  | SiRhyme -> Some si_rhyme_group_data
  | _ -> None

(** 获取指定韵组的所有字符 *)
let get_chars_by_rhyme_group_2 rhyme_group =
  match get_rhyme_group_by_name_2 rhyme_group with
  | Some group_data -> 
    List.map (fun entry -> entry.character) group_data.entries
  | None -> []

(** 检查字符是否属于第二组整合的韵组 *)
let is_char_in_consolidated_groups_2 char =
  let all_groups = get_all_consolidated_rhyme_groups_2 () in
  List.exists (fun group ->
    List.exists (fun entry -> 
      String.equal entry.character char
    ) group.entries
  ) all_groups

(** 获取字符所属的韵组 *)
let get_rhyme_group_for_char_2 char =
  let all_groups = get_all_consolidated_rhyme_groups_2 () in
  List.find_opt (fun group ->
    List.exists (fun entry -> 
      String.equal entry.character char
    ) group.entries
  ) all_groups