(** 骆言编译选项模块增强测试套件 - Fix #968 第十阶段测试覆盖率提升计划 *)

open Alcotest
open Yyocamlc_lib.Compile_options

(** 测试辅助模块 *)
module TestHelpers = struct
  (** 检查编译选项字段相等性 *)
  let check_options_equal desc expected actual =
    check bool (desc ^ " - show_tokens") (expected.show_tokens = actual.show_tokens) true;
    check bool (desc ^ " - show_ast") (expected.show_ast = actual.show_ast) true;
    check bool (desc ^ " - show_types") (expected.show_types = actual.show_types) true;
    check bool (desc ^ " - check_only") (expected.check_only = actual.check_only) true;
    check bool (desc ^ " - quiet_mode") (expected.quiet_mode = actual.quiet_mode) true;
    check bool (desc ^ " - recovery_mode") (expected.recovery_mode = actual.recovery_mode) true;
    check string (desc ^ " - log_level") expected.log_level actual.log_level;
    check bool (desc ^ " - compile_to_c") (expected.compile_to_c = actual.compile_to_c) true

  (** 创建自定义编译选项 *)
  let make_custom_options ?(show_tokens=false) ?(show_ast=false) ?(show_types=false) 
                          ?(check_only=false) ?(quiet_mode=false) ?(filename=None)
                          ?(recovery_mode=true) ?(log_level="normal") ?(compile_to_c=false) 
                          ?(c_output_file=None) () =
    {
      show_tokens;
      show_ast;
      show_types;
      check_only;
      quiet_mode;
      filename;
      recovery_mode;
      log_level;
      compile_to_c;
      c_output_file;
    }
end

(** 默认选项测试 *)
module DefaultOptionsTests = struct
  open TestHelpers

  (** 测试默认选项值 *)
  let test_default_options_values () =
    let options = default_options in
    
    check bool "默认show_tokens为false" false options.show_tokens;
    check bool "默认show_ast为false" false options.show_ast;
    check bool "默认show_types为false" false options.show_types;
    check bool "默认check_only为false" false options.check_only;
    check bool "默认quiet_mode为false" false options.quiet_mode;
    check (option string) "默认filename为None" None options.filename;
    check bool "默认recovery_mode为true" true options.recovery_mode;
    check string "默认log_level为normal" "normal" options.log_level;
    check bool "默认compile_to_c为false" false options.compile_to_c;
    check (option string) "默认c_output_file为None" None options.c_output_file

  (** 测试默认选项一致性 *)
  let test_default_options_consistency () =
    let options1 = default_options in
    let options2 = default_options in
    
    check_options_equal "两次获取的默认选项应该相同" options1 options2

  (** 测试默认选项不可变性 *)
  let test_default_options_immutability () =
    let original = default_options in
    let modified = { original with show_tokens = true } in
    
    check bool "修改后原默认选项不变" false original.show_tokens;
    check bool "修改后新选项已变" true modified.show_tokens
end

(** 选项构造测试 *)
module OptionsConstructionTests = struct
  open TestHelpers

  (** 测试自定义选项构造 *)
  let test_custom_options_construction () =
    let custom_options = make_custom_options 
      ~show_tokens:true 
      ~show_ast:true 
      ~log_level:"debug" 
      ~compile_to_c:true 
      () in
    
    check bool "自定义show_tokens设置正确" true custom_options.show_tokens;
    check bool "自定义show_ast设置正确" true custom_options.show_ast;
    check string "自定义log_level设置正确" "debug" custom_options.log_level;
    check bool "自定义compile_to_c设置正确" true custom_options.compile_to_c

  (** 测试部分选项修改 *)
  let test_partial_options_modification () =
    let base_options = default_options in
    let modified_options = { base_options with 
                            show_tokens = true; 
                            quiet_mode = true;
                            log_level = "verbose" } in
    
    check bool "部分修改 - show_tokens" true modified_options.show_tokens;
    check bool "部分修改 - quiet_mode" true modified_options.quiet_mode;
    check string "部分修改 - log_level" "verbose" modified_options.log_level;
    check bool "部分修改 - 其他选项不变" false modified_options.show_ast

  (** 测试文件名选项 *)
  let test_filename_options () =
    let with_filename = { default_options with filename = Some "test.ly" } in
    let without_filename = { default_options with filename = None } in
    
    check (option string) "设置文件名选项" (Some "test.ly") with_filename.filename;
    check (option string) "无文件名选项" None without_filename.filename

  (** 测试C输出文件选项 *)
  let test_c_output_file_options () =
    let with_c_output = { default_options with 
                         compile_to_c = true; 
                         c_output_file = Some "output.c" } in
    
    check bool "C编译选项设置" true with_c_output.compile_to_c;
    check (option string) "C输出文件设置" (Some "output.c") with_c_output.c_output_file
end

(** 选项组合测试 *)
module OptionsCombinationTests = struct

  (** 测试调试模式组合 *)
  let test_debug_mode_combination () =
    let debug_options = { default_options with 
                         show_tokens = true;
                         show_ast = true;
                         show_types = true;
                         log_level = "debug" } in
    
    check bool "调试模式 - 显示tokens" true debug_options.show_tokens;
    check bool "调试模式 - 显示AST" true debug_options.show_ast;
    check bool "调试模式 - 显示类型" true debug_options.show_types;
    check string "调试模式 - 日志级别" "debug" debug_options.log_level

  (** 测试静默模式组合 *)
  let test_quiet_mode_combination () =
    let quiet_options = { default_options with 
                         quiet_mode = true;
                         log_level = "error" } in
    
    check bool "静默模式 - quiet_mode" true quiet_options.quiet_mode;
    check string "静默模式 - 日志级别" "error" quiet_options.log_level

  (** 测试仅检查模式组合 *)
  let test_check_only_combination () =
    let check_only_options = { default_options with 
                              check_only = true;
                              compile_to_c = false } in
    
    check bool "仅检查模式 - check_only" true check_only_options.check_only;
    check bool "仅检查模式 - 不编译到C" false check_only_options.compile_to_c

  (** 测试C编译模式组合 *)
  let test_c_compilation_combination () =
    let c_compile_options = { default_options with 
                             compile_to_c = true;
                             c_output_file = Some "luoyan_output.c";
                             check_only = false } in
    
    check bool "C编译模式 - compile_to_c" true c_compile_options.compile_to_c;
    check (option string) "C编译模式 - 输出文件" (Some "luoyan_output.c") c_compile_options.c_output_file;
    check bool "C编译模式 - 非仅检查" false c_compile_options.check_only
end

(** 边界条件测试 *)
module EdgeCaseTests = struct

  (** 测试极端日志级别 *)
  let test_extreme_log_levels () =
    let extreme_levels = [""; "verbose"; "debug"; "info"; "warn"; "error"; "off"] in
    
    List.iter (fun level ->
      let options = { default_options with log_level = level } in
      check string ("日志级别设置: " ^ level) level options.log_level
    ) extreme_levels

  (** 测试特殊文件名 *)
  let test_special_filenames () =
    let special_names = [
      "测试文件.ly";
      "file with spaces.ly";
      "";
      "very_long_filename_with_many_characters_that_might_cause_issues.ly";
      "unicode_文件名_αβγ.ly";
    ] in
    
    List.iter (fun name ->
      let options = { default_options with filename = Some name } in
      check (option string) ("特殊文件名: " ^ name) (Some name) options.filename
    ) special_names

  (** 测试矛盾选项组合 *)
  let test_contradictory_options () =
    (* 这些组合在逻辑上可能矛盾，但应该能正常构造 *)
    let contradictory = { default_options with 
                         quiet_mode = true;
                         show_tokens = true;  (* 静默但显示tokens *)
                         check_only = true;
                         compile_to_c = true; (* 仅检查但编译到C *)
                        } in
    
    check bool "矛盾选项 - quiet_mode" true contradictory.quiet_mode;
    check bool "矛盾选项 - show_tokens" true contradictory.show_tokens;
    check bool "矛盾选项 - check_only" true contradictory.check_only;
    check bool "矛盾选项 - compile_to_c" true contradictory.compile_to_c
end

(** 性能测试 *)
module PerformanceTests = struct

  (** 测试大量选项创建性能 *)
  let test_bulk_options_creation_performance () =
    let start_time = Sys.time () in
    let options_list = List.init 1000 (fun i ->
      { default_options with 
        show_tokens = (i mod 2 = 0);
        log_level = if i mod 3 = 0 then "debug" else "normal";
        filename = Some ("file" ^ string_of_int i ^ ".ly");
      }
    ) in
    let end_time = Sys.time () in
    let duration = end_time -. start_time in
    
    check int "创建1000个选项数量正确" 1000 (List.length options_list);
    check bool "创建1000个选项在合理时间内完成" true (duration < 1.0)

  (** 测试选项修改性能 *)
  let test_options_modification_performance () =
    let base_options = default_options in
    
    let start_time = Sys.time () in
    let modified_options = List.init 1000 (fun i ->
      { base_options with 
        show_tokens = (i mod 2 = 0);
        show_ast = (i mod 3 = 0);
        show_types = (i mod 5 = 0);
      }
    ) in
    let end_time = Sys.time () in
    let duration = end_time -. start_time in
    
    check int "修改1000次选项数量正确" 1000 (List.length modified_options);
    check bool "修改1000次选项在合理时间内完成" true (duration < 1.0)
end

(** 主测试套件 *)
let test_suite = [
  ("默认选项测试", [
    test_case "默认选项值" `Quick DefaultOptionsTests.test_default_options_values;
    test_case "默认选项一致性" `Quick DefaultOptionsTests.test_default_options_consistency;
    test_case "默认选项不可变性" `Quick DefaultOptionsTests.test_default_options_immutability;
  ]);
  
  ("选项构造测试", [
    test_case "自定义选项构造" `Quick OptionsConstructionTests.test_custom_options_construction;
    test_case "部分选项修改" `Quick OptionsConstructionTests.test_partial_options_modification;
    test_case "文件名选项" `Quick OptionsConstructionTests.test_filename_options;
    test_case "C输出文件选项" `Quick OptionsConstructionTests.test_c_output_file_options;
  ]);
  
  ("选项组合测试", [
    test_case "调试模式组合" `Quick OptionsCombinationTests.test_debug_mode_combination;
    test_case "静默模式组合" `Quick OptionsCombinationTests.test_quiet_mode_combination;
    test_case "仅检查模式组合" `Quick OptionsCombinationTests.test_check_only_combination;
    test_case "C编译模式组合" `Quick OptionsCombinationTests.test_c_compilation_combination;
  ]);
  
  ("边界条件测试", [
    test_case "极端日志级别" `Quick EdgeCaseTests.test_extreme_log_levels;
    test_case "特殊文件名" `Quick EdgeCaseTests.test_special_filenames;
    test_case "矛盾选项组合" `Quick EdgeCaseTests.test_contradictory_options;
  ]);
  
  ("性能测试", [
    test_case "大量选项创建性能" `Slow PerformanceTests.test_bulk_options_creation_performance;
    test_case "选项修改性能" `Slow PerformanceTests.test_options_modification_performance;
  ]);
]

(** 运行测试 *)
let () = run "骆言编译选项模块增强测试" test_suite