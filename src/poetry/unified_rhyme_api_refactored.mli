(** 统一韵律API模块接口 - 外部化数据版本
    
    此模块提供统一的韵律数据访问接口，使用外部JSON文件加载韵律数据。
    消除项目中273处音韵相关的重复代码。
    
    @author 骆言诗词编程团队
    @version 3.0 - 外部化重构版  
    @since 2025-07-19 *)

open Rhyme_json_loader

(** {1 核心API函数} *)

val find_rhyme_info : string -> (rhyme_category * rhyme_group) option
(** 查找字符的韵律信息 - 替代13处重复的find_rhyme_info实现 
    @param char 要查找的字符
    @return 韵类和韵组的组合，如果未找到则返回None *)

val detect_rhyme_category : string -> rhyme_category  
(** 检测字符的韵类 - 统一的韵类检测函数
    @param char 要检测的字符
    @return 韵类，如果无法检测则返回PingSheng作为默认值 *)

val detect_rhyme_group : string -> rhyme_group
(** 检测字符的韵组 - 统一的韵组检测函数
    @param char 要检测的字符
    @return 韵组，如果无法检测则返回UnknownRhyme *)

val get_rhyme_characters : rhyme_group -> string list
(** 获取韵组包含的所有字符
    @param group 韵组
    @return 字符列表 *)

val validate_rhyme_consistency : string list -> bool
(** 验证字符列表的韵律一致性
    @param chars 字符列表  
    @return 如果所有字符属于同一韵组则返回true *)

val check_rhyme : string -> string -> bool
(** 检查两个字符是否押韵
    @param char1 第一个字符
    @param char2 第二个字符
    @return 如果两字符押韵则返回true *)

val find_rhyming_characters : string -> string list
(** 查找与给定字符押韵的所有字符
    @param char 参考字符
    @return 押韵字符列表 *)

(** {1 高级韵律分析函数} *)

val analyze_rhyme_pattern : string -> (rhyme_category * int) list * (rhyme_group * int) list
(** 分析文本的韵律模式
    @param text 要分析的文本
    @return (韵类分布, 韵组分布) *)

val get_rhyme_analysis_report : string -> string
(** 获取韵律分析报告
    @param text 要分析的文本
    @return 分析报告字符串 *)

(** {1 性能优化函数} *)

val batch_find_rhyme_info : string list -> (string * (rhyme_category * rhyme_group) option) list
(** 批量查找字符的韵律信息
    @param chars 字符列表
    @return (字符, 韵律信息) 列表 *)

val preload_rhyme_data : unit -> unit
(** 预加载韵律数据到内存缓存 *)

(** {1 缓存管理} *)

val clear_cache : unit -> unit
(** 清空韵律缓存 *)

val reload_rhyme_data : unit -> unit
(** 重新加载韵律数据 *)

val get_cache_statistics : unit -> int * int
(** 获取缓存统计信息
    @return (字符数量, 韵组数量) *)

val print_cache_statistics : unit -> unit
(** 打印缓存统计信息 *)

(** {1 向后兼容接口} *)

val get_unified_rhyme_data : unit -> (string * (rhyme_category * rhyme_group)) list
(** 兼容原有的韵律数据获取接口 *)

val get_unified_rhyme_group_chars : unit -> (rhyme_group * string list) list
(** 兼容原有的韵组字符获取接口 *)

(** {1 错误处理和降级} *)

val validate_rhyme_data_integrity : unit -> bool
(** 验证韵律数据完整性 *)

val safe_find_rhyme_info : string -> (rhyme_category * rhyme_group) option
(** 安全的韵律查找（带错误处理） *)

(** {1 兼容性模块} *)

(** 向后兼容的函数别名 *)
module Legacy : sig
  val find_rhyme : string -> (rhyme_category * rhyme_group) option
  (** find_rhyme_info的别名 *)
  
  val get_rhyme_info : string -> (rhyme_category * rhyme_group) option
  (** find_rhyme_info的别名 *)
  
  val rhyme_detection : string -> rhyme_category
  (** detect_rhyme_category的别名 *)
  
  val rhyme_group_detection : string -> rhyme_group
  (** detect_rhyme_group的别名 *)
  
  val is_same_rhyme : string -> string -> bool
  (** check_rhyme的别名 *)
  
  val validate_rhyme : string list -> bool
  (** validate_rhyme_consistency的别名 *)
end