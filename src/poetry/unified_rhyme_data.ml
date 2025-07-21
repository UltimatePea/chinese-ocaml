(** 韵律数据加载模块

    负责加载和管理韵律数据，将硬编码数据集中管理，便于维护和扩展。

    @author 骆言诗词编程团队
    @version 1.0
    @since 2025-07-19 - unified_rhyme_api.ml重构 *)

open Rhyme_types

(** {1 硬编码韵律数据} *)

(** 安韵组字符集 *)
let an_rhyme_chars =
  [
    "安";
    "干";
    "看";
    "山";
    "蓝";
    "难";
    "兰";
    "潘";
    "单";
    "残";
    "满";
    "寒";
    "管";
    "万";
    "半";
    "间";
    "关";
    "欢";
    "还";
    "班";
    "坛";
    "船";
    "全";
    "川";
    "天";
    "边";
    "便";
    "年";
    "前";
    "先";
  ]

(** 思韵组字符集 *)
let si_rhyme_chars =
  [
    "思";
    "丝";
    "时";
    "持";
    "支";
    "知";
    "之";
    "池";
    "痴";
    "迟";
    "辞";
    "词";
    "疑";
    "期";
    "奇";
    "棋";
    "骑";
    "基";
    "姿";
    "资";
    "慈";
    "雌";
    "师";
    "施";
    "诗";
    "治";
    "自";
    "子";
    "此";
    "止";
  ]

(** 天韵组字符集 *)
let tian_rhyme_chars =
  [
    "天";
    "仙";
    "先";
    "边";
    "连";
    "年";
    "眠";
    "田";
    "千";
    "前";
    "贤";
    "钱";
    "全";
    "川";
    "船";
    "烟";
    "然";
    "宣";
    "延";
    "玄";
    "便";
    "见";
    "软";
    "短";
    "院";
    "面";
    "变";
    "电";
    "线";
    "店";
  ]

(** 风韵组字符集 *)
let feng_rhyme_chars =
  [
    "风";
    "中";
    "空";
    "东";
    "红";
    "同";
    "通";
    "龙";
    "工";
    "公";
    "功";
    "弓";
    "共";
    "终";
    "钟";
    "重";
    "虫";
    "从";
    "丛";
    "冬";
    "冲";
    "充";
    "匆";
    "聪";
    "葱";
    "松";
    "宗";
    "综";
    "总";
    "纵";
  ]

(** 鱼韵组字符集 *)
let yu_rhyme_chars =
  [
    "鱼";
    "书";
    "余";
    "居";
    "如";
    "初";
    "虚";
    "除";
    "渠";
    "驱";
    "须";
    "输";
    "愚";
    "愉";
    "舒";
    "徐";
    "诸";
    "于";
    "予";
    "与";
    "雨";
    "语";
    "取";
    "去";
    "处";
    "据";
    "举";
    "拒";
    "巨";
    "聚";
  ]

(** 花韵组字符集 *)
let hua_rhyme_chars =
  [
    "花";
    "家";
    "华";
    "加";
    "嘉";
    "夸";
    "哗";
    "茶";
    "车";
    "查";
    "差";
    "叉";
    "纱";
    "沙";
    "杀";
    "刹";
    "剎";
    "霎";
    "察";
    "嚓";
    "瓜";
    "蛙";
    "洼";
    "娃";
    "挖";
    "瓦";
    "怕";
    "把";
    "巴";
    "爸";
  ]

(** 月韵组字符集 *)
let yue_rhyme_chars =
  [
    "月";
    "节";
    "设";
    "切";
    "热";
    "别";
    "裂";
    "灭";
    "雪";
    "血";
    "铁";
    "贴";
    "跌";
    "结";
    "洁";
    "列";
    "烈";
    "说";
    "悦";
    "越";
    "决";
    "绝";
    "掘";
    "觉";
    "学";
    "薛";
    "穴";
    "缺";
    "阙";
    "歇";
  ]

(** 江韵组字符集 *)
let jiang_rhyme_chars =
  [
    "江";
    "窗";
    "双";
    "桩";
    "庄";
    "装";
    "霜";
    "爽";
    "状";
    "闯";
    "创";
    "抢";
    "强";
    "墙";
    "枪";
    "狂";
    "忙";
    "茫";
    "芒";
    "郎";
    "浪";
    "娘";
    "良";
    "凉";
    "粮";
    "梁";
    "量";
    "响";
    "想";
    "象";
  ]

(** 会韵组字符集 *)
let hui_rhyme_chars =
  [
    "会";
    "对";
    "队";
    "内";
    "外";
    "退";
    "推";
    "回";
    "杯";
    "悔";
    "灰";
    "辉";
    "飞";
    "非";
    "肥";
    "菲";
    "妃";
    "姬";
    "机";
    "基";
    "鸡";
    "积";
    "激";
    "击";
    "及";
    "急";
    "级";
    "极";
    "集";
    "计";
  ]

(** {1 韵律数据配置} *)

(** 所有韵组数据配置 *)
let rhyme_groups_data =
  [
    (AnRhyme, PingSheng, an_rhyme_chars);
    (SiRhyme, PingSheng, si_rhyme_chars);
    (TianRhyme, PingSheng, tian_rhyme_chars);
    (FengRhyme, PingSheng, feng_rhyme_chars);
    (YuRhyme, PingSheng, yu_rhyme_chars);
    (HuaRhyme, ZeSheng, hua_rhyme_chars);
    (YueRhyme, ZeSheng, yue_rhyme_chars);
    (JiangRhyme, ZeSheng, jiang_rhyme_chars);
    (HuiRhyme, ZeSheng, hui_rhyme_chars);
  ]

(** {1 数据加载函数} *)

(** 加载韵律数据到缓存 *)
let load_rhyme_data_to_cache () =
  if not (Rhyme_cache.is_initialized ()) then (
    List.iter
      (fun (group, category, chars) ->
        (* 添加字符到缓存 *)
        List.iter (fun char -> Rhyme_cache.add_to_cache char category group) chars;
        (* 添加韵组字符集 *)
        Rhyme_cache.add_rhyme_group_chars group chars)
      rhyme_groups_data;

    Rhyme_cache.set_initialized true)

(** 获取指定韵组的字符集 *)
let get_rhyme_group_chars group =
  List.find_opt (fun (g, _, _) -> g = group) rhyme_groups_data
  |> Option.map (fun (_, _, chars) -> chars)

(** 获取所有韵组列表 *)
let get_all_rhyme_groups () =
  List.map (fun (group, category, _) -> (group, category)) rhyme_groups_data

(** 获取韵律数据统计信息 *)
let get_data_stats () =
  let total_chars =
    List.fold_left (fun acc (_, _, chars) -> acc + List.length chars) 0 rhyme_groups_data
  in
  let total_groups = List.length rhyme_groups_data in
  (total_chars, total_groups)
