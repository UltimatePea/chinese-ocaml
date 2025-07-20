(** 骆言日志消息模块 - 包含所有预定义的消息格式 *)

(** 错误消息模块 *)
module Error : sig
  (** 生成未定义变量的错误消息 *)
  val undefined_variable : string -> string

  (** 生成函数参数数量不匹配的错误消息 *)
  val function_arity_mismatch : string -> int -> int -> string

  (** 生成类型不匹配的错误消息 *)
  val type_mismatch : string -> string -> string

  (** 生成文件未找到的错误消息 *)
  val file_not_found : string -> string

  (** 生成模块成员未找到的错误消息 *)
  val module_member_not_found : string -> string -> string
end

(** 编译器消息模块 *)
module Compiler : sig
  (** 生成正在编译文件的消息 *)
  val compiling_file : string -> string

  (** 生成编译完成的消息 *)
  val compilation_complete : int -> float -> string

  (** 生成分析统计的消息 *)
  val analysis_stats : int -> int -> string
end

(** 调试消息模块 *)
module Debug : sig
  (** 生成变量值的调试消息 *)
  val variable_value : string -> string -> string

  (** 生成函数调用的调试消息 *)
  val function_call : string -> string list -> string

  (** 生成类型推断的调试消息 *)
  val type_inference : string -> string -> string
end