(** 性能回归检测模块
    
    专注于性能回归检测、分析和报告生成功能 *)

open Utils.Base_formatter
open Benchmark_coordinator

module RegressionDetector = struct
  (** 回归检测阈值配置 *)
  type regression_threshold = {
    performance_degradation : float;  (** 性能下降阈值 (百分比) *)
    memory_increase : float;          (** 内存增长阈值 (百分比) *)
    variance_increase : float;        (** 方差增长阈值 (百分比) *)
  }

  (** 默认回归检测阈值 *)
  let default_threshold = {
    performance_degradation = 0.2;  (* 20%性能下降 *)
    memory_increase = 0.3;          (* 30%内存增长 *)
    variance_increase = 0.5;        (* 50%方差增长 *)
  }

  (** 回归检测结果类型 *)
  type regression_result = {
    test_name : string;
    regression_type : string;
    current_value : float;
    baseline_value : float;
    change_percentage : float;
    severity : string;
    description : string;
  }

  (** 检测单个指标的性能回归 *)
  let detect_regression ?(threshold = default_threshold) (current : performance_metric) (baseline : performance_metric) =
    let performance_change =
      (current.execution_time -. baseline.execution_time) /. baseline.execution_time
    in
    
    let memory_change = match (current.memory_usage, baseline.memory_usage) with
      | Some curr_mem, Some base_mem -> 
          Some ((float_of_int curr_mem -. float_of_int base_mem) /. float_of_int base_mem)
      | _ -> None
    in
    
    let variance_change = match (current.variance, baseline.variance) with
      | Some curr_var, Some base_var ->
          Some ((curr_var -. base_var) /. base_var)
      | _ -> None
    in
    
    let regressions = ref [] in
    
    (* 检测性能回归 *)
    if performance_change > threshold.performance_degradation then
      regressions := {
        test_name = current.name;
        regression_type = "性能回归";
        current_value = current.execution_time;
        baseline_value = baseline.execution_time;
        change_percentage = performance_change *. 100.0;
        severity = if performance_change > 0.5 then "严重" else "中等";
        description = concat_strings [
          "执行时间从 "; string_of_float baseline.execution_time; "秒 增加到 ";
          string_of_float current.execution_time; "秒"
        ];
      } :: !regressions;
    
    (* 检测内存回归 *)
    (match memory_change with
     | Some mem_change when mem_change > threshold.memory_increase ->
         regressions := {
           test_name = current.name;
           regression_type = "内存回归";
           current_value = float_of_int (Option.get current.memory_usage);
           baseline_value = float_of_int (Option.get baseline.memory_usage);
           change_percentage = mem_change *. 100.0;
           severity = if mem_change > 0.8 then "严重" else "中等";
           description = "内存使用显著增加";
         } :: !regressions
     | _ -> ());
    
    (* 检测方差回归 *)
    (match variance_change with
     | Some var_change when var_change > threshold.variance_increase ->
         regressions := {
           test_name = current.name;
           regression_type = "稳定性回归";
           current_value = Option.get current.variance;
           baseline_value = Option.get baseline.variance;
           change_percentage = var_change *. 100.0;
           severity = if var_change > 1.0 then "严重" else "轻微";
           description = "性能稳定性下降";
         } :: !regressions
     | _ -> ());
    
    !regressions

  (** 生成回归检测报告 *)
  let generate_regression_report ?(threshold = default_threshold) baseline_results current_results =
    let baseline_map = List.fold_left
      (fun acc metric -> (metric.name, metric) :: acc)
      [] baseline_results in
    
    let all_regressions = List.fold_left
      (fun acc current_metric ->
        try
          let baseline_metric = List.assoc current_metric.name baseline_map in
          let regressions = detect_regression ~threshold current_metric baseline_metric in
          regressions @ acc
        with Not_found -> acc)
      [] current_results in
    
    if List.length all_regressions = 0 then
      ["✅ 未检测到性能回归"]
    else
      List.map
        (fun regression ->
          concat_strings [
            "⚠️  ["; regression.severity; "] "; regression.regression_type; ": ";
            regression.test_name; " - ";
            regression.description;
            " (变化: "; string_of_float regression.change_percentage; "%)"
          ])
        all_regressions

  (** 生成详细的回归分析报告 *)
  let generate_detailed_regression_report ?(threshold = default_threshold) baseline_results current_results =
    let baseline_map = List.fold_left
      (fun acc metric -> (metric.name, metric) :: acc)
      [] baseline_results in
    
    let all_regressions = List.fold_left
      (fun acc current_metric ->
        try
          let baseline_metric = List.assoc current_metric.name baseline_map in
          let regressions = detect_regression ~threshold current_metric baseline_metric in
          regressions @ acc
        with Not_found -> acc)
      [] current_results in
    
    let report_header = [
      "# 性能回归分析报告\n";
      concat_strings ["检测阈值: 性能下降"; string_of_float (threshold.performance_degradation *. 100.0); "%, "];
      concat_strings ["内存增长"; string_of_float (threshold.memory_increase *. 100.0); "%, "];
      concat_strings ["方差增长"; string_of_float (threshold.variance_increase *. 100.0); "%\n\n"];
    ] in
    
    if List.length all_regressions = 0 then
      report_header @ ["## ✅ 检测结果\n\n未检测到性能回归。所有测试指标都在可接受范围内。\n"]
    else
      let regression_details = List.map
        (fun regression ->
          concat_strings [
            "### "; regression.regression_type; ": "; regression.test_name; "\n\n";
            "- **严重程度**: "; regression.severity; "\n";
            "- **当前值**: "; string_of_float regression.current_value; "\n";
            "- **基线值**: "; string_of_float regression.baseline_value; "\n";
            "- **变化幅度**: "; string_of_float regression.change_percentage; "%\n";
            "- **描述**: "; regression.description; "\n\n";
          ])
        all_regressions in
      
      report_header @ ["## ⚠️ 检测到的回归问题\n\n"] @ regression_details

  (** 执行完整的回归检测分析 *)
  let analyze_performance_regression ?(threshold = default_threshold) baseline_suite current_suite =
    let baseline_metrics = List.fold_left
      (fun acc result -> result.metrics @ acc) 
      [] baseline_suite.results in
    
    let current_metrics = List.fold_left
      (fun acc result -> result.metrics @ acc) 
      [] current_suite.results in
    
    {
      suite_name = concat_strings [current_suite.suite_name; " - 回归分析"];
      results = []; (* 简化，不包含详细结果 *)
      summary = String.concat "\n" (generate_regression_report ~threshold baseline_metrics current_metrics);
      total_duration = current_suite.total_duration;
    }
end

(** 公共接口函数 *)
let detect_regression = RegressionDetector.detect_regression
let generate_regression_report = RegressionDetector.generate_regression_report
let generate_detailed_regression_report = RegressionDetector.generate_detailed_regression_report
let analyze_performance_regression = RegressionDetector.analyze_performance_regression