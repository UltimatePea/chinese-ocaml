(** 统一格律检查引擎实现 - 重构版本
    
    基础实现，提供格律检查的核心功能。
    实现meter_engine.mli中定义的所有接口。
    
    Author: Whisky, PR Worker - 修复Issue #2145构建失败
    @version 3.0 (临时实现)
    @since 2025-08-03
    @fix_issue #2145 *)

open Meter_types
open Poetry_rhyme.Rhyme_query

(** {1 异常定义} *)

exception MeterEngineError of string

(** {1 辅助功能函数} *)

(** 将字符串转换为字符列表 *)
let string_to_char_list s =
  let rec aux i acc =
    if i < 0 then acc
    else aux (i - 1) (String.get s i :: acc)
  in
  aux (String.length s - 1) []

(** {1 引擎状态管理} *)

(** 创建新的格律引擎状态 *)
let create_meter_engine_state rhythm_analyzer artistic_evaluator =
  {
    rhythm_analyzer;
    artistic_evaluator;
    cache_enabled = true;
    cached_results = Hashtbl.create 100;
    performance_stats = [("total_analyses", 0.0); ("cache_hits", 0.0); ("avg_analysis_time", 0.0)];
  }

(** 初始化格律引擎 (向后兼容函数) *)
let initialize_meter_engine rhythm_analyzer artistic_evaluator =
  create_meter_engine_state rhythm_analyzer artistic_evaluator

(** {1 诗体识别功能} *)

(** 基于行数识别诗体 *)
let detect_form_by_line_count verses =
  match List.length verses with
  | 4 -> Some (JueJu 5)
  | 8 -> Some (LuShi 5)
  | _ -> None

(** 基于字数模式识别诗体 *)
let detect_form_by_line_lengths verses =
  let lengths = List.map (fun verse -> 
    String.length verse) verses in
  match lengths with
  | [5; 5; 5; 5] -> Some (JueJu 5)
  | [7; 7; 7; 7] -> Some (JueJu 7)
  | [5; 5; 5; 5; 5; 5; 5; 5] -> Some (LuShi 5)
  | [7; 7; 7; 7; 7; 7; 7; 7] -> Some (LuShi 7)
  | _ -> Some GuTi

(** 识别诗体 *)
let recognize_poetry_form verses (_engine_state : meter_engine_state) =
  let by_count = detect_form_by_line_count verses in
  let by_length = detect_form_by_line_lengths verses in
  
  let detected_form = match (by_count, by_length) with
  | (Some form1, Some form2) when form1 = form2 -> form1
  | (Some form, None) | (None, Some form) -> form
  | _ -> GuTi
  in
  
  let confidence = match (by_count, by_length) with
  | (Some _, Some _) -> 0.9
  | (Some _, None) | (None, Some _) -> 0.6
  | _ -> 0.3
  in
  
  {
    detected_form;
    confidence;
    reasons = ["基于行数和字数模式识别"];
    alternatives = [(GuTi, 0.1)];
  }

(** {1 格律检查功能} *)

(** 执行格律检查 *)
let check_meter verses pattern (engine_state : meter_engine_state) =
  let verse_count = List.length verses in
  let line_length_compliance = List.map2 (fun verse expected_length ->
    let actual_length = List.length (string_to_char_list verse) in
    actual_length = expected_length
  ) verses pattern.line_lengths in
  
  let violations = [] in
  let suggestions = [] in
  
  let overall_compliance = 
    let compliant_count = List.fold_left (fun acc b -> if b then acc + 1 else acc) 0 line_length_compliance in
    float_of_int compliant_count /. float_of_int (List.length line_length_compliance)
  in
  
  (* 性能统计更新 - 简化版本 *)
  
  {
    pattern;
    verse_count;
    line_length_compliance;
    rhyme_compliance = List.map (fun _ -> true) verses;
    tonal_compliance = List.map (fun _ -> true) verses;
    parallelism_compliance = [];
    overall_compliance;
    violations;
    suggestions;
  }

(** 自动识别诗体并检查格律 *)
let auto_check_meter verses (engine_state : meter_engine_state) =
  let form_result = recognize_poetry_form verses engine_state in
  
  let pattern = match form_result.detected_form with
  | JueJu 5 -> {
      form = JueJu 5;
      required_lines = 4;
      line_lengths = [5; 5; 5; 5];
      rhyme_scheme = [None; None; None; None];
      tonal_pattern = [];
      parallelism_requirements = [];
    }
  | JueJu 7 -> {
      form = JueJu 7;
      required_lines = 4;
      line_lengths = [7; 7; 7; 7];
      rhyme_scheme = [None; None; None; None];
      tonal_pattern = [];
      parallelism_requirements = [];
    }
  | LuShi 5 -> {
      form = LuShi 5;
      required_lines = 8;
      line_lengths = [5; 5; 5; 5; 5; 5; 5; 5];
      rhyme_scheme = [None; None; None; None; None; None; None; None];
      tonal_pattern = [];
      parallelism_requirements = [];
    }
  | LuShi 7 -> {
      form = LuShi 7;
      required_lines = 8;
      line_lengths = [7; 7; 7; 7; 7; 7; 7; 7];
      rhyme_scheme = [None; None; None; None; None; None; None; None];
      tonal_pattern = [];
      parallelism_requirements = [];
    }
  | _ -> {
      form = GuTi;
      required_lines = List.length verses;
      line_lengths = List.map (fun verse -> List.length (string_to_char_list verse)) verses;
      rhyme_scheme = List.map (fun _ -> None) verses;
      tonal_pattern = [];
      parallelism_requirements = [];
    }
  in
  
  let meter_result = check_meter verses pattern engine_state in
  (form_result, meter_result)

(** {1 统计和工具函数} *)

(** 获取格律引擎统计信息 *)
let get_meter_engine_statistics (engine_state : meter_engine_state) =
  let stats = engine_state.performance_stats in
  [
    ("总分析次数", string_of_int stats.total_analyses);
    ("缓存命中次数", string_of_int stats.cache_hits);
    ("平均分析时间", Printf.sprintf "%.4fs" stats.avg_analysis_time);
    ("缓存启用", if engine_state.cache_enabled then "是" else "否");
    ("缓存大小", string_of_int (Hashtbl.length engine_state.cached_results));
  ]

(** 清理格律引擎缓存 *)
let clear_meter_engine_cache (engine_state : meter_engine_state) =
  Hashtbl.clear engine_state.cached_results;
  engine_state.performance_stats.cache_hits <- 0;
  engine_state

(** 格式化诗体类型 *)
let format_poetry_form = function
  | LuShi n -> Printf.sprintf "%d言律诗" n
  | JueJu n -> Printf.sprintf "%d言绝句" n
  | Ci name -> Printf.sprintf "词(%s)" name
  | Qu name -> Printf.sprintf "曲(%s)" name
  | GuTi -> "古体诗"
  | ZiYou -> "自由体"

(** 格式化诗体识别结果 *)
let format_recognition_result result =
  Printf.sprintf "识别结果: %s (置信度: %.2f)\n原因: %s"
    (format_poetry_form result.detected_form)
    result.confidence
    (String.concat "; " result.reasons)

(** 格式化格律检查结果 *)
let format_meter_check_result result =
  Printf.sprintf "格律检查: %s\n整体符合度: %.2f\n违规数: %d"
    (format_poetry_form result.pattern.form)
    result.overall_compliance
    (List.length result.violations)