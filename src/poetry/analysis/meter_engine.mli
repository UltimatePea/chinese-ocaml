(** 统一格律检查引擎接口 - Phase 2: Engine Layer Refactoring
    
    此模块提供Poetry系统的统一格律检查功能，整合诗词格律验证和分析，
    支持律诗、绝句、词、曲等多种诗体的格律检查。
    
    技术债务修复：整合分散的格律检查逻辑，建立统一诗体定义框架
    
    @author Alpha, 主要开发代理 - Poetry模块重构团队
    @version 2.0 (Phase 2: 引擎层重构版)
    @since 2025-07-27
    @fix_issue #1501 *)

open Poetry_core.Poetry_types
open Rhythm_analyzer
open Artistic_evaluator

(** {1 格律类型定义} *)

(** 诗体类型 *)
type poetry_form =
  | LuShi of int  (** 律诗 (5言/7言) *)
  | JueJu of int  (** 绝句 (5言/7言) *)
  | Ci of string  (** 词 (词牌名) *)
  | Qu of string  (** 曲 (曲牌名) *)
  | GuTi  (** 古体诗 *)
  | ZiYou  (** 自由体 *)

type meter_pattern = {
  form : poetry_form;  (** 诗体形式 *)
  required_lines : int;  (** 要求行数 *)
  line_lengths : int list;  (** 各行字数要求 *)
  rhyme_scheme : rhyme_group option list;  (** 韵式要求 *)
  tonal_pattern : rhyme_category list list;  (** 平仄模式 *)
  parallelism_requirements : (int * int) list;  (** 对仗要求 (行号对) *)
}
(** 格律模式 *)

type meter_check_result = {
  pattern : meter_pattern;  (** 使用的格律模式 *)
  verse_count : int;  (** 实际诗句数 *)
  line_length_compliance : bool list;  (** 各行字数符合度 *)
  rhyme_compliance : bool list;  (** 各行韵律符合度 *)
  tonal_compliance : bool list;  (** 各行平仄符合度 *)
  parallelism_compliance : bool list;  (** 对仗符合度 *)
  overall_compliance : float;  (** 整体符合度 *)
  violations : string list;  (** 违规项列表 *)
  suggestions : string list;  (** 改进建议 *)
}
(** 格律检查结果 *)

type form_recognition_result = {
  detected_form : poetry_form;  (** 检测到的诗体 *)
  confidence : float;  (** 识别置信度 *)
  reasons : string list;  (** 识别依据 *)
  alternatives : (poetry_form * float) list;  (** 备选诗体 *)
}
(** 诗体识别结果 *)

(** {1 预定义格律模式} *)

val wuyan_lushi_pattern : meter_pattern
(** 五言律诗格律模式 *)

val qiyan_lushi_pattern : meter_pattern
(** 七言律诗格律模式 *)

val wuyan_jueju_pattern : meter_pattern
(** 五言绝句格律模式 *)

val qiyan_jueju_pattern : meter_pattern
(** 七言绝句格律模式 *)

val guti_pattern : meter_pattern
(** 古体诗格律模式 (较宽松) *)

(** {1 格律引擎状态} *)

type meter_engine_state
(** 格律引擎状态 - 不透明类型 *)

exception MeterEngineError of string
(** 格律引擎异常 *)

val initialize_meter_engine : analyzer_state -> artistic_evaluator_state -> meter_engine_state
(** 初始化格律引擎
    @param rhythm_analyzer 韵律分析引擎状态
    @param artistic_evaluator 艺术性评价引擎状态
    @return 初始化的格律引擎状态 *)

(** {1 诗体识别功能} *)

val recognize_poetry_form : string list -> meter_engine_state -> form_recognition_result
(** 根据诗句特征识别诗体
    @param verses 诗句列表
    @param meter_state 格律引擎状态
    @return 诗体识别结果 *)

(** {1 格律检查功能} *)

val check_meter : string list -> meter_pattern -> meter_engine_state -> meter_check_result
(** 执行格律检查
    @param verses 诗句列表
    @param pattern 格律模式
    @param meter_state 格律引擎状态
    @return 格律检查结果
    @raise MeterEngineError 当检查失败时 *)

(** {1 自动格律检查} *)

val auto_check_meter :
  string list -> meter_engine_state -> form_recognition_result * meter_check_result
(** 自动识别诗体并检查格律
    @param verses 诗句列表
    @param meter_state 格律引擎状态
    @return (诗体识别结果, 格律检查结果) *)

(** {1 统计和工具函数} *)

val get_meter_engine_statistics : meter_engine_state -> (string * string) list
(** 获取格律引擎统计信息
    @param meter_state 格律引擎状态
    @return 统计信息键值对列表 *)

val clear_meter_engine_cache : meter_engine_state -> meter_engine_state
(** 清理格律引擎缓存
    @param meter_state 格律引擎状态
    @return 清理缓存后的格律引擎状态 *)

val format_poetry_form : poetry_form -> string
(** 格式化诗体类型
    @param form 诗体类型
    @return 格式化的字符串表示 *)

val format_recognition_result : form_recognition_result -> string
(** 格式化诗体识别结果
    @param result 诗体识别结果
    @return 格式化的字符串表示 *)

val format_meter_check_result : meter_check_result -> string
(** 格式化格律检查结果
    @param result 格律检查结果
    @return 格式化的字符串表示 *)
