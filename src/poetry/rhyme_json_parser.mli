(** 韵律JSON解析器接口

    @author 骆言诗词编程团队
    @version 1.0
    @since 2025-07-20 - Phase 29 rhyme_json_loader重构 *)

open Rhyme_json_types

(** {1 字符串处理} *)

val clean_json_string : string -> string
(** 清理JSON字符串，去除引号和多余字符 *)

(** {1 解析函数} *)

val parse_nested_json : string -> (string * rhyme_group_data) list
(** 解析嵌套JSON内容，返回韵组数据列表 *)
