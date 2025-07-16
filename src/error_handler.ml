(** 骆言编译器统一错误处理系统 *)

open Config
open Compiler_errors

(** 错误恢复策略类型 *)
type recovery_strategy =
  | SkipAndContinue  (** 跳过错误，继续处理 *)
  | SyncToNextStatement  (** 同步到下一语句边界 *)
  | TryAlternative of string  (** 尝试替代方案 *)
  | RequestUserInput  (** 请求用户输入 *)
  | Abort  (** 终止处理 *)

type error_context = {
  source_file : string;  (** 源文件名 *)
  function_name : string;  (** 出错的函数名 *)
  module_name : string;  (** 出错的模块名 *)
  timestamp : float;  (** 错误发生时间 *)
  call_stack : string list;  (** 调用栈 *)
  user_data : (string * string) list;  (** 用户自定义数据 *)
}
(** 错误上下文信息 *)

type enhanced_error_info = {
  base_error : error_info;  (** 基础错误信息 *)
  context : error_context;  (** 错误上下文 *)
  recovery_strategy : recovery_strategy;  (** 恢复策略 *)
  attempt_count : int;  (** 重试次数 *)
  related_errors : enhanced_error_info list;  (** 相关错误 *)
}
(** 增强的错误信息 *)

type error_statistics = {
  mutable total_errors : int;
  mutable warnings : int;
  mutable errors : int;
  mutable fatal_errors : int;
  mutable recovered_errors : int;
  mutable start_time : float;
}
(** 错误统计信息 *)

(** 全局错误统计 *)
let global_stats =
  {
    total_errors = 0;
    warnings = 0;
    errors = 0;
    fatal_errors = 0;
    recovered_errors = 0;
    start_time = Unix.time ();
  }

(** 错误历史记录 *)
let error_history = ref []

let max_history_size = ref 100

(** 创建错误上下文 *)
let create_context ?(source_file = "<unknown>") ?(function_name = "<unknown>")
    ?(module_name = "<unknown>") ?(call_stack = []) ?(user_data = []) () =
  { source_file; function_name; module_name; timestamp = Unix.time (); call_stack; user_data }

(** 创建增强错误信息 *)
let create_enhanced_error ?(recovery_strategy = SkipAndContinue) ?(attempt_count = 0)
    ?(related_errors = []) base_error context =
  { base_error; context; recovery_strategy; attempt_count; related_errors }

(** 根据配置确定恢复策略 *)
let determine_recovery_strategy error_type =
  let runtime_cfg = Config.get_runtime_config () in
  if not runtime_cfg.error_recovery then Abort
  else
    match error_type with
    | LexError (_, _) -> SkipAndContinue
    | ParseError (_, _) -> SyncToNextStatement
    | SyntaxError (_, _) -> SyncToNextStatement
    | PoetryParseError (_, _) -> SkipAndContinue
    | TypeError (_, _) -> SkipAndContinue
    | SemanticError (_, _) -> SkipAndContinue
    | CodegenError (_, _) -> TryAlternative "使用默认代码生成"
    | RuntimeError (_, _) -> RequestUserInput
    | ExceptionRaised (_, _) -> RequestUserInput
    | InternalError _ -> Abort
    | UnimplementedFeature (_, _) -> TryAlternative "使用替代实现"
    | IOError (_, _) -> TryAlternative "重试IO操作"

(** 格式化增强错误信息 *)
let format_enhanced_error enhanced_error =
  let runtime_cfg = Config.get_runtime_config () in
  let base_msg = format_error_info enhanced_error.base_error in

  let context_info =
    Printf.sprintf "\n[上下文] 文件: %s | 模块: %s | 函数: %s | 时间: %.0f" enhanced_error.context.source_file
      enhanced_error.context.module_name enhanced_error.context.function_name
      enhanced_error.context.timestamp
  in

  let recovery_info =
    match enhanced_error.recovery_strategy with
    | SkipAndContinue -> "\n[恢复] 跳过此错误，继续处理"
    | SyncToNextStatement -> "\n[恢复] 同步到下一语句边界"
    | TryAlternative alt -> Printf.sprintf "\n[恢复] 尝试替代方案: %s" alt
    | RequestUserInput -> "\n[恢复] 需要用户输入"
    | Abort -> "\n[恢复] 终止处理"
  in

  let attempt_info =
    if enhanced_error.attempt_count > 0 then
      Printf.sprintf "\n[重试] 第 %d 次尝试" enhanced_error.attempt_count
    else ""
  in

  let call_stack_info =
    if List.length enhanced_error.context.call_stack > 0 && runtime_cfg.verbose_logging then
      "\n[调用栈]\n"
      ^ String.concat "\n"
          (List.mapi
             (fun i frame -> Printf.sprintf "  %d. %s" (i + 1) frame)
             enhanced_error.context.call_stack)
    else ""
  in

  base_msg ^ context_info ^ recovery_info ^ attempt_info ^ call_stack_info

(** 彩色输出支持 *)
let colorize_error_message severity message =
  let runtime_cfg = Config.get_runtime_config () in
  if not runtime_cfg.colored_output then message
  else
    let color_code =
      match severity with
      | Warning -> "\027[33m" (* 黄色 *)
      | Error -> "\027[31m" (* 红色 *)
      | Fatal -> "\027[91m" (* 亮红色 *)
    in
    color_code ^ message ^ "\027[0m" (* 重置颜色 *)

(** 更新错误统计 *)
let update_statistics enhanced_error =
  global_stats.total_errors <- global_stats.total_errors + 1;
  match enhanced_error.base_error.severity with
  | Warning -> global_stats.warnings <- global_stats.warnings + 1
  | Error -> global_stats.errors <- global_stats.errors + 1
  | Fatal -> global_stats.fatal_errors <- global_stats.fatal_errors + 1

(** 记录错误到历史 *)
let record_error enhanced_error =
  error_history := enhanced_error :: !error_history;
  if List.length !error_history > !max_history_size then
    error_history := List.rev (List.tl (List.rev !error_history))

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
  Printf.eprintf "%s\n" colored_msg;
  flush stderr;

  (* 如果启用了详细日志，输出更多信息 *)
  if runtime_cfg.verbose_logging then (
    Printf.eprintf "[调试] 总错误数: %d | 本次严重程度: %s\n" global_stats.total_errors
      (match base_error.severity with Warning -> "警告" | Error -> "错误" | Fatal -> "严重");
    flush stderr);

  enhanced_error

(** 错误恢复执行 *)
let attempt_recovery enhanced_error =
  let runtime_cfg = Config.get_runtime_config () in
  if not runtime_cfg.error_recovery then false
  else
    match enhanced_error.recovery_strategy with
    | SkipAndContinue ->
        global_stats.recovered_errors <- global_stats.recovered_errors + 1;
        true
    | SyncToNextStatement ->
        (* 这里应该实现具体的语法同步逻辑 *)
        global_stats.recovered_errors <- global_stats.recovered_errors + 1;
        true
    | TryAlternative _ ->
        (* 这里应该实现替代方案逻辑 *)
        global_stats.recovered_errors <- global_stats.recovered_errors + 1;
        true
    | RequestUserInput ->
        (* 这里可以实现用户交互逻辑 *)
        false
    | Abort -> false

(** 批量错误处理 *)
let handle_multiple_errors errors context =
  let runtime_cfg = Config.get_runtime_config () in
  let enhanced_errors = List.map (fun err -> handle_error ~context err) errors in

  (* 检查是否应该继续 *)
  let should_continue =
    runtime_cfg.continue_on_error
    && global_stats.total_errors < runtime_cfg.max_error_count
    && global_stats.fatal_errors = 0
  in

  (enhanced_errors, should_continue)

(** 获取错误统计报告 *)
let get_error_report () =
  let elapsed_time = Unix.time () -. global_stats.start_time in
  Printf.sprintf
    "=== 错误统计报告 ===\n\
     总错误数: %d\n\
     警告: %d\n\
     错误: %d\n\
     严重错误: %d\n\
     已恢复错误: %d\n\
     处理时间: %.2f秒\n\
     ==================="
    global_stats.total_errors global_stats.warnings global_stats.errors global_stats.fatal_errors
    global_stats.recovered_errors elapsed_time

(** 重置错误统计 *)
let reset_statistics () =
  global_stats.total_errors <- 0;
  global_stats.warnings <- 0;
  global_stats.errors <- 0;
  global_stats.fatal_errors <- 0;
  global_stats.recovered_errors <- 0;
  global_stats.start_time <- Unix.time ();
  error_history := []

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

(** 错误模式匹配助手 *)
let is_recoverable enhanced_error =
  match enhanced_error.recovery_strategy with Abort -> false | _ -> true

let is_fatal enhanced_error = enhanced_error.base_error.severity = Fatal

(** 错误日志记录到文件 *)
let log_error_to_file enhanced_error =
  let runtime_cfg = Config.get_runtime_config () in
  if runtime_cfg.verbose_logging then
    try
      let timestamp = Unix.time () |> Unix.localtime in
      let log_filename =
        Printf.sprintf "%s/error_%04d%02d%02d.log" (Config.get_compiler_config ()).temp_directory
          (timestamp.tm_year + 1900) (timestamp.tm_mon + 1) timestamp.tm_mday
      in
      let oc = open_out_gen [ Open_wronly; Open_creat; Open_append ] 0o644 log_filename in
      Printf.fprintf oc "[%02d:%02d:%02d] %s\n" timestamp.tm_hour timestamp.tm_min timestamp.tm_sec
        (format_enhanced_error enhanced_error);
      close_out oc
    with _ -> () (* 忽略日志记录错误 *)

(** 初始化错误处理系统 *)
let init_error_handling () =
  reset_statistics ();
  max_history_size := (Config.get_runtime_config ()).max_error_count * 2
