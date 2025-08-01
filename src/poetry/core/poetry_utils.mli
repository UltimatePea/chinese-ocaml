(** 骆言诗词通用工具模块接口 Author: Alpha, 主要工作代理 - 负责功能实现和技术债务处理

    提供诗词模块的通用工具函数和数据结构。 *)

open Poetry_types

(** === 字符串处理工具 === *)

val is_chinese_character : string -> bool
(** 判断字符串是否为中文字符 *)

val extract_chinese_characters : string -> string list
(** 从文本中提取所有中文字符 *)

val normalize_whitespace : string -> string
(** 规范化空白字符 *)

val remove_punctuation : string -> string
(** 移除标点符号 *)

(** === 列表处理工具 === *)

val take : int -> 'a list -> 'a list
(** 取列表前n个元素 *)

val drop : int -> 'a list -> 'a list
(** 丢弃列表前n个元素 *)

val partition_by_size : int -> 'a list -> 'a list list
(** 按指定大小分割列表 *)

val unique_by : ('a -> 'b) -> 'a list -> 'a list
(** 按指定函数去重 *)

(** === 分数和评级工具 === *)

val normalize_score : float -> float -> float -> float
(** 将分数标准化到0-1范围 *)

val score_to_grade : float -> evaluation_grade
(** 将数值分数转换为等级 *)

val grade_to_score : evaluation_grade -> float
(** 将等级转换为数值分数 *)

val weighted_average : float list -> float list -> float analysis_result
(** 计算加权平均值 *)

(** === 缓存工具 === *)

module LRU_Cache : sig
  type ('k, 'v) t

  val create : int -> ('k, 'v) t
  (** 创建指定容量的LRU缓存 *)

  val get : ('k, 'v) t -> 'k -> 'v option
  (** 从缓存获取值 *)

  val put : ('k, 'v) t -> 'k -> 'v -> unit
  (** 向缓存存储值 *)

  val clear : ('k, 'v) t -> unit
  (** 清空缓存 *)

  val size : ('k, 'v) t -> int
  (** 获取缓存当前大小 *)
end

(** === 性能测量工具 === *)

val time_execution : (unit -> 'a) -> 'a * float
(** 测量函数执行时间 *)

val benchmark_function : string -> (unit -> 'a) -> int -> unit
(** 基准测试函数性能 *)

(** === 配置工具 === *)

val load_config_from_json : string -> [`Assoc of (string * [`Null]) list] analysis_result
(** 从JSON文件加载配置 *)

val get_config_value : [`Assoc of (string * [`Null]) list] -> string -> [`Assoc of (string * [`Null]) list] -> [`Assoc of (string * [`Null]) list]
(** 从配置中获取值，支持点分路径 *)

(** === 调试和日志工具 === *)

val enable_debug : unit -> unit
(** 启用调试模式 *)

val disable_debug : unit -> unit
(** 禁用调试模式 *)

val debug_print : ('a, out_channel, unit) format -> 'a
(** 调试输出 *)

val trace_function : string -> ('a -> 'b) -> 'a -> 'b
(** 跟踪函数执行 *)

(** === 比较和排序工具 === *)

val compare_by : ('a -> 'b) -> 'a -> 'a -> int
(** 按指定函数比较 *)

val sort_by_score : ('a * float) list -> ('a * float) list
(** 按分数排序（降序） *)

val group_by : ('a -> 'b) -> 'a list -> ('b * 'a list) list
(** 按指定函数分组 *)

(** === 文本分析工具 === *)

val count_characters : string -> int
(** 计算中文字符数量 *)

val similarity_score : string -> string -> float
(** 计算两个文本的相似度（0-1） *)

(** === 数据验证工具 === *)

val validate_non_empty : string -> string analysis_result
(** 验证文本非空 *)

val validate_length : string -> int -> string analysis_result
(** 验证文本长度 *)

val validate_chinese_only : string -> string analysis_result
(** 验证文本只包含中文字符 *)
