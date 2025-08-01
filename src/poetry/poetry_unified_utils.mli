(** 骆言诗词统一工具模块接口 - 韵律工具和辅助模块整合
 *
 * Issue #2015: 韵律工具和辅助模块整合
 * 统一通用工具模块的公共接口定义
 *
 * Author: Whisky, PR Worker
 * @since 2025-08-01
 * @version 1.0 - 初始整合版本
 *)

open Poetry_core.Poetry_types

(** {1 核心模块定义} *)

(** StringSet模块：高效字符串集合操作 *)
module StringSet : Set.S with type elt = string

(** {1 字符串处理工具} *)

(** === UTF-8和中文字符处理 === *)

(** UTF-8字符列表转换函数 *)
val utf8_to_char_list : string -> char list
val string_to_char_list : string -> char list
val char_list_to_string : char list -> string

(** 中文字符处理函数 *)
val is_chinese_char : char -> bool
val filter_chinese_chars : string -> string
val chinese_length : string -> int

(** 字符串边界操作 *)
val get_last_char : string -> char option
val get_first_char : string -> char option

(** === 高级中文字符处理 === *)

(** 判断字符是否为中文字符 *)
val is_chinese_character : string -> bool

(** 从文本中提取所有中文字符 *)
val extract_chinese_characters : string -> string list

(** === 空白字符和格式化处理 === *)

(** 移除字符串中的空白字符 *)
val trim_whitespace : string -> string

(** 规范化空白字符 *)
val normalize_whitespace : string -> string

(** 移除标点符号 *)
val remove_punctuation : string -> string

(** 检查字符串是否为空或仅包含空白字符 *)
val is_empty_or_whitespace : string -> bool

(** === 诗词特定字符串处理 === *)

(** 分割字符串为诗句 *)
val split_verse_lines : string -> string list

(** 规范化诗句格式 *)
val normalize_verse : string -> string

(** 判断两个字符串是否相等（忽略空白） *)
val equal_ignoring_whitespace : string -> string -> bool

(** === 高效子串搜索 === *)

(** 高效子串搜索 *)
val contains_substring : string -> string -> bool

(** {1 列表处理工具} *)

(** === 基础列表操作 === *)

(** 安全获取列表元素 *)
val safe_nth : 'a list -> int -> 'a option

(** 安全获取列表头部 *)
val safe_head : 'a list -> 'a option

(** 安全获取列表尾部 *)
val safe_tail : 'a list -> 'a list option

(** 列表去重 - 使用统一的List_utils实现 *)
val unique_list : 'a list -> 'a list

(** === 高级列表操作 === *)

(** 取列表前n个元素 *)
val take : int -> 'a list -> 'a list

(** 丢弃列表前n个元素 *)
val drop : int -> 'a list -> 'a list

(** 按大小分割列表 *)
val partition_by_size : int -> 'a list -> 'a list list

(** 按函数去重 *)
val unique_by : ('a -> 'b) -> 'a list -> 'a list

(** === 集合操作 === *)

(** 计算两个列表的交集 *)
val intersect : 'a list -> 'a list -> 'a list

(** 计算两个列表的并集 *)
val union : 'a list -> 'a list -> 'a list

(** 映射并过滤None值 *)
val filter_map : ('a -> 'b option) -> 'a list -> 'b list

(** === 分组和枚举 === *)

(** 创建带编号的列表 *)
val enumerate : 'a list -> (int * 'a) list

(** 按函数分组 *)
val group_by : ('a -> 'b) -> 'a list -> ('b * 'a list) list

(** {1 评分和评级工具} *)

(** 标准化评分 *)
val normalize_score : float -> float -> float -> float

(** 评分转等级 *)
val score_to_grade : float -> evaluation_grade

(** 等级转评分 *)
val grade_to_score : evaluation_grade -> float

(** 加权平均计算 *)
val weighted_average : float list -> float list -> (float, string) result

(** {1 缓存工具} *)

(** LRU缓存模块 *)
module LRU_Cache : sig
  type ('k, 'v) t

  (** 创建缓存 *)
  val create : int -> ('k, 'v) t

  (** 获取缓存值 *)
  val get : ('k, 'v) t -> 'k -> 'v option

  (** 存储缓存值 *)
  val put : ('k, 'v) t -> 'k -> 'v -> unit

  (** 清空缓存 *)
  val clear : ('k, 'v) t -> unit

  (** 获取缓存大小 *)
  val size : ('k, 'v) t -> int
end

(** {1 性能测量工具} *)

(** 执行时间测量 *)
val time_execution : (unit -> 'a) -> 'a * float

(** 基准测试函数 *)
val benchmark_function : string -> (unit -> 'a) -> int -> unit

(** {1 配置工具} *)

(** 从JSON文件加载配置 *)
val load_config_from_json : string -> (Yojson.Safe.t, string) result

(** 获取配置值 *)
val get_config_value : Yojson.Safe.t -> string -> Yojson.Safe.t -> Yojson.Safe.t

(** {1 调试和日志工具} *)

(** 启用调试 *)
val enable_debug : unit -> unit

(** 禁用调试 *)
val disable_debug : unit -> unit

(** 调试打印 *)
val debug_print : ('a, out_channel, unit) format -> 'a

(** 跟踪函数执行 *)
val trace_function : string -> ('a -> 'b) -> 'a -> 'b

(** {1 比较和排序工具} *)

(** 按函数比较 *)
val compare_by : ('a -> 'b) -> 'a -> 'a -> int

(** 按评分排序 *)
val sort_by_score : ('a * float) list -> ('a * float) list

(** {1 文本分析工具} *)

(** 计算字符数 *)
val count_characters : string -> int

(** 计算文本相似度 *)
val similarity_score : string -> string -> float

(** {1 词汇计数分析} *)

(** 计算意象词汇数量 *)
val count_imagery_words : string -> int

(** 计算雅致词汇数量 *)
val count_elegant_words : string -> int

(** {1 改进建议生成} *)

(** 生成改进建议 *)
val generate_improvement_suggestions : artistic_report -> string list

(** {1 高阶分析工具} *)

(** 检测艺术缺陷 *)
val detect_artistic_flaws : string -> artistic_report -> string list

(** 计算总体评分 *)
val calculate_overall_score : artistic_report -> float

(** {1 数据验证工具} *)

(** 验证非空 *)
val validate_non_empty : string -> (string, string) result

(** 验证长度 *)
val validate_length : string -> int -> (string, string) result

(** 验证仅中文字符 *)
val validate_chinese_only : string -> (string, string) result

(** {1 字符串格式化辅助函数} *)

(** 格式化列表 *)
val format_list : ('a -> string) -> string -> 'a list -> string