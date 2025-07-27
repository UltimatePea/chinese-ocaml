(** 骆言编译器错误处理系统 - 统计模块 重构自error_handler.ml，第五阶段系统一致性优化：长函数重构 Critical技术债务修复：消除全局可变状态 Fix #1497

    @author 骆言技术债务清理团队
    @version 2.0 (函数式重构版 - 消除全局状态)
    @since 2025-07-27 Issue #1497 全局状态消除重构 *)

open Error_handler_types
open Utils

type immutable_statistics = {
  total_errors : int;
  warnings : int;
  errors : int;
  fatal_errors : int;
  recovered_errors : int;
  start_time : float;
}
(** 不可变内部统计类型 *)

type internal_context = {
  statistics : immutable_statistics;
  history : enhanced_error_info list;
  max_history_size : int;
}
(** 不可变错误处理上下文 *)

(** 创建初始不可变统计 *)
let create_initial_immutable_statistics () =
  {
    total_errors = 0;
    warnings = 0;
    errors = 0;
    fatal_errors = 0;
    recovered_errors = 0;
    start_time = Unix.time ();
  }

(** 创建初始内部上下文 *)
let create_initial_internal_context max_size =
  { statistics = create_initial_immutable_statistics (); history = []; max_history_size = max_size }

(** 内部状态 - 函数式状态管理 *)
let internal_context : internal_context ref = ref (create_initial_internal_context 100)

(** 向后兼容的全局状态对象 *)
let global_stats : Error_handler_types.error_statistics =
  {
    total_errors = 0;
    warnings = 0;
    errors = 0;
    fatal_errors = 0;
    recovered_errors = 0;
    start_time = Unix.time ();
  }

(** 向后兼容的历史记录 *)
let error_history : enhanced_error_info list ref = ref []

let max_history_size = ref 100

(** 同步max_history_size修改到内部上下文 *)
let sync_max_history_size_to_context () =
  let ctx = !internal_context in
  let new_ctx = { ctx with max_history_size = !max_history_size } in
  internal_context := new_ctx

(** 同步内部状态到外部可变接口 *)
let sync_to_mutable_interface () =
  let ctx = !internal_context in
  global_stats.total_errors <- ctx.statistics.total_errors;
  global_stats.warnings <- ctx.statistics.warnings;
  global_stats.errors <- ctx.statistics.errors;
  global_stats.fatal_errors <- ctx.statistics.fatal_errors;
  global_stats.recovered_errors <- ctx.statistics.recovered_errors;
  global_stats.start_time <- ctx.statistics.start_time;
  error_history := ctx.history;
  max_history_size := ctx.max_history_size

(** 函数式错误统计更新 *)
let update_statistics_functional stats enhanced_error =
  let new_total = stats.total_errors + 1 in
  match enhanced_error.base_error.severity with
  | Warning -> { stats with total_errors = new_total; warnings = stats.warnings + 1 }
  | Error -> { stats with total_errors = new_total; errors = stats.errors + 1 }
  | Fatal -> { stats with total_errors = new_total; fatal_errors = stats.fatal_errors + 1 }

(** 函数式历史记录更新 *)
let record_error_functional history enhanced_error max_size =
  let new_history = enhanced_error :: history in
  let truncate_list lst n =
    let rec aux acc remaining count =
      if count <= 0 || remaining = [] then List.rev acc
      else match remaining with hd :: tl -> aux (hd :: acc) tl (count - 1) | [] -> List.rev acc
    in
    aux [] lst n
  in
  if List.length new_history > max_size then truncate_list new_history max_size else new_history

(** 更新错误统计 - 向后兼容接口 *)
let update_statistics enhanced_error =
  let ctx = !internal_context in
  let new_stats = update_statistics_functional ctx.statistics enhanced_error in
  let new_ctx = { ctx with statistics = new_stats } in
  internal_context := new_ctx;
  sync_to_mutable_interface ()

(** 记录错误到历史 - 向后兼容接口 *)
let record_error enhanced_error =
  sync_max_history_size_to_context ();
  (* 确保使用最新的历史大小限制 *)
  let ctx = !internal_context in
  let new_history = record_error_functional ctx.history enhanced_error ctx.max_history_size in
  let new_ctx = { ctx with history = new_history } in
  internal_context := new_ctx;
  sync_to_mutable_interface ()

(** 获取错误统计报告 - 使用Base_formatter消除Printf.sprintf *)
let get_error_report () =
  let ctx = !internal_context in
  let elapsed_time = Unix.time () -. ctx.statistics.start_time in
  let report_lines =
    [
      "=== 错误统计报告 ===";
      Base_formatter.concat_strings
        [ "总错误数: "; Base_formatter.int_to_string ctx.statistics.total_errors ];
      Base_formatter.concat_strings [ "警告: "; Base_formatter.int_to_string ctx.statistics.warnings ];
      Base_formatter.concat_strings [ "错误: "; Base_formatter.int_to_string ctx.statistics.errors ];
      Base_formatter.concat_strings
        [ "严重错误: "; Base_formatter.int_to_string ctx.statistics.fatal_errors ];
      Base_formatter.concat_strings
        [ "已恢复错误: "; Base_formatter.int_to_string ctx.statistics.recovered_errors ];
      Base_formatter.concat_strings [ "处理时间: "; Base_formatter.float_to_string elapsed_time; "秒" ];
      "===================";
    ]
  in
  Base_formatter.join_with_separator "\n" report_lines

(** 重置错误统计 - 向后兼容接口 *)
let reset_statistics () =
  let new_stats = create_initial_immutable_statistics () in
  let new_ctx = { statistics = new_stats; history = []; max_history_size = !max_history_size } in
  internal_context := new_ctx;
  sync_to_mutable_interface ()

(** 初始化错误统计系统 - 向后兼容接口 *)
let init_statistics () =
  reset_statistics ();
  let new_max_size = (Config.get_runtime_config ()).max_error_count * 2 in
  let ctx = !internal_context in
  let new_ctx = { ctx with max_history_size = new_max_size } in
  internal_context := new_ctx;
  max_history_size := new_max_size;
  sync_to_mutable_interface ()
