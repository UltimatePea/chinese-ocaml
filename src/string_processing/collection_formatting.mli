(** 列表和集合格式化模块

    本模块提供各种集合和列表的格式化功能， 统一处理不同分隔符和格式的需求。

    @author 骆言技术债务清理团队
    @version 1.0
    @since 2025-07-20 Issue #708 重构 *)

(** {1 基础分隔符格式化} *)

val join_chinese : string list -> string
(** [join_chinese items] 使用中文顿号分隔符连接字符串列表 *)

val join_english : string list -> string
(** [join_english items] 使用英文逗号和空格分隔符连接字符串列表 *)

val join_semicolon : string list -> string
(** [join_semicolon items] 使用分号和空格分隔符连接字符串列表 *)

val join_newline : string list -> string
(** [join_newline items] 使用换行符分隔符连接字符串列表 *)

(** {1 结构化格式化} *)

val indented_list : string list -> string
(** [indented_list items] 将字符串列表格式化为带缩进的项目列表 *)

val array_format : string list -> string
(** [array_format items] 将字符串列表格式化为数组形式 [item1; item2; item3] *)

val tuple_format : string list -> string
(** [tuple_format items] 将字符串列表格式化为元组形式 (item1, item2, item3) *)

val type_signature_format : string list -> string
(** [type_signature_format types] 将类型列表格式化为OCaml类型签名 type1 * type2 * type3 *)
