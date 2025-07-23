(** 骆言编译器错误处理系统 - 格式化和日志模块 重构自error_handler.ml，第五阶段系统一致性优化：长函数重构

    @author 骆言技术债务清理团队
    @version 1.0 (重构版)
    @since 2025-07-20 Issue #718 长函数重构 *)

open Compiler_errors
open Error_handler_types

(** 格式化增强错误信息 *)
let format_enhanced_error enhanced_error =
  let runtime_cfg = Config.get_runtime_config () in
  let buffer = Buffer.create 512 in
  
  (* 基础错误信息 *)
  Buffer.add_string buffer (format_error_info enhanced_error.base_error);

  (* 上下文信息 *)
  Buffer.add_string buffer "\n[上下文] 文件: ";
  Buffer.add_string buffer enhanced_error.context.source_file;
  Buffer.add_string buffer " | 模块: ";
  Buffer.add_string buffer enhanced_error.context.module_name;
  Buffer.add_string buffer " | 函数: ";
  Buffer.add_string buffer enhanced_error.context.function_name;
  Buffer.add_string buffer " | 时间: ";
  Buffer.add_string buffer (string_of_float enhanced_error.context.timestamp);

  (* 恢复策略信息 *)
  (match enhanced_error.recovery_strategy with
  | SkipAndContinue -> Buffer.add_string buffer "\n[恢复] 跳过此错误，继续处理"
  | SyncToNextStatement -> Buffer.add_string buffer "\n[恢复] 同步到下一语句边界"
  | TryAlternative alt -> 
      Buffer.add_string buffer "\n[恢复] 尝试替代方案: ";
      Buffer.add_string buffer alt
  | RequestUserInput -> Buffer.add_string buffer "\n[恢复] 需要用户输入"
  | Abort -> Buffer.add_string buffer "\n[恢复] 终止处理");

  (* 重试信息 *)
  if enhanced_error.attempt_count > 0 then (
    Buffer.add_string buffer "\n[重试] 第 ";
    Buffer.add_string buffer (string_of_int enhanced_error.attempt_count);
    Buffer.add_string buffer " 次尝试"
  );

  (* 调用栈信息 *)
  if List.length enhanced_error.context.call_stack > 0 && runtime_cfg.verbose_logging then (
    Buffer.add_string buffer "\n[调用栈]\n";
    List.iteri (fun i frame ->
      Buffer.add_string buffer "  ";
      Buffer.add_string buffer (string_of_int (i + 1));
      Buffer.add_string buffer ". ";
      Buffer.add_string buffer frame;
      Buffer.add_char buffer '\n'
    ) enhanced_error.context.call_stack
  );

  Buffer.contents buffer

(** 彩色输出支持 *)
let colorize_error_message severity message =
  let runtime_cfg = Config.get_runtime_config () in
  if not runtime_cfg.colored_output then message
  else
    let color_code =
      match severity with
      | Warning -> Constants.Colors.warn_color (* 黄色 *)
      | Error -> Constants.Colors.error_color (* 红色 *)
      | Fatal -> Constants.Colors.fatal_color (* 亮红色 *)
    in
    Constants.Colors.with_color color_code message

(** 错误日志记录到文件 *)
let log_error_to_file enhanced_error =
  let runtime_cfg = Config.get_runtime_config () in
  if runtime_cfg.verbose_logging then
    try
      let timestamp = Unix.time () |> Unix.localtime in
      let log_filename =
        (Config.get_compiler_config ()).temp_directory ^ "/error_"
        ^ string_of_int (timestamp.tm_year + 1900)
        ^ (if timestamp.tm_mon + 1 < 10 then "0" else "")
        ^ string_of_int (timestamp.tm_mon + 1)
        ^ (if timestamp.tm_mday < 10 then "0" else "")
        ^ string_of_int timestamp.tm_mday ^ ".log"
      in
      let oc = open_out_gen [ Open_wronly; Open_creat; Open_append ] 0o644 log_filename in
      Printf.fprintf oc "[%02d:%02d:%02d] %s\n" timestamp.tm_hour timestamp.tm_min timestamp.tm_sec
        (format_enhanced_error enhanced_error);
      close_out oc
    with _ -> () (* 忽略日志记录错误 *)
