(** 韵律API核心模块接口

    提供核心的韵律检测和查询API，包括韵类检测、韵组检测和基础押韵验证功能。 *)

open Rhyme_types

(** {1 核心API函数} *)

val find_rhyme_info : string -> (rhyme_category * rhyme_group) option
(** 查找字符的韵律信息 *)

val detect_rhyme_category : string -> rhyme_category
(** 检测字符的韵类 *)

val detect_rhyme_group : string -> rhyme_group
(** 检测字符的韵组 *)

val get_rhyme_characters : rhyme_group -> string list
(** 获取韵组包含的所有字符 *)

val validate_rhyme_consistency : string list -> bool
(** 验证字符列表的韵律一致性 *)

val check_rhyme : string -> string -> bool
(** 检查两个字符是否押韵 *)

val find_rhyming_characters : string -> string list
(** 查找与给定字符押韵的所有字符 *)

val is_known_rhyme_char : string -> bool
(** 检查字符是否为已知韵字 *)

val get_rhyme_description : string -> string
(** 获取字符的韵律描述 *)
