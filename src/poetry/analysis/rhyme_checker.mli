(** 韵律符合性检查器接口

    @author Alpha, 主要开发代理
    @version 1.0
    @since 2025-07-30 *)

open Poetry_core.Poetry_types
open Meter_types

type rhyme_check_result = {
  rhyme_compliance : bool list;
  rhyme_violations : string list;
  detected_scheme : rhyme_group option list;
  expected_scheme : rhyme_group option list;
}
(** 韵律检查结果类型 *)

type rhyme_usage_stats = {
  total_lines : int;
  rhyming_lines : int;
  non_rhyming_lines : int;
  rhyme_ratio : float;
  unique_rhyme_groups : int;
}
(** 韵律使用统计结果类型 *)

(** {1 韵律检查核心功能} *)

val check_rhyme_compliance :
  string list -> meter_pattern -> Rhythm_analyzer.analyzer_state -> rhyme_check_result
(** 检查韵律符合度 *)

(** {1 韵律分析辅助功能} *)

val analyze_rhyme_pattern : string list -> Rhythm_analyzer.analyzer_state -> rhyme_group option list
(** 分析诗句的韵律模式 *)

val check_lines_rhyme : string -> string -> Rhythm_analyzer.analyzer_state -> bool
(** 检查两行是否押韵 *)

val get_line_rhyme_group : string -> Rhythm_analyzer.analyzer_state -> rhyme_group option
(** 获取单行的韵组 *)

(** {1 韵律符合度计算} *)

val calculate_rhyme_compliance_score : bool list -> float
(** 计算韵律符合度得分 *)

val generate_rhyme_suggestions : string list -> rhyme_group option list -> string list
(** 生成韵律相关的改进建议 *)

(** {1 韵律模式验证} *)

val validate_rhyme_scheme : rhyme_group option list -> bool * string list
(** 验证韵律模式的有效性 *)

val compare_rhyme_schemes : rhyme_group option list -> rhyme_group option list -> float
(** 比较两个韵律模式的相似度 *)

(** {1 韵律统计分析} *)

val analyze_rhyme_usage : string list -> Rhythm_analyzer.analyzer_state -> rhyme_usage_stats
(** 统计韵律使用情况 *)
