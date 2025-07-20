(** 韵律JSON降级数据接口
    
    @author 骆言诗词编程团队 
    @version 1.0
    @since 2025-07-20 - Phase 29 rhyme_json_loader重构 *)

open Rhyme_json_types

(** {1 降级数据} *)

val fallback_rhyme_data : (string * rhyme_group_data) list
(** 降级韵律数据 *)

(** {1 降级操作} *)

val use_fallback_data : unit -> rhyme_data_file
(** 使用降级数据 *)