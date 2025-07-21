(** 诗词数据JSON解析器 - 专门负责JSON数据解析

    提供简单但有效的JSON解析功能，专门用于诗词数据文件的解析。 支持字符串数组解析和字段提取操作。

    @author 骆言技术债务清理团队
    @version 1.0
    @since 2025-07-20 *)

val trim_whitespace : string -> string
(** 去除字符串首尾空白字符
    @param s 待处理的字符串
    @return 去除空白字符后的字符串 *)

val parse_string_array : string -> string list
(** 解析JSON字符串数组 将形如 ["item1", "item2", "item3"] 的字符串解析为字符串列表
    @param content JSON数组字符串
    @return 解析后的字符串列表，解析失败时返回空列表 *)

val extract_field : string -> string -> string
(** 从JSON对象中提取指定字段的值 支持字符串值和数组值的提取
    @param content JSON对象字符串
    @param field_name 字段名称
    @return 字段值，提取失败时返回空字符串 *)
