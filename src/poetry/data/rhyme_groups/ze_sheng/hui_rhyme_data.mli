(** 灰韵组数据模块接口 - 骆言诗词编程特性
    
    灰回推开，灰飞烟灭韵苍茫。灰韵组提供深沉苍凉的韵律字符数据，
    依《平水韵》传统分类，属仄声韵，为诗词创作提供厚重有力的韵律支持。 *)

(** 直接定义所需类型，避免循环依赖 *)
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

(** {1 灰韵组核心字符数据} *)

(** 灰韵核心字组 - 灰回推开等核心字 *)
val hui_yun_core_chars : (string * rhyme_category * rhyme_group) list

(** 灰韵带字系列 - 戴带待代等字 *)
val hui_yun_dai_series : (string * rhyme_category * rhyme_group) list

(** 灰韵买字系列 - 埋买迈麦等字 *)
val hui_yun_mai_series : (string * rhyme_category * rhyme_group) list

(** 灰韵拍字系列 - 派拍牌排等字 *)
val hui_yun_pai_series : (string * rhyme_category * rhyme_group) list

(** 灰韵柴字系列 - 差柴拆豺等字 *)
val hui_yun_chai_series : (string * rhyme_category * rhyme_group) list

(** 灰韵菜字系列 - 蔡菜采彩等字 *)
val hui_yun_cai_series : (string * rhyme_category * rhyme_group) list

(** 灰韵来字系列 - 来莱赖癞等字 *)
val hui_yun_lai_series : (string * rhyme_category * rhyme_group) list

(** 灰韵海字系列 - 海害亥骇等字 *)
val hui_yun_hai_series : (string * rhyme_category * rhyme_group) list

(** 灰韵岁字系列 - 邃碎岁穗等字 *)
val hui_yun_sui_series : (string * rhyme_category * rhyme_group) list

(** 灰韵宗字系列 - 崇宗综踪等字 *)
val hui_yun_zong_series : (string * rhyme_category * rhyme_group) list

(** 灰韵松字系列 - 松耸送宋等字 *)
val hui_yun_song_series : (string * rhyme_category * rhyme_group) list

(** 灰韵从字系列 - 从丛聪葱等字 *)
val hui_yun_cong_series : (string * rhyme_category * rhyme_group) list

(** 灰韵冲字系列 - 冲充虫重等字 *)
val hui_yun_chong_series : (string * rhyme_category * rhyme_group) list

(** 灰韵东字系列 - 冬东中等字 *)
val hui_yun_dong_series : (string * rhyme_category * rhyme_group) list

(** 灰韵风字系列 - 风峰锋丰等字 *)
val hui_yun_feng_series : (string * rhyme_category * rhyme_group) list

(** 灰韵繁体字系列 - 紅東鳳經等传统字符 *)
val hui_yun_traditional_series : (string * rhyme_category * rhyme_group) list

(** 灰韵剩余字符 - 传统生僻字符 *)
val hui_yun_remaining_chars : (string * rhyme_category * rhyme_group) list

(** {1 灰韵组数据合成} *)

(** 灰韵组仄声韵数据 - 完整的灰韵仄声韵数据 *)
val hui_yun_ze_sheng : (string * rhyme_category * rhyme_group) list

(** {1 数据接口函数} *)

(** 获取灰韵组所有字符数据
    
    @return 灰韵组的完整韵律数据列表 *)
val get_hui_rhyme_data : unit -> (string * rhyme_category * rhyme_group) list

(** 获取灰韵组字符数量统计
    
    @return 灰韵组包含的字符总数 *)
val get_hui_rhyme_count : unit -> int

(** 检查字符是否属于灰韵组
    
    @param char 要检查的字符
    @return 如果字符属于灰韵组则返回true，否则返回false *)
val is_hui_rhyme_char : string -> bool

(** 获取灰韵组所有字符列表
    
    @return 灰韵组的字符列表（不包含韵律信息） *)
val get_hui_rhyme_chars : unit -> string list