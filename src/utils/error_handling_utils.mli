(** 通用错误处理工具模块接口 - 统一项目中的错误处理模式 *)

(** 错误处理结果类型 - 扩展标准Result类型 *)
type ('a, 'e) error_result = ('a, 'e) result

(** 简化的位置信息类型 - 避免循环依赖 *)
type simple_position = {
  filename : string;
  line : int;
  column : int;
}

(** 错误上下文信息 *)
type error_context = {
  function_name : string;
  module_name : string;
  position : simple_position option;
  additional_info : (string * string) list;
}

(** 格式化错误消息类型 *)
type formatted_error = {
  raw_error : string;
  context : error_context;
  formatted_message : string;
}

(** Result操作工具函数 *)

(** 安全的Result操作，带错误上下文 *)
val with_error_context : error_context -> ('a, string) result -> ('a, formatted_error) result

(** Result链式操作 - 类似于Result.bind但带错误累积 *)
val chain_results : ('a -> ('b, 'e) result) -> ('a, 'e) result -> ('b, 'e) result

(** 多个Result的批量处理 *)
val collect_results : ('a, 'e) result list -> ('a list, 'e list) result

(** Result映射操作，保持错误类型 *)
val map_result : ('a -> 'b) -> ('a, 'e) result -> ('b, 'e) result

(** Result错误映射操作 *)
val map_error : ('e1 -> 'e2) -> ('a, 'e1) result -> ('a, 'e2) result

(** Try-with异常处理工具 *)

(** 通用异常捕获器 *)
val safe_execute : (unit -> 'a) -> ('a, string) result

(** 带自定义错误消息的异常捕获 *)
val safe_execute_with_msg : string -> (unit -> 'a) -> ('a, string) result

(** 带错误转换的异常捕获 *)
val safe_execute_with_converter : (exn -> string) -> (unit -> 'a) -> ('a, string) result

(** 数值运算安全包装器 *)
val safe_numeric_op : (unit -> 'a) -> ('a, string) result

(** 错误消息构建工具 *)

(** 创建标准化错误上下文 *)
val create_error_context : 
  ?position:simple_position -> 
  ?additional_info:(string * string) list ->
  function_name:string -> 
  module_name:string -> 
  unit -> error_context

(** 格式化错误消息 *)
val format_error : error_context -> string -> formatted_error

(** 创建运行时错误消息 *)
val runtime_error_msg : error_context -> string -> string

(** 创建类型错误消息 *)
val type_error_msg : error_context -> expected:string -> actual:string -> string

(** 创建参数错误消息 *)
val param_error_msg : error_context -> expected:int -> actual:int -> string

(** 错误累积和报告 *)

(** 错误累积器类型 *)
type 'e error_accumulator = {
  errors : 'e list;
  has_errors : bool;
}

(** 创建空的错误累积器 *)
val empty_accumulator : unit -> 'e error_accumulator

(** 向累积器添加错误 *)
val add_error : 'e -> 'e error_accumulator -> 'e error_accumulator

(** 向累积器添加多个错误 *)
val add_errors : 'e list -> 'e error_accumulator -> 'e error_accumulator

(** 从Result向累积器添加错误 *)
val accumulate_result : ('a, 'e) result -> 'e error_accumulator -> 'e error_accumulator

(** 将累积器转换为Result *)
val accumulator_to_result : 'e error_accumulator -> (unit, 'e list) result

(** 便利函数 - 常用错误处理模式 *)

(** Option到Result的转换 *)
val option_to_result : error_msg:string -> 'a option -> ('a, string) result

(** 条件检查 *)
val check_condition : bool -> error_msg:string -> (unit, string) result

(** 非空检查 *)
val check_non_empty : 'a list -> error_msg:string -> ('a list, string) result

(** 范围检查 *)
val check_range : int -> min:int -> max:int -> error_msg:string -> (int, string) result

(** 函数参数数量检查 *)
val check_args_count : int -> expected:int -> function_name:string -> (unit, string) result