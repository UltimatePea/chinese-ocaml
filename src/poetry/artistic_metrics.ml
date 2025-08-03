(** 诗词艺术评估指标模块 - Issue #2000 整合实施
 *
 * 此文件整合了从各个evaluator中提取的指标定义，
 * 提供统一的评估指标体系、性能监控和分析功能。
 *
 * 整合完成后，分散的评估指标逻辑将被统一管理。
 * @consolidation_issue #2000
 * @author Whisky, PR Worker
 *)

(** {1 指标类型定义} *)

type metric_category =
  | Performance     (** 性能指标 *)
  | Quality        (** 质量指标 *)
  | Usage          (** 使用指标 *)
  | Accuracy       (** 准确性指标 *)

type metric_value =
  | IntValue of int
  | FloatValue of float
  | StringValue of string
  | BoolValue of bool

type metric_entry = {
  name : string;
  category : metric_category;
  value : metric_value;
  unit : string;
  timestamp : float;
  description : string;
}

(** {1 指标收集存储} *)

let metrics_storage = Hashtbl.create 200
let metrics_history = ref []

(** {1 基础指标操作} *)

(** 记录指标 *)
let record_metric name category value unit description =
  let metric = {
    name;
    category;
    value;
    unit;
    timestamp = Unix.time ();
    description;
  } in
  Hashtbl.replace metrics_storage name metric;
  metrics_history := metric :: !metrics_history

(** 获取指标 *)
let get_metric name =
  try Some (Hashtbl.find metrics_storage name)
  with Not_found -> None

(** 获取所有指标 *)
let get_all_metrics () =
  Hashtbl.fold (fun _name metric acc -> metric :: acc) metrics_storage []

(** {1 性能指标} *)

let evaluation_start_time = ref 0.0
let evaluation_count = ref 0
let total_evaluation_time = ref 0.0

(** 开始性能测量 *)
let start_performance_measurement () =
  evaluation_start_time := Unix.time ()

(** 结束性能测量 *)
let end_performance_measurement () =
  let duration = Unix.time () -. !evaluation_start_time in
  incr evaluation_count;
  total_evaluation_time := !total_evaluation_time +. duration;
  
  record_metric "evaluation_duration" Performance (FloatValue duration) "seconds" "单次评估耗时";
  record_metric "evaluation_count" Performance (IntValue !evaluation_count) "times" "总评估次数";
  record_metric "average_duration" Performance 
    (FloatValue (!total_evaluation_time /. float_of_int !evaluation_count)) 
    "seconds" "平均评估耗时"

(** 记录内存使用 *)
let record_memory_usage () =
  let gc_stats = Gc.stat () in
  record_metric "heap_words" Performance (IntValue gc_stats.heap_words) "words" "堆内存字数";
  record_metric "major_collections" Performance (IntValue gc_stats.major_collections) "times" "主要GC次数";
  record_metric "minor_collections" Performance (IntValue gc_stats.minor_collections) "times" "次要GC次数"

(** {1 质量指标} *)

(** 记录评估质量指标 *)
let record_evaluation_quality overall_score dimension_count =
  record_metric "overall_score" Quality (FloatValue overall_score) "0.0-1.0" "整体评分";
  record_metric "dimension_count" Quality (IntValue dimension_count) "count" "评估维度数量";
  
  let quality_level = 
    if overall_score >= 0.9 then "excellent"
    else if overall_score >= 0.75 then "good"
    else if overall_score >= 0.6 then "fair"
    else "poor"
  in
  record_metric "quality_level" Quality (StringValue quality_level) "level" "质量等级"

(** 记录准确性指标 *)
let record_accuracy_metrics confidence_scores =
  let avg_confidence = List.fold_left (+.) 0.0 confidence_scores /. float_of_int (List.length confidence_scores) in
  let min_confidence = List.fold_left min 1.0 confidence_scores in
  let max_confidence = List.fold_left max 0.0 confidence_scores in
  
  record_metric "average_confidence" Accuracy (FloatValue avg_confidence) "0.0-1.0" "平均置信度";
  record_metric "min_confidence" Accuracy (FloatValue min_confidence) "0.0-1.0" "最低置信度";
  record_metric "max_confidence" Accuracy (FloatValue max_confidence) "0.0-1.0" "最高置信度"

(** {1 使用指标} *)

let api_call_counts = Hashtbl.create 50

(** 记录API调用 *)
let record_api_call api_name =
  let current_count = try Hashtbl.find api_call_counts api_name with Not_found -> 0 in
  let new_count = current_count + 1 in
  Hashtbl.replace api_call_counts api_name new_count;
  record_metric ("api_call_" ^ api_name) Usage (IntValue new_count) "times" ("API调用次数: " ^ api_name)

(** 获取热门API *)
let get_popular_apis limit =
  let api_list = Hashtbl.fold (fun name count acc -> (name, count) :: acc) api_call_counts [] in
  let sorted = List.sort (fun (_, c1) (_, c2) -> compare c2 c1) api_list in
  let rec take n lst = match n, lst with
    | 0, _ | _, [] -> []
    | n, h :: t -> h :: take (n-1) t
  in
  take limit sorted

(** {1 错误指标} *)

let error_counts = Hashtbl.create 20

(** 记录错误 *)
let record_error error_type error_message =
  let current_count = try Hashtbl.find error_counts error_type with Not_found -> 0 in
  let new_count = current_count + 1 in
  Hashtbl.replace error_counts error_type new_count;
  
  record_metric ("error_" ^ error_type) Quality (IntValue new_count) "times" ("错误次数: " ^ error_type);
  record_metric "last_error" Quality (StringValue error_message) "message" "最后一次错误信息"

(** 计算错误率 *)
let calculate_error_rate () =
  let total_errors = Hashtbl.fold (fun _ count acc -> acc + count) error_counts 0 in
  let error_rate = if !evaluation_count = 0 then 0.0 
                  else float_of_int total_errors /. float_of_int !evaluation_count in
  record_metric "error_rate" Quality (FloatValue error_rate) "percentage" "错误率";
  error_rate

(** {1 聚合指标} *)

(** 计算指标统计 *)
let calculate_metric_statistics metric_name =
  let values = List.filter_map (fun metric ->
    if metric.name = metric_name then
      match metric.value with
      | FloatValue f -> Some f
      | IntValue i -> Some (float_of_int i)
      | _ -> None
    else None
  ) !metrics_history in
  
  if values = [] then None
  else
    let count = List.length values in
    let sum = List.fold_left (+.) 0.0 values in
    let avg = sum /. float_of_int count in
    let min_val = List.fold_left min (List.hd values) values in
    let max_val = List.fold_left max (List.hd values) values in
    
    Some (count, avg, min_val, max_val, sum)

(** 生成性能摘要 *)
let generate_performance_summary () =
  let current_time = Unix.time () in
  let recent_metrics = List.filter (fun metric ->
    current_time -. metric.timestamp < 3600.0  (* 最近1小时 *)
  ) !metrics_history in
  
  let performance_metrics = List.filter (fun metric ->
    metric.category = Performance
  ) recent_metrics in
  
  [
    ("总指标数", string_of_int (List.length !metrics_history));
    ("最近1小时指标", string_of_int (List.length recent_metrics));
    ("性能指标数", string_of_int (List.length performance_metrics));
    ("总评估次数", string_of_int !evaluation_count);
    ("总评估时间", Printf.sprintf "%.2f秒" !total_evaluation_time);
    ("错误率", Printf.sprintf "%.2f%%" (calculate_error_rate () *. 100.0));
  ]

(** {1 指标导出} *)

(** 导出指标到CSV格式 *)
let export_metrics_csv () =
  let header = "名称,类别,值,单位,时间戳,描述" in
  let rows = List.map (fun metric ->
    let category_str = match metric.category with
      | Performance -> "性能"
      | Quality -> "质量"
      | Usage -> "使用"
      | Accuracy -> "准确性"
    in
    let value_str = match metric.value with
      | IntValue i -> string_of_int i
      | FloatValue f -> string_of_float f
      | StringValue s -> s
      | BoolValue b -> string_of_bool b
    in
    Printf.sprintf "%s,%s,%s,%s,%.2f,%s" 
      metric.name category_str value_str metric.unit metric.timestamp metric.description
  ) (get_all_metrics ()) in
  String.concat "\n" (header :: rows)

(** 导出性能报告 *)
let export_performance_report () =
  let summary = generate_performance_summary () in
  let popular_apis = get_popular_apis 5 in
  
  let report_lines = [
    "# 诗词艺术评估系统性能报告";
    "";
    "## 总体统计";
  ] @ (List.map (fun (key, value) -> Printf.sprintf "- %s: %s" key value) summary) @ [
    "";
    "## 热门API调用";
  ] @ (List.map (fun (api, count) -> Printf.sprintf "- %s: %d次" api count) popular_apis) @ [
    "";
    "## 错误统计";
  ] @ (Hashtbl.fold (fun error_type count acc ->
    (Printf.sprintf "- %s: %d次" error_type count) :: acc
  ) error_counts []) in
  
  String.concat "\n" report_lines

(** {1 指标分析} *)

(** 检测异常指标 *)
let detect_anomalies () =
  let anomalies = ref [] in
  
  (* 检查错误率异常 *)
  let error_rate = calculate_error_rate () in
  if error_rate > 0.1 then
    anomalies := ("错误率过高", Printf.sprintf "%.2f%%" (error_rate *. 100.0)) :: !anomalies;
  
  (* 检查性能异常 *)
  (match calculate_metric_statistics "evaluation_duration" with
  | Some (_, avg, _, max_val, _) ->
    if max_val > avg *. 3.0 then
      anomalies := ("评估耗时异常", Printf.sprintf "最大值%.2fs超过平均值%.2fs的3倍" max_val avg) :: !anomalies
  | None -> ());
  
  (* 检查内存异常 *)
  (match get_metric "heap_words" with
  | Some metric ->
    (match metric.value with
    | IntValue words when words > 1000000 ->
      anomalies := ("内存使用过高", Printf.sprintf "%d words" words) :: !anomalies
    | _ -> ())
  | None -> ());
  
  !anomalies

(** {1 基准测试} *)

(** 运行基准测试 *)
let run_benchmark test_data =
  let start_time = Unix.time () in
  start_performance_measurement ();
  
  (* 模拟评估过程 *)
  List.iteri (fun i poem ->
    record_api_call "evaluate_poem";
    let score = 0.7 +. (Random.float 0.3) in
    record_evaluation_quality score 5;
    if Random.float 1.0 < 0.05 then  (* 5%错误率 *)
      record_error "evaluation_error" "模拟评估错误"
  ) test_data;
  
  end_performance_measurement ();
  record_memory_usage ();
  
  let end_time = Unix.time () in
  let total_time = end_time -. start_time in
  
  record_metric "benchmark_duration" Performance (FloatValue total_time) "seconds" "基准测试总耗时";
  record_metric "benchmark_throughput" Performance 
    (FloatValue (float_of_int (List.length test_data) /. total_time)) 
    "poems/second" "基准测试吞吐量"

(** {1 清理和维护} *)

(** 清理旧指标 *)
let cleanup_old_metrics max_age_hours =
  let cutoff_time = Unix.time () -. (max_age_hours *. 3600.0) in
  metrics_history := List.filter (fun metric ->
    metric.timestamp > cutoff_time
  ) !metrics_history

(** 重置所有指标 *)
let reset_all_metrics () =
  Hashtbl.clear metrics_storage;
  Hashtbl.clear api_call_counts;
  Hashtbl.clear error_counts;
  metrics_history := [];
  evaluation_count := 0;
  total_evaluation_time := 0.0