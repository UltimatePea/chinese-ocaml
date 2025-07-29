(** 统一格律检查引擎 - Phase 2: Engine Layer Refactoring
    
    此模块整合了诗词格律检查功能，支持律诗、绝句、词、曲等多种诗体的
    格律验证和分析，基于统一的韵律分析和艺术性评价引擎。
    
    技术债务修复：
    - 整合分散的格律检查逻辑
    - 建立统一的诗体定义和验证框架
    - 基于统一引擎架构，提供准确的格律分析
    
    @author Alpha, 主要开发代理 - Poetry模块重构团队
    @version 2.0 (Phase 2: 引擎层重构版)
    @since 2025-07-27
    @fix_issue #1501 *)

open Poetry_core.Poetry_types
open Rhythm_analyzer
open Artistic_evaluator

(** {1 格律类型定义} *)

(** 诗体类型 *)
type poetry_form =
  | LuShi of int  (** 律诗 (5言/7言) *)
  | JueJu of int  (** 绝句 (5言/7言) *)
  | Ci of string  (** 词 (词牌名) *)
  | Qu of string  (** 曲 (曲牌名) *)
  | GuTi  (** 古体诗 *)
  | ZiYou  (** 自由体 *)

type meter_pattern = {
  form : poetry_form;  (** 诗体形式 *)
  required_lines : int;  (** 要求行数 *)
  line_lengths : int list;  (** 各行字数要求 *)
  rhyme_scheme : rhyme_group option list;  (** 韵式要求 *)
  tonal_pattern : rhyme_category list list;  (** 平仄模式 *)
  parallelism_requirements : (int * int) list;  (** 对仗要求 (行号对) *)
}
(** 格律模式 *)

type meter_check_result = {
  pattern : meter_pattern;  (** 使用的格律模式 *)
  verse_count : int;  (** 实际诗句数 *)
  line_length_compliance : bool list;  (** 各行字数符合度 *)
  rhyme_compliance : bool list;  (** 各行韵律符合度 *)
  tonal_compliance : bool list;  (** 各行平仄符合度 *)
  parallelism_compliance : bool list;  (** 对仗符合度 *)
  overall_compliance : float;  (** 整体符合度 *)
  violations : string list;  (** 违规项列表 *)
  suggestions : string list;  (** 改进建议 *)
}
(** 格律检查结果 *)

type form_recognition_result = {
  detected_form : poetry_form;  (** 检测到的诗体 *)
  confidence : float;  (** 识别置信度 *)
  reasons : string list;  (** 识别依据 *)
  alternatives : (poetry_form * float) list;  (** 备选诗体 *)
}
(** 诗体识别结果 *)

(** {1 预定义格律模式} *)

(** 五言律诗格律模式 *)
let wuyan_lushi_pattern =
  {
    form = LuShi 5;
    required_lines = 8;
    line_lengths = [ 5; 5; 5; 5; 5; 5; 5; 5 ];
    rhyme_scheme =
      [ None; Some YuRhyme; None; Some YuRhyme; None; Some YuRhyme; None; Some YuRhyme ];
    tonal_pattern =
      [
        [ ZeSheng; ZeSheng; PingSheng; PingSheng; ZeSheng ];
        [ PingSheng; PingSheng; ZeSheng; ZeSheng; PingSheng ];
        [ PingSheng; PingSheng; ZeSheng; ZeSheng; PingSheng ];
        [ ZeSheng; ZeSheng; PingSheng; PingSheng; ZeSheng ];
        [ ZeSheng; ZeSheng; PingSheng; PingSheng; ZeSheng ];
        [ PingSheng; PingSheng; ZeSheng; ZeSheng; PingSheng ];
        [ PingSheng; PingSheng; ZeSheng; ZeSheng; PingSheng ];
        [ ZeSheng; ZeSheng; PingSheng; PingSheng; ZeSheng ];
      ];
    parallelism_requirements = [ (3, 4); (5, 6) ];
  }

(** 七言律诗格律模式 *)
let qiyan_lushi_pattern =
  {
    form = LuShi 7;
    required_lines = 8;
    line_lengths = [ 7; 7; 7; 7; 7; 7; 7; 7 ];
    rhyme_scheme =
      [ None; Some YuRhyme; None; Some YuRhyme; None; Some YuRhyme; None; Some YuRhyme ];
    tonal_pattern =
      [
        [ PingSheng; PingSheng; ZeSheng; ZeSheng; PingSheng; PingSheng; ZeSheng ];
        [ ZeSheng; ZeSheng; PingSheng; PingSheng; ZeSheng; ZeSheng; PingSheng ];
        [ ZeSheng; ZeSheng; PingSheng; PingSheng; ZeSheng; ZeSheng; PingSheng ];
        [ PingSheng; PingSheng; ZeSheng; ZeSheng; PingSheng; PingSheng; ZeSheng ];
        [ PingSheng; PingSheng; ZeSheng; ZeSheng; PingSheng; PingSheng; ZeSheng ];
        [ ZeSheng; ZeSheng; PingSheng; PingSheng; ZeSheng; ZeSheng; PingSheng ];
        [ ZeSheng; ZeSheng; PingSheng; PingSheng; ZeSheng; ZeSheng; PingSheng ];
        [ PingSheng; PingSheng; ZeSheng; ZeSheng; PingSheng; PingSheng; ZeSheng ];
      ];
    parallelism_requirements = [ (3, 4); (5, 6) ];
  }

(** 五言绝句格律模式 *)
let wuyan_jueju_pattern =
  {
    form = JueJu 5;
    required_lines = 4;
    line_lengths = [ 5; 5; 5; 5 ];
    rhyme_scheme = [ None; Some YuRhyme; None; Some YuRhyme ];
    tonal_pattern =
      [
        [ ZeSheng; ZeSheng; PingSheng; PingSheng; ZeSheng ];
        [ PingSheng; PingSheng; ZeSheng; ZeSheng; PingSheng ];
        [ PingSheng; PingSheng; ZeSheng; ZeSheng; PingSheng ];
        [ ZeSheng; ZeSheng; PingSheng; PingSheng; ZeSheng ];
      ];
    parallelism_requirements = [];
  }

(** 七言绝句格律模式 *)
let qiyan_jueju_pattern =
  {
    form = JueJu 7;
    required_lines = 4;
    line_lengths = [ 7; 7; 7; 7 ];
    rhyme_scheme = [ None; Some YuRhyme; None; Some YuRhyme ];
    tonal_pattern =
      [
        [ PingSheng; PingSheng; ZeSheng; ZeSheng; PingSheng; PingSheng; ZeSheng ];
        [ ZeSheng; ZeSheng; PingSheng; PingSheng; ZeSheng; ZeSheng; PingSheng ];
        [ ZeSheng; ZeSheng; PingSheng; PingSheng; ZeSheng; ZeSheng; PingSheng ];
        [ PingSheng; PingSheng; ZeSheng; ZeSheng; PingSheng; PingSheng; ZeSheng ];
      ];
    parallelism_requirements = [];
  }

(** 古体诗格律模式 (较宽松) *)
let guti_pattern =
  {
    form = GuTi;
    required_lines = 0;
    (* 不限行数 *)
    line_lengths = [];
    (* 不限字数 *)
    rhyme_scheme = [];
    (* 不限韵式 *)
    tonal_pattern = [];
    (* 不限平仄 *)
    parallelism_requirements = [];
  }

(** {1 格律引擎状态} *)

type meter_engine_state = {
  rhythm_analyzer : analyzer_state;
  artistic_evaluator : artistic_evaluator_state; [@warning "-69"]
      (* Used in construction, reserved for future expansion *)
  known_patterns : meter_pattern list;
  pattern_cache : (string, meter_check_result) Hashtbl.t;
  recognition_cache : (string, form_recognition_result) Hashtbl.t;
  last_check_time : float;
}
(** 格律引擎状态 *)

exception MeterEngineError of string
(** 格律引擎异常 *)

(** 初始化格律引擎 *)
let initialize_meter_engine rhythm_analyzer artistic_evaluator =
  {
    rhythm_analyzer;
    artistic_evaluator;
    known_patterns =
      [
        wuyan_lushi_pattern;
        qiyan_lushi_pattern;
        wuyan_jueju_pattern;
        qiyan_jueju_pattern;
        guti_pattern;
      ];
    pattern_cache = Hashtbl.create 100;
    recognition_cache = Hashtbl.create 100;
    last_check_time = Unix.time ();
  }

(** {1 诗体识别功能} *)

(** 根据诗句特征识别诗体 *)
let recognize_poetry_form verses meter_state =
  let cache_key = String.concat "|" verses in

  (* 检查缓存 *)
  match Hashtbl.find_opt meter_state.recognition_cache cache_key with
  | Some result -> result
  | None ->
      let verse_count = List.length verses in
      let line_lengths = List.map String.length verses in

      let candidates = ref [] in

      (* 检查律诗特征 *)
      if verse_count = 8 then (
        if List.for_all (fun len -> len = 5) line_lengths then
          candidates := (LuShi 5, 0.9) :: !candidates;
        if List.for_all (fun len -> len = 7) line_lengths then
          candidates := (LuShi 7, 0.9) :: !candidates);

      (* 检查绝句特征 *)
      if verse_count = 4 then (
        if List.for_all (fun len -> len = 5) line_lengths then
          candidates := (JueJu 5, 0.9) :: !candidates;
        if List.for_all (fun len -> len = 7) line_lengths then
          candidates := (JueJu 7, 0.9) :: !candidates);

      (* 检查古体诗特征 *)
      if verse_count > 0 then candidates := (GuTi, 0.6) :: !candidates;

      (* 选择最佳候选 *)
      let sorted_candidates = List.sort (fun (_, c1) (_, c2) -> compare c2 c1) !candidates in

      let result =
        match sorted_candidates with
        | (best_form, confidence) :: alternatives ->
            let reasons =
              match best_form with
              | LuShi n -> [ Printf.sprintf "%d言律诗：8行，每行%d字" n n ]
              | JueJu n -> [ Printf.sprintf "%d言绝句：4行，每行%d字" n n ]
              | GuTi -> [ "古体诗：行数字数相对自由" ]
              | _ -> [ "基于诗句结构特征" ]
            in
            { detected_form = best_form; confidence; reasons; alternatives }
        | [] ->
            { detected_form = ZiYou; confidence = 0.3; reasons = [ "无法识别明确诗体" ]; alternatives = [] }
      in

      (* 缓存结果 *)
      Hashtbl.replace meter_state.recognition_cache cache_key result;
      result

(** {1 格律检查功能} *)

(** 检查行数符合度 *)
let check_line_count verses pattern =
  let actual_count = List.length verses in
  if pattern.required_lines = 0 then (true, []) (* 古体诗不限行数 *)
  else if actual_count = pattern.required_lines then (true, [])
  else (false, [ Printf.sprintf "行数不符：要求%d行，实际%d行" pattern.required_lines actual_count ])

(** 检查各行字数符合度 *)
let check_line_lengths verses pattern =
  let actual_lengths = List.map String.length verses in

  if List.length pattern.line_lengths = 0 then
    (* 古体诗不限字数 *)
    (List.map (fun _ -> true) actual_lengths, [])
  else
    let compliance =
      List.map2 (fun actual expected -> actual = expected) actual_lengths pattern.line_lengths
    in
    let violations =
      List.mapi
        (fun i ((actual, expected), compliant) ->
          if not compliant then Some (Printf.sprintf "第%d行字数不符：要求%d字，实际%d字" (i + 1) expected actual)
          else None)
        (List.combine (List.combine actual_lengths pattern.line_lengths) compliance)
      |> List.filter_map (fun x -> x)
    in
    (compliance, violations)

(** 检查韵律符合度 *)
let check_rhyme_compliance verses pattern meter_state =
  if List.length pattern.rhyme_scheme = 0 then
    (* 古体诗不限韵律 *)
    (List.map (fun _ -> true) verses, [])
  else
    let multi_analysis = analyze_multi_verse_rhythm verses meter_state.rhythm_analyzer in
    let actual_scheme = multi_analysis.rhyme_scheme in

    let compliance =
      List.map2
        (fun actual_opt expected_opt ->
          match (actual_opt, expected_opt) with
          | Some actual, Some expected -> actual = expected
          | None, None -> true
          | _, _ -> false)
        actual_scheme pattern.rhyme_scheme
    in

    let violations =
      List.mapi
        (fun i ((actual_opt, expected_opt), compliant) ->
          if not compliant then
            let actual_str =
              Option.map rhyme_group_to_string actual_opt |> Option.value ~default:"无韵"
            in
            let expected_str =
              Option.map rhyme_group_to_string expected_opt |> Option.value ~default:"无韵"
            in
            Some (Printf.sprintf "第%d行韵律不符：要求%s，实际%s" (i + 1) expected_str actual_str)
          else None)
        (List.combine (List.combine actual_scheme pattern.rhyme_scheme) compliance)
      |> List.filter_map (fun x -> x)
    in
    (compliance, violations)

(** 检查平仄符合度 *)
let check_tonal_compliance verses pattern meter_state =
  if List.length pattern.tonal_pattern = 0 then
    (* 古体诗不限平仄 *)
    (List.map (fun _ -> true) verses, [])
  else
    let verse_analyses =
      List.map (fun verse -> analyze_verse_rhythm verse meter_state.rhythm_analyzer) verses
    in

    let actual_patterns = List.map (fun analysis -> analysis.rhyme_pattern) verse_analyses in

    let compliance =
      List.map2
        (fun actual expected ->
          if List.length actual = List.length expected then
            List.for_all2 (fun a e -> a = e) actual expected
          else false)
        actual_patterns pattern.tonal_pattern
    in

    let violations =
      List.mapi
        (fun i ((actual, expected), compliant) ->
          if not compliant then
            let actual_str = List.map rhyme_category_to_string actual |> String.concat "" in
            let expected_str = List.map rhyme_category_to_string expected |> String.concat "" in
            Some (Printf.sprintf "第%d行平仄不符：要求%s，实际%s" (i + 1) expected_str actual_str)
          else None)
        (List.combine (List.combine actual_patterns pattern.tonal_pattern) compliance)
      |> List.filter_map (fun x -> x)
    in
    (compliance, violations)

(** 检查对仗符合度 *)
let check_parallelism_compliance verses pattern meter_state =
  if List.length pattern.parallelism_requirements = 0 then ([], [])
  else
    let verse_array = Array.of_list verses in
    let compliance = ref [] in
    let violations = ref [] in

    List.iter
      (fun (line1_idx, line2_idx) ->
        if line1_idx <= Array.length verse_array && line2_idx <= Array.length verse_array then (
          let line1 = verse_array.(line1_idx - 1) in
          let line2 = verse_array.(line2_idx - 1) in

          (* 简单的对仗检查：字数相等 *)
          let char_count_match = String.length line1 = String.length line2 in

          (* 韵律对仗检查 *)
          let analysis1 = analyze_verse_rhythm line1 meter_state.rhythm_analyzer in
          let analysis2 = analyze_verse_rhythm line2 meter_state.rhythm_analyzer in
          let pattern_match =
            List.length analysis1.rhyme_pattern = List.length analysis2.rhyme_pattern
          in

          let is_compliant = char_count_match && pattern_match in
          compliance := is_compliant :: !compliance;

          if not is_compliant then
            violations := Printf.sprintf "第%d行与第%d行对仗不符" line1_idx line2_idx :: !violations))
      pattern.parallelism_requirements;

    (List.rev !compliance, List.rev !violations)

(** 生成缓存键 *)
let generate_cache_key verses pattern =
  String.concat "|" verses ^ "#" ^
  match pattern.form with
  | LuShi n -> "lushi" ^ string_of_int n
  | JueJu n -> "jueju" ^ string_of_int n
  | GuTi -> "guti"
  | _ -> "other"

(** 执行所有格律检查 *)
let perform_all_checks verses pattern meter_state =
  let line_count_ok, line_count_violations = check_line_count verses pattern in
  let line_length_compliance, line_length_violations = check_line_lengths verses pattern in
  let rhyme_compliance, rhyme_violations = check_rhyme_compliance verses pattern meter_state in
  let tonal_compliance, tonal_violations = check_tonal_compliance verses pattern meter_state in
  let parallelism_compliance, parallelism_violations = check_parallelism_compliance verses pattern meter_state in
  
  (line_count_ok, line_count_violations, line_length_compliance, line_length_violations,
   rhyme_compliance, rhyme_violations, tonal_compliance, tonal_violations,
   parallelism_compliance, parallelism_violations)

(** 计算符合度的辅助函数 *)
let count_compliant items = List.fold_left (fun acc x -> acc +. if x then 1.0 else 0.0) 0.0 items

(** 计算整体符合度 *)
let calculate_overall_compliance line_count_ok line_length_compliance rhyme_compliance tonal_compliance parallelism_compliance =
  let total_checks =
    (if line_count_ok then 1.0 else 0.0) +.
    count_compliant line_length_compliance +.
    count_compliant rhyme_compliance +.
    count_compliant tonal_compliance +.
    count_compliant parallelism_compliance
  in
  let max_checks =
    1.0 +. float_of_int (List.length line_length_compliance) +.
    float_of_int (List.length rhyme_compliance) +.
    float_of_int (List.length tonal_compliance) +.
    float_of_int (List.length parallelism_compliance)
  in
  if max_checks > 0.0 then total_checks /. max_checks else 0.0

(** 汇总所有违规项 *)
let collect_all_violations line_count_violations line_length_violations rhyme_violations tonal_violations parallelism_violations =
  line_count_violations @ line_length_violations @ rhyme_violations @ tonal_violations @ parallelism_violations

(** 生成格律建议 *)
let generate_meter_suggestions overall_compliance line_count_violations line_length_violations rhyme_violations tonal_violations parallelism_violations =
  if overall_compliance > 0.8 then ["格律符合度很高，继续保持！"]
  else if overall_compliance > 0.6 then ["格律基本符合，注意细节调整"]
  else
    ["建议参考标准格律进行重大调整"] @
    (if List.length line_count_violations > 0 then ["调整诗句行数"] else []) @
    (if List.length line_length_violations > 0 then ["调整各行字数"] else []) @
    (if List.length rhyme_violations > 0 then ["调整韵律安排"] else []) @
    (if List.length tonal_violations > 0 then ["调整平仄搭配"] else []) @
    (if List.length parallelism_violations > 0 then ["完善对仗结构"] else [])

(** 构建检查结果 *)
let build_meter_result pattern verse_count line_length_compliance rhyme_compliance tonal_compliance parallelism_compliance overall_compliance all_violations suggestions =
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
  match Hashtbl.find_opt meter_state.pattern_cache cache_key with
  | Some result -> result
  | None -> (
      try
        let verse_count = List.length verses in
        let (line_count_ok, line_count_violations, line_length_compliance, line_length_violations,
             rhyme_compliance, rhyme_violations, tonal_compliance, tonal_violations,
             parallelism_compliance, parallelism_violations) = perform_all_checks verses pattern meter_state in
        
        let overall_compliance = calculate_overall_compliance line_count_ok line_length_compliance rhyme_compliance tonal_compliance parallelism_compliance in
        let all_violations = collect_all_violations line_count_violations line_length_violations rhyme_violations tonal_violations parallelism_violations in
        let suggestions = generate_meter_suggestions overall_compliance line_count_violations line_length_violations rhyme_violations tonal_violations parallelism_violations in
        
        let result = build_meter_result pattern verse_count line_length_compliance rhyme_compliance tonal_compliance parallelism_compliance overall_compliance all_violations suggestions in

        (* 缓存结果 *)
        Hashtbl.replace meter_state.pattern_cache cache_key result;
        result
      with exn -> raise (MeterEngineError ("格律检查失败: " ^ Printexc.to_string exn)))

(** {1 自动格律检查} *)

(** 自动识别诗体并检查格律 *)
let auto_check_meter verses meter_state =
  let recognition = recognize_poetry_form verses meter_state in

  let pattern =
    List.find_opt
      (fun p ->
        match (p.form, recognition.detected_form) with
        | LuShi n1, LuShi n2 -> n1 = n2
        | JueJu n1, JueJu n2 -> n1 = n2
        | GuTi, GuTi -> true
        | ZiYou, ZiYou -> true
        | _, _ -> false)
      meter_state.known_patterns
    |> Option.value ~default:guti_pattern
  in

  let check_result = check_meter verses pattern meter_state in
  (recognition, check_result)

(** {1 统计和工具函数} *)

(** 获取格律引擎统计信息 *)
let get_meter_engine_statistics meter_state =
  let pattern_cache_size = Hashtbl.length meter_state.pattern_cache in
  let recognition_cache_size = Hashtbl.length meter_state.recognition_cache in
  let known_patterns_count = List.length meter_state.known_patterns in

  [
    ("格律检查缓存大小", string_of_int pattern_cache_size);
    ("诗体识别缓存大小", string_of_int recognition_cache_size);
    ("已知格律模式数量", string_of_int known_patterns_count);
    ("上次检查时间", string_of_float meter_state.last_check_time);
  ]

(** 清理格律引擎缓存 *)
let clear_meter_engine_cache meter_state =
  Hashtbl.clear meter_state.pattern_cache;
  Hashtbl.clear meter_state.recognition_cache;
  { meter_state with last_check_time = Unix.time () }

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
