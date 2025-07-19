(** 扩展词性数据模块 - 骆言诗词编程特性 Phase 1

    应Issue #419需求，扩展词性数据从100字到500字。 依《现代汉语词典》、《古汉语常用字字典》等典籍， 结合诗词用字特点，分类整理常用字词词性。

    @author 骆言诗词编程团队
    @version 1.0
    @since 2025-07-18 
    @updated 2025-07-19 Phase 12: 使用统一词性类型定义 *)

(** 使用统一的词性类型定义，消除重复 *)
open Word_class_types

val get_expanded_word_class_database : unit -> (string * word_class) list
(** 获取扩展词性数据库
    @return 完整的扩展词性数据库 *)

val is_in_expanded_word_class_database : string -> bool
(** 判断字符是否在扩展词性数据库中
    @param char 待查字符
    @return 如果字符在数据库中返回true，否则返回false *)

val get_expanded_char_list : unit -> string list
(** 获取扩展字符列表
    @return 所有扩展词性数据库中的字符列表 *)

val find_word_class : string -> word_class option
(** 查找字符的词性
    @param char 待查字符
    @return 字符的词性，如果未找到返回None *)

val get_chars_by_class : word_class -> string list
(** 按词性获取字符列表
    @param word_class 词性类别
    @return 该词性的所有字符列表 *)

val expanded_word_class_char_count : int
(** 扩展词性数据库字符总数 *)
