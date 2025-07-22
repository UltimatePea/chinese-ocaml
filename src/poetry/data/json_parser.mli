(** JSON解析器模块接口 - 专门处理诗词数据的JSON解析

    @author 骆言诗词编程团队 - Phase 15 超长文件重构
    @version 1.0
    @since 2025-07-21 *)

open Rhyme_groups.Rhyme_group_types

(** {1 JSON字段提取器} *)

module JsonFieldExtractor : sig
  val extract_field : string -> string -> string
  (** 从JSON条目字符串中提取指定字段的值

      @param entry_str JSON条目字符串
      @param field_name 要提取的字段名
      @return 字段值，如果不存在则返回空字符串 *)
end

(** {1 韵律类型转换器} *)

module RhymeTypeConverter : sig
  val parse_rhyme_category : string -> rhyme_category
  (** 解析韵律类别字符串

      @param category_str 韵律类别字符串
      @return 韵律类别枚举值 *)

  val parse_rhyme_group : string -> rhyme_group
  (** 解析韵律组字符串

      @param group_str 韵律组字符串
      @return 韵律组枚举值 *)
end

(** {1 JSON数组解析器} *)

module JsonArrayParser : sig
  val parse_rhyme_entry : string -> string * rhyme_category * rhyme_group
  (** 解析单个韵律数据条目

      @param entry_str JSON条目字符串
      @return 韵律数据三元组 (字符, 韵律类别, 韵律组) *)

  val split_json_array : string -> string list
  (** 分割JSON数组为条目列表

      @param content JSON数组内容
      @return 条目字符串列表 *)

  val parse_entries : string list -> (string * rhyme_category * rhyme_group) list
  (** 解析条目列表为韵律数据

      @param entries 条目字符串列表
      @return 韵律数据列表 *)
end

(** {1 主要解析接口} *)

val parse_rhyme_data_json : string -> (string * rhyme_category * rhyme_group) list
(** 从JSON字符串解析韵律数据条目列表

    @param content JSON格式的韵律数据内容
    @return 解析后的韵律数据列表 *)

val parse_single_rhyme_entry : string -> string * rhyme_category * rhyme_group
(** 解析单个韵律数据条目

    @param entry_str 单个JSON条目字符串
    @return 解析后的韵律数据三元组 *)
