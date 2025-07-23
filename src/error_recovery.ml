(** 骆言错误恢复模块 - Chinese Programming Language Error Recovery Module 第五阶段Printf.sprintf统一化重构 -
    基于Base_formatter *)

type error_recovery_config = {
  enabled : bool;
  type_conversion : bool;
  spell_correction : bool;
  parameter_adaptation : bool;
  log_level : string; (* "quiet" | "normal" | "verbose" | "debug" *)
  collect_statistics : bool;
}
(** 错误恢复配置 *)

type recovery_statistics = {
  mutable total_errors : int;
  mutable type_conversions : int;
  mutable spell_corrections : int;
  mutable parameter_adaptations : int;
  mutable variable_suggestions : int;
  mutable or_else_fallbacks : int;
}
(** 错误恢复统计 *)

(** 默认错误恢复配置 *)
let default_recovery_config =
  {
    enabled = true;
    type_conversion = true;
    spell_correction = true;
    parameter_adaptation = true;
    log_level = "normal";
    collect_statistics = true;
  }

(** 全局错误恢复统计 *)
let recovery_stats =
  {
    total_errors = 0;
    type_conversions = 0;
    spell_corrections = 0;
    parameter_adaptations = 0;
    variable_suggestions = 0;
    or_else_fallbacks = 0;
  }

(** 全局错误恢复配置 *)
let recovery_config = ref default_recovery_config

(** 初始化模块日志器 *)
let log_debug, log_info = Logger_utils.init_debug_info_loggers "ErrorRecovery"

(** 内部统计格式化模块 - 基于Base_formatter统一化 *)
module Internal_formatter = struct
  (* 导入Base_formatter模块以使用统一格式化函数 *)
  open Utils.Base_formatter

  let format_debug_summary msg stats =
    concat_strings
      [
        "错误恢复: ";
        msg;
        "\n  统计: 总错误=";
        int_to_string stats.total_errors;
        ", 类型转换=";
        int_to_string stats.type_conversions;
        ", 拼写纠正=";
        int_to_string stats.spell_corrections;
      ]

  let format_total_errors count = concat_strings [ "总错误数: "; int_to_string count ]
  let format_type_conversions count = concat_strings [ "类型转换: "; int_to_string count; " 次" ]
  let format_spell_corrections count = concat_strings [ "拼写纠正: "; int_to_string count; " 次" ]

  let format_parameter_adaptations count = concat_strings [ "参数适配: "; int_to_string count; " 次" ]

  let format_variable_suggestions count = concat_strings [ "变量建议: "; int_to_string count; " 次" ]

  let format_or_else_fallbacks count = concat_strings [ "默认值回退: "; int_to_string count; " 次" ]

  let format_success_rate rate = concat_strings [ "恢复成功率: "; float_to_string rate; "%%" ]
end

(** 计算两个字符串的编辑距离 (Levenshtein distance) *)
let levenshtein_distance str1 str2 =
  let len1 = String.length str1 in
  let len2 = String.length str2 in
  let matrix = Array.make_matrix (len1 + 1) (len2 + 1) 0 in

  (* 初始化第一行和第一列 *)
  for i = 0 to len1 do
    matrix.(i).(0) <- i
  done;
  for j = 0 to len2 do
    matrix.(0).(j) <- j
  done;

  (* 填充矩阵 *)
  for i = 1 to len1 do
    for j = 1 to len2 do
      let cost = if str1.[i - 1] = str2.[j - 1] then 0 else 1 in
      matrix.(i).(j) <-
        min
          (min (matrix.(i - 1).(j) + 1) (* 删除 *) (matrix.(i).(j - 1) + 1)) (* 插入 *)
          (matrix.(i - 1).(j - 1) + cost)
      (* 替换 *)
    done
  done;
  matrix.(len1).(len2)

(** 从环境中获取所有可用的变量名 *)
let get_available_vars env = List.map fst env

(** 找到最相似的变量名 *)
let find_closest_var target_var available_vars =
  let distances = List.map (fun var -> (var, levenshtein_distance target_var var)) available_vars in
  let sorted = List.sort (fun (_, d1) (_, d2) -> compare d1 d2) distances in
  match sorted with
  | [] -> None
  | (closest_var, distance) :: _ ->
      (* 只有当距离足够小时才建议 *)
      if distance <= 2 && distance < String.length target_var / 2 then Some closest_var else None

(** 记录错误恢复日志 *)
let log_recovery msg =
  if !recovery_config.collect_statistics then
    recovery_stats.total_errors <- recovery_stats.total_errors + 1;
  match !recovery_config.log_level with
  | "quiet" -> ()
  | "normal" -> log_info msg
  | "verbose" -> log_info msg
  | "debug" -> log_debug (Internal_formatter.format_debug_summary msg recovery_stats)
  | _ -> log_info msg

(** 记录特定类型的恢复操作 *)
let log_recovery_type recovery_type msg =
  if !recovery_config.collect_statistics then (
    recovery_stats.total_errors <- recovery_stats.total_errors + 1;
    match recovery_type with
    | "type_conversion" -> recovery_stats.type_conversions <- recovery_stats.type_conversions + 1
    | "spell_correction" -> recovery_stats.spell_corrections <- recovery_stats.spell_corrections + 1
    | "parameter_adaptation" ->
        recovery_stats.parameter_adaptations <- recovery_stats.parameter_adaptations + 1
    | "variable_suggestion" ->
        recovery_stats.variable_suggestions <- recovery_stats.variable_suggestions + 1
    | "or_else_fallback" -> recovery_stats.or_else_fallbacks <- recovery_stats.or_else_fallbacks + 1
    | _ -> ());
  log_recovery msg

(** 显示错误恢复统计信息 *)
let show_recovery_statistics () =
  if !recovery_config.collect_statistics && recovery_stats.total_errors > 0 then (
    log_info "\n=== 错误恢复统计 ===";
    log_info (Internal_formatter.format_total_errors recovery_stats.total_errors);
    log_info (Internal_formatter.format_type_conversions recovery_stats.type_conversions);
    log_info (Internal_formatter.format_spell_corrections recovery_stats.spell_corrections);
    log_info (Internal_formatter.format_parameter_adaptations recovery_stats.parameter_adaptations);
    log_info (Internal_formatter.format_variable_suggestions recovery_stats.variable_suggestions);
    log_info (Internal_formatter.format_or_else_fallbacks recovery_stats.or_else_fallbacks);
    log_info
      (Internal_formatter.format_success_rate
         (100.0
         *. float_of_int recovery_stats.total_errors
         /. float_of_int (max 1 recovery_stats.total_errors)));
    log_info "================\n")

(** 重置错误恢复统计 *)
let reset_recovery_statistics () =
  recovery_stats.total_errors <- 0;
  recovery_stats.type_conversions <- 0;
  recovery_stats.spell_corrections <- 0;
  recovery_stats.parameter_adaptations <- 0;
  recovery_stats.variable_suggestions <- 0;
  recovery_stats.or_else_fallbacks <- 0

(** 设置错误恢复配置 *)
let set_recovery_config new_config = recovery_config := new_config

(** 获取当前错误恢复配置 *)
let get_recovery_config () = !recovery_config

(** 设置日志级别 *)
let set_log_level level = recovery_config := { !recovery_config with log_level = level }

(** 启用错误恢复功能 *)
let enable_recovery () = recovery_config := { !recovery_config with enabled = true }

(** 禁用错误恢复功能 *)
let disable_recovery () = recovery_config := { !recovery_config with enabled = false }
