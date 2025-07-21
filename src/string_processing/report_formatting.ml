(** 报告生成格式化模块

    本模块专门处理各种报告和分析结果的格式化， 提供统一的报告格式和样式。

    @author 骆言技术债务清理团队
    @version 1.0
    @since 2025-07-20 Issue #708 重构 *)

(** 统计信息格式 *)
let stats_line icon category count = Printf.sprintf "   %s %s: %d 个\n" icon category count

(** 分析结果格式 *)
let analysis_result_line icon message = Printf.sprintf "%s %s\n\n" icon message

(** 上下文信息格式 *)
let context_line context = Printf.sprintf "📍 上下文: %s\n\n" context

(** 建议信息格式 *)
let suggestion_line current suggestion = Printf.sprintf "建议将「%s」改为「%s」" current suggestion

(** 相似度建议格式 *)
let similarity_suggestion match_name score =
  Printf.sprintf "可能想使用：「%s」(相似度: %.0f%%)" match_name (score *. 100.0)
