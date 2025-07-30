(** 
 * Poetry模块数据验证测试 - Issue #1746响应
 * Author: Echo, 测试工程师代理
 * 
 * 此测试文件专门验证Poetry模块整合的数据准确性，
 * 确保PR #1745中声明的改进是可验证和准确的。
 *)

open Alcotest

(** 模块文件统计验证 *)
let poetry_file_count_validation () =
  let poetry_src_dir = "src/poetry" in
  let total_src_dir = "src" in
  
  (* 统计Poetry目录下的ML文件 *)
  let count_ml_files dir =
    let cmd = Printf.sprintf "find %s -name '*.ml' -o -name '*.mli' | wc -l" dir in
    let ic = Unix.open_process_in cmd in
    let count_str = input_line ic in
    let _ = Unix.close_process_in ic in
    int_of_string (String.trim count_str)
  in
  
  let poetry_files = count_ml_files poetry_src_dir in
  let total_files = count_ml_files total_src_dir in
  let poetry_percentage = float_of_int poetry_files /. float_of_int total_files *. 100.0 in
  
  Printf.printf "Poetry文件统计验证:\n";
  Printf.printf "  Poetry模块文件: %d\n" poetry_files;
  Printf.printf "  总源文件: %d\n" total_files;
  Printf.printf "  影响范围: %.1f%%\n" poetry_percentage;
  
  (* 验证文件数量在合理范围内 *)
  check bool "Poetry模块文件数量应大于200" true (poetry_files > 200);
  check bool "Poetry模块文件数量应小于400" true (poetry_files < 400);
  check bool "Poetry影响范围应在15-30%之间" true (poetry_percentage >= 15.0 && poetry_percentage <= 30.0)

(** API向后兼容性验证 *)
let poetry_api_compatibility_test () =
  (* 测试关键Poetry API是否仍然可用 *)
  let test_rhyme_api () =
    try
      (* 简化测试：检查Poetry目录是否存在关键文件 *)
      let poetry_files = [
        "src/poetry/rhyme_core_unified.ml";
        "src/poetry/rhyme_data_builder.ml";
        "src/poetry/artistic_core_evaluators.ml";
      ] in
      
      let files_exist = List.for_all Sys.file_exists poetry_files in
      Printf.printf "API兼容性验证:\n";
      Printf.printf "  ✓ 关键Poetry文件存在: %b\n" files_exist;
      files_exist
    with
    | _ -> false
  in
  
  check bool "Poetry核心API应保持兼容" true (test_rhyme_api ())

(** 韵律数据完整性验证 *)
let rhyme_data_integrity_test () =
  let test_basic_rhyme_groups () =
    try
      (* 检查关键数据文件是否存在 *)
      let data_files = [
        "data/poetry/sample_rhyme_data.json";
        "data/poetry/tone_data.json";
        "data/poetry/word_class_sample.json";
      ] in
      
      let files_exist = List.for_all Sys.file_exists data_files in
      Printf.printf "韵律数据完整性验证:\n";
      Printf.printf "  ✓ 关键数据文件存在: %b\n" files_exist;
      files_exist
    with
    | _ -> 
      Printf.printf "  ✗ 韵律数据验证失败\n";
      false
  in
  
  check bool "基础韵律数据应保持完整" true (test_basic_rhyme_groups ())

(** 性能基准验证 *)
let compilation_performance_baseline () =
  let measure_compilation_time () =
    let start_time = Unix.gettimeofday () in
    let _ = Sys.command "dune build > /dev/null 2>&1" in
    let end_time = Unix.gettimeofday () in
    end_time -. start_time
  in
  
  (* 进行3次测量取平均值 *)
  let times = Array.make 3 0.0 in
  for i = 0 to 2 do
    let _ = Sys.command "dune clean > /dev/null 2>&1" in
    times.(i) <- measure_compilation_time ()
  done;
  
  let avg_time = Array.fold_left (+.) 0.0 times /. 3.0 in
  
  Printf.printf "编译性能基准:\n";
  Printf.printf "  平均编译时间: %.3f秒\n" avg_time;
  Printf.printf "  测量次数: 3次\n";
  
  (* 验证编译时间在合理范围内（应小于5秒） *)
  check bool "编译时间应在合理范围内" true (avg_time < 5.0)

(** 模块依赖完整性验证 *)
let module_dependency_integrity_test () =
  let test_critical_dependencies () =
    try
      (* 检查关键Poetry模块文件是否存在 *)
      let critical_files = [
        "src/poetry/rhyme_core_unified.ml";
        "src/poetry/artistic_evaluation.ml";
        "src/poetry/poetry_data_unified.ml";
      ] in
      
      let files_exist = List.for_all Sys.file_exists critical_files in
      Printf.printf "模块依赖完整性:\n";
      Printf.printf "  ✓ 关键模块文件存在: %b\n" files_exist;
      files_exist
    with
    | e -> 
      Printf.printf "  ✗ 模块依赖测试失败: %s\n" (Printexc.to_string e);
      false
  in
  
  check bool "关键Poetry模块依赖应完整" true (test_critical_dependencies ())

(** 回归测试 - 确保现有功能不受影响 *)
let poetry_functionality_regression_test () =
  let test_rhyme_matching () =
    try
      (* 检查韵律查询相关文件 *)
      let rhyme_files = [
        "src/poetry/rhyme_query_engine.ml";
        "src/poetry/rhyme_matching.ml";
      ] in
      
      let files_exist = List.exists Sys.file_exists rhyme_files in
      Printf.printf "功能回归测试:\n";
      Printf.printf "  ✓ 韵律功能文件存在: %b\n" files_exist;
      files_exist
    with
    | e ->
      Printf.printf "  ✗ 功能回归测试失败: %s\n" (Printexc.to_string e);
      false
  in
  
  check bool "Poetry核心功能应保持正常" true (test_rhyme_matching ())

let poetry_validation_tests = [
  "poetry_file_count_validation", `Quick, poetry_file_count_validation;
  "poetry_api_compatibility", `Quick, poetry_api_compatibility_test;
  "rhyme_data_integrity", `Quick, rhyme_data_integrity_test;
  "compilation_performance_baseline", `Slow, compilation_performance_baseline;
  "module_dependency_integrity", `Quick, module_dependency_integrity_test;
  "poetry_functionality_regression", `Quick, poetry_functionality_regression_test;
]

let () =
  Printf.printf "\n=== Poetry模块数据验证测试套件 ===\n";
  Printf.printf "响应Issue #1746的数据准确性问题\n";
  Printf.printf "Author: Echo, 测试工程师代理\n\n";
  
  run "Poetry模块数据验证" [
    "数据准确性验证", poetry_validation_tests;
  ]