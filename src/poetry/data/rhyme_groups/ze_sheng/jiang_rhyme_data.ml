(** 江韵组数据模块 - 骆言诗词编程特性
    
    江窗双庄，大江东去韵悠长。江韵组包含"江、窗、双、庄"等字符，
    依《平水韵》传统分类，属仄声韵，意境开阔雄浑，为诗词创作提供豪放壮美的韵律选择。
    
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

(** 江韵组仄声韵数据
    
    江韵组核心字符，体现大江东去的豪放意境。
    包含"江、窗、双、庄"等常用字符，韵律铿锵有力，
    适用于表现雄浑壮阔的诗词主题。 *)
let jiang_yun_ze_sheng =
  [
    ("江", ZeSheng, JiangRhyme);
    ("窗", ZeSheng, JiangRhyme);
    ("双", ZeSheng, JiangRhyme);
    ("庄", ZeSheng, JiangRhyme);
    ("装", ZeSheng, JiangRhyme);
    ("妆", ZeSheng, JiangRhyme);
    ("桩", ZeSheng, JiangRhyme);
    ("撞", ZeSheng, JiangRhyme);
    ("状", ZeSheng, JiangRhyme);
    ("壮", ZeSheng, JiangRhyme);
    ("强", ZeSheng, JiangRhyme);
    ("墙", ZeSheng, JiangRhyme);
    ("枪", ZeSheng, JiangRhyme);
    ("呛", ZeSheng, JiangRhyme);
    ("腔", ZeSheng, JiangRhyme);
    ("创", ZeSheng, JiangRhyme);
    ("床", ZeSheng, JiangRhyme);
    ("闯", ZeSheng, JiangRhyme);
    ("疮", ZeSheng, JiangRhyme);
    ("仓", ZeSheng, JiangRhyme);
    ("沧", ZeSheng, JiangRhyme);
    ("苍", ZeSheng, JiangRhyme);
    ("舱", ZeSheng, JiangRhyme);
    ("臧", ZeSheng, JiangRhyme);
    ("藏", ZeSheng, JiangRhyme);
    ("刚", ZeSheng, JiangRhyme);
    ("冈", ZeSheng, JiangRhyme);
    ("纲", ZeSheng, JiangRhyme);
    ("缸", ZeSheng, JiangRhyme);
    ("肛", ZeSheng, JiangRhyme);
    ("港", ZeSheng, JiangRhyme);
    ("杠", ZeSheng, JiangRhyme);
    ("扛", ZeSheng, JiangRhyme);
    ("康", ZeSheng, JiangRhyme);
    ("抗", ZeSheng, JiangRhyme);
    ("炕", ZeSheng, JiangRhyme);
    ("烫", ZeSheng, JiangRhyme);
    ("汤", ZeSheng, JiangRhyme);
    ("糖", ZeSheng, JiangRhyme);
    ("塘", ZeSheng, JiangRhyme);
    ("堂", ZeSheng, JiangRhyme);
    ("棠", ZeSheng, JiangRhyme);
    ("桑", ZeSheng, JiangRhyme);
    ("嗓", ZeSheng, JiangRhyme);
    ("搡", ZeSheng, JiangRhyme);
    ("磅", ZeSheng, JiangRhyme);
    ("膀", ZeSheng, JiangRhyme);
    ("帮", ZeSheng, JiangRhyme);
    ("邦", ZeSheng, JiangRhyme);
    ("榜", ZeSheng, JiangRhyme);
    ("梆", ZeSheng, JiangRhyme);
    ("棒", ZeSheng, JiangRhyme);
    ("绑", ZeSheng, JiangRhyme);
    ("蚌", ZeSheng, JiangRhyme);
    ("谤", ZeSheng, JiangRhyme);
    ("傍", ZeSheng, JiangRhyme);
    ("旁", ZeSheng, JiangRhyme);
    ("庞", ZeSheng, JiangRhyme);
    ("胖", ZeSheng, JiangRhyme);
    ("抛", ZeSheng, JiangRhyme);
    ("炮", ZeSheng, JiangRhyme);
    ("泡", ZeSheng, JiangRhyme);
    ("跑", ZeSheng, JiangRhyme);
    ("袍", ZeSheng, JiangRhyme);
    ("刨", ZeSheng, JiangRhyme);
    ("饱", ZeSheng, JiangRhyme);
    ("褒", ZeSheng, JiangRhyme);
    ("苞", ZeSheng, JiangRhyme);
    ("包", ZeSheng, JiangRhyme);
    ("报", ZeSheng, JiangRhyme);
    ("抱", ZeSheng, JiangRhyme);
    ("豹", ZeSheng, JiangRhyme);
    ("暴", ZeSheng, JiangRhyme);
    ("堡", ZeSheng, JiangRhyme);
    ("保", ZeSheng, JiangRhyme);
    ("宝", ZeSheng, JiangRhyme);
  ]

(** {1 公共接口} *)

(** 获取江韵组的所有数据
    
    @return 江韵组的完整韵律数据列表 *)
let get_all_data () = jiang_yun_ze_sheng

(** 获取江韵组字符数量统计
    
    @return 江韵组包含的字符总数 *)
let get_char_count () = List.length jiang_yun_ze_sheng

(** 导出数据供外部模块使用 *)
let () = ()