(** 月韵组数据模块接口 - 骆言诗词编程特性
    
    月雪节切，秋月如霜韵味深。月韵组提供清雅深远的韵律字符数据，
    依《平水韵》传统分类，属仄声韵，为诗词创作提供标准的韵律支持。 *)

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

(** {1 月韵组核心字符数据} *)

(** 月韵基础字组 - 月雪节切等核心字 *)
val yue_yun_basic_chars : (string * rhyme_category * rhyme_group) list

(** 月韵列烈组 - 列烈裂劣等字 *)
val yue_yun_lie_group : (string * rhyme_category * rhyme_group) list

(** 月韵缺却组 - 缺却确雀等字 *)
val yue_yun_que_group : (string * rhyme_category * rhyme_group) list

(** 月韵趋区组 - 趋区曲屈等字 *)
val yue_yun_qu_group : (string * rhyme_category * rhyme_group) list

(** 月韵如儒组 - 如儒乳辱等字 *)
val yue_yun_ru_group : (string * rhyme_category * rhyme_group) list

(** 月韵锐瑞组 - 锐瑞睿蕊等字 *)
val yue_yun_rui_group : (string * rhyme_category * rhyme_group) list

(** 月韵水顺组 - 水顺硕说等字 *)
val yue_yun_shui_group : (string * rhyme_category * rhyme_group) list

(** 月韵设歇组 - 设歇些蝎等字 *)
val yue_yun_she_group : (string * rhyme_category * rhyme_group) list

(** 月韵牙压组 - 牙压雅哑等字 *)
val yue_yun_ya_group : (string * rhyme_category * rhyme_group) list

(** {1 月韵组数据合成} *)

(** 月韵组仄声韵数据 - 完整的月韵仄声韵数据 *)
val yue_yun_ze_sheng : (string * rhyme_category * rhyme_group) list

(** {1 公共接口} *)

(** 获取月韵组的所有数据
    
    @return 月韵组的完整韵律数据列表 *)
val get_all_data : unit -> (string * rhyme_category * rhyme_group) list

(** 获取月韵组字符数量统计
    
    @return 月韵组包含的字符总数 *)
val get_char_count : unit -> int