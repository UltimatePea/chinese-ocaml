(** Buffer累积辅助模块

    本模块提供Buffer操作的便利函数， 简化报告生成和字符串累积操作。

    @author 骆言技术债务清理团队
    @version 1.0
    @since 2025-07-20 Issue #708 重构 *)

(** 安全地向Buffer添加格式化字符串 *)
let add_formatted_string buffer format_fn = Buffer.add_string buffer (format_fn ())

(** 批量添加统计信息 *)
let add_stats_batch buffer stats_list =
  List.iter
    (fun (icon, category, count) ->
      Buffer.add_string buffer (Report_formatting.stats_line icon category count))
    stats_list

(** 添加带上下文的错误信息 *)
let add_error_with_context buffer error_msg context_opt =
  Buffer.add_string buffer (Report_formatting.analysis_result_line "🚨" error_msg);
  match context_opt with
  | Some ctx -> Buffer.add_string buffer (Report_formatting.context_line ctx)
  | None -> ()
