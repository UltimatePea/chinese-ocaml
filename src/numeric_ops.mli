(** 统一数值操作模块 - 消除内置函数中重复的数值类型处理模式 *)

open Value_operations

(** {1 类型定义} *)

(** 数值二元操作类型 *)
type numeric_binary_op = {
  int_op : int -> int -> int;
  float_op : float -> float -> float;
  mixed_op : float -> float -> float;
}

(** {1 数值操作应用} *)

(** 应用数值二元操作 - 处理所有的数值类型组合 *)
val apply_numeric_binary_op : numeric_binary_op -> runtime_value -> runtime_value -> runtime_value

(** {1 数值处理器创建} *)

(** 用于fold操作的数值处理器 *)
val create_numeric_folder : numeric_binary_op -> string -> runtime_value -> runtime_value -> runtime_value

(** {1 预定义数值操作} *)

(** 加法操作 *)
val add_op : numeric_binary_op

(** 最大值操作 *)
val max_op : numeric_binary_op

(** 最小值操作 *)
val min_op : numeric_binary_op

(** 乘法操作 *)
val multiply_op : numeric_binary_op

(** {1 列表折叠函数} *)

(** 通用的数值列表折叠函数 *)
val fold_numeric_list : numeric_binary_op -> runtime_value -> runtime_value list -> string -> runtime_value

(** 通用的非空数值列表处理函数 *)
val process_nonempty_numeric_list : numeric_binary_op -> runtime_value list -> string -> runtime_value

(** {1 数值类型检查} *)

(** 检查是否为数值类型 *)
val is_numeric : runtime_value -> bool

(** 验证列表是否为数值列表 *)
val validate_numeric_list : runtime_value list -> string -> runtime_value list

(** {1 聚合函数创建} *)

(** 创建简化的数值聚合函数 *)
val create_numeric_aggregator : numeric_binary_op -> runtime_value -> string -> runtime_value list -> runtime_value

(** 创建简化的非空数值聚合函数 *)
val create_nonempty_numeric_aggregator : numeric_binary_op -> string -> runtime_value list -> runtime_value