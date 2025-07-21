(** 江韵组数据模块 - 骆言诗词编程特性

    江窗双庄，大江东去韵悠长。江韵组包含"江、窗、双、庄"等字符， 依《平水韵》传统分类，属仄声韵，意境开阔雄浑，为诗词创作提供豪放壮美的韵律选择。

    @author 骆言诗词编程团队
    @version 1.0
    @since 2025-07-19 - Phase 14.3 模块化重构 *)

(** 使用统一的韵律类型定义 - 保持与主模块兼容 *)
type rhyme_category =
  | PingSheng (* 平声韵 *)
  | ZeSheng (* 仄声韵 *)
  | ShangSheng (* 上声韵 *)
  | QuSheng (* 去声韵 *)
  | RuSheng (* 入声韵 *)

type rhyme_group =
  | AnRhyme (* 安韵组 *)
  | SiRhyme (* 思韵组 *)
  | TianRhyme (* 天韵组 *)
  | WangRhyme (* 望韵组 *)
  | QuRhyme (* 去韵组 *)
  | YuRhyme (* 鱼韵组 *)
  | HuaRhyme (* 花韵组 *)
  | FengRhyme (* 风韵组 *)
  | YueRhyme (* 月韵组 *)
  | XueRhyme (* 雪韵组 *)
  | JiangRhyme (* 江韵组 *)
  | HuiRhyme (* 灰韵组 *)
  | UnknownRhyme (* 未知韵组 *)

(** {1 江韵组数据} *)

(** 韵律数据构建器 *)
module RhymeDataBuilder = struct
  let create_jiang_rhyme_entry char = (char, ZeSheng, JiangRhyme)

  let create_entries chars = List.map create_jiang_rhyme_entry chars
end

(** 江韵字符分组 *)
let jiang_core_chars = ["江"]

let zhuang_group_chars = ["窗"; "双"; "庄"; "装"; "妆"; "桩"; "撞"; "状"; "壮"]

let qiang_group_chars = ["强"; "墙"; "枪"; "呛"; "腔"; "创"; "床"; "闯"; "疮"]

let cang_group_chars = ["仓"; "沧"; "苍"; "舱"; "臧"; "藏"]

let gang_group_chars = ["刚"; "冈"; "纲"; "缸"; "肛"; "港"; "杠"; "扛"; "康"; "抗"; "炕"]

let tang_group_chars = ["烫"; "汤"; "糖"; "塘"; "堂"; "棠"; "桑"; "嗓"; "搡"]

let bang_group_chars = ["磅"; "膀"; "帮"; "邦"; "榜"; "梆"; "棒"; "绑"; "蚌"; "谤"; "傍"; "旁"; "庞"; "胖"]

let bao_group_chars = ["抛"; "炮"; "泡"; "跑"; "袍"; "刨"; "饱"; "褒"; "苞"; "包"; "报"; "抱"; "豹"; "暴"; "堡"; "保"; "宝"]

(** 所有江韵字符组合 *)
let all_jiang_chars = 
  jiang_core_chars @ zhuang_group_chars @ qiang_group_chars @ 
  cang_group_chars @ gang_group_chars @ tang_group_chars @ 
  bang_group_chars @ bao_group_chars

(** 江韵仄声数据 *)
let jiang_yun_ze_sheng = RhymeDataBuilder.create_entries all_jiang_chars

(** {1 公共接口} *)

(** 获取江韵组的所有数据

    @return 江韵组的完整韵律数据列表 *)
let get_all_data () = jiang_yun_ze_sheng

(** 获取江韵组字符数量统计

    @return 江韵组包含的字符总数 *)
let get_char_count () = List.length jiang_yun_ze_sheng

(** 导出数据供外部模块使用 *)
let () = ()
