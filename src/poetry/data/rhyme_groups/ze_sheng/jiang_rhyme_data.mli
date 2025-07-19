(** 江韵组数据模块接口 - 骆言诗词编程特性

    江窗双庄，大江东去韵悠长。江韵组提供豪放壮美的韵律字符数据， 依《平水韵》传统分类，属仄声韵，为诗词创作提供标准的韵律支持。 *)

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

(** {1 江韵组数据} *)

val jiang_yun_ze_sheng : (string * rhyme_category * rhyme_group) list
(** 江韵组仄声韵数据 - 完整的江韵仄声韵数据 *)

(** {1 公共接口} *)

val get_all_data : unit -> (string * rhyme_category * rhyme_group) list
(** 获取江韵组的所有数据

    @return 江韵组的完整韵律数据列表 *)

val get_char_count : unit -> int
(** 获取江韵组字符数量统计

    @return 江韵组包含的字符总数 *)
