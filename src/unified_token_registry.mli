(** 统一Token注册系统接口 - 管理token映射和转换 *)

open Unified_token_core

(** 映射条目类型 *)
type mapping_entry = {
  source: string;                    (** 源字符串 *)
  target: unified_token;             (** 目标token *)
  priority: token_priority;          (** 优先级 *)
  context: string option;            (** 上下文信息 *)
  enabled: bool;                     (** 是否启用 *)
}

(** Token注册表模块 *)
module TokenRegistry : sig
  (** 注册单个映射 *)
  val register_mapping : mapping_entry -> unit
  
  (** 批量注册映射 *)
  val register_batch : mapping_entry list -> unit
  
  (** 查找映射 - 支持优先级排序 *)
  val find_mapping : string -> mapping_entry option
  
  (** 查找所有映射 *)
  val find_all_mappings : string -> mapping_entry list
  
  (** 反向查找 *)
  val reverse_lookup : unified_token -> string list
  
  (** 检查映射冲突 *)
  val check_conflicts : unit -> (string * mapping_entry list) list
  
  (** 获取统计信息 *)
  val get_stats : unit -> int * int * int * int
  
  (** 清空注册表 *)
  val clear : unit -> unit
end

(** 映射DSL - 提供便捷的映射定义语法 *)
module MappingDSL : sig
  (** 创建映射条目 *)
  val make_mapping : string -> unified_token -> 
    ?priority:token_priority -> ?context:string option -> ?enabled:bool -> 
    unit -> mapping_entry
  
  (** 高优先级映射 *)
  val high_priority : string -> unified_token -> mapping_entry
  
  (** 中优先级映射 *)
  val medium_priority : string -> unified_token -> mapping_entry
  
  (** 低优先级映射 *)
  val low_priority : string -> unified_token -> mapping_entry
  
  (** 带上下文的映射 *)
  val with_context : string -> unified_token -> string -> mapping_entry
  
  (** 禁用的映射 *)
  val disabled : string -> unified_token -> mapping_entry
end

(** 预定义映射注册器 *)
module PredefinedMappings : sig
  (** 注册基础关键字映射 *)
  val register_basic_keywords : unit -> unit
  
  (** 注册数字关键字映射 *)
  val register_number_keywords : unit -> unit
  
  (** 注册类型关键字映射 *)
  val register_type_keywords : unit -> unit
  
  (** 注册运算符映射 *)
  val register_operators : unit -> unit
  
  (** 注册分隔符映射 *)
  val register_delimiters : unit -> unit
  
  (** 注册文言文关键字映射 *)
  val register_wenyan_keywords : unit -> unit
  
  (** 注册古雅体关键字映射 *)
  val register_classical_keywords : unit -> unit
  
  (** 注册所有预定义映射 *)
  val register_all : unit -> unit
end

(** 初始化注册表 *)
val initialize : unit -> unit