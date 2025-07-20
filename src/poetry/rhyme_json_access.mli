(** 韵律JSON数据访问接口
    
    @author 骆言诗词编程团队 
    @version 1.0
    @since 2025-07-20 - Phase 29 rhyme_json_loader重构 *)

open Rhyme_json_types

(** {1 数据查询} *)

val get_all_rhyme_groups : unit -> (string * rhyme_group_data) list
(** 获取所有韵组 *)

val get_rhyme_group_characters : string -> string list
(** 获取指定韵组的字符列表 *)

val get_rhyme_group_category : string -> rhyme_category
(** 获取指定韵组的韵类 *)

val get_rhyme_mappings : unit -> (string * (rhyme_category * rhyme_group)) list
(** 获取韵律映射关系 *)

(** {1 数据统计} *)

val get_data_statistics : unit -> (int * int) option
(** 获取数据统计信息 (韵组数, 字符数) *)

val print_statistics : unit -> unit
(** 打印统计信息 *)