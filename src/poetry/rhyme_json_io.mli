(** 韵律JSON文件I/O操作接口
    
    @author 骆言诗词编程团队 
    @version 1.0
    @since 2025-07-20 - Phase 29 rhyme_json_loader重构 *)

open Rhyme_json_types

(** {1 配置} *)

val default_data_file : string
(** 默认数据文件路径 *)

(** {1 文件操作} *)

val safe_read_file : string -> string
(** 安全地读取文件内容 *)

(** {1 数据加载} *)

val load_rhyme_data_from_file : ?filename:string -> unit -> rhyme_data_file
(** 从文件加载韵律数据 *)

val get_rhyme_data : ?force_reload:bool -> unit -> rhyme_data_file
(** 获取韵律数据（支持缓存） *)