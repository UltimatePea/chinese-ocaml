(** 错误消息报告模块 - Error Message Reporting Module 
    Phase 4 重构: 使用统一格式化器消除Printf.sprintf *)

open Error_messages_analysis
open Unified_formatter.ErrorHandlingFormatter

(** 生成智能错误报告 *)
let generate_intelligent_error_report analysis =
  let buffer = Buffer.create (Constants.BufferSizes.default_buffer ()) in
  Buffer.add_string buffer ("🚨 " ^ analysis.error_message ^ "\n\n");

  (match analysis.context with
  | Some ctx -> Buffer.add_string buffer ("📍 上下文: " ^ ctx ^ "\n\n")
  | None -> ());

  Buffer.add_string buffer "💡 智能建议:\n";
  List.iteri
    (fun i suggestion -> Buffer.add_string buffer (format_error_suggestion (i + 1) suggestion ^ "\n"))
    analysis.suggestions;

  if List.length analysis.fix_hints > 0 then (
    Buffer.add_string buffer "\n🔧 修复提示:\n";
    List.iteri
      (fun i hint -> Buffer.add_string buffer (format_error_hint (i + 1) hint ^ "\n"))
      analysis.fix_hints);

  Buffer.add_string buffer (format_confidence_score (int_of_float (analysis.confidence *. 100.0)) ^ "\n");
  Buffer.contents buffer

(** 生成AI友好的错误建议 *)
let generate_error_suggestions error_type _context =
  match error_type with
  | "type_mismatch" -> "建议: 检查变量类型是否正确，或使用类型转换功能"
  | "undefined_variable" -> "建议: 检查变量名拼写，或确保变量已在当前作用域中定义"
  | "function_arity" -> "建议: 检查函数调用的参数数量，或使用参数适配功能"
  | "pattern_match" -> "建议: 确保模式匹配覆盖所有可能的情况"
  | _ -> "建议: 查看文档或使用 -types 选项查看类型信息"
