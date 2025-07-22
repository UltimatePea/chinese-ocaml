(** 违规报告生成器 - 骆言中文编程最佳实践 *)

open Chinese_best_practices_types.Severity_types
open Utils.Base_formatter

(** Buffer helper functions *)
let append_line buffer text =
  Buffer.add_string buffer text;
  Buffer.add_char buffer '\n'

(** 获取严重程度图标 *)
let get_severity_icon = function Error -> "🚨" | Warning -> "⚠️" | Style -> "🎨" | Info -> "💡"

(** 获取严重程度文本 *)
let get_severity_text = function Error -> "错误" | Warning -> "警告" | Style -> "风格" | Info -> "提示"

(** 统计违规数量 *)
let count_violations_by_severity violations =
  let count_severity sev =
    List.length (List.filter (fun result -> result.severity = sev) violations)
  in
  (count_severity Error, count_severity Warning, count_severity Style, count_severity Info)

(** 生成违规详细报告 *)
let generate_violation_details violations =
  let buffer = Buffer.create 1024 in

  violations
  |> List.iteri (fun i result ->
         let icon = get_severity_icon result.severity in
         let severity_text = get_severity_text result.severity in
         let ai_friendly_mark = if result.ai_friendly then " [AI友好]" else "" in

         let formatted_message = violation_numbered_pattern i icon severity_text 
           (result.message ^ ai_friendly_mark) in
         append_line buffer formatted_message;
         append_line buffer (violation_suggestion_pattern result.suggestion);
         append_line buffer (violation_confidence_pattern result.confidence);
         append_line buffer "");

  Buffer.contents buffer

(** 生成统计报告 *)
let generate_stats_report violations =
  let buffer = Buffer.create 512 in
  let error_count, warning_count, style_count, info_count =
    count_violations_by_severity violations
  in

  append_line buffer "📊 检查结果统计:";
  append_line buffer (error_count_pattern error_count);
  append_line buffer (warning_count_pattern warning_count);
  append_line buffer (style_count_pattern style_count);
  append_line buffer (info_count_pattern info_count);
  append_line buffer "";

  Buffer.contents buffer

(** 生成改进建议 *)
let generate_improvement_suggestions violations =
  let buffer = Buffer.create 512 in
  let error_count, warning_count, style_count, info_count =
    count_violations_by_severity violations
  in

  append_line buffer "🛠️ 总体改进建议:";

  if error_count > 0 then append_line buffer "   1. 优先修复所有错误级别的问题，这些会影响AI代理的理解";

  if warning_count > 0 then append_line buffer "   2. 处理警告级别的问题，提升代码的地道性";

  if style_count > 0 then append_line buffer "   3. 统一编程风格，保持代码一致性";

  if info_count > 0 then append_line buffer "   4. 考虑信息级别的建议，进一步优化表达";

  Buffer.contents buffer

(** 生成成功报告 *)
let generate_success_report () =
  let buffer = Buffer.create 256 in
  append_line buffer "✅ 恭喜！您的代码符合中文编程最佳实践";
  append_line buffer "🎉 没有发现需要改进的问题";
  append_line buffer "👏 代码质量良好，AI代理友好";
  Buffer.contents buffer

(** 生成完整报告 *)
let generate_practice_report violations =
  let buffer = Buffer.create 2048 in

  append_line buffer "📋 中文编程最佳实践检查报告";
  append_line buffer "";

  if List.length violations = 0 then Buffer.add_string buffer (generate_success_report ())
  else (
    Buffer.add_string buffer (generate_stats_report violations);
    append_line buffer "📝 详细检查结果:";
    append_line buffer "";
    Buffer.add_string buffer (generate_violation_details violations);
    Buffer.add_string buffer (generate_improvement_suggestions violations));

  Buffer.contents buffer
