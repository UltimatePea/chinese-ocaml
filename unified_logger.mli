(** 统一日志系统接口 - 用于消除项目中的printf重复调用 *)

(** 日志级别定义 *)
type log_level = 
  | Debug    (** 调试信息 *)
  | Info     (** 一般信息 *)
  | Warning  (** 警告信息 *)
  | Error    (** 错误信息 *)

(** 设置全局日志级别 *)
val set_log_level : log_level -> unit

(** 基础日志函数 *)
val debug : string -> string -> unit
val info : string -> string -> unit  
val warning : string -> string -> unit
val error : string -> string -> unit

(** 带格式化的日志函数 *)
val debugf : string -> ('a, unit, string, unit) format4 -> 'a
val infof : string -> ('a, unit, string, unit) format4 -> 'a
val warningf : string -> ('a, unit, string, unit) format4 -> 'a
val errorf : string -> ('a, unit, string, unit) format4 -> 'a

(** 专门的消息模块 *)
module Messages : sig
  (** 错误消息模块 *)
  module Error : sig
    val undefined_variable : string -> string
    val function_arity_mismatch : string -> int -> int -> string
    val type_mismatch : string -> string -> string
    val file_not_found : string -> string
    val module_member_not_found : string -> string -> string
  end
  
  (** 编译器消息模块 *)
  module Compiler : sig
    val compiling_file : string -> string
    val compilation_complete : int -> float -> string
    val analysis_stats : int -> int -> string
  end
  
  (** C代码生成消息模块 *)
  module Codegen : sig
    val luoyan_int : int -> string
    val luoyan_string : string -> string
    val luoyan_call : string -> int -> string -> string
    val luoyan_bool : bool -> string
    val luoyan_float : float -> string
  end
  
  (** 调试消息模块 *)
  module Debug : sig
    val variable_value : string -> string -> string
    val function_call : string -> string list -> string
    val type_inference : string -> string -> string
    val infer_calls : int -> string
  end
  
  (** 位置信息模块 *)
  module Position : sig
    val format_position : string -> int -> int -> string
    val format_error_with_position : string -> string -> string -> string
  end
end

(** 结构化日志模块 *)
module Structured : sig
  val log_with_context : log_level -> string -> string -> (string * string) list -> unit
  val debugf_ctx : string -> (string * string) list -> ('a, unit, string, unit) format4 -> 'a
  val infof_ctx : string -> (string * string) list -> ('a, unit, string, unit) format4 -> 'a
  val warningf_ctx : string -> (string * string) list -> ('a, unit, string, unit) format4 -> 'a
  val errorf_ctx : string -> (string * string) list -> ('a, unit, string, unit) format4 -> 'a
end

(** 性能监控日志模块 *)
module Performance : sig
  val compilation_stats : files_compiled:int -> total_time:float -> memory_used:int -> unit
  val cache_stats : hits:int -> misses:int -> hit_rate:float -> unit
  val parsing_time : string -> float -> unit
end

(** 用户输出模块 - 用于替代直接的打印输出 *)
module UserOutput : sig
  val success : string -> unit
  val warning : string -> unit
  val error : string -> unit
  val info : string -> unit
  val progress : string -> unit
end

(** 兼容性函数 - 用于逐步迁移 *)
module Legacy : sig
  val printf : ('a, unit, string, unit) format4 -> 'a
  val eprintf : ('a, unit, string, unit) format4 -> 'a
  val sprintf : ('a, unit, string) format -> 'a
end