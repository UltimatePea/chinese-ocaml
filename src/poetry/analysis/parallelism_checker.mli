(** 对仗检查器接口
    
    此模块提供诗句对仗检查功能的公共接口。
    
    @author Alpha, 主要开发代理
    @version 1.0 
    @since 2025-07-30 *)

open Meter_types

(** {1 对仗检查核心功能} *)

(** 检查对仗符合度
    @param verses 诗句列表
    @param pattern 格律模式
    @param meter_state 格律引擎状态
    @return (符合度列表, 违规描述列表) *)
val check_parallelism_compliance : string list -> meter_pattern -> meter_engine_state -> bool list * string list

(** {1 对仗分析辅助功能} *)

(** 验证对仗要求合法性 *)
val validate_parallelism_requirements : meter_pattern -> bool

(** 计算对仗符合度得分 *)
val calculate_parallelism_score : bool list -> float

(** 生成对仗违规建议 *)
val generate_parallelism_suggestions : string list -> string list

(** {1 高级对仗分析} *)

(** 对仗类型 *)
type parallelism_type =
  | StrictParallelism    (** 严格对仗 *)
  | LooseParallelism     (** 宽松对仗 *)
  | NoParallelism        (** 无对仗要求 *)

(** 对仗质量评估结果 *)
type parallelism_quality = {
  parallelism_type : parallelism_type;
  structural_score : float;    (** 结构对仗得分 (0.0-1.0) *)
  semantic_score : float;      (** 语义对仗得分 (0.0-1.0) *)
  tonal_score : float;         (** 平仄对仗得分 (0.0-1.0) *)
  overall_score : float;       (** 综合对仗得分 (0.0-1.0) *)
}

(** 分析对仗质量 *)
val analyze_parallelism_quality : string list -> meter_pattern -> meter_engine_state -> parallelism_quality

(** {1 对仗模式定义} *)

(** 获取标准对仗模式 *)
val get_standard_parallelism_patterns : poetry_form -> (int * int) list

(** 检查对仗模式是否符合传统要求 *)
val validate_traditional_parallelism : meter_pattern -> bool