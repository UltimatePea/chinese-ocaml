(** 韵律组注册中心 - 骆言诗词编程特性

    该模块整合所有韵律组数据，提供统一的访问接口。 替代 rhyme_core_data_original.ml 的大文件结构。

    @author Beta, 代码审查代理
    @version 1.0 - 模块化重构版本
    @since 2025-07-27 *)

open Poetry_core.Rhyme_core_types

(** {1 韵律组模块集成} *)

(** 所有韵律数据的统一集合 *)
let all_rhyme_data =
  Rhyme_group_an.all_data @ Rhyme_group_si.all_data @ Rhyme_group_tian.all_data
  @ Rhyme_group_wang.all_data @ Rhyme_group_qu.all_data @ Rhyme_group_yu.all_data
  @ Rhyme_group_hua.all_data @ Rhyme_group_feng.all_data @ Rhyme_group_yue.all_data
  @ Rhyme_group_jiang.all_data @ Rhyme_group_hui.all_data

(** 按韵组分类的数据 *)
let data_by_group =
  [
    (AnRhyme, Rhyme_group_an.all_data);
    (SiRhyme, Rhyme_group_si.all_data);
    (TianRhyme, Rhyme_group_tian.all_data);
    (WangRhyme, Rhyme_group_wang.all_data);
    (QuRhyme, Rhyme_group_qu.all_data);
    (YuRhyme, Rhyme_group_yu.all_data);
    (HuaRhyme, Rhyme_group_hua.all_data);
    (FengRhyme, Rhyme_group_feng.all_data);
    (YueRhyme, Rhyme_group_yue.all_data);
    (JiangRhyme, Rhyme_group_jiang.all_data);
    (HuiRhyme, Rhyme_group_hui.all_data);
  ]

(** 按声韵类别分类的数据 *)
let data_by_category =
  let ping_sheng_data =
    Rhyme_group_an.ping_sheng_data @ Rhyme_group_si.ping_sheng_data
    @ Rhyme_group_tian.ping_sheng_data @ Rhyme_group_yu.ping_sheng_data
    @ Rhyme_group_hua.ping_sheng_data @ Rhyme_group_feng.ping_sheng_data
    @ Rhyme_group_jiang.ping_sheng_data
  in
  let ze_sheng_data =
    Rhyme_group_an.ze_sheng_data @ Rhyme_group_si.ze_sheng_data @ Rhyme_group_wang.ze_sheng_data
    @ Rhyme_group_yue.ze_sheng_data @ Rhyme_group_hui.ze_sheng_data
  in
  let qu_sheng_data = Rhyme_group_qu.qu_sheng_data in
  [ (PingSheng, ping_sheng_data); (ZeSheng, ze_sheng_data); (QuSheng, qu_sheng_data) ]

(** {2 韵组描述数据} *)

(** 韵组描述信息 *)
let rhyme_group_descriptions =
  [
    (AnRhyme, "安韵组 - 含山、间、闲等字，音韵和谐");
    (SiRhyme, "思韵组 - 含时、诗、知等字，情思绵绵");
    (TianRhyme, "天韵组 - 含年、先、田等字，天籁之音");
    (WangRhyme, "望韵组 - 含放、向、响等字，远望之意");
    (QuRhyme, "去韵组 - 含路、度、步等字，去声之韵");
    (YuRhyme, "鱼韵组 - 含鱼、书、居等字，渔樵江渚");
    (HuaRhyme, "花韵组 - 含花、霞、家等字，春花秋月");
    (FengRhyme, "风韵组 - 含风、送、中等字，秋风萧瑟");
    (YueRhyme, "月韵组 - 含月、雪、节等字，秋月如霜");
    (JiangRhyme, "江韵组 - 含江、窗、双等字，大江东去");
    (HuiRhyme, "灰韵组 - 含灰、回、推等字，灰飞烟灭");
  ]

(** {3 统计分析} *)

(** 按韵组统计字符数量 *)
let char_count_by_group =
  [
    (AnRhyme, Rhyme_group_an.char_count);
    (SiRhyme, Rhyme_group_si.char_count);
    (TianRhyme, Rhyme_group_tian.char_count);
    (WangRhyme, Rhyme_group_wang.char_count);
    (QuRhyme, Rhyme_group_qu.char_count);
    (YuRhyme, Rhyme_group_yu.char_count);
    (HuaRhyme, Rhyme_group_hua.char_count);
    (FengRhyme, Rhyme_group_feng.char_count);
    (YueRhyme, Rhyme_group_yue.char_count);
    (JiangRhyme, Rhyme_group_jiang.char_count);
    (HuiRhyme, Rhyme_group_hui.char_count);
  ]

(** 按声韵类别统计字符数量 *)
let char_count_by_category =
  let ping_count =
    List.fold_left ( + ) 0
      [
        List.length Rhyme_group_an.ping_sheng_chars;
        List.length Rhyme_group_si.ping_sheng_chars;
        List.length Rhyme_group_tian.ping_sheng_chars;
        List.length Rhyme_group_yu.ping_sheng_chars;
        List.length Rhyme_group_hua.ping_sheng_chars;
        List.length Rhyme_group_feng.ping_sheng_chars;
        List.length Rhyme_group_jiang.ping_sheng_chars;
      ]
  in
  let ze_count =
    List.fold_left ( + ) 0
      [
        List.length Rhyme_group_an.ze_sheng_chars;
        List.length Rhyme_group_si.ze_sheng_chars;
        List.length Rhyme_group_wang.ze_sheng_chars;
        List.length Rhyme_group_yue.ze_sheng_chars;
        List.length Rhyme_group_hui.ze_sheng_chars;
      ]
  in
  let qu_count = List.length Rhyme_group_qu.qu_sheng_chars in
  [ (PingSheng, ping_count); (ZeSheng, ze_count); (QuSheng, qu_count) ]

(** 总字符数 *)
let total_char_count = List.length all_rhyme_data

(** 韵组总数 *)
let total_group_count = List.length char_count_by_group
