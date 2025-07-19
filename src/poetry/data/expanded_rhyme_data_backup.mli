(** 扩展音韵数据模块 - 骆言诗词编程特性 Phase 1 *)

(** {1 类型定义} *)

(** 韵声分类 *)
type rhyme_category =
  | PingSheng (* 平声韵 *)
  | ZeSheng (* 仄声韵 *)
  | ShangSheng (* 上声韵 *)
  | QuSheng (* 去声韵 *)
  | RuSheng (* 入声韵 *)

(** 韵组分类 *)
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

(** {1 韵律数据辅助工具} *)

(** 创建韵律数据项的辅助函数 *)
val create_rhyme_data : string list -> rhyme_category -> rhyme_group -> (string * rhyme_category * rhyme_group) list

(** {1 韵组数据} *)

(** 鱼韵组平声字数据 *)
val yu_yun_ping_sheng : (string * rhyme_category * rhyme_group) list

(** 花韵组平声字数据 *)
val hua_yun_ping_sheng : (string * rhyme_category * rhyme_group) list

(** 风韵组平声字数据 *)
val feng_yun_ping_sheng : (string * rhyme_category * rhyme_group) list

(** 月韵组仄声字数据 *)
val yue_yun_ze_sheng : (string * rhyme_category * rhyme_group) list

(** 江韵组仄声字数据 *)
val jiang_yun_ze_sheng : (string * rhyme_category * rhyme_group) list

(** 灰韵组仄声字数据 *)
val hui_yun_ze_sheng : (string * rhyme_category * rhyme_group) list

(** {1 扩展音韵数据库} *)

(** 扩展音韵数据库 - 合并所有韵组的完整数据库 *)
val expanded_rhyme_database : (string * rhyme_category * rhyme_group) list

(** 扩展音韵数据库字符统计 *)
val expanded_rhyme_char_count : int

(** {1 数据库访问接口} *)

(** 获取扩展音韵数据库 *)
val get_expanded_rhyme_database : unit -> (string * rhyme_category * rhyme_group) list

(** 检查字符是否在扩展音韵数据库中 *)
val is_in_expanded_rhyme_database : string -> bool

(** 获取扩展音韵数据库中的字符列表 *)
val get_expanded_char_list : unit -> string list