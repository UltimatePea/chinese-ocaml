(** 统一格律检查引擎接口 - 重构版本
    
    此模块提供Poetry系统的统一格律检查功能，基于模块化的检查器架构，
    支持律诗、绝句、词、曲等多种诗体的格律检查。
    
    重构后的接口：
    - 从Meter_types模块导入核心类型定义
    - 从Poetry_forms模块导入预定义格律模式
    - 保持向后兼容的主要API函数
    
    @author Alpha, 主要开发代理 - Poetry模块重构团队
    @version 3.0 (Phase 2: 模块化重构版)
    @since 2025-07-30
    @fix_issue #1775 - 严重技术债务修复 *)

open Rhythm_analyzer
open Artistic_evaluator

(** {1 核心类型 - 从Meter_types重新导出} *)

include module type of Meter_types

(** {1 异常定义} *)

exception MeterEngineError of string

(** {1 引擎状态管理} *)

(** 创建新的格律引擎状态 *)
val create_meter_engine_state : analyzer_state -> artistic_evaluator_state -> meter_engine_state

(** 初始化格律引擎 (向后兼容函数) *)
val initialize_meter_engine : analyzer_state -> artistic_evaluator_state -> meter_engine_state

(** {1 诗体识别功能} *)

(** 基于行数识别诗体 *)
val detect_form_by_line_count : string list -> poetry_form option

(** 基于字数模式识别诗体 *)
val detect_form_by_line_lengths : string list -> poetry_form option

(** 识别诗体 *)
val recognize_poetry_form : string list -> meter_engine_state -> form_recognition_result

(** {1 格律检查功能} *)

(** 执行格律检查 *)
val check_meter : string list -> meter_pattern -> meter_engine_state -> meter_check_result

(** 自动识别诗体并检查格律 *)
val auto_check_meter : string list -> meter_engine_state -> form_recognition_result * meter_check_result

(** {1 统计和工具函数} *)

(** 获取格律引擎统计信息 *)
val get_meter_engine_statistics : meter_engine_state -> (string * string) list

(** 清理格律引擎缓存 *)
val clear_meter_engine_cache : meter_engine_state -> meter_engine_state

(** 格式化诗体类型 *)
val format_poetry_form : poetry_form -> string

(** 格式化诗体识别结果 *)
val format_recognition_result : form_recognition_result -> string

(** 格式化格律检查结果 *)
val format_meter_check_result : meter_check_result -> string