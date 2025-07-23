(** 音韵数据存储模块 - 骆言诗词编程特性

    盖古之诗者，音韵为要。此模块统一管理音韵数据， 引用分离后的数据模块，架构清晰便于维护。 依《广韵》、《集韵》等韵书传统，模块化管理。

    重构说明：将大型数据列表分离为独立模块， 提升代码可维护性和模块化程度。

    @author 骆言诗词编程团队
    @version 2.0 (重构版)
    @since 2025-07-18 *)

open Rhyme_types
open Rhyme_helpers

(** {1 音韵数据统一接口} *)

module An_yun = Poetry_data.An_yun_data
(** 引入分离后的数据模块 *)

module Expanded_rhyme = Poetry_data.Expanded_rhyme_data
(** 引入扩展音韵数据模块 - Phase 1 Enhancement *)

(** {2 平声韵数据 - 重构后接口} *)

(** 安韵组数据 - 从独立模块引入，140行数据拆分为独立文件 *)
let an_yun_ping_sheng =
  List.map (fun (char, _, _) -> (char, PingSheng, AnRhyme)) An_yun.an_yun_ping_sheng

(** 思韵组 - 诗时知思，情思绵绵如春水 *)

(** 思韵数据模块化重构 - 按语音特征分组 *)
module Si_yun_data = struct
  (** 基础诗词用韵 - 诗时知思程成清等 *)
  let poetry_core_chars = make_ping_sheng_group SiRhyme [ "诗"; "时"; "知"; "思"; "程"; "成"; "清" ]

  (** 东韵系列 - 同中东冬终钟等 *)
  let dong_rhyme_group = make_ping_sheng_group SiRhyme [ "同"; "中"; "东"; "冬"; "终"; "钟"; "种"; "重" ]

  (** 冲韵系列 - 冲虫崇聪等 *)
  let chong_rhyme_group =
    make_ping_sheng_group SiRhyme [ "充"; "冲"; "虫"; "崇"; "匆"; "从"; "丛"; "聪"; "葱"; "囱" ]

  (** 松韵系列 - 松嵩送宋等 *)
  let song_rhyme_group =
    make_ping_sheng_group SiRhyme [ "松"; "嵩"; "送"; "宋"; "颂"; "诵"; "耸"; "怂"; "悚" ]

  (** 肃韵系列 - 粟肃宿素速等 *)
  let su_rhyme_group =
    make_ping_sheng_group SiRhyme [ "粟"; "肃"; "宿"; "素"; "速"; "塑"; "诉"; "溯"; "蔌"; "夙"; "俗" ]

  (** 古韵系列 - 谷鼓古故固等 *)
  let gu_rhyme_group =
    make_ping_sheng_group SiRhyme
      [ "谷"; "鼓"; "古"; "故"; "固"; "顾"; "雇"; "股"; "骨"; "姑"; "孤"; "辜"; "菇"; "枯" ]

  (** 苦韵系列 - 哭库裤酷窟苦等 *)
  let ku_rhyme_group = make_ping_sheng_group SiRhyme [ "哭"; "库"; "裤"; "酷"; "窟"; "苦" ]

  (** 毒韵系列 - 堵赌毒独读督都等 *)
  let du_rhyme_group = make_ping_sheng_group SiRhyme [ "堵"; "赌"; "毒"; "独"; "读"; "督"; "都" ]

  (** 斗韵系列 - 豆斗抖逗痘陡兜等 *)
  let dou_rhyme_group =
    [
      ("豆", PingSheng, SiRhyme);
      ("斗", PingSheng, SiRhyme);
      ("抖", PingSheng, SiRhyme);
      ("逗", PingSheng, SiRhyme);
      ("痘", PingSheng, SiRhyme);
      ("陡", PingSheng, SiRhyme);
      ("兜", PingSheng, SiRhyme);
      ("蚪", PingSheng, SiRhyme);
      ("窦", PingSheng, SiRhyme);
    ]

  (** 渎韵系列 - 渎牍椟犊黩等 *)
  let du_variant_group =
    [
      ("渎", PingSheng, SiRhyme);
      ("牍", PingSheng, SiRhyme);
      ("椟", PingSheng, SiRhyme);
      ("犊", PingSheng, SiRhyme);
      ("黩", PingSheng, SiRhyme);
    ]

  (** 浊韵系列 - 浊濯灼拙卓啄着等 *)
  let zhuo_rhyme_group = make_ping_sheng_group SiRhyme [ "浊"; "濯"; "灼"; "拙"; "卓"; "啄"; "着" ]
end

(** 思韵平声综合列表 - 模块化重构后的统一接口，优化使用List.concat避免O(n²)复杂度 *)
let si_yun_ping_sheng =
  List.concat
    [
      Si_yun_data.poetry_core_chars;
      Si_yun_data.dong_rhyme_group;
      Si_yun_data.chong_rhyme_group;
      Si_yun_data.song_rhyme_group;
      Si_yun_data.su_rhyme_group;
      Si_yun_data.gu_rhyme_group;
      Si_yun_data.ku_rhyme_group;
      Si_yun_data.du_rhyme_group;
      Si_yun_data.dou_rhyme_group;
      Si_yun_data.du_variant_group;
      Si_yun_data.zhuo_rhyme_group;
    ]

(** {2 天韵组平声韵数据分组定义} *)

(** 天韵基础字符 - 天年先田，核心韵字 *)
let tian_yun_base_chars = [ "天"; "年"; "先"; "田"; "言"; "然" ]

(** 天韵连接字符 - 连边变见，连贯之意 *)
let tian_yun_connection_chars = [ "连"; "边"; "变"; "见"; "面"; "前" ]

(** 天韵财富字符 - 钱千迁牵，财富迁移之意 *)
let tian_yun_wealth_chars = [ "钱"; "千"; "迁"; "牵"; "签"; "浅"; "遣"; "谴"; "歉"; "欠"; "倩"; "嵌"; "悭" ]

(** 天韵建设字符 - 涧建健键，建设发展之意 *)
let tian_yun_construction_chars = [ "涧"; "建"; "健"; "键"; "渐"; "间"; "监" ]

(** 天韵品质字符 - 坚兼肩艰，品质特征之意 *)
let tian_yun_quality_chars = [ "坚"; "兼"; "肩"; "艰"; "奸"; "尖"; "煎" ]

(** 天韵工具字符 - 拣检减简，工具操作之意 *)
let tian_yun_tool_chars = [ "拣"; "检"; "减"; "简"; "茧"; "碱"; "剪"; "箭" ]

(** 天韵组完整数据 - 通过分组合并生成 *)
let tian_yun_all_chars =
  List.concat
    [
      tian_yun_base_chars;
      tian_yun_connection_chars;
      tian_yun_wealth_chars;
      tian_yun_construction_chars;
      tian_yun_quality_chars;
      tian_yun_tool_chars;
    ]

(** 天韵组 - 天年先田，天籁之音驰太虚 *)
let tian_yun_ping_sheng = make_ping_sheng_group TianRhyme tian_yun_all_chars

(** {2 仄声韵数据} *)

(** 望韵组 - 上想望放，远望之意蕴深情 *)
let wang_yun_ze_sheng =
  make_ze_sheng_group WangRhyme
    [ "上"; "想"; "望"; "放"; "向"; "响"; "象"; "像"; "相"; "项"; "享"; "详"; "祥"; "翔"; "香"; "乡" ]

(** 去韵组 - 去路度步，去声之韵意深远 *)
let qu_yun_ze_sheng =
  make_ze_sheng_group QuRhyme
    [
      "去";
      "路";
      "度";
      "步";
      "处";
      "住";
      "数";
      "组";
      "序";
      "述";
      "树";
      "注";
      "助";
      "主";
      "著";
      "驻";
      "柱";
      "筑";
      "竹";
      "逐";
      "烛";
      "族";
      "足";
      "阻";
      "组";
      "租";
      "祖";
      "诅";
      "做";
      "坐";
      "座";
      "作";
      "昨";
    ]

(** {2 入声韵数据} *)

(** 入声韵字符分组数据 *)
module RuShengCharGroups = struct
  let guo_que_group = [ "国"; "确"; "却"; "鹊"; "雀"; "缺"; "阙"; "瘸"; "炔" ]
  let qu_ru_group = [ "趣"; "取"; "娶"; "曲"; "屈"; "驱"; "区"; "躯"; "渠"; "蛆"; "蠕" ]
  let ru_ri_group = [ "如"; "儒"; "乳"; "辱"; "入"; "日"; "肉"; "柔"; "揉"; "若"; "弱" ]
  let rui_run_group = [ "锐"; "瑞"; "睿"; "蕊"; "芮"; "闰"; "润"; "软" ]
  let shui_shun_group = [ "孀"; "爽"; "谁"; "水"; "税"; "睡"; "吮"; "顺"; "瞬"; "舜" ]
  let shuo_group = [ "硕"; "朔"; "烁"; "铄"; "妁"; "蒴"; "搠"; "槊" ]

  let all_chars =
    List.concat
      [ guo_que_group; qu_ru_group; ru_ri_group; rui_run_group; shui_shun_group; shuo_group ]
end

(** 入声韵组数据 *)
let ru_sheng_yun_zu = make_ru_sheng_group QuRhyme RuShengCharGroups.all_chars

(** {1 音韵数据库合成} *)

(** 音韵数据库 - 合并所有韵组的完整数据库，优化使用List.concat避免O(n²)复杂度

    通过组合各韵组数据，形成完整的音韵数据库。 此设计使数据结构清晰，便于维护和扩展。 各韵组数据相互独立，符合模块化设计原则。 *)
let rhyme_database =
  List.concat
    [
      an_yun_ping_sheng;
      si_yun_ping_sheng;
      tian_yun_ping_sheng;
      wang_yun_ze_sheng;
      qu_yun_ze_sheng;
      ru_sheng_yun_zu;
    ]

(** 扩展音韵数据库 - Phase 1 Enhancement

    合并原有数据库与扩展数据库，实现Issue #419 Phase 1目标： 从300字扩展到1000+字，支持更完整的诗词韵律分析。 *)
let expanded_rhyme_database =
  rhyme_database
  @ List.map
      (fun (char, cat, group) ->
        (* 将扩展模块的类型转换为本模块的类型 *)
        let local_cat =
          match cat with
          | Poetry_data.Expanded_rhyme_data.PingSheng -> PingSheng
          | Poetry_data.Expanded_rhyme_data.ZeSheng -> ZeSheng
          | Poetry_data.Expanded_rhyme_data.ShangSheng -> ShangSheng
          | Poetry_data.Expanded_rhyme_data.QuSheng -> QuSheng
          | Poetry_data.Expanded_rhyme_data.RuSheng -> RuSheng
        in
        let local_group =
          match group with
          | Poetry_data.Expanded_rhyme_data.AnRhyme -> AnRhyme
          | Poetry_data.Expanded_rhyme_data.SiRhyme -> SiRhyme
          | Poetry_data.Expanded_rhyme_data.TianRhyme -> TianRhyme
          | Poetry_data.Expanded_rhyme_data.WangRhyme -> WangRhyme
          | Poetry_data.Expanded_rhyme_data.QuRhyme -> QuRhyme
          | Poetry_data.Expanded_rhyme_data.YuRhyme -> YuRhyme
          | Poetry_data.Expanded_rhyme_data.HuaRhyme -> HuaRhyme
          | Poetry_data.Expanded_rhyme_data.FengRhyme -> FengRhyme
          | Poetry_data.Expanded_rhyme_data.YueRhyme -> YueRhyme
          | Poetry_data.Expanded_rhyme_data.XueRhyme -> YueRhyme (* 将XueRhyme映射到YueRhyme *)
          | Poetry_data.Expanded_rhyme_data.JiangRhyme -> JiangRhyme
          | Poetry_data.Expanded_rhyme_data.HuiRhyme -> HuiRhyme
          | Poetry_data.Expanded_rhyme_data.UnknownRhyme -> UnknownRhyme
        in
        (char, local_cat, local_group))
      (Poetry_data.Expanded_rhyme_data.get_expanded_rhyme_database ())

(** 扩展音韵数据库字符统计 *)
let expanded_rhyme_char_count = List.length expanded_rhyme_database

(** 获取扩展音韵数据库 *)
let get_expanded_rhyme_database () = expanded_rhyme_database

(** 检查字符是否在扩展音韵数据库中 *)
let is_in_expanded_rhyme_database char =
  List.exists (fun (c, _, _) -> c = char) expanded_rhyme_database
