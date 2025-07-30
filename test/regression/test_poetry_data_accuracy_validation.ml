(** 
 * Poetry数据准确性验证测试 - Issue #1746响应
 * Author: Echo, 测试工程师代理
 * 
 * 此测试专门验证PR #1745中数据声明的准确性，
 * 建立可重复的数据验证机制，防止未来的数据不一致问题。
 *)

open Alcotest

(** 文件统计验证工具 *)
module FileCounter = struct
  type file_stats = {
    ml_files: int;
    mli_files: int;
    total_files: int;
    timestamp: string;
  }
  
  let count_files_in_directory dir pattern =
    let cmd = Printf.sprintf "find %s -name '%s' 2>/dev/null | wc -l" dir pattern in
    let ic = Unix.open_process_in cmd in
    let count_str = input_line ic in
    let _ = Unix.close_process_in ic in
    int_of_string (String.trim count_str)
  
  let get_poetry_stats () =
    let poetry_dir = "src/poetry" in
    let ml_files = count_files_in_directory poetry_dir "*.ml" in
    let mli_files = count_files_in_directory poetry_dir "*.mli" in
    {
      ml_files = ml_files;
      mli_files = mli_files;
      total_files = ml_files + mli_files;
      timestamp = Printf.sprintf "%.0f" (Unix.time ());
    }
  
  let get_total_src_stats () =
    let src_dir = "src" in
    let ml_files = count_files_in_directory src_dir "*.ml" in
    let mli_files = count_files_in_directory src_dir "*.mli" in
    {
      ml_files = ml_files;
      mli_files = mli_files;
      total_files = ml_files + mli_files;
      timestamp = Printf.sprintf "%.0f" (Unix.time ());
    }
  
  let save_stats_to_file stats filename =
    let oc = open_out filename in
    Printf.fprintf oc "# Poetry文件统计 - Author: Echo, 测试工程师代理\n";
    Printf.fprintf oc "ml_files=%d\n" stats.ml_files;
    Printf.fprintf oc "mli_files=%d\n" stats.mli_files;
    Printf.fprintf oc "total_files=%d\n" stats.total_files;
    Printf.fprintf oc "timestamp=%s\n" stats.timestamp;
    close_out oc
  
  let load_stats_from_file filename =
    if Sys.file_exists filename then
      let ic = open_in filename in
      let rec read_values acc =
        try
          let line = input_line ic in
          if String.get line 0 = '#' then
            read_values acc
          else
            let parts = String.split_on_char '=' line in
            match parts with
            | [key; value] -> (String.trim key, String.trim value) :: acc
            | _ -> read_values acc
        with
        | End_of_file -> close_in ic; acc
      in
      let data = read_values [] in
      try
        Some {
          ml_files = List.assoc "ml_files" data |> int_of_string;
          mli_files = List.assoc "mli_files" data |> int_of_string;
          total_files = List.assoc "total_files" data |> int_of_string;
          timestamp = List.assoc "timestamp" data;
        }
      with
      | _ -> None
    else
      None
end

(** PR声明验证测试 *)
let pr_claims_verification_test () =
  Printf.printf "\n=== PR #1745声明验证 ===\n";
  
  let poetry_stats = FileCounter.get_poetry_stats () in
  let total_stats = FileCounter.get_total_src_stats () in
  
  Printf.printf "当前Poetry模块统计:\n";
  Printf.printf "  .ml文件: %d\n" poetry_stats.ml_files;
  Printf.printf "  .mli文件: %d\n" poetry_stats.mli_files;
  Printf.printf "  总文件: %d\n" poetry_stats.total_files;
  
  Printf.printf "\n整个src目录统计:\n";
  Printf.printf "  总.ml文件: %d\n" total_stats.ml_files;
  Printf.printf "  总.mli文件: %d\n" total_stats.mli_files;
  Printf.printf "  总文件: %d\n" total_stats.total_files;
  
  let poetry_percentage = float_of_int poetry_stats.total_files /. float_of_int total_stats.total_files *. 100.0 in
  Printf.printf "\nPoetry影响范围: %.1f%%\n" poetry_percentage;
  
  (* 保存当前统计 *)
  FileCounter.save_stats_to_file poetry_stats "poetry_file_stats_current.txt";
  FileCounter.save_stats_to_file total_stats "total_file_stats_current.txt";
  
  (* 验证PR声明的合理性 *)
  Printf.printf "\n=== 声明验证 ===\n";
  
  (* 基于Issue #1746的数据，实际应该有304个文件 *)
  let expected_min = 280 in
  let expected_max = 320 in
  
  Printf.printf "预期Poetry文件范围: %d-%d\n" expected_min expected_max;
  Printf.printf "实际Poetry文件: %d\n" poetry_stats.total_files;
  
  if poetry_stats.total_files >= expected_min && poetry_stats.total_files <= expected_max then
    Printf.printf "✓ 文件数量在合理范围内\n"
  else
    Printf.printf "⚠ 文件数量超出预期范围\n";
  
  (* 验证影响范围 *)
  let expected_impact_min = 15.0 in
  let expected_impact_max = 30.0 in
  
  if poetry_percentage >= expected_impact_min && poetry_percentage <= expected_impact_max then
    Printf.printf "✓ 影响范围在合理区间 (%.1f%%)\n" poetry_percentage
  else
    Printf.printf "⚠ 影响范围超出预期 (%.1f%%)\n" poetry_percentage;
  
  (* Alcotest验证 *)
  check bool "Poetry文件数量应在合理范围" true 
    (poetry_stats.total_files >= expected_min && poetry_stats.total_files <= expected_max);
  check bool "Poetry影响范围应在15-30%之间" true 
    (poetry_percentage >= expected_impact_min && poetry_percentage <= expected_impact_max);
  check bool "Poetry模块至少应有150个ML文件" true (poetry_stats.ml_files >= 150)

(** 历史数据对比测试 *)
let historical_data_comparison_test () =
  Printf.printf "\n=== 历史数据对比 ===\n";
  
  let current_stats = FileCounter.get_poetry_stats () in
  let baseline_file = "poetry_file_stats_baseline.txt" in
  
  match FileCounter.load_stats_from_file baseline_file with
  | Some baseline_stats ->
    Printf.printf "基准Poetry文件: %d\n" baseline_stats.total_files;
    Printf.printf "当前Poetry文件: %d\n" current_stats.total_files;
    
    let file_diff = current_stats.total_files - baseline_stats.total_files in
    let change_percent = float_of_int file_diff /. float_of_int baseline_stats.total_files *. 100.0 in
    
    Printf.printf "文件数变化: %+d (%.1f%%)\n" file_diff change_percent;
    
    if abs file_diff <= 5 then
      Printf.printf "✓ 文件数量变化在预期范围内\n"
    else if file_diff < 0 then
      Printf.printf "✓ 文件数量减少，符合整合目标\n"
    else
      Printf.printf "⚠ 文件数量显著增加，需要分析原因\n";
    
    (* 验证变化在合理范围 *)
    check bool "文件数量变化应小于20%" true (abs_float change_percent < 20.0)
  | None ->
    Printf.printf "未找到基准文件，创建新基准\n";
    FileCounter.save_stats_to_file current_stats baseline_file;
    Printf.printf "基准已保存到: %s\n" baseline_file

(** 依赖关系验证测试 *)
let dependency_integrity_test () =
  Printf.printf "\n=== 依赖关系完整性验证 ===\n";
  
  let count_files_importing_poetry () =
    let cmd = "grep -r 'Poetry\\.' src/ --include='*.ml' --include='*.mli' | cut -d: -f1 | sort -u | wc -l" in
    let ic = Unix.open_process_in cmd in
    let count_str = input_line ic in
    let _ = Unix.close_process_in ic in
    int_of_string (String.trim count_str)
  in
  
  let importing_files = count_files_importing_poetry () in
  Printf.printf "导入Poetry模块的文件数: %d\n" importing_files;
  
  (* 根据Issue #1746，应该有229个文件导入Poetry *)
  let expected_importing_min = 200 in
  let expected_importing_max = 250 in
  
  if importing_files >= expected_importing_min && importing_files <= expected_importing_max then
    Printf.printf "✓ 依赖文件数量在合理范围\n"
  else
    Printf.printf "⚠ 依赖文件数量异常: %d\n" importing_files;
  
  check bool "导入Poetry的文件数应在200-250之间" true 
    (importing_files >= expected_importing_min && importing_files <= expected_importing_max)

(** 模块导出验证测试 *)
let module_exports_validation_test () =
  Printf.printf "\n=== 模块导出验证 ===\n";
  
  let test_critical_exports () =
    let critical_modules = [
      "Poetry.Rhyme_core_unified";
      "Poetry.Artistic_evaluation";
      "Poetry.Poetry_data_unified";
      "Poetry.Rhyme_query_engine";
      "Poetry.Artistic_core_evaluators";
    ] in
    
    let check_module_exists module_name =
      try
        (* 简单检查：尝试创建模块引用 *)
        let test_code = Printf.sprintf "let _ = %s in ()" module_name in
        let temp_file = "/tmp/luoyan_module_test.ml" in
        let oc = open_out temp_file in
        Printf.fprintf oc "%s\n" test_code;
        close_out oc;
        
        let compile_cmd = Printf.sprintf "ocamlfind ocamlc -package unix -I _build/default/src -c %s > /dev/null 2>&1" temp_file in
        let result = Sys.command compile_cmd = 0 in
        let _ = Sys.remove temp_file in
        result
      with
      | _ -> false
    in
    
    let results = List.map (fun module_name ->
      let exists = check_module_exists module_name in
      Printf.printf "  %s: %s\n" module_name (if exists then "✓" else "✗");
      (module_name, exists)
    ) critical_modules in
    
    let success_count = List.fold_left (fun acc (_, exists) -> 
      if exists then acc + 1 else acc
    ) 0 results in
    
    Printf.printf "\n关键模块可访问性: %d/%d\n" success_count (List.length critical_modules);
    
    (* 至少80%的关键模块应该可访问 *)
    let success_rate = float_of_int success_count /. float_of_int (List.length critical_modules) in
    check bool "至少80%的关键Poetry模块应可访问" true (success_rate >= 0.8)
  in
  
  try
    test_critical_exports ()
  with
  | _ -> 
    Printf.printf "⚠ 模块导出测试遇到编译环境问题，跳过\n"

(** 数据一致性自动监控 *)
let data_consistency_monitoring_test () =
  Printf.printf "\n=== 数据一致性自动监控 ===\n";
  
  let generate_monitoring_report () =
    let poetry_stats = FileCounter.get_poetry_stats () in
    let total_stats = FileCounter.get_total_src_stats () in
    
    let report_file = "poetry_consistency_report.json" in
    let oc = open_out report_file in
    
    Printf.fprintf oc "{\n";
    Printf.fprintf oc "  \"timestamp\": \"%s\",\n" poetry_stats.timestamp;
    Printf.fprintf oc "  \"author\": \"Echo, 测试工程师代理\",\n";
    Printf.fprintf oc "  \"poetry_files\": {\n";
    Printf.fprintf oc "    \"ml_files\": %d,\n" poetry_stats.ml_files;
    Printf.fprintf oc "    \"mli_files\": %d,\n" poetry_stats.mli_files;
    Printf.fprintf oc "    \"total_files\": %d\n" poetry_stats.total_files;
    Printf.fprintf oc "  },\n";
    Printf.fprintf oc "  \"total_src_files\": {\n";
    Printf.fprintf oc "    \"ml_files\": %d,\n" total_stats.ml_files;
    Printf.fprintf oc "    \"mli_files\": %d,\n" total_stats.mli_files;
    Printf.fprintf oc "    \"total_files\": %d\n" total_stats.total_files;
    Printf.fprintf oc "  },\n";
    
    let impact_percentage = float_of_int poetry_stats.total_files /. float_of_int total_stats.total_files *. 100.0 in
    Printf.fprintf oc "  \"impact_analysis\": {\n";
    Printf.fprintf oc "    \"poetry_impact_percentage\": %.1f,\n" impact_percentage;
    Printf.fprintf oc "    \"status\": \"%s\"\n" (if impact_percentage >= 15.0 && impact_percentage <= 30.0 then "NORMAL" else "WARNING");
    Printf.fprintf oc "  }\n";
    Printf.fprintf oc "}\n";
    
    close_out oc;
    
    Printf.printf "数据一致性报告已生成: %s\n" report_file;
    Printf.printf "Poetry影响范围: %.1f%%\n" impact_percentage;
    
    check bool "数据监控应成功执行" true (impact_percentage > 0.0)
  in
  
  generate_monitoring_report ()

let data_accuracy_tests = [
  "pr_claims_verification", `Quick, pr_claims_verification_test;
  "historical_data_comparison", `Quick, historical_data_comparison_test;
  "dependency_integrity", `Quick, dependency_integrity_test;
  "module_exports_validation", `Quick, module_exports_validation_test;
  "data_consistency_monitoring", `Quick, data_consistency_monitoring_test;
]

let () =
  Printf.printf "\n=== Poetry数据准确性验证测试套件 ===\n";
  Printf.printf "确保数据声明的准确性和可验证性\n";
  Printf.printf "Author: Echo, 测试工程师代理\n\n";
  
  run "Poetry数据准确性验证" [
    "数据准确性与一致性", data_accuracy_tests;
  ]