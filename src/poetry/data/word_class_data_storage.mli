(** 词性数据存储模块接口 - 数据外化重构

    提供词性数据的标准接口，支持自然景物名词、量词、工具物品名词等 中文词汇分类数据的访问。

    @author 骆言诗词编程团队
    @version 1.0 - 数据外化重构
    @since 2025-07-18 *)

val nature_nouns_list : string list
(** 自然景物名词数据列表 - 113个自然景物词汇 *)

val measuring_classifiers_list : string list
(** 量词数据列表 - 113个量词 *)

val tools_objects_nouns_list : string list
(** 工具物品名词数据列表 - 83个工具物品词汇 *)
