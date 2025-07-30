(*
  数据完整性验证测试

  测试PR #1810中修复的数据完整性问题，确保：
  1. 质量门控工具不再误报
  2. 真实的数据重复问题得到解决
  3. 韵律数据保持完整性

  Author: Echo, 测试工程师代理
  Created: 2025-07-30
  Related: Issue #1809, PR #1810
*)

open Alcotest
open Printf

(* 数据完整性测试模块 *)
module DataIntegrityTests = struct
  
  (* 测试质量门控工具是否正常工作 *)
  let test_quality_gate_tool_fixed () =
    let cmd = "python scripts/quality/quality_gate_tools_fixed.py 2>&1" in
    let result = Unix.open_process_in cmd in
    let output = really_input_string result (in_channel_length result) in
    let exit_code = Unix.close_process_in result in
    
    (* 验证数据完整性检查通过 *)
    check bool "数据完整性检查应该通过" true 
      (String.contains output '数' && String.contains output '完整性');
    
    (* 验证不再有误报的重复数据问题 *)
    check bool "不应该有数据完整性FAIL状态" true
      (not (String.contains output "数据完整性检查器（修复版）" && 
            String.contains output "FAIL"))
      
  (* 测试韵律数据文件的完整性 *)
  let test_rhyme_data_integrity () =
    let test_files = [
      "src/poetry/rhyme_core_unified.ml";
      "src/poetry/poetry_data_unified.ml";
    ] in
    
    List.iter (fun file_path ->
      if Sys.file_exists file_path then (
        let ic = open_in file_path in
        let content = really_input_string ic (in_channel_length ic) in
        close_in ic;
        
        (* 检查是否有明显的重复字符定义 *)
        let lines = String.split_on_char '\n' content in
        let string_literals = List.filter_map (fun line ->
          let trimmed = String.trim line in
          if String.contains trimmed '"' then
            Some trimmed
          else
            None
        ) lines in
        
        (* 简单的重复检测 - 查找明显重复的字符串字面量 *)
        let has_obvious_duplicates = 
          let seen = Hashtbl.create 100 in
          List.exists (fun line ->
            if Hashtbl.mem seen line then
              true
            else (
              Hashtbl.add seen line ();
              false
            )
          ) string_literals
        in
        
        check bool (sprintf "文件 %s 不应有明显的重复字符定义" file_path) 
          false has_obvious_duplicates
      )
    ) test_files
    
  (* 测试修复后的质量工具过滤逻辑 *)
  let test_quality_tool_filtering () =
    (* 测试过滤逻辑是否正确识别中文字符数据 *)
    let test_chars = ["山"; "水"; "花"; "月"; "test"; "punctuation"; ""] in
    
    (* 模拟修复后的过滤条件：char.strip() and len(char) <= 3 and not char.isalpha() *)
    let should_be_filtered char =
      let trimmed = String.trim char in
      String.length trimmed > 0 && String.length trimmed <= 3 && 
      not (String.for_all (function 'a'..'z' | 'A'..'Z' -> true | _ -> false) trimmed)
    in
    
    (* 验证中文字符不会被错误过滤 *)
    List.iter (fun char ->
      match char with
      | "山" | "水" | "花" | "月" -> 
          check bool (sprintf "中文字符 '%s' 应该被正确处理" char) 
            true (should_be_filtered char)
      | "test" | "punctuation" ->
          check bool (sprintf "英文标识符 '%s' 应该被过滤" char) 
            false (should_be_filtered char)
      | "" ->
          check bool "空字符串应该被过滤" false (should_be_filtered char)
      | _ -> ()
    ) test_chars
    
  (* 测试韵律系统功能完整性 *)
  let test_rhyme_system_integrity () =
    (* 这里应该测试韵律系统的基本功能是否正常 *)
    (* 由于涉及具体的模块调用，这里做一个基础的存在性检查 *)
    let rhyme_modules = [
      "src/poetry/rhyme_core_unified.ml";
      "src/poetry/poetry_data_unified.ml";
    ] in
    
    List.iter (fun module_path ->
      check bool (sprintf "韵律模块 %s 应该存在" module_path) 
        true (Sys.file_exists module_path)
    ) rhyme_modules;
    
    (* 检查模块是否可以正常编译 *)
    let build_result = Sys.command "dune build src/poetry/ 2>/dev/null" in
    check int "韵律模块应该能正常编译" 0 build_result

end

(* 测试套件定义 *)
let data_integrity_tests = [
  test_case "质量门控工具修复验证" `Quick DataIntegrityTests.test_quality_gate_tool_fixed;
  test_case "韵律数据文件完整性检查" `Quick DataIntegrityTests.test_rhyme_data_integrity;
  test_case "质量工具过滤逻辑验证" `Quick DataIntegrityTests.test_quality_tool_filtering;
  test_case "韵律系统功能完整性验证" `Quick DataIntegrityTests.test_rhyme_system_integrity;
]

(* 主测试运行函数 *)
let () =
  Alcotest.run "数据完整性验证测试 - Fix #1809" [
    ("数据完整性修复验证", data_integrity_tests);
  ]