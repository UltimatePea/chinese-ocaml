(** 编译选项配置模块测试 - 第五阶段核心编译器测试补强 *)

open Alcotest
open Yyocamlc_lib.Compile_options

(** 测试辅助函数 *)
module Test_helpers = struct
  (** 验证编译选项结构的辅助函数 *)
  let check_option_field field_name expected actual =
    check bool field_name expected actual
    
  let check_option_string field_name expected actual =
    check string field_name expected actual
    
  let check_option_file field_name expected actual =
    check (option string) field_name expected actual
end

(** 测试默认编译选项 *)
let test_default_options () =
  let opts = default_options in
  
  (* 验证所有默认选项的值 *)
  Test_helpers.check_option_field "默认show_tokens为false" false opts.show_tokens;
  Test_helpers.check_option_field "默认show_ast为false" false opts.show_ast;
  Test_helpers.check_option_field "默认show_types为false" false opts.show_types;
  Test_helpers.check_option_field "默认check_only为false" false opts.check_only;
  Test_helpers.check_option_field "默认quiet_mode为false" false opts.quiet_mode;
  Test_helpers.check_option_field "默认recovery_mode为true" true opts.recovery_mode;
  Test_helpers.check_option_field "默认compile_to_c为false" false opts.compile_to_c;
  
  Test_helpers.check_option_string "默认log_level为normal" "normal" opts.log_level;
  Test_helpers.check_option_file "默认filename为None" None opts.filename;
  Test_helpers.check_option_file "默认c_output_file为None" None opts.c_output_file

(** 测试测试模式编译选项 *)
let test_test_options () =
  let opts = test_options in
  
  (* 验证测试模式的特定配置 *)
  Test_helpers.check_option_field "测试模式show_tokens为false" false opts.show_tokens;
  Test_helpers.check_option_field "测试模式show_ast为false" false opts.show_ast;
  Test_helpers.check_option_field "测试模式show_types为false" false opts.show_types;
  Test_helpers.check_option_field "测试模式check_only为false" false opts.check_only;
  Test_helpers.check_option_field "测试模式quiet_mode为false" false opts.quiet_mode;
  Test_helpers.check_option_field "测试模式recovery_mode为true" true opts.recovery_mode;
  Test_helpers.check_option_field "测试模式compile_to_c为false" false opts.compile_to_c;
  
  (* 测试模式的关键特征：log_level为quiet *)
  Test_helpers.check_option_string "测试模式log_level为quiet" "quiet" opts.log_level;
  Test_helpers.check_option_file "测试模式filename为None" None opts.filename;
  Test_helpers.check_option_file "测试模式c_output_file为None" None opts.c_output_file

(** 测试静默模式编译选项 *)
let test_quiet_options () =
  let opts = quiet_options in
  
  (* 验证静默模式的特定配置 *)
  Test_helpers.check_option_field "静默模式show_tokens为false" false opts.show_tokens;
  Test_helpers.check_option_field "静默模式show_ast为false" false opts.show_ast;
  Test_helpers.check_option_field "静默模式show_types为false" false opts.show_types;
  Test_helpers.check_option_field "静默模式check_only为false" false opts.check_only;
  Test_helpers.check_option_field "静默模式recovery_mode为true" true opts.recovery_mode;
  Test_helpers.check_option_field "静默模式compile_to_c为false" false opts.compile_to_c;
  
  (* 静默模式的关键特征 *)
  Test_helpers.check_option_field "静默模式quiet_mode为true" true opts.quiet_mode;
  Test_helpers.check_option_string "静默模式log_level为quiet" "quiet" opts.log_level;
  Test_helpers.check_option_file "静默模式filename为None" None opts.filename;
  Test_helpers.check_option_file "静默模式c_output_file为None" None opts.c_output_file

(** 测试编译选项类型结构完整性 *)
let test_compile_options_structure () =
  (* 创建一个自定义的编译选项以验证结构 *)
  let custom_options = {
    show_tokens = true;
    show_ast = true;
    show_types = true;
    check_only = true;
    quiet_mode = true;
    filename = Some "test.ly";
    recovery_mode = false;
    log_level = "debug";
    compile_to_c = true;
    c_output_file = Some "output.c";
  } in
  
  (* 验证所有字段都可以正确设置和访问 *)
  Test_helpers.check_option_field "自定义show_tokens设置" true custom_options.show_tokens;
  Test_helpers.check_option_field "自定义show_ast设置" true custom_options.show_ast;
  Test_helpers.check_option_field "自定义show_types设置" true custom_options.show_types;
  Test_helpers.check_option_field "自定义check_only设置" true custom_options.check_only;
  Test_helpers.check_option_field "自定义quiet_mode设置" true custom_options.quiet_mode;
  Test_helpers.check_option_field "自定义recovery_mode设置" false custom_options.recovery_mode;
  Test_helpers.check_option_field "自定义compile_to_c设置" true custom_options.compile_to_c;
  
  Test_helpers.check_option_string "自定义log_level设置" "debug" custom_options.log_level;
  Test_helpers.check_option_file "自定义filename设置" (Some "test.ly") custom_options.filename;
  Test_helpers.check_option_file "自定义c_output_file设置" (Some "output.c") custom_options.c_output_file

(** 测试编译选项的记录更新语法 *)
let test_compile_options_updates () =
  let base_options = default_options in
  
  (* 测试单个字段更新 *)
  let updated_tokens = { base_options with show_tokens = true } in
  Test_helpers.check_option_field "更新show_tokens" true updated_tokens.show_tokens;
  Test_helpers.check_option_field "其他字段保持不变" false updated_tokens.show_ast;
  
  (* 测试多个字段更新 *)
  let updated_multiple = { 
    base_options with 
    show_tokens = true; 
    show_ast = true; 
    log_level = "verbose" 
  } in
  Test_helpers.check_option_field "多字段更新-show_tokens" true updated_multiple.show_tokens;
  Test_helpers.check_option_field "多字段更新-show_ast" true updated_multiple.show_ast;
  Test_helpers.check_option_string "多字段更新-log_level" "verbose" updated_multiple.log_level;
  Test_helpers.check_option_field "未更新字段保持原值" false updated_multiple.show_types;
  
  (* 测试可选字段更新 *)
  let updated_filename = { base_options with filename = Some "program.ly" } in
  Test_helpers.check_option_file "更新filename选项" (Some "program.ly") updated_filename.filename;
  
  let updated_c_output = { base_options with c_output_file = Some "out.c" } in
  Test_helpers.check_option_file "更新c_output_file选项" (Some "out.c") updated_c_output.c_output_file

(** 测试预定义选项之间的差异 *)
let test_predefined_options_differences () =
  let default_opts = default_options in
  let test_opts = test_options in
  let quiet_opts = quiet_options in
  
  (* 验证不同预定义选项的关键差异 *)
  
  (* default vs test 的差异 *)
  check bool "default和test的quiet_mode相同" 
    (default_opts.quiet_mode = test_opts.quiet_mode) true;
  check bool "default和test的log_level不同" 
    (default_opts.log_level <> test_opts.log_level) true;
  
  (* default vs quiet 的差异 *)
  check bool "default和quiet的quiet_mode不同" 
    (default_opts.quiet_mode <> quiet_opts.quiet_mode) true;
  check bool "default和quiet的log_level不同" 
    (default_opts.log_level <> quiet_opts.log_level) true;
  
  (* test vs quiet 的差异 *)
  check bool "test和quiet的quiet_mode不同" 
    (test_opts.quiet_mode <> quiet_opts.quiet_mode) true;
  check bool "test和quiet的log_level相同" 
    (test_opts.log_level = quiet_opts.log_level) true

(** 测试选项组合的有效性 *)
let test_option_combinations () =
  (* 测试调试模式组合 *)
  let debug_options = {
    default_options with
    show_tokens = true;
    show_ast = true;
    show_types = true;
    log_level = "debug";
  } in
  
  check bool "调试模式组合有效" true (
    debug_options.show_tokens && 
    debug_options.show_ast && 
    debug_options.show_types &&
    debug_options.log_level = "debug"
  );
  
  (* 测试编译到C的组合 *)
  let c_compile_options = {
    default_options with
    compile_to_c = true;
    c_output_file = Some "program.c";
    filename = Some "program.ly";
  } in
  
  check bool "C编译模式组合有效" true (
    c_compile_options.compile_to_c &&
    c_compile_options.c_output_file = Some "program.c" &&
    c_compile_options.filename = Some "program.ly"
  );
  
  (* 测试静默检查模式组合 *)
  let quiet_check_options = {
    quiet_options with
    check_only = true;
  } in
  
  check bool "静默检查模式组合有效" true (
    quiet_check_options.quiet_mode &&
    quiet_check_options.check_only &&
    quiet_check_options.log_level = "quiet"
  )

(** 测试边界情况和异常选项 *)
let test_edge_cases () =
  (* 测试极端的日志级别组合 *)
  let verbose_quiet = {
    default_options with
    quiet_mode = true;
    log_level = "verbose";
  } in
  
  check bool "矛盾选项组合可以创建" true (
    verbose_quiet.quiet_mode && verbose_quiet.log_level = "verbose"
  );
  
  (* 测试空文件名处理 *)
  let empty_filename = { default_options with filename = Some "" } in
  Test_helpers.check_option_file "空文件名设置" (Some "") empty_filename.filename;
  
  (* 测试特殊字符的文件名 *)
  let special_filename = { default_options with filename = Some "文件.ly" } in
  Test_helpers.check_option_file "中文文件名设置" (Some "文件.ly") special_filename.filename;
  
  (* 测试长文件名 *)
  let long_filename = String.make 100 'a' ^ ".ly" in
  let long_name_opts = { default_options with filename = Some long_filename } in
  Test_helpers.check_option_file "长文件名设置" (Some long_filename) long_name_opts.filename

(** 测试选项的默认值合理性 *)
let test_default_values_rationality () =
  let opts = default_options in
  
  (* 验证默认值的合理性 *)
  check bool "默认不显示调试信息（合理）" true (
    not opts.show_tokens && 
    not opts.show_ast && 
    not opts.show_types
  );
  
  check bool "默认启用恢复模式（容错性）" true opts.recovery_mode;
  check bool "默认不启用静默模式（用户友好）" true (not opts.quiet_mode);
  check bool "默认不仅检查（完整执行）" true (not opts.check_only);
  check bool "默认不编译到C（解释执行）" true (not opts.compile_to_c);
  check string "默认日志级别适中" "normal" opts.log_level

(** 测试套件 *)
let () =
  run "编译选项配置模块测试"
    [
      ( "预定义选项测试",
        [
          test_case "测试默认编译选项" `Quick test_default_options;
          test_case "测试测试模式选项" `Quick test_test_options;
          test_case "测试静默模式选项" `Quick test_quiet_options;
        ] );
      ( "选项结构和更新测试",
        [
          test_case "测试编译选项结构" `Quick test_compile_options_structure;
          test_case "测试选项更新语法" `Quick test_compile_options_updates;
          test_case "测试预定义选项差异" `Quick test_predefined_options_differences;
        ] );
      ( "选项组合和边界测试",
        [
          test_case "测试选项组合有效性" `Quick test_option_combinations;
          test_case "测试边界情况处理" `Quick test_edge_cases;
          test_case "测试默认值合理性" `Quick test_default_values_rationality;
        ] );
    ]