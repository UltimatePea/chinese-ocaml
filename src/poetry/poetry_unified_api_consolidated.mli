(** Poetry Unified API Consolidated Module Interface - Issue #1999
 * 
 * 对外统一API接口模块
 * Author: Whisky, PR Worker
 *)

(** {1 统一类型导出} *)

include module type of Poetry_core_consolidated

(** {1 统一初始化接口} *)

(** 初始化Poetry模块 *)
val initialize_poetry_system : ?performance_mode:bool -> unit -> unit

(** 检查系统是否已初始化 *)
val is_system_ready : unit -> bool

(** {1 核心查询接口} *)

(** 查找韵律信息 *)
val find_rhyme : string -> rhyme_info option

(** 检查两字是否押韵 *)
val check_rhyme : string -> string -> bool

(** 批量韵律查询 *)
val batch_find_rhyme : string list -> (string * rhyme_info option) list

(** 查找同韵字 *)
val find_rhyme_partners : string -> int -> string list

(** {1 诗词评价接口} *)

(** 全面诗词评价 *)
val evaluate_poem : string list -> evaluation_result

(** 快速诗词评分 *)
val quick_evaluate : string list -> float

(** {1 韵律分析接口} *)

(** 分析诗词韵律模式 *)
val analyze_rhyme_pattern : string list -> (int * rhyme_match_result) list

(** 获取韵律改进建议 *)
val get_rhyme_suggestions : string list -> string list

(** 验证诗词格律 *)
val validate_poetry_form : string list -> (bool * string list)

(** {1 艺术性分析接口} *)

(** 分析诗词意象 *)
val analyze_imagery : string list -> Poetry_artistic_engine_consolidated.imagery_element list

(** 获取艺术性改进建议 *)
val get_artistic_suggestions : string list -> string list

(** {1 数据查询接口} *)

(** 获取韵部字符列表 *)
val get_rhyme_group_chars : rhyme_group -> string list

(** 按声调查找字符 *)
val find_chars_by_tone : int -> (string * rhyme_info) list

(** 按声调分类查找字符 *)
val find_chars_by_category : rhyme_category -> (string * rhyme_info) list

(** 获取所有可用韵部 *)
val get_available_rhyme_groups : unit -> rhyme_group list

(** {1 性能监控接口} *)

(** 获取系统性能统计 *)
val get_performance_stats : unit -> string

(** 打印性能报告 *)
val print_performance_report : unit -> unit

(** {1 系统管理接口} *)

(** 重置系统统计 *)
val reset_system_stats : unit -> unit

(** 清理系统缓存 *)
val cleanup_system : unit -> unit

(** 重新加载数据 *)
val reload_data : unit -> unit

(** {1 向后兼容接口} *)

module Compatibility : sig
  val find_rhyme_info : string -> rhyme_info option
  val detect_rhyme_category : string -> rhyme_category
  val check_rhyme_match : string -> string -> bool
  val evaluate_poem_quality : string list -> evaluation_result
  val preload_rhyme_data : unit -> unit
  val cleanup_cache : unit -> unit
  
  module Rhyme_api_core : sig
    val find_rhyme_info : string -> rhyme_info option
    val detect_rhyme_category : string -> rhyme_category
  end
  
  module Poetry_rhyme_engine : sig
    val initialize_engine : ?performance_mode:bool -> unit -> unit
    val validate_poem_rhyme : string list -> (int * rhyme_match_result) list
    val suggest_rhyme_improvements : string list -> string list
  end
  
  module Poetry_artistic_engine : sig
    val comprehensive_artistic_evaluation : string list -> Poetry_artistic_engine_consolidated.comprehensive_artistic_evaluation
    val generate_improvement_guidance : Poetry_artistic_engine_consolidated.comprehensive_artistic_evaluation -> string list
  end
  
  module Unified_rhyme_data : sig
    val load_rhyme_data_to_cache : unit -> unit
  end
  
  module Rhyme_cache : sig
    val clear_cache_global : unit -> unit
  end
end

(** {1 高级功能接口} *)

(** 诗词创作辅助 *)
val suggest_next_line_rhyme : string list -> int -> string list

(** 批量诗词评价 *)
val batch_evaluate_poems : string list list -> (string list * evaluation_result) list

(** 生成系统状态报告 *)
val generate_system_report : unit -> string