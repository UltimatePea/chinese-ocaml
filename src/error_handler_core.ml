(** 骆言编译器错误处理系统 - 核心处理模块
    重构自error_handler.ml，第五阶段系统一致性优化：长函数重构
    
    @author 骆言技术债务清理团队
    @version 1.0 (重构版)
    @since 2025-07-20 Issue #718 长函数重构 *)

open Compiler_errors
open Error_handler_types
open Error_handler_statistics
open Error_handler_recovery
open Error_handler_formatting

(** 主要的错误处理函数 *)
let handle_error ?(context = create_context ()) base_error =
  let runtime_cfg = Config.get_runtime_config () in

  (* 确定恢复策略 *)
  let recovery_strategy = determine_recovery_strategy base_error.error in

  (* 创建增强错误信息 *)
  let enhanced_error = create_enhanced_error ~recovery_strategy base_error context in

  (* 更新统计和记录 *)
  update_statistics enhanced_error;
  record_error enhanced_error;

  (* 格式化并输出错误 *)
  let formatted_msg = format_enhanced_error enhanced_error in
  let colored_msg = colorize_error_message base_error.severity formatted_msg in

  (* 输出到stderr *)
  Unified_logging.Legacy.eprintf "%s\n" colored_msg;
  flush stderr;

  (* 如果启用了详细日志，输出更多信息 *)
  if runtime_cfg.verbose_logging then (
    Unified_logging.Legacy.eprintf "[调试] 总错误数: %d | 本次严重程度: %s\n" global_stats.total_errors
      (match base_error.severity with Warning -> "警告" | Error -> "错误" | Fatal -> "严重");
    flush stderr);

  (* 记录到日志文件 *)
  log_error_to_file enhanced_error;

  enhanced_error

(** 便捷的错误创建函数 *)
module Create = struct
  let resolve_context context = match context with Some c -> c | None -> create_context ()

  let parse_error ?context ?suggestions msg pos =
    let base_error = make_error_info ?suggestions (ParseError (msg, pos)) in
    let ctx = resolve_context context in
    handle_error ~context:ctx base_error

  let type_error ?context ?suggestions msg pos =
    let base_error = make_error_info ?suggestions (TypeError (msg, pos)) in
    let ctx = resolve_context context in
    handle_error ~context:ctx base_error

  let runtime_error ?context ?suggestions msg =
    let base_error = make_error_info ?suggestions (RuntimeError (msg, None)) in
    let ctx = resolve_context context in
    handle_error ~context:ctx base_error

  let internal_error ?context ?suggestions msg =
    let base_error = make_error_info ~severity:Fatal ?suggestions (InternalError msg) in
    let ctx = resolve_context context in
    handle_error ~context:ctx base_error
end

(** 批量错误处理 - 修复版本 *)
let handle_multiple_errors errors context =
  let enhanced_errors = List.map (fun err -> handle_error ~context err) errors in
  let should_continue = should_continue_processing () in
  (enhanced_errors, should_continue)

(** 初始化错误处理系统 *)
let init_error_handling () =
  init_statistics ()