(** 诗词数据后备支持模块 - 提供默认数据和容错机制

    当主要数据文件加载失败时，提供基本的词汇数据作为后备。 确保系统在数据文件缺失的情况下仍能正常运行。

    @author 骆言技术债务清理团队
    @version 1.0
    @since 2025-07-20 *)

open Word_class_types

val basic_person_relation_nouns : (string * word_class) list
(** 基本人际关系名词 *)

val basic_social_status_nouns : (string * word_class) list
(** 基本社会地位名词 *)

val basic_movement_verbs : (string * word_class) list
(** 基本运动动词 *)

val basic_size_adjectives : (string * word_class) list
(** 基本尺寸形容词 *)

val basic_degree_adverbs : (string * word_class) list
(** 基本程度副词 *)

val basic_numbers : (string * word_class) list
(** 基本数词 *)

val basic_classifiers : (string * word_class) list
(** 基本量词 *)

val basic_pronouns : (string * word_class) list
(** 基本代词 *)
