(** 通用错误处理工具模块接口 - 统一项目中的错误处理模式 *)

(** 错误上下文信息 - 简化设计 *)
type error_context = {
  function_name : string;
  module_name : string;
}

(** 核心Result操作工具函数 *)

(** Result错误映射操作，添加模块上下文 *)
val map_error_with_context : error_context -> ('a, string) result -> ('a, string) result

(** 核心异常处理工具 *)

(** 通用异常捕获器 *)
val safe_execute : (unit -> 'a) -> ('a, string) result

(** 数值运算安全包装器 *)
val safe_numeric_op : (unit -> 'a) -> ('a, string) result

(** 核心错误消息构建工具 *)

(** 创建错误上下文 *)
val create_error_context : function_name:string -> module_name:string -> error_context

(** 格式化错误消息 *)
val format_error_msg : error_context -> string -> string

(** 创建参数错误消息 *)
val param_error_msg : error_context -> expected:int -> actual:int -> string

(** 核心便利函数 - 最常用的错误处理模式 *)

(** Option到Result的转换 *)
val option_to_result : error_msg:string -> 'a option -> ('a, string) result

(** 条件检查 *)
val check_condition : bool -> error_msg:string -> (unit, string) result

(** 函数参数数量检查 *)
val check_args_count : int -> expected:int -> function_name:string -> (unit, string) result