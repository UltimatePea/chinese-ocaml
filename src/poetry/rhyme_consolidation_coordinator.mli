(** 韵律模块整合协调器接口 - Issue #1999 总协调实施
    
    Author: Whisky, PR Worker
    @version 1.0 - Poetry韵律模块整合协调器 
    @since 2025-08-01
    @implements Issue #1999 - Poetry韵律模块统一整合实施 *)

open Rhyme_types_unified

(** {1 整合协调器核心} *)

(** 整合状态类型 *)
type consolidation_status = {
  modules_loaded: string list;                   (** 已加载模块 *)
  legacy_modules_active: string list;           (** 活跃的遗留模块 *)
  performance_baseline: float option;           (** 性能基线 *)
  data_integrity_verified: bool;                (** 数据完整性验证状态 *)
  cache_initialized: bool;                      (** 缓存初始化状态 *)
  compatibility_mode: bool;                     (** 兼容模式状态 *)
  last_health_check: float;                     (** 最后健康检查时间 *)
}

(** {2 模块初始化和协调} *)

(** 初始化所有整合模块 *)
val initialize_consolidated_modules : unit -> consolidation_status

(** {3 统一对外接口} *)

(** 主要查询接口 - 统一所有查询功能 *)
val unified_rhyme_lookup : string -> unified_rhyme_entry option

(** 主要匹配接口 - 统一所有匹配功能 *)
val unified_rhyme_match : string -> string -> bool

(** 主要韵组接口 - 统一所有韵组功能 *)  
val unified_rhyme_group_lookup : rhyme_group -> string list

(** 批量处理接口 - 高性能批量操作 *)
val unified_batch_lookup : string list -> (string * (rhyme_group * rhyme_category)) list

(** 高级查询接口 - 支持复杂查询参数 *)
val unified_advanced_query : query_params -> query_result

(** {4 性能监控和健康检查} *)

(** 执行完整健康检查 *)
val perform_health_check : unit -> bool

(** 生成性能报告 *)
val generate_performance_report : unit -> unit

(** {5 向后兼容协调} *)

(** 兼容模式切换 *)
val toggle_compatibility_mode : bool -> unit

(** 遗留API兼容层 - 完整兼容所有原有接口 *)
module Legacy_Compatibility : sig
  module Rhyme_Types : sig
    type rhyme_entry = unified_rhyme_entry
    type rhyme_database = unified_rhyme_database
    val create_entry : string -> rhyme_group -> rhyme_category -> unified_rhyme_entry
  end
  
  module An_Rhyme_Data : sig
    val ping_sheng_chars : string list
    val ze_sheng_chars : string list
    val data : (string * rhyme_group * rhyme_category * float) list
  end
  
  module Feng_Rhyme_Data : sig
    val ping_sheng_chars : string list
    val ze_sheng_chars : string list
    val data : (string * rhyme_group * rhyme_category * float) list
  end
  
  module Hua_Rhyme_Data : sig
    val ping_sheng_chars : string list
    val ze_sheng_chars : string list
    val data : (string * rhyme_group * rhyme_category * float) list
  end
  
  module Rhyme_Database : sig
    val query_rhyme : string -> unified_rhyme_entry option
    val find_rhymes : string -> string list
  end
  
  module Unified_Rhyme_Data : sig
    val load_rhyme_data_from_json : unit -> (rhyme_group * rhyme_category * string list) list
  end
  
  module Rhyme_Core_Unified : sig
    val lookup_character : string -> unified_rhyme_entry option
    val check_rhyme : string -> string -> bool
  end
end

(** {6 模块间依赖管理} *)

(** 检查模块依赖 *)
val check_module_dependencies : unit -> bool

(** 获取整合状态 *)
val get_consolidation_status : unit -> consolidation_status

(** {7 错误处理和恢复} *)

(** 尝试自动修复问题 *)
val attempt_auto_repair : unit -> bool

(** {8 完整性测试套件} *)

(** 运行完整性测试 *)
val run_integration_tests : unit -> bool

(** 模块整合完成入口点 *)
val complete_consolidation : unit -> bool