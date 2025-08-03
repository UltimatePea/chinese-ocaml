(** 韵律数据统一验证模块
    
    提供全面的韵律数据验证和一致性检查功能。
    确保整合后的韵律数据符合《平水韵》标准，无重复、错误或不一致。
    
    Author: Whisky, PR Worker
    Issue: #1999 - Poetry韵律模块统一整合实施
    
    @since 2025-08-03 *)

open Rhyme_core_unified
open Rhyme_data_consolidated

(** {1 验证结果类型定义} *)

type validation_severity = 
  | Error     (** 严重错误，必须修复 *)
  | Warning   (** 警告，建议修复 *)
  | Info      (** 信息性提示 *)

type validation_issue = {
  severity: validation_severity;
  category: string;
  message: string;
  affected_items: string list;
  suggestion: string option;
}

type validation_report = {
  is_valid: bool;
  total_issues: int;
  error_count: int;
  warning_count: int;
  info_count: int;
  issues: validation_issue list;
  validation_time: float;
}

(** {1 核心验证函数} *)

(** 验证字符重复 *)
let validate_character_uniqueness () =
  let issues = ref [] in
  let char_counts = Hashtbl.create 500 in
  let all_chars = get_all_rhyme_data () in
  
  (* 统计字符出现次数 *)
  List.iter (fun char_info ->
    let char = char_info.character in
    let current_count = try Hashtbl.find char_counts char with Not_found -> 0 in
    Hashtbl.replace char_counts char (current_count + 1)
  ) all_chars;
  
  (* 检查重复 *)
  Hashtbl.iter (fun char count ->
    if count > 1 then
      let issue = {
        severity = Error;
        category = "数据重复";
        message = Printf.sprintf "字符 '%s' 重复出现 %d 次" char count;
        affected_items = [char];
        suggestion = Some "检查数据源，确保每个字符只出现一次";
      } in
      issues := issue :: !issues
  ) char_counts;
  
  !issues

(** 验证使用频率合理性 *)
let validate_usage_frequency () =
  let issues = ref [] in
  let all_chars = get_all_rhyme_data () in
  
  List.iter (fun char_info ->
    let freq = char_info.usage_frequency in
    if freq < 0.0 || freq > 1.0 then
      let issue = {
        severity = Error;
        category = "数据范围";
        message = Printf.sprintf "字符 '%s' 使用频率超出范围: %f" char_info.character freq;
        affected_items = [char_info.character];
        suggestion = Some "使用频率应在 0.0 到 1.0 之间";
      } in
      issues := issue :: !issues
    else if freq < 0.1 then
      let issue = {
        severity = Warning;
        category = "数据质量";
        message = Printf.sprintf "字符 '%s' 使用频率过低: %f" char_info.character freq;
        affected_items = [char_info.character];
        suggestion = Some "检查该字符是否为生僻字或数据错误";
      } in
      issues := issue :: !issues
  ) all_chars;
  
  !issues

(** 验证韵组完整性 *)
let validate_group_completeness () =
  let issues = ref [] in
  let groups = get_all_groups () in
  
  List.iter (fun group_data ->
    let char_count = group_data.character_count in
    if char_count = 0 then
      let issue = {
        severity = Error;
        category = "韵组完整性";
        message = Printf.sprintf "韵组 '%s' 为空" group_data.group_description;
        affected_items = [];
        suggestion = Some "为该韵组添加相应的字符数据";
      } in
      issues := issue :: !issues
    else if char_count < 3 then
      let issue = {
        severity = Warning;
        category = "韵组完整性";
        message = Printf.sprintf "韵组 '%s' 字符数量过少: %d" group_data.group_description char_count;
        affected_items = List.map (fun ci -> ci.character) group_data.entries;
        suggestion = Some "检查是否缺少该韵组的常用字符";
      } in
      issues := issue :: !issues
  ) groups;
  
  !issues

(** 验证声调分布合理性 *)
let validate_tone_distribution () =
  let issues = ref [] in
  let all_chars = get_all_rhyme_data () in
  let total_count = List.length all_chars in
  
  let ping_count = List.length (get_characters_by_category PingSheng) in
  let ze_count = List.length (get_characters_by_category ZeSheng) in
  let ru_count = List.length (get_characters_by_category RuSheng) in
  
  let ping_ratio = float_of_int ping_count /. float_of_int total_count in
  let _ze_ratio = float_of_int ze_count /. float_of_int total_count in
  let ru_ratio = float_of_int ru_count /. float_of_int total_count in
  
  (* 根据平水韵标准，平声和仄声应该相对平衡 *)
  if ping_ratio < 0.3 then (
    let issue = {
      severity = Warning;
      category = "声调分布";
      message = Printf.sprintf "平声字符比例过低: %.1f%%" (ping_ratio *. 100.0);
      affected_items = [];
      suggestion = Some "检查是否缺少平声字符数据";
    } in
    issues := issue :: !issues
  );
  
  if ping_ratio > 0.7 then (
    let issue = {
      severity = Warning;
      category = "声调分布";
      message = Printf.sprintf "平声字符比例过高: %.1f%%" (ping_ratio *. 100.0);
      affected_items = [];
      suggestion = Some "检查仄声字符数据是否完整";
    } in
    issues := issue :: !issues
  );
  
  if ru_ratio > 0.3 then (
    let issue = {
      severity = Info;
      category = "声调分布";
      message = Printf.sprintf "入声字符比例较高: %.1f%%" (ru_ratio *. 100.0);
      affected_items = [];
      suggestion = Some "入声在现代汉语中较少，比例偏高可能正常";
    } in
    issues := issue :: !issues
  );
  
  !issues

(** 验证异体字关系 *)
let validate_variant_relationships () =
  let issues = ref [] in
  let all_chars = get_all_rhyme_data () in
  let all_char_set = Hashtbl.create 500 in
  
  (* 建立字符集合 *)
  List.iter (fun char_info ->
    Hashtbl.add all_char_set char_info.character char_info
  ) all_chars;
  
  (* 检查异体字是否存在于主数据中 *)
  List.iter (fun char_info ->
    List.iter (fun variant ->
      if Hashtbl.mem all_char_set variant then
        let issue = {
          severity = Warning;
          category = "异体字关系";
          message = Printf.sprintf "异体字 '%s' 也存在于主数据中" variant;
          affected_items = [char_info.character; variant];
          suggestion = Some "检查异体字关系是否正确，避免数据冗余";
        } in
        issues := issue :: !issues
    ) char_info.variants
  ) all_chars;
  
  !issues

(** 验证常用字标记合理性 *)
let validate_common_character_marks () =
  let issues = ref [] in
  let all_chars = get_all_rhyme_data () in
  
  let common_chars = List.filter (fun ci -> ci.is_common) all_chars in
  let _uncommon_chars = List.filter (fun ci -> not ci.is_common) all_chars in
  
  let common_count = List.length common_chars in
  let total_count = List.length all_chars in
  let common_ratio = float_of_int common_count /. float_of_int total_count in
  
  (* 检查常用字比例是否合理 *)
  if common_ratio < 0.4 then (
    let issue = {
      severity = Warning;
      category = "常用字标记";
      message = Printf.sprintf "常用字比例偏低: %.1f%%" (common_ratio *. 100.0);
      affected_items = [];
      suggestion = Some "检查常用字标记是否过于严格";
    } in
    issues := issue :: !issues
  );
  
  if common_ratio > 0.8 then (
    let issue = {
      severity = Warning;
      category = "常用字标记";
      message = Printf.sprintf "常用字比例偏高: %.1f%%" (common_ratio *. 100.0);
      affected_items = [];
      suggestion = Some "检查常用字标记是否过于宽松";
    } in
    issues := issue :: !issues
  );
  
  (* 检查高频字符是否标记为常用 *)
  List.iter (fun char_info ->
    if char_info.usage_frequency > 0.8 && not char_info.is_common then (
      let issue = {
        severity = Info;
        category = "常用字标记";
        message = Printf.sprintf "高频字符 '%s' (%.2f) 未标记为常用" char_info.character char_info.usage_frequency;
        affected_items = [char_info.character];
        suggestion = Some "考虑将高频字符标记为常用";
      } in
      issues := issue :: !issues
    )
  ) all_chars;
  
  !issues

(** {1 综合验证功能} *)

(** 运行所有验证检查 *)
let run_full_validation () =
  let start_time = Unix.gettimeofday () in
  Printf.printf "开始韵律数据全面验证...\n";
  
  let all_issues = ref [] in
  
  (* 运行各项验证 *)
  let uniqueness_issues = validate_character_uniqueness () in
  let frequency_issues = validate_usage_frequency () in
  let completeness_issues = validate_group_completeness () in
  let distribution_issues = validate_tone_distribution () in
  let variant_issues = validate_variant_relationships () in
  let common_issues = validate_common_character_marks () in
  
  all_issues := uniqueness_issues @ frequency_issues @ completeness_issues @
                distribution_issues @ variant_issues @ common_issues;
  
  let total_issues = List.length !all_issues in
  let error_count = List.length (List.filter (fun i -> i.severity = Error) !all_issues) in
  let warning_count = List.length (List.filter (fun i -> i.severity = Warning) !all_issues) in
  let info_count = List.length (List.filter (fun i -> i.severity = Info) !all_issues) in
  
  let is_valid = error_count = 0 in
  let validation_time = Unix.gettimeofday () -. start_time in
  
  let report = {
    is_valid;
    total_issues;
    error_count;
    warning_count;
    info_count;
    issues = !all_issues;
    validation_time;
  } in
  
  Printf.printf "验证完成 (耗时: %.3f秒)\n" validation_time;
  report

(** 打印验证报告 *)
let print_validation_report report =
  Printf.printf "\n=== 韵律数据验证报告 ===\n";
  Printf.printf "验证状态: %s\n" (if report.is_valid then "✓ 通过" else "✗ 失败");
  Printf.printf "总问题数: %d\n" report.total_issues;
  Printf.printf "  错误: %d\n" report.error_count;
  Printf.printf "  警告: %d\n" report.warning_count;
  Printf.printf "  信息: %d\n" report.info_count;
  Printf.printf "验证耗时: %.3f秒\n" report.validation_time;
  
  if report.total_issues > 0 then (
    Printf.printf "\n详细问题列表:\n";
    List.iteri (fun i issue ->
      let severity_str = match issue.severity with
        | Error -> "❌ 错误"
        | Warning -> "⚠️  警告"
        | Info -> "ℹ️  信息"
      in
      Printf.printf "%d. %s [%s] %s\n" (i+1) severity_str issue.category issue.message;
      if List.length issue.affected_items > 0 then
        Printf.printf "   影响项目: %s\n" (String.concat ", " issue.affected_items);
      match issue.suggestion with
      | Some suggestion -> Printf.printf "   建议: %s\n" suggestion
      | None -> ()
    ) report.issues
  );
  
  Printf.printf "====================\n"

(** {1 快速验证接口} *)

(** 快速数据完整性检查 *)
let quick_integrity_check () =
  let uniqueness_issues = validate_character_uniqueness () in
  let frequency_issues = validate_usage_frequency () in
  let error_issues = List.filter (fun i -> i.severity = Error) (uniqueness_issues @ frequency_issues) in
  List.length error_issues = 0

(** 验证单个字符数据 *)
let validate_single_character char =
  match find_character_info char with
  | Some char_info ->
      let issues = ref [] in
      
      (* 检查使用频率 *)
      if char_info.usage_frequency < 0.0 || char_info.usage_frequency > 1.0 then (
        let issue = {
          severity = Error;
          category = "数据范围";
          message = "使用频率超出范围";
          affected_items = [char];
          suggestion = Some "使用频率应在 0.0 到 1.0 之间";
        } in
        issues := issue :: !issues
      );
      
      (List.length !issues = 0, !issues)
  | None ->
      let issue = {
        severity = Error;
        category = "数据缺失";
        message = "字符不存在于韵律数据中";
        affected_items = [char];
        suggestion = Some "检查字符是否应该被包含在韵律数据中";
      } in
      (false, [issue])

(** {1 性能监控} *)

(** 验证性能基准测试 *)
let benchmark_validation_performance iterations =
  let start_time = Unix.gettimeofday () in
  
  for _i = 1 to iterations do
    ignore (quick_integrity_check ())
  done;
  
  let total_time = Unix.gettimeofday () -. start_time in
  let avg_time = total_time /. float_of_int iterations in
  
  Printf.printf "验证性能基准测试:\n";
  Printf.printf "迭代次数: %d\n" iterations;
  Printf.printf "总耗时: %.3f秒\n" total_time;
  Printf.printf "平均耗时: %.6f秒/次\n" avg_time;
  
  avg_time

(** {1 公开接口} *)

(** 导出主要验证函数 *)
let validate_data_integrity () =
  let report = run_full_validation () in
  (report.is_valid, List.map (fun issue -> issue.message) report.issues)

let validate_character_consistency char =
  let (is_valid, _) = validate_single_character char in
  is_valid

let run_validation () =
  let report = run_full_validation () in
  print_validation_report report;
  report.is_valid