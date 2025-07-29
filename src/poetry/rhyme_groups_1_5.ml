(** 韵律数据模块 1-5 - 安、思、天、王、曲韵组

    此模块包含前5个韵组的数据定义，从rhyme_data_builder.ml重构提取。 目标是减少单文件复杂度，提升模块化程度。

    Author: Alpha, 主要工作代理
    @version 1.0 - 模块化重构版本
    @since 2025-07-28 - Fix #1588 韵律数据构建器模块化重构计划 *)

open Rhyme_core_types
open Rhyme_group_helpers

(** {2 安韵组数据} *)

(** 安韵组数据 - 整合自 an_rhyme_data.ml 和相关文件 *)
let an_rhyme_data =
  let ping_sheng_chars =
    [
      "山";
      "间";
      "闲";
      "关";
      "还";
      "班";
      "颜";
      "安";
      "删";
      "蛮";
      "环";
      "弯";
      "天";
      "年";
      "先";
      "边";
      "前";
      "连";
      "千";
      "线";
      "坚";
      "全";
      "圆";
      "便";
      "面";
      "见";
      "片";
      "编";
      "眠";
      "蟾";
      "贤";
      "田";
      "填";
      "肩";
      "坚";
    ]
  in
  let ze_sheng_chars =
    [
      "看";
      "叹";
      "散";
      "慢";
      "管";
      "段";
      "短";
      "断";
      "半";
      "满";
      "汗";
      "寒";
      "卷";
      "算";
      "乱";
      "暖";
      "换";
      "幻";
      "善";
      "骗";
      "转";
      "软";
      "选";
    ]
  in
  {
    group_name = AnRhyme;
    group_description = "安韵组 - 含山、间、闲等字，音韵和谐";
    entries =
      make_group_entries PingSheng AnRhyme ping_sheng_chars
      @ make_group_entries ZeSheng AnRhyme ze_sheng_chars;
    example_poems = [ "山不在高，有仙则名"; "千山鸟飞绝，万径人踪灭"; "青山横北郭，白水绕东城" ];
  }

(** {2 思韵组数据} *)

(** 思韵组数据 - 整合自 si_rhyme_data.ml 和相关文件 *)
let si_rhyme_data =
  let ping_sheng_chars =
    [
      "思";
      "丝";
      "时";
      "持";
      "支";
      "春";
      "人";
      "真";
      "因";
      "新";
      "心";
      "深";
      "林";
      "金";
      "寻";
      "音";
      "吟";
      "今";
      "临";
      "琴";
      "禁";
      "森";
      "参";
      "淋";
      "任";
      "沈";
      "阴";
      "侵";
      "针";
      "怀";
      "来";
      "开";
      "台";
      "回";
      "才";
      "材";
    ]
  in
  let ze_sheng_chars =
    [
      "是";
      "此";
      "里";
      "子";
      "止";
      "起";
      "已";
      "士";
      "市";
      "史";
      "死";
      "使";
      "始";
      "似";
      "致";
      "至";
      "治";
      "智";
      "志";
      "字";
      "次";
      "事";
      "诗";
      "师";
    ]
  in
  {
    group_name = SiRhyme;
    group_description = "思韵组 - 含时、诗、知等字，情思绵绵";
    entries =
      make_group_entries PingSheng SiRhyme ping_sheng_chars
      @ make_group_entries ZeSheng SiRhyme ze_sheng_chars;
    example_poems = [ "月下飞天镜，云生结海楼"; "春眠不觉晓，处处闻啼鸟"; "举头望明月，低头思故乡" ];
  }

(** {2 天韵组数据} *)

(** 天韵组数据 - 整合自 tian_rhyme_data.ml 和相关文件 *)
let tian_rhyme_data =
  let ping_sheng_chars =
    [
      "天";
      "年";
      "先";
      "田";
      "边";
      "前";
      "连";
      "千";
      "线";
      "坚";
      "全";
      "圆";
      "便";
      "面";
      "见";
      "片";
      "编";
      "眠";
      "蟾";
      "贤";
      "填";
      "肩";
      "传";
      "船";
      "川";
      "泉";
      "弦";
      "烟";
      "燕";
      "县";
      "仙";
      "鲜";
      "绵";
      "延";
      "颠";
      "牵";
    ]
  in
  let ze_sheng_chars =
    [
      "变";
      "电";
      "片";
      "店";
      "点";
      "念";
      "见";
      "现";
      "线";
      "显";
      "典";
      "殿";
      "遍";
      "便";
      "面";
      "箭";
      "剑";
      "件";
      "建";
      "健";
      "键";
      "练";
      "炼";
      "链";
    ]
  in
  {
    group_name = TianRhyme;
    group_description = "天韵组 - 含年、先、田等字，天籁之音";
    entries =
      make_group_entries PingSheng TianRhyme ping_sheng_chars
      @ make_group_entries ZeSheng TianRhyme ze_sheng_chars;
    example_poems = [ "天生我材必有用，千金散尽还复来"; "春花秋月何时了，往事知多少"; "床前明月光，疑是地上霜" ];
  }

(** {2 王韵组数据} *)

(** 望韵组数据 - 整合自 wang_rhyme_data.ml 和相关文件 *)
let wang_rhyme_data =
  let ze_sheng_chars =
    [
      "望";
      "放";
      "向";
      "响";
      "亮";
      "唱";
      "忘";
      "想";
      "上";
      "当";
      "长";
      "张";
      "房";
      "方";
      "旁";
      "傍";
      "堂";
      "塘";
      "墙";
      "强";
      "光";
      "广";
      "网";
      "状";
      "样";
      "量";
      "场";
      "常";
      "床";
      "窗";
      "双";
      "霜";
      "创";
      "装";
      "藏";
      "浪";
    ]
  in
  {
    group_name = WangRhyme;
    group_description = "望韵组 - 含放、向、响等字，远望之意";
    entries = make_group_entries ZeSheng WangRhyme ze_sheng_chars;
    example_poems = [ "西塞山前白鹭飞，桃花流水鳜鱼肥"; "两个黄鹂鸣翠柳，一行白鹭上青天"; "窗含西岭千秋雪，门泊东吴万里船" ];
  }

(** {2 曲韵组数据} *)

(** 去韵组数据 - 整合自 qu_rhyme_data.ml 和相关文件 *)
let qu_rhyme_data =
  let ze_sheng_chars =
    [
      "去";
      "路";
      "度";
      "步";
      "府";
      "故";
      "住";
      "处";
      "数";
      "素";
      "布";
      "户";
      "古";
      "土";
      "苦";
      "库";
      "护";
      "互";
      "注";
      "助";
      "著";
      "部";
      "图";
      "途";
      "树";
      "书";
      "鼠";
      "暑";
      "绪";
      "序";
      "叙";
      "述";
      "术";
      "束";
      "属";
      "竹";
    ]
  in
  {
    group_name = QuRhyme;
    group_description = "去韵组 - 含路、度、步等字，去声之韵";
    entries = make_group_entries ZeSheng QuRhyme ze_sheng_chars;
    example_poems = [ "国破山河在，城春草木深"; "好雨知时节，当春乃发生"; "黄河远上白云间，一片孤城万仞山" ];
  }
