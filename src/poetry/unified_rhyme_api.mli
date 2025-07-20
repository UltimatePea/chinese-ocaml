(** 统一韵律API模块接口 - 消除音韵数据重复 *)

open Rhyme_types

(** {1 核心API函数} *)

val find_rhyme_info : string -> (rhyme_category * rhyme_group) option
(** 查找字符的韵律信息 - 替代13处重复的find_rhyme_info实现 *)

val detect_rhyme_category : string -> rhyme_category
(** 检测字符的韵类 - 统一的韵类检测函数 *)

val detect_rhyme_group : string -> rhyme_group
(** 检测字符的韵组 - 统一的韵组检测函数 *)

val get_rhyme_characters : rhyme_group -> string list
(** 获取韵组包含的所有字符 *)

val validate_rhyme_consistency : string list -> bool
(** 验证字符列表的韵律一致性 *)

val check_rhyme : string -> string -> bool
(** 检查两个字符是否押韵 *)

val find_rhyming_characters : string -> string list
(** 查找与给定字符押韵的所有字符 *)

(** {1 高级韵律分析函数} *)

val analyze_rhyme_pattern : string -> (rhyme_category * int) list * (rhyme_group * int) list
(** 分析文本的韵律模式 *)

val get_rhyme_stats : unit -> (string * int) list
(** 获取韵律数据统计信息 *)

val analyze_poem_line_structure : string -> (string * (rhyme_category * rhyme_group) option * string) list
(** 分析诗句的韵律结构 *)

val detect_poem_rhyme_scheme : string list -> (int * rhyme_group) list
(** 检测诗句间的押韵关系 *)

val evaluate_rhyme_quality : string -> float
(** 评估文本的韵律质量 *)

val suggest_rhyming_chars : string -> string list -> string list
(** 建议押韵字符 *)

(** {1 数据管理API} *)

val load_rhyme_data : unit -> unit
(** 加载韵律数据到缓存 *)

val get_rhyme_group_chars : rhyme_group -> string list option
(** 获取指定韵组的字符集 *)

val get_all_rhyme_groups : unit -> rhyme_group list
(** 获取所有韵组列表 *)

val get_data_stats : unit -> int * int
(** 获取韵律数据统计信息 *)

(** {1 缓存管理API} *)

val clear_cache : unit -> unit
(** 清空韵律缓存 *)

val get_cache_statistics : unit -> int * int
(** 获取缓存统计信息 *)

val preload_rhyme_data : unit -> unit
(** 预加载韵律数据 - 性能优化 *)

(** {1 批量处理API} *)

val batch_find_rhyme_info : string list -> (string * (rhyme_category * rhyme_group) option) list
(** 批量查找字符的韵律信息 *)

val batch_validate_rhyme_consistency : string list list -> (string list * bool) list
(** 批量检测韵律一致性 *)

(** {1 高级分析功能} *)

val get_rhyme_analysis_report : string -> string
(** 获取韵律分析报告 *)

val validate_rhyme_data_integrity : unit -> bool
(** 验证韵律数据完整性 *)

val safe_find_rhyme_info : string -> (rhyme_category * rhyme_group) option
(** 安全的韵律查找（带错误处理） *)

val is_known_rhyme_char : string -> bool
(** 检查字符是否为已知韵字 *)

val get_rhyme_description : string -> string
(** 获取字符的韵律描述 *)

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

val initialize : unit -> unit
(** 初始化函数 - 供外部模块调用 *)
