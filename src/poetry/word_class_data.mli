(* 词性数据模块接口 - 骆言诗词编程特性
   此模块提供词性数据存储和访问接口，
   与对仗分析业务逻辑分离，提升代码可维护性。
*)

(* 使用统一的词性类型定义，消除重复 *)
open Poetry_data.Word_class_types

(* 词性数据库：收录常用汉字词性的关联列表
   字符串到词性的映射，用于词性检测和对仗分析
*)
val word_class_database : (string * word_class) list
