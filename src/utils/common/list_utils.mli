(** 骆言统一列表工具模块接口 - Unified List Utilities Interface *)

(** Either类型定义 *)
type ('a, 'b) either = Left of 'a | Right of 'b

(** 安全的列表操作工具 *)
module Safe : sig
  (** 安全的列表头部获取 *)
  val head : 'a list -> 'a option

  (** 安全的列表尾部获取 *)
  val tail : 'a list -> 'a list option

  (** 安全的列表元素访问 *)
  val nth : 'a list -> int -> 'a option

  (** 安全的列表最后一个元素 *)
  val last : 'a list -> 'a option

  (** 安全的列表初始部分（除最后一个元素） *)
  val init : 'a list -> 'a list option
end

(** 列表转换和映射工具 *)
module Transform : sig
  (** 带索引的映射 *)
  val mapi_safe : (int -> 'a -> 'b option) -> 'a list -> 'b list

  (** 过滤并映射，一步完成 *)
  val filter_map : ('a -> 'b option) -> 'a list -> 'b list

  (** 分区并映射 *)
  val partition_map : ('a -> ('b, 'c) either) -> 'a list -> 'b list * 'c list

  (** 展平并映射 *)
  val flat_map : ('a -> 'b list) -> 'a list -> 'b list

  (** 累积映射（保留中间结果） *)
  val scan_left : ('acc -> 'a -> 'acc) -> 'acc -> 'a list -> 'acc list
end

(** 列表聚合和统计工具 *)
module Aggregate : sig
  (** 安全的列表求和 *)
  val sum_int : int list -> int

  (** 安全的列表求和（浮点数） *)
  val sum_float : float list -> float

  (** 求列表最大值 *)
  val max_opt : 'a list -> 'a option

  (** 求列表最小值 *)
  val min_opt : 'a list -> 'a option

  (** 计算列表平均值 *)
  val average_float : float list -> float option

  (** 计算列表中元素出现次数 *)
  val count_occurrences : 'a -> 'a list -> int

  (** 按条件计数 *)
  val count_if : ('a -> bool) -> 'a list -> int
end

(** 列表分组和排序工具 *)
module Group : sig
  (** 按键值分组 *)
  val group_by : ('a -> 'b) -> 'a list -> ('b * 'a list) list

  (** 去重（保持顺序） *)
  val unique : 'a list -> 'a list

  (** 按条件去重 *)
  val unique_by : ('a -> 'b) -> 'a list -> 'a list

  (** 分块处理 *)
  val chunk : int -> 'a list -> 'a list list

  (** 交替组合两个列表 *)
  val interleave : 'a list -> 'a list -> 'a list
end

(** 列表验证和检查工具 *)
module Validate : sig
  (** 检查列表是否所有元素都满足条件 *)
  val all : ('a -> bool) -> 'a list -> bool

  (** 检查列表是否有元素满足条件 *)
  val any : ('a -> bool) -> 'a list -> bool

  (** 检查列表是否为空 *)
  val is_empty : 'a list -> bool

  (** 检查列表是否有重复元素 *)
  val has_duplicates : 'a list -> bool

  (** 检查两个列表是否有相同元素 *)
  val has_intersection : 'a list -> 'a list -> bool
end

(** 高级列表操作工具 *)
module Advanced : sig
  (** 列表的笛卡尔积 *)
  val cartesian_product : 'a list -> 'b list -> ('a * 'b) list

  (** 列表的排列组合 *)
  val combinations : int -> 'a list -> 'a list list

  (** 列表的全排列 *)
  val permutations : 'a list -> 'a list list

  (** 滑动窗口 *)
  val sliding_window : int -> 'a list -> 'a list list

  (** 转置（矩阵转置） *)
  val transpose : 'a list list -> 'a list list
end