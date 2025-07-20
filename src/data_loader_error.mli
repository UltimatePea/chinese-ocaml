(* 数据加载器错误处理模块接口 *)

open Data_loader_types

(** 格式化错误信息 *)
val format_error : data_error -> string

(** 记录错误日志 *)
val log_error : data_error -> unit

(** 处理错误结果 *)
val handle_error_result : 'a data_result -> 'a

(** 将结果转换为选项类型 *)
val result_to_option : 'a data_result -> 'a option

(** 组合多个结果 *)
val combine_results : 'a data_result list -> 'a list data_result