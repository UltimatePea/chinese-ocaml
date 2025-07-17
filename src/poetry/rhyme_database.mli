(** 音韵数据库模块 - 骆言诗词编程特性
    
    盖古之诗者，音韵为要。声韵调谐，方称佳构。
    此模块专司音韵数据库，收录三千余字音韵分类。
    依《广韵》、《集韵》等韵书传统，分类整理。
    平声清越，仄声沉郁，入声短促，各有所归。
    
    @author 骆言诗词编程团队
    @version 1.0
    @since 2025-07-17
*)

open Rhyme_types

(** {1 数据库统计类型} *)

(** 数据库统计信息类型
    
    用于描述音韵数据库的整体统计信息，包含各韵类和韵组的字符数量。
*)
type database_stats = {
  total_chars: int;           (** 数据库中字符总数 *)
  ping_sheng_count: int;      (** 平声韵字符数 *)
  ze_sheng_count: int;        (** 仄声韵字符数 *)
  ru_sheng_count: int;        (** 入声韵字符数 *)
  group_counts: (string * int) list;  (** 各韵组字符数统计 *)
}

(** {1 数据库查询函数} *)

(** 查找字符的音韵信息
    
    在音韵数据库中查找指定字符的韵类和韵组信息。
    
    @param char 待查找的字符
    @return 音韵信息选项，包含韵类和韵组；如果未找到则返回None
    
    @example [find_rhyme_info '山'] 返回 [Some (PingSheng, AnRhyme)]
    @example [find_rhyme_info '不'] 返回 [None]（如果数据库中没有该字）
*)
val find_rhyme_info : char -> (rhyme_category * rhyme_group) option

(** 获取数据库统计信息
    
    生成音韵数据库的详细统计信息，包括各韵类和韵组的字符数量。
    
    @return 数据库统计信息记录
    
    @example [get_database_stats ()] 返回包含总字符数、各韵类计数等信息的记录
*)
val get_database_stats : unit -> database_stats

(** 按韵组获取字符列表
    
    返回属于指定韵组的所有字符列表。
    
    @param group 目标韵组
    @return 属于该韵组的字符列表
    
    @example [get_chars_by_group AnRhyme] 返回 [["安"; "山"; "间"; "闲"; ...]]
*)
val get_chars_by_group : rhyme_group -> string list

(** 按韵类获取字符列表
    
    返回属于指定韵类的所有字符列表。
    
    @param category 目标韵类
    @return 属于该韵类的字符列表
    
    @example [get_chars_by_category PingSheng] 返回所有平声韵字符的列表
*)
val get_chars_by_category : rhyme_category -> string list

(** {1 数据库访问} *)

(** 音韵数据库
    
    包含汉字音韵分类的主要数据库，以(字符, 韵类, 韵组)三元组形式存储。
    依据《广韵》、《集韵》等韵书传统，收录常用汉字的音韵分类。
    
    @note 此数据结构为模块内部使用，一般通过查询函数访问
*)
val rhyme_database : (string * rhyme_category * rhyme_group) list