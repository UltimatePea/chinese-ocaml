(** 统一韵律API模块接口 - 消除音韵数据重复 *)

open Poetry.Data.Rhyme_groups.Rhyme_types

(** {1 核心API函数} *)

(** 查找字符的韵律信息 - 替代13处重复的find_rhyme_info实现 *)
val find_rhyme_info : string -> (rhyme_category * rhyme_group) option

(** 检测字符的韵类 - 统一的韵类检测函数 *)
val detect_rhyme_category : string -> rhyme_category

(** 检测字符的韵组 - 统一的韵组检测函数 *)
val detect_rhyme_group : string -> rhyme_group

(** 获取韵组包含的所有字符 *)
val get_rhyme_characters : rhyme_group -> string list

(** 验证字符列表的韵律一致性 *)
val validate_rhyme_consistency : string list -> bool

(** 检查两个字符是否押韵 *)
val check_rhyme : string -> string -> bool

(** 查找与给定字符押韵的所有字符 *)
val find_rhyming_characters : string -> string list

(** {1 高级韵律分析函数} *)

(** 分析文本的韵律模式 *)
val analyze_rhyme_pattern : string -> (rhyme_category * int) list * (rhyme_group * int) list

(** 获取韵律数据统计信息 *)
val get_rhyme_stats : unit -> (string * int) list

(** {1 兼容性函数} *)

(** 兼容原有接口的函数别名 *)
module Legacy : sig
  val find_rhyme : string -> (rhyme_category * rhyme_group) option
  val get_rhyme_info : string -> (rhyme_category * rhyme_group) option
  val rhyme_detection : string -> rhyme_category
  val rhyme_group_detection : string -> rhyme_group
  val is_same_rhyme : string -> string -> bool
  val validate_rhyme : string list -> bool
end

(** 初始化函数 - 供外部模块调用 *)
val initialize : unit -> unit