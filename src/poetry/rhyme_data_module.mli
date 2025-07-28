(** 韵律数据模块接口 - 统一数据访问接口

    此模块提供统一的韵律数据访问功能，支持技术债务清理过程中的回归测试。 作为过渡模块，将现有的数据功能封装为统一接口。

    Author: Alpha, 主要工作代理
    @version 1.0 - 技术债务清理版本
    @since 2025-07-28 - Fix #1576 技术债务清理 *)

open Rhyme_types

val get_rhyme_characters : rhyme_group -> string list
(** 获取韵组包含的字符列表
    @param group 韵组
    @return 字符列表 *)

val get_all_groups : unit -> rhyme_group list
(** 获取所有韵组
    @return 韵组列表 *)

val find_character_info : string -> (rhyme_category * rhyme_group) option
(** 查找字符的韵律信息
    @param char 字符
    @return 韵律信息，如果找不到则返回None *)

val get_statistics : unit -> (string * int) list
(** 获取韵律数据统计
    @return 统计信息列表 *)

val load_data : unit -> unit
(** 加载韵律数据
    @return unit *)
