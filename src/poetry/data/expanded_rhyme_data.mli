(** 扩展音韵数据模块 - 骆言诗词编程特性 Phase 1

    应Issue #419需求，扩展音韵数据从300字到1000字。 依《平水韵》、《中华新韵》等韵书传统，精心收录常用诗词字符。 按韵组分类，音韵和谐，便于诗词创作和分析。

    @author 骆言诗词编程团队
    @version 1.0
    @since 2025-07-18 *)

(** 韵类 - 按照传统韵书分类 *)
type rhyme_category =
  | PingSheng (* 平声韵 *)
  | ZeSheng (* 仄声韵 *)
  | ShangSheng (* 上声韵 *)
  | QuSheng (* 去声韵 *)
  | RuSheng (* 入声韵 *)

(** 韵组 - 具体的韵部分组 *)
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

val create_rhyme_data :
  string list -> rhyme_category -> rhyme_group -> (string * rhyme_category * rhyme_group) list
(** 创建韵数据记录
    @param chars 字符列表
    @param category 韵类
    @param group 韵组
    @return 韵数据记录列表 *)

val get_expanded_rhyme_database : unit -> (string * rhyme_category * rhyme_group) list
(** 获取扩展韵数据库
    @return 完整的扩展韵数据库 *)

val is_in_expanded_rhyme_database : string -> bool
(** 判断字符是否在扩展韵数据库中
    @param char 待查字符
    @return 如果字符在数据库中返回true，否则返回false *)

val get_expanded_char_list : unit -> string list
(** 获取扩展字符列表
    @return 所有扩展韵数据库中的字符列表 *)

val expanded_rhyme_char_count : int
(** 扩展韵数据库字符总数 *)
