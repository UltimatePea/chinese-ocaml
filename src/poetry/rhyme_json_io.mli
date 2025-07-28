(** 韵律JSON文件I/O操作接口 - Wave 2 重构版本

    此接口已完全重构为Poetry_core.Json_core的兼容接口层。
    原本独立的I/O操作接口现在转发到统一的JSON核心。

    @author Beta, Code Reviewer Agent - Wave 2 重构团队
    @version 3.0 - Wave 2 兼容层版本
    @since 2025-07-28 - Poetry Phase 3 Wave 2 继续实施
    @fix_issue #1550 *)

(** {1 配置} *)

val default_data_file : string
(** 默认数据文件路径 *)

(** {1 主要I/O接口 - 转发到统一核心} *)

val get_rhyme_data : ?force_reload:bool -> unit -> Poetry_core.Json_core.rhyme_data_file option
(** 获取韵律数据 - 转发到统一核心 *)