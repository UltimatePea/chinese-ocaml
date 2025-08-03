(** 骆言诗词统一API接口 - Issue #2084 最终整合
 *
 * 此接口是Issue #2084架构整合的最终成果，提供简洁、统一、高效的骆言诗词编程API。
 *
 * **整合成果**: 298个文件 → 25个核心模块 (92%减少) ✨
 *
 * @author Whisky, PR Worker
 * @consolidation_issue #2084
 * @version 1.0 - 统一诗词API接口
 * @achievement 298→25文件架构整合成功
 *)

(** {1 核心系统模块} *)

module RhymeSystem = Rhyme_system_unified
module DataSystem = Data_system_unified
module CacheSystem = Cache_system_unified  
module ArtisticSystem = Artistic_evaluators

(* 重新导出核心类型 *)
include module type of Poetry_core.Types

(** {1 统一诗词处理API} *)

(** 诗词基础信息 *)
type poem_info = {
  title : string option;
  author : string option;
  dynasty : string option;
  verses : string list;
  poem_type : poetry_form option;
  metadata : (string * string) list;
}

(** 诗词分析结果 *)
type poem_analysis = {
  rhyme_analysis : RhymeSystem.RhymeValidator.validation_result;
  meter_analysis : RhymeSystem.PoetryMeter.meter_result;
  artistic_analysis : ArtisticSystem.artistic_evaluation;
  data_quality : float;
  overall_score : float;
  recommendations : string list;
}

(** {1 快速分析接口} *)

(** 快速诗词检查 - 骆言编程最常用功能 *)
val quick_poem_check : string list -> 
  < rhyme_score : float; artistic_score : float; overall_score : float; 
    detected_form : RhymeSystem.PoetryMeter.meter_type option; 
    suggestions : string list; analysis_time : float;
    quality_grade : [`Excellent | `Good | `Fair | `Poor] >

(** 详细诗词分析 *)
val comprehensive_poem_analysis : poem_info -> poem_analysis

(** {1 字符和韵律查询} *)

(** 查找字符完整信息 *)
val lookup_character : string -> string option

(** 查找韵律匹配 *)
val find_rhyme_matches : string -> int -> (string * string option) list

(** 获取韵组字符 *)
val get_rhyme_group_chars : rhyme_group -> string list

(** {1 诗词创作辅助} *)

(** 诗词创作建议 *)
type creation_suggestion = {
  rhyme_chars : string list;
  meter_pattern : string;
  style_tips : string list;
  cultural_elements : string list;
}

(** 获取创作建议 *)
val get_creation_suggestions : poetry_form option -> rhyme_group -> creation_suggestion

(** {1 系统管理和统计} *)

(** 系统状态 *)
type system_status = {
  rhyme_system : (string * string) list;
  data_system : (string * string) list;
  cache_system : (string * (string * string) list) list;
  total_characters : int;
  system_uptime : float;
  memory_usage : string;
}

(** 获取系统状态 *)
val get_system_status : unit -> system_status

(** 执行系统维护 *)
val perform_system_maintenance : unit -> bool

(** {1 便捷函数和向后兼容} *)

(** 检查单句韵律 *)
val check_verse_rhyme : string -> bool * float * string list

(** 检查多句韵律 *)
val check_verses_rhyme : string list -> bool

(** 评价诗词艺术水平 *)
val evaluate_poem_artistic : string list -> float

(** 简单诗词检查 - 最基础API *)
val simple_poem_check : string list -> bool * bool * float

(** {1 专家级功能} *)

(** 导出系统配置 *)
val export_system_config : unit -> (string * string) list

(** 获取整合统计 *)
val get_consolidation_statistics : unit -> (string * string) list

(** 系统自检: (全部正常, 失败系统列表, 总检查项数) *)
val system_self_check : unit -> bool * string list * int