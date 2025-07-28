(** 韵律数据模块 6-10 - 鱼、花、风、月、江韵组

    此模块包含第6-10个韵组的数据定义，从rhyme_data_builder.ml重构提取。 目标是减少单文件复杂度，提升模块化程度。

    Author: Alpha, 主要工作代理
    @version 1.0 - 模块化重构版本
    @since 2025-07-28 - Fix #1588 韵律数据构建器模块化重构计划 *)

open Rhyme_core_types

(** {1 韵律数据构建辅助函数} *)

(** 创建韵律数据条目的辅助函数 *)
let make_entry char category group ?(variants = []) ?(frequency = 1.0) () =
  { character = char; category; group; variants; usage_frequency = frequency }

(** 创建某个韵组字符列表的辅助函数 *)
let make_group_entries category group chars =
  List.map (fun char -> make_entry char category group ()) chars

(** {2 鱼韵组数据} *)

(** 鱼韵组数据 - 整合自 yu_rhyme_data.ml 和相关文件 *)
let yu_rhyme_data =
  let ping_sheng_chars =
    [
      "鱼";
      "书";
      "余";
      "居";
      "如";
      "初";
      "渠";
      "车";
      "花";
      "家";
      "华";
      "加";
      "嘉";
      "茶";
      "沙";
      "纱";
      "牙";
      "芽";
      "霞";
      "瓜";
      "蛙";
      "娃";
      "画";
      "话";
      "化";
      "划";
      "马";
      "下";
      "夏";
      "价";
      "架";
      "假";
      "货";
      "火";
      "果";
      "过";
    ]
  in
  {
    group_name = YuRhyme;
    group_description = "鱼韵组 - 含鱼、书、居等字，渔樵江渚";
    entries = make_group_entries PingSheng YuRhyme ping_sheng_chars;
    example_poems = [ "江南可采莲，莲叶何田田"; "青青河畔草，绵绵思远道"; "相见时难别亦难，东风无力百花残" ];
  }

(** {2 花韵组数据} *)

(** 花韵组数据 - 整合自 hua_rhyme_data.ml 和相关文件 *)
let hua_rhyme_data =
  let ping_sheng_chars =
    [
      "花";
      "华";
      "家";
      "加";
      "嘉";
      "茶";
      "沙";
      "纱";
      "牙";
      "芽";
      "霞";
      "瓜";
      "蛙";
      "娃";
      "画";
      "话";
      "化";
      "划";
      "马";
      "下";
      "夏";
      "价";
      "架";
      "假";
    ]
  in
  let ze_sheng_chars =
    [
      "化";
      "话";
      "画";
      "划";
      "价";
      "架";
      "假";
      "货";
      "火";
      "果";
      "过";
      "坐";
      "座";
      "作";
      "做";
      "破";
      "播";
      "课";
      "可";
      "河";
      "何";
      "哥";
      "歌";
      "多";
    ]
  in
  {
    group_name = HuaRhyme;
    group_description = "花韵组 - 含花、霞、家等字，春花秋月";
    entries =
      make_group_entries PingSheng HuaRhyme ping_sheng_chars
      @ make_group_entries ZeSheng HuaRhyme ze_sheng_chars;
    example_poems = [ "人面不知何处去，桃花依旧笑春风"; "花开堪折直须折，莫待无花空折枝"; "春色满园关不住，一枝红杏出墙来" ];
  }

(** {2 风韵组数据} *)

(** 风韵组数据 - 整合自 feng_rhyme_data.ml 和相关文件 *)
let feng_rhyme_data =
  let ping_sheng_chars =
    [
      "风";
      "中";
      "空";
      "东";
      "红";
      "虫";
      "冲";
      "从";
      "重";
      "宫";
      "公";
      "功";
      "工";
      "弓";
      "穷";
      "终";
      "钟";
      "雄";
      "熊";
      "充";
      "松";
      "送";
      "通";
      "同";
      "童";
      "桐";
      "铜";
      "朋";
      "蓬";
      "鹏";
      "陇";
      "隆";
      "龙";
      "浓";
      "农";
      "绒";
    ]
  in
  let ze_sheng_chars =
    [
      "送";
      "用";
      "动";
      "众";
      "重";
      "种";
      "总";
      "宗";
      "综";
      "纵";
      "从";
      "冲";
      "统";
      "痛";
      "通";
      "同";
      "童";
      "桐";
      "铜";
      "筒";
      "控";
      "空";
      "孔";
      "洞";
    ]
  in
  {
    group_name = FengRhyme;
    group_description = "风韵组 - 含风、送、中等字，秋风萧瑟";
    entries =
      make_group_entries PingSheng FengRhyme ping_sheng_chars
      @ make_group_entries ZeSheng FengRhyme ze_sheng_chars;
    example_poems = [ "大漠沙如雪，燕山月似钩"; "黄河之水天上来，奔流到海不复回"; "飞流直下三千尺，疑是银河落九天" ];
  }

(** {2 月韵组数据} *)

(** 月韵组数据 - 整合自 yue_rhyme_data.ml 和相关文件 *)
let yue_rhyme_data =
  let ze_sheng_chars =
    [
      "月";
      "雪";
      "节";
      "热";
      "切";
      "设";
      "说";
      "决";
      "绝";
      "血";
      "铁";
      "别";
      "列";
      "烈";
      "裂";
      "灭";
      "结";
      "洁";
      "接";
      "街";
      "解";
      "界";
      "借";
      "介";
      "戒";
      "届";
      "疥";
      "芥";
      "械";
      "懈";
      "谢";
      "楔";
      "泄";
      "屑";
      "咽";
      "噎";
    ]
  in
  {
    group_name = YueRhyme;
    group_description = "月韵组 - 含月、雪、节等字，秋月如霜";
    entries = make_group_entries ZeSheng YueRhyme ze_sheng_chars;
    example_poems = [ "明月几时有，把酒问青天"; "海上生明月，天涯共此时"; "月落乌啼霜满天，江枫渔火对愁眠" ];
  }

(** {2 江韵组数据} *)

(** 江韵组数据 - 整合自 jiang_rhyme_data.ml 和相关文件 *)
let jiang_rhyme_data =
  let ping_sheng_chars =
    [
      "江";
      "窗";
      "双";
      "霜";
      "创";
      "装";
      "藏";
      "浪";
      "郎";
      "狼";
      "廊";
      "朗";
      "忙";
      "茫";
      "忘";
      "芒";
      "亡";
      "王";
      "往";
      "网";
      "旺";
      "汪";
      "妄";
    ]
  in
  let ze_sheng_chars =
    [
      "唱";
      "创";
      "装";
      "藏";
      "浪";
      "郎";
      "狼";
      "廊";
      "朗";
      "忙";
      "茫";
      "忘";
      "芒";
      "亡";
      "王";
      "往";
      "网";
      "旺";
      "汪";
      "妄";
      "方";
      "房";
    ]
  in
  {
    group_name = JiangRhyme;
    group_description = "江韵组 - 含江、窗、双等字，大江东去";
    entries =
      make_group_entries PingSheng JiangRhyme ping_sheng_chars
      @ make_group_entries ZeSheng JiangRhyme ze_sheng_chars;
    example_poems = [ "孤帆远影碧空尽，唯见长江天际流"; "无边落木萧萧下，不尽长江滚滚来"; "朝辞白帝彩云间，千里江陵一日还" ];
  }
