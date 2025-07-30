(** 平仄模式检查器接口
    
    此模块提供诗句平仄模式检查功能的公共接口。
    
    @author Alpha, 主要开发代理
    @version 1.0 
    @since 2025-07-30 *)

open Poetry_core.Poetry_types
open Meter_types

(** {1 平仄检查核心功能} *)

(** 检查平仄符合度
    @param verses 诗句列表
    @param pattern 格律模式
    @param meter_state 格律引擎状态
    @return (符合度列表, 违规描述列表) *)
val check_tonal_compliance : string list -> meter_pattern -> meter_engine_state -> bool list * string list

(** {1 平仄模式辅助功能} *)

(** 将平仄类别转换为字符串表示 *)
val rhyme_category_to_string : rhyme_category -> string

(** 验证平仄模式合法性 *)
val validate_tonal_pattern : meter_pattern -> bool

(** 生成平仄违规建议 *)
val generate_tonal_suggestions : string list -> string list

(** {1 高级平仄分析} *)

(** 平仄特征分析结果 *)
type tonal_analysis_result = {
  pattern_type : string;          (** 模式类型 *)
  alternation_score : float;      (** 平仄交替度 (0.0-1.0) *)
  balance_score : float;          (** 平仄平衡度 (0.0-1.0) *)
  complexity_score : float;       (** 复杂度得分 (0.0-1.0) *)
}

(** 计算平仄符合度得分 *)
val calculate_tonal_score : bool list -> float

(** 分析平仄模式特征 *)
val analyze_tonal_features : string list -> meter_pattern -> tonal_analysis_result