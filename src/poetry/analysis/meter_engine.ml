(** 统一格律检查引擎 - 重构版本
    
    此模块整合了诗词格律检查功能，支持律诗、绝句、词、曲等多种诗体的
    格律验证和分析，基于模块化的检查器架构。
    
    重构内容：
    - 使用模块化的检查器（line_checker, rhyme_checker, tonal_checker, parallelism_checker）
    - 从meter_types模块导入类型定义
    - 保持向后兼容的API接口
    - 减少代码重复，提高可维护性
    
    @author Alpha, 主要开发代理 - Poetry模块重构团队
    @version 3.0 (Phase 2: 模块化重构版)
    @since 2025-07-30
    @fix_issue #1775 - 严重技术债务修复 *)

(* Re-export types from Meter_types *)
include Meter_types

(** {1 异常定义} *)

exception MeterEngineError of string

(** {1 引擎状态管理} *)

(** 生成缓存键 *)
let generate_cache_key verses pattern =
  let verses_hash = String.concat "|" verses |> Hashtbl.hash in
  let pattern_hash = Hashtbl.hash pattern in
  Printf.sprintf "%d_%d" verses_hash pattern_hash

(** 创建新的格律引擎状态 *)
let create_meter_engine_state rhythm_analyzer artistic_evaluator =
  {
    rhythm_analyzer;
    artistic_evaluator;
    cache_enabled = true;
    cached_results = Hashtbl.create 128;
    performance_stats = {
      total_checks = 0;
      cache_hits = 0;
      avg_check_time = 0.0;
    };
  }

(** 初始化格律引擎 (向后兼容函数) *)
let initialize_meter_engine rhythm_analyzer artistic_evaluator =
  create_meter_engine_state rhythm_analyzer artistic_evaluator

(** {1 诗体识别功能} *)

(** 基于行数识别诗体 *)
let detect_form_by_line_count verses =
  match List.length verses with
  | 4 -> Some (JueJu 5)  (* 默认五言绝句 *)
  | 8 -> Some (LuShi 5)  (* 默认五言律诗 *)
  | _ -> Some GuTi       (* 其他归为古体诗 *)

(** 基于字数模式识别诗体 *)
let detect_form_by_line_lengths verses =
  let line_lengths = List.map String.length verses in
  let avg_length = 
    List.fold_left (+) 0 line_lengths |> float_of_int |> fun x -> x /. float_of_int (List.length verses)
  in
  
  if List.length verses = 4 then
    if avg_length >= 6.5 then Some (JueJu 7) else Some (JueJu 5)
  else if List.length verses = 8 then
    if avg_length >= 6.5 then Some (LuShi 7) else Some (LuShi 5)
  else
    Some GuTi

(** 识别诗体 *)
let recognize_poetry_form verses meter_state =
  let cache_key = "recognition_" ^ String.concat "|" verses in
  
  (* 检查缓存 *)
  match Hashtbl.find_opt meter_state.cached_results cache_key with
  | Some cached -> 
    (* 从缓存结果中提取识别信息，这里简化处理 *)
    {
      detected_form = cached.pattern.form;
      confidence = 0.9;
      reasons = ["缓存结果"];
      alternatives = [];
    }
  | None ->
    let line_count_detection = detect_form_by_line_count verses in
    let line_length_detection = detect_form_by_line_lengths verses in
    
    let detected_form = 
      match line_count_detection, line_length_detection with
      | Some f1, Some f2 when f1 = f2 -> f1
      | Some f1, Some _f2 -> f1  (* 优先采用行数判断 *)
      | Some f, None | None, Some f -> f
      | None, None -> GuTi
    in
    
    let confidence = if line_count_detection = line_length_detection then 0.9 else 0.7 in
    let reasons = ["基于行数和字数模式分析"] in
    let alternatives = 
      match detected_form with
      | JueJu _n -> [(GuTi, 0.3)]
      | LuShi _n -> [(GuTi, 0.2)]
      | _ -> []
    in
    
    {
      detected_form;
      confidence;
      reasons;
      alternatives;
    }

(** {1 综合格律检查} *)

(** 执行所有检查 *)
let perform_all_checks verses pattern meter_state =
  (* 使用新的模块化检查器 *)
  let line_result = Line_checker.check_all_line_requirements verses pattern in
  let rhyme_result = Rhyme_checker.check_rhyme_compliance verses pattern meter_state.rhythm_analyzer in
  let tonal_compliance, tonal_violations = Tonal_checker.check_tonal_compliance verses pattern meter_state in
  let parallelism_compliance, parallelism_violations = Parallelism_checker.check_parallelism_compliance verses pattern meter_state in
  
  (line_result.line_count_compliance,
   line_result.line_count_violations,
   line_result.line_length_compliance,
   line_result.line_length_violations,
   rhyme_result.rhyme_compliance,
   rhyme_result.rhyme_violations,
   tonal_compliance,
   tonal_violations,
   parallelism_compliance,
   parallelism_violations)

(** 计算符合度的辅助函数 *)
let count_compliant items = List.fold_left (fun acc x -> acc +. if x then 1.0 else 0.0) 0.0 items

(** 计算整体符合度 *)
let calculate_overall_compliance line_count_ok line_length_compliance rhyme_compliance
    tonal_compliance parallelism_compliance =
  let total_checks =
    (if line_count_ok then 1.0 else 0.0)
    +. count_compliant line_length_compliance
    +. count_compliant rhyme_compliance +. count_compliant tonal_compliance
    +. count_compliant parallelism_compliance
  in
  let max_checks =
    1.0
    +. float_of_int (List.length line_length_compliance)
    +. float_of_int (List.length rhyme_compliance)
    +. float_of_int (List.length tonal_compliance)
    +. float_of_int (List.length parallelism_compliance)
  in
  if max_checks > 0.0 then total_checks /. max_checks else 0.0

(** 汇总所有违规项 *)
let collect_all_violations line_count_violations line_length_violations rhyme_violations
    tonal_violations parallelism_violations =
  line_count_violations @ line_length_violations @ rhyme_violations @ tonal_violations
  @ parallelism_violations

(** 生成格律建议 *)
let generate_meter_suggestions overall_compliance line_count_violations line_length_violations
    rhyme_violations tonal_violations parallelism_violations =
  if overall_compliance > 0.8 then [ "格律符合度很高，继续保持！" ]
  else if overall_compliance > 0.6 then [ "格律基本符合，注意细节调整" ]
  else
    [ "建议参考标准格律进行重大调整" ]
    @ (if List.length line_count_violations > 0 then [ "调整诗句行数" ] else [])
    @ (if List.length line_length_violations > 0 then [ "调整各行字数" ] else [])
    @ (if List.length rhyme_violations > 0 then [ "调整韵律安排" ] else [])
    @ (if List.length tonal_violations > 0 then [ "调整平仄搭配" ] else [])
    @ if List.length parallelism_violations > 0 then [ "完善对仗结构" ] else []

(** 构建检查结果 *)
let build_meter_result pattern verse_count line_length_compliance rhyme_compliance tonal_compliance
    parallelism_compliance overall_compliance all_violations suggestions =
  {
    pattern;
    verse_count;
    line_length_compliance;
    rhyme_compliance;
    tonal_compliance;
    parallelism_compliance;
    overall_compliance;
    violations = all_violations;
    suggestions;
  }

(** 执行格律检查 *)
let check_meter verses pattern meter_state =
  let cache_key = generate_cache_key verses pattern in

  (* 检查缓存 *)
  match Hashtbl.find_opt meter_state.cached_results cache_key with
  | Some result -> 
    meter_state.performance_stats.cache_hits <- meter_state.performance_stats.cache_hits + 1;
    result
  | None -> 
    try
      let start_time = Unix.gettimeofday () in
      let verse_count = List.length verses in
      
      let ( line_count_ok,
            line_count_violations,
            line_length_compliance,
            line_length_violations,
            rhyme_compliance,
            rhyme_violations,
            tonal_compliance,
            tonal_violations,
            parallelism_compliance,
            parallelism_violations ) =
        perform_all_checks verses pattern meter_state
      in

      let overall_compliance =
        calculate_overall_compliance line_count_ok line_length_compliance rhyme_compliance
          tonal_compliance parallelism_compliance
      in
      let all_violations =
        collect_all_violations line_count_violations line_length_violations rhyme_violations
          tonal_violations parallelism_violations
      in
      let suggestions =
        generate_meter_suggestions overall_compliance line_count_violations line_length_violations
          rhyme_violations tonal_violations parallelism_violations
      in

      let result =
        build_meter_result pattern verse_count line_length_compliance rhyme_compliance
          tonal_compliance parallelism_compliance overall_compliance all_violations suggestions
      in

      (* 缓存结果 *)
      Hashtbl.replace meter_state.cached_results cache_key result;
      
      (* 更新性能统计 *)
      let end_time = Unix.gettimeofday () in
      let check_time = end_time -. start_time in
      meter_state.performance_stats.total_checks <- meter_state.performance_stats.total_checks + 1;
      let total_checks = float_of_int meter_state.performance_stats.total_checks in
      let old_avg = meter_state.performance_stats.avg_check_time in
      meter_state.performance_stats.avg_check_time <- (old_avg *. (total_checks -. 1.0) +. check_time) /. total_checks;
      
      result
    with exn -> raise (MeterEngineError ("格律检查失败: " ^ Printexc.to_string exn))

(** {1 自动格律检查} *)

(** 自动识别诗体并检查格律 *)
let auto_check_meter verses meter_state =
  let recognition = recognize_poetry_form verses meter_state in

  let pattern = 
    match Poetry_forms.get_pattern_by_form recognition.detected_form with
    | Some p -> p
    | None -> Poetry_forms.guti_pattern
  in

  let check_result = check_meter verses pattern meter_state in
  (recognition, check_result)

(** {1 统计和工具函数} *)

(** 获取格律引擎统计信息 *)
let get_meter_engine_statistics meter_state =
  let cache_size = Hashtbl.length meter_state.cached_results in
  let stats = meter_state.performance_stats in

  [
    ("格律检查缓存大小", string_of_int cache_size);
    ("总检查次数", string_of_int stats.total_checks);
    ("缓存命中次数", string_of_int stats.cache_hits);
    ("平均检查时间", Printf.sprintf "%.4fs" stats.avg_check_time);
    ("缓存命中率", 
     if stats.total_checks > 0 then 
       Printf.sprintf "%.2f%%" (float_of_int stats.cache_hits /. float_of_int stats.total_checks *. 100.0)
     else "0.00%");
  ]

(** 清理格律引擎缓存 *)
let clear_meter_engine_cache meter_state =
  Hashtbl.clear meter_state.cached_results;
  meter_state.performance_stats.total_checks <- 0;
  meter_state.performance_stats.cache_hits <- 0;
  meter_state.performance_stats.avg_check_time <- 0.0;
  meter_state

(** 格式化诗体类型 *)
let format_poetry_form = function
  | LuShi n -> Printf.sprintf "%d言律诗" n
  | JueJu n -> Printf.sprintf "%d言绝句" n
  | Ci name -> Printf.sprintf "词·%s" name
  | Qu name -> Printf.sprintf "曲·%s" name
  | GuTi -> "古体诗"
  | ZiYou -> "自由体"

(** 格式化诗体识别结果 *)
let format_recognition_result result =
  let alternatives_str =
    List.map
      (fun (form, conf) -> Printf.sprintf "%s (%.2f)" (format_poetry_form form) conf)
      result.alternatives
    |> String.concat ", "
  in

  let reasons_str = String.concat "; " result.reasons in

  Printf.sprintf "识别诗体: %s (置信度: %.2f)\n识别依据: %s\n备选: %s"
    (format_poetry_form result.detected_form)
    result.confidence reasons_str alternatives_str

(** 格式化格律检查结果 *)
let format_meter_check_result result =
  let compliance_str = Printf.sprintf "整体符合度: %.2f" result.overall_compliance in
  let violations_str =
    if List.length result.violations = 0 then "无违规项" else String.concat "; " result.violations
  in
  let suggestions_str = String.concat "; " result.suggestions in

  Printf.sprintf "=== 格律检查结果 ===\n诗体: %s\n%s\n违规项: %s\n建议: %s"
    (format_poetry_form result.pattern.form)
    compliance_str violations_str suggestions_str