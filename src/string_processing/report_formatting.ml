(** 报告生成格式化模块

    本模块专门处理各种报告和分析结果的格式化， 提供统一的报告格式和样式。
    
    重构历史：Printf.sprintf统一化第三阶段Phase 3.3完全重构
    - 消除所有Printf.sprintf依赖，使用Base_formatter统一格式化
    - 实现100%格式化输出一致性保证

    @author 骆言技术债务清理团队
    @version 2.0
    @since 2025-07-22 Issue #864 Printf.sprintf统一化完成 *)

(** 统计信息格式 - 使用Base_formatter统一模式 *)
let stats_line icon category count = Utils.Base_formatter.stat_report_line_pattern icon category count

(** 分析结果格式 - 使用Base_formatter统一模式 *)
let analysis_result_line icon message = Utils.Base_formatter.analysis_message_line_pattern icon message

(** 上下文信息格式 - 使用Base_formatter统一模式 *)
let context_line context = Utils.Base_formatter.context_info_pattern context

(** 建议信息格式 - 使用Base_formatter统一模式 *)
let suggestion_line current suggestion = Utils.Base_formatter.suggestion_replacement_pattern current suggestion

(** 相似度建议格式 - 使用Base_formatter统一模式 *)
let similarity_suggestion match_name score = Utils.Base_formatter.similarity_match_pattern match_name score
