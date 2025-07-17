(* 音韵匹配算法模块接口 - 骆言诗词编程特性
   专司音韵之匹配，辨析字符之韵归。
   此接口定义音韵匹配相关函数的类型签名。
*)

(* 导入韵母类型定义 *)
open Rhyme_types

(* 寻韵察音：从数据库中查找字符的韵母信息 *)
val find_rhyme_info : char -> (rhyme_category * rhyme_group) option

(* 辨音识韵：检测字符的韵母分类 *)
val detect_rhyme_category : char -> rhyme_category
val detect_rhyme_category_by_string : string -> rhyme_category

(* 归类成组：检测字符的韵组 *)
val detect_rhyme_group : char -> rhyme_group

(* 检查两个字符是否押韵 *)
val chars_rhyme : char -> char -> bool

(* 建议韵脚字符：根据韵组提供用韵建议 *)
val suggest_rhyme_characters : rhyme_group -> string list

(* 获取韵组名称：返回韵组的字符串表示 *)
val rhyme_group_to_string : rhyme_group -> string

(* 获取韵类名称：返回韵类的字符串表示 *)
val rhyme_category_to_string : rhyme_category -> string