(** 统一Token注册系统接口 - 管理token映射和转换 *)

open Yyocamlc_lib.Token_types

type mapping_entry = {
  source : string;  (** 源字符串 *)
  target : token;  (** 目标token *)
  priority : int;  (** 优先级 (1=高, 2=中, 3=低) *)
  category : string;  (** 分类信息 *)
  enabled : bool;  (** 是否启用 *)
}
(** 映射条目类型 *)

(** Token注册表模块 *)
module TokenRegistry : sig
  val register_mapping : mapping_entry -> unit
  (** 注册单个映射 *)

  val register_batch : mapping_entry list -> unit
  (** 批量注册映射 *)

  val find_mapping : string -> mapping_entry option
  (** 查找映射 - 支持优先级排序 *)

  val find_all_mappings : string -> mapping_entry list
  (** 查找所有映射 *)

  val reverse_lookup : token -> string list
  (** 反向查找 *)

  val check_conflicts : unit -> (string * mapping_entry list) list
  (** 检查映射冲突 *)

  val get_stats : unit -> int * int * int * int
  (** 获取统计信息 *)

  val clear : unit -> unit
  (** 清空注册表 *)
end

(** 映射Builder - 提供便捷的映射创建 API *)
module MappingBuilder : sig
  val make_mapping :
    string -> token -> ?priority:int -> ?category:string -> ?enabled:bool -> unit -> mapping_entry
  (** 创建映射条目 *)

  val high_priority : string -> token -> mapping_entry
  (** 高优先级映射 *)

  val medium_priority : string -> token -> mapping_entry
  (** 中优先级映射 *)

  val low_priority : string -> token -> mapping_entry
  (** 低优先级映射 *)

  val with_category : string -> token -> string -> mapping_entry
  (** 带分类的映射 *)

  val disabled : string -> token -> mapping_entry
  (** 禁用的映射 *)

  val batch_mappings : (string * token * int * string) list -> mapping_entry list
  (** 批量创建器 *)
end

(** 数据驱动的映射注册器 - 替代硬编码方案 *)
module DataDrivenMappings : sig
  val register_core_mappings : unit -> unit
  (** 从内置数据注册映射 *)

  val register_runtime_extensions : unit -> unit
  (** 注册扩展映射 *)

  val validate_mappings : unit -> unit
  (** 验证映射完整性 *)

  val initialize_all : unit -> unit
  (** 统一初始化函数 *)
end

val initialize : unit -> unit
(** 初始化注册表 *)
