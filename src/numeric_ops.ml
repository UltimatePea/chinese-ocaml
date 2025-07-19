(** 统一数值操作模块 - 消除内置函数中重复的数值类型处理模式 *)

open Value_operations
open Builtin_error

(** 数值二元操作类型 *)
type numeric_binary_op = {
  int_op : int -> int -> int;
  float_op : float -> float -> float;
  mixed_op : float -> float -> float;
}

(** 应用数值二元操作 - 处理所有的数值类型组合 *)
let apply_numeric_binary_op op v1 v2 = 
  match (v1, v2) with
  | IntValue a, IntValue b -> IntValue (op.int_op a b)
  | FloatValue a, FloatValue b -> FloatValue (op.float_op a b)
  | IntValue a, FloatValue b -> FloatValue (op.mixed_op (float_of_int a) b)
  | FloatValue a, IntValue b -> FloatValue (op.mixed_op a (float_of_int b))
  | _ -> failwith "非数值类型"

(** 用于fold操作的数值处理器 *)
let create_numeric_folder (op: numeric_binary_op) (error_msg: string) =
  fun acc elem ->
    try apply_numeric_binary_op op acc elem
    with _ -> runtime_error error_msg

(** 预定义的常用数值操作 *)

(** 加法操作 *)
let add_op = {
  int_op = (+);
  float_op = (+.);
  mixed_op = (+.);
}

(** 最大值操作 *)
let max_op = {
  int_op = max;
  float_op = max;
  mixed_op = max;
}

(** 最小值操作 *)
let min_op = {
  int_op = min;
  float_op = min;
  mixed_op = min;
}

(** 乘法操作 *)
let multiply_op = {
  int_op = ( * );
  float_op = ( *. );
  mixed_op = ( *. );
}

(** 通用的数值列表折叠函数 *)
let fold_numeric_list op initial_value lst error_msg =
  List.fold_left (create_numeric_folder op error_msg) initial_value lst

(** 通用的非空数值列表处理函数 *)
let process_nonempty_numeric_list op lst error_msg =
  match lst with
  | first :: rest -> List.fold_left (create_numeric_folder op error_msg) first rest
  | [] -> runtime_error "列表不能为空"

(** 数值类型检查 *)
let is_numeric = function
  | IntValue _ | FloatValue _ -> true
  | _ -> false

(** 验证列表是否为数值列表 *)
let validate_numeric_list lst function_name =
  if List.for_all is_numeric lst then lst
  else runtime_error (function_name ^ "只能用于数字列表")

(** 创建简化的数值聚合函数 *)
let create_numeric_aggregator op zero_value error_msg =
  fun lst ->
    let validated_lst = validate_numeric_list lst error_msg in
    fold_numeric_list op zero_value validated_lst error_msg

(** 创建简化的非空数值聚合函数 *)
let create_nonempty_numeric_aggregator op error_msg =
  fun lst ->
    let validated_lst = validate_numeric_list lst error_msg in
    process_nonempty_numeric_list op validated_lst error_msg