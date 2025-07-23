(** 骆言编译器错误处理系统 - 统计模块 重构自error_handler.ml，第五阶段系统一致性优化：长函数重构

    @author 骆言技术债务清理团队
    @version 1.0 (重构版)
    @since 2025-07-20 Issue #718 长函数重构 *)

open Error_handler_types
open Utils

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
let error_history : enhanced_error_info list ref = ref []

let max_history_size = ref 100

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
  let rec truncate_list lst n =
    if n <= 0 then [] else match lst with [] -> [] | hd :: tl -> hd :: truncate_list tl (n - 1)
  in
  if List.length !error_history > !max_history_size then
    error_history := truncate_list !error_history !max_history_size

(** 获取错误统计报告 - 使用Base_formatter消除Printf.sprintf *)
let get_error_report () =
  let elapsed_time = Unix.time () -. global_stats.start_time in
  let report_lines =
    [
      "=== 错误统计报告 ===";
      Base_formatter.concat_strings
        [ "总错误数: "; Base_formatter.int_to_string global_stats.total_errors ];
      Base_formatter.concat_strings [ "警告: "; Base_formatter.int_to_string global_stats.warnings ];
      Base_formatter.concat_strings [ "错误: "; Base_formatter.int_to_string global_stats.errors ];
      Base_formatter.concat_strings
        [ "严重错误: "; Base_formatter.int_to_string global_stats.fatal_errors ];
      Base_formatter.concat_strings
        [ "已恢复错误: "; Base_formatter.int_to_string global_stats.recovered_errors ];
      Base_formatter.concat_strings [ "处理时间: "; Base_formatter.float_to_string elapsed_time; "秒" ];
      "===================";
    ]
  in
  Base_formatter.join_with_separator "\n" report_lines

(** 重置错误统计 *)
let reset_statistics () =
  global_stats.total_errors <- 0;
  global_stats.warnings <- 0;
  global_stats.errors <- 0;
  global_stats.fatal_errors <- 0;
  global_stats.recovered_errors <- 0;
  global_stats.start_time <- Unix.time ();
  error_history := []

(** 初始化错误统计系统 *)
let init_statistics () =
  reset_statistics ();
  max_history_size := (Config.get_runtime_config ()).max_error_count * 2
