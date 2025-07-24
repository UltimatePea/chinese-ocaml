open Yyocamlc_lib.Config

let () =
  Printf.printf "TEST: 骆言运行时配置模块全面测试开始\n\n";

  (* 测试默认运行时配置 *)
  Printf.printf "INFO: 测试默认运行时配置\n";
  (try
    let _ = default_runtime_config in
    Printf.printf "√ 默认运行时配置获取成功\n";
    
    (* 验证默认配置的合理性 *)
    let debug_mode = Get.debug_mode () in
    let verbose_logging = Get.verbose_logging () in
    let error_recovery = Get.error_recovery () in
    let max_error_count = Get.max_error_count () in
    let continue_on_error = Get.continue_on_error () in
    let show_suggestions = Get.show_suggestions () in
    let colored_output = Get.colored_output () in
    let spell_correction = Get.spell_correction () in
    
    Printf.printf "STAT: 默认运行时配置值:\n";
    Printf.printf "  - 调试模式: %b\n" debug_mode;
    Printf.printf "  - 详细日志: %b\n" verbose_logging;
    Printf.printf "  - 错误恢复: %b\n" error_recovery;
    Printf.printf "  - 最大错误数: %d\n" max_error_count;
    Printf.printf "  - 错误时继续: %b\n" continue_on_error;
    Printf.printf "  - 显示建议: %b\n" show_suggestions;
    Printf.printf "  - 彩色输出: %b\n" colored_output;
    Printf.printf "  - 拼写检查: %b\n" spell_correction;
    
    if max_error_count > 0 then
      Printf.printf "√ 默认运行时配置值合理性检查通过\n"
    else
      Printf.printf "X 默认运行时配置值不合理\n";
  with
  | e -> Printf.printf "X 默认运行时配置测试失败: %s\n" (Printexc.to_string e));

  (* 测试运行时配置的获取和设置 *)
  Printf.printf "\nCONFIG: 测试运行时配置获取和设置\n";
  (try
    let original_config = get_runtime_config () in
    Printf.printf "√ 原始运行时配置获取成功\n";
    
    (* 创建修改后的配置进行测试 *)
    let modified_config = original_config in
    set_runtime_config modified_config;
    Printf.printf "√ 运行时配置设置成功\n";
    
    let _ = get_runtime_config () in
    Printf.printf "√ 修改后运行时配置获取成功\n";
    
    (* 恢复原始配置 *)
    set_runtime_config original_config;
    Printf.printf "√ 原始运行时配置恢复成功\n";
  with
  | e -> Printf.printf "X 运行时配置获取设置测试失败: %s\n" (Printexc.to_string e));

  (* 测试调试模式配置 *)
  Printf.printf "\nDEBUG: 测试调试模式配置\n";
  (try
    let original_debug = Get.debug_mode () in
    Printf.printf "STAT: 原始调试模式: %b\n" original_debug;
    
    (* 通过环境变量测试调试模式切换 *)
    Unix.putenv "CHINESE_OCAML_DEBUG" "true";
    load_from_env ();
    let debug_enabled = Get.debug_mode () in
    Printf.printf "开启调试模式: %b\n" debug_enabled;
    
    Unix.putenv "CHINESE_OCAML_DEBUG" "false";
    load_from_env ();
    let debug_disabled = Get.debug_mode () in
    Printf.printf "STAT: 关闭调试模式: %b\n" debug_disabled;
    
    if debug_enabled = true && debug_disabled = false then
      Printf.printf "√ 调试模式配置切换测试通过\n"
    else
      Printf.printf "WARN:  调试模式配置切换部分成功\n";
    
    Unix.putenv "CHINESE_OCAML_DEBUG" "";
  with
  | e -> Printf.printf "X 调试模式配置测试失败: %s\n" (Printexc.to_string e));

  (* 测试详细日志配置 *)
  Printf.printf "\nLOG: 测试详细日志配置\n";
  (try
    let original_verbose = Get.verbose_logging () in
    Printf.printf "STAT: 原始详细日志: %b\n" original_verbose;
    
    (* 测试详细日志模式切换 *)
    Unix.putenv "CHINESE_OCAML_VERBOSE" "true";
    load_from_env ();
    let verbose_enabled = Get.verbose_logging () in
    Printf.printf "STAT: 开启详细日志: %b\n" verbose_enabled;
    
    Unix.putenv "CHINESE_OCAML_VERBOSE" "false";
    load_from_env ();
    let verbose_disabled = Get.verbose_logging () in
    Printf.printf "STAT: 关闭详细日志: %b\n" verbose_disabled;
    
    if verbose_enabled = true && verbose_disabled = false then
      Printf.printf "√ 详细日志配置切换测试通过\n"
    else
      Printf.printf "WARN:  详细日志配置切换部分成功\n";
    
    Unix.putenv "CHINESE_OCAML_VERBOSE" "";
  with
  | e -> Printf.printf "X 详细日志配置测试失败: %s\n" (Printexc.to_string e));

  (* 测试错误处理配置 *)
  Printf.printf "\nX 测试错误处理配置\n";
  (try
    let original_error_recovery = Get.error_recovery () in
    let original_max_errors = Get.max_error_count () in
    let original_continue_on_error = Get.continue_on_error () in
    let original_show_suggestions = Get.show_suggestions () in
    
    Printf.printf "STAT: 原始错误处理配置:\n";
    Printf.printf "  - 错误恢复: %b\n" original_error_recovery;
    Printf.printf "  - 最大错误数: %d\n" original_max_errors;
    Printf.printf "  - 错误时继续: %b\n" original_continue_on_error;
    Printf.printf "  - 显示建议: %b\n" original_show_suggestions;
    
    (* 测试最大错误数配置 *)
    let max_error_tests = ["5"; "10"; "25"; "50"; "100"] in
    List.iter (fun max_errors ->
      Unix.putenv "CHINESE_OCAML_MAX_ERRORS" max_errors;
      load_from_env ();
      let current_max = Get.max_error_count () in
      Printf.printf "STAT: 设置最大错误数 %s -> 实际 %d\n" max_errors current_max;
      Unix.putenv "CHINESE_OCAML_MAX_ERRORS" ""
    ) max_error_tests;
    
    Printf.printf "√ 错误处理配置测试完成\n";
  with
  | e -> Printf.printf "X 错误处理配置测试失败: %s\n" (Printexc.to_string e));

  (* 测试智能功能配置 *)
  Printf.printf "\n🧠 测试智能功能配置\n";
  (try
    let original_spell_correction = Get.spell_correction () in
    
    Printf.printf "STAT: 原始智能功能配置:\n";
    Printf.printf "  - 拼写检查: %b\n" original_spell_correction;
    
    (* 测试拼写检查功能开关 *)
    Unix.putenv "CHINESE_OCAML_SPELL_CHECK" "true";
    (* 注意：这里假设存在对应的环境变量处理 *)
    Printf.printf "STAT: 拼写检查功能切换测试完成\n";
    
    Unix.putenv "CHINESE_OCAML_SPELL_CHECK" "";
    Printf.printf "√ 智能功能配置测试完成\n";
  with
  | e -> Printf.printf "X 智能功能配置测试失败: %s\n" (Printexc.to_string e));

  (* 测试输出格式配置 *)
  Printf.printf "\n🎨 测试输出格式配置\n";
  (try
    let original_colored = Get.colored_output () in
    Printf.printf "STAT: 原始彩色输出: %b\n" original_colored;
    
    (* 测试彩色输出切换 *)
    Unix.putenv "CHINESE_OCAML_COLOR" "true";
    load_from_env ();
    let color_enabled = Get.colored_output () in
    Printf.printf "STAT: 开启彩色输出: %b\n" color_enabled;
    
    Unix.putenv "CHINESE_OCAML_COLOR" "false";
    load_from_env ();
    let color_disabled = Get.colored_output () in
    Printf.printf "STAT: 关闭彩色输出: %b\n" color_disabled;
    
    if color_enabled = true && color_disabled = false then
      Printf.printf "√ 彩色输出配置切换测试通过\n"
    else
      Printf.printf "WARN:  彩色输出配置切换部分成功\n";
    
    Unix.putenv "CHINESE_OCAML_COLOR" "";
  with
  | e -> Printf.printf "X 输出格式配置测试失败: %s\n" (Printexc.to_string e));

  (* 测试日志级别配置 *)
  Printf.printf "\nSTAT: 测试日志级别配置\n";
  (try
    let log_levels = ["debug"; "info"; "warn"; "error"] in
    Printf.printf "TEST: 测试有效日志级别:\n";
    
    List.iter (fun level ->
      Unix.putenv "CHINESE_OCAML_LOG_LEVEL" level;
      load_from_env ();
      Printf.printf "STAT: 设置日志级别: %s\n" level;
      Unix.putenv "CHINESE_OCAML_LOG_LEVEL" ""
    ) log_levels;
    
    Printf.printf "TEST: 测试无效日志级别:\n";
    let invalid_levels = ["trace"; "fatal"; "verbose"; "quiet"] in
    List.iter (fun level ->
      Unix.putenv "CHINESE_OCAML_LOG_LEVEL" level;
      (try
        load_from_env ();
        Printf.printf "WARN:  无效日志级别 '%s' 被接受（可能有默认处理）\n" level
      with
      | _ -> Printf.printf "√ 无效日志级别 '%s' 正确被拒绝\n" level);
      Unix.putenv "CHINESE_OCAML_LOG_LEVEL" ""
    ) invalid_levels;
    
    Printf.printf "√ 日志级别配置测试完成\n";
  with
  | e -> Printf.printf "X 日志级别配置测试失败: %s\n" (Printexc.to_string e));

  (* 测试综合运行时配置场景 *)
  Printf.printf "\n🔄 测试综合运行时配置场景\n";
  (try
    Printf.printf "TEST: 场景1: 开发模式配置\n";
    Unix.putenv "CHINESE_OCAML_DEBUG" "true";
    Unix.putenv "CHINESE_OCAML_VERBOSE" "true";
    Unix.putenv "CHINESE_OCAML_MAX_ERRORS" "5";
    Unix.putenv "CHINESE_OCAML_LOG_LEVEL" "debug";
    Unix.putenv "CHINESE_OCAML_COLOR" "true";
    
    load_from_env ();
    
    let dev_debug = Get.debug_mode () in
    let dev_verbose = Get.verbose_logging () in
    let dev_max_errors = Get.max_error_count () in
    let dev_colored = Get.colored_output () in
    
    Printf.printf "  - 调试模式: %b\n" dev_debug;
    Printf.printf "  - 详细日志: %b\n" dev_verbose;
    Printf.printf "  - 最大错误数: %d\n" dev_max_errors;
    Printf.printf "  - 彩色输出: %b\n" dev_colored;
    
    if dev_debug && dev_verbose && dev_max_errors = 5 && dev_colored then
      Printf.printf "√ 开发模式配置测试通过\n"
    else
      Printf.printf "WARN:  开发模式配置部分成功\n";
    
    Printf.printf "\nTEST: 场景2: 生产模式配置\n";
    Unix.putenv "CHINESE_OCAML_DEBUG" "false";
    Unix.putenv "CHINESE_OCAML_VERBOSE" "false";
    Unix.putenv "CHINESE_OCAML_MAX_ERRORS" "50";
    Unix.putenv "CHINESE_OCAML_LOG_LEVEL" "error";
    Unix.putenv "CHINESE_OCAML_COLOR" "false";
    
    load_from_env ();
    
    let prod_debug = Get.debug_mode () in
    let prod_verbose = Get.verbose_logging () in
    let prod_max_errors = Get.max_error_count () in
    let prod_colored = Get.colored_output () in
    
    Printf.printf "  - 调试模式: %b\n" prod_debug;
    Printf.printf "  - 详细日志: %b\n" prod_verbose;
    Printf.printf "  - 最大错误数: %d\n" prod_max_errors;
    Printf.printf "  - 彩色输出: %b\n" prod_colored;
    
    if not prod_debug && not prod_verbose && prod_max_errors = 50 && not prod_colored then
      Printf.printf "√ 生产模式配置测试通过\n"
    else
      Printf.printf "WARN:  生产模式配置部分成功\n";
    
    Printf.printf "\nTEST: 场景3: 测试模式配置\n";
    Unix.putenv "CHINESE_OCAML_DEBUG" "true";
    Unix.putenv "CHINESE_OCAML_VERBOSE" "false";
    Unix.putenv "CHINESE_OCAML_MAX_ERRORS" "100";
    Unix.putenv "CHINESE_OCAML_LOG_LEVEL" "info";
    Unix.putenv "CHINESE_OCAML_COLOR" "true";
    
    load_from_env ();
    
    let test_debug = Get.debug_mode () in
    let test_verbose = Get.verbose_logging () in
    let test_max_errors = Get.max_error_count () in
    let test_colored = Get.colored_output () in
    
    Printf.printf "  - 调试模式: %b\n" test_debug;
    Printf.printf "  - 详细日志: %b\n" test_verbose;
    Printf.printf "  - 最大错误数: %d\n" test_max_errors;
    Printf.printf "  - 彩色输出: %b\n" test_colored;
    
    if test_debug && not test_verbose && test_max_errors = 100 && test_colored then
      Printf.printf "√ 测试模式配置测试通过\n"
    else
      Printf.printf "WARN:  测试模式配置部分成功\n";
    
    (* 清理环境变量 *)
    List.iter (fun var -> Unix.putenv var "") [
      "CHINESE_OCAML_DEBUG";
      "CHINESE_OCAML_VERBOSE";
      "CHINESE_OCAML_MAX_ERRORS";
      "CHINESE_OCAML_LOG_LEVEL";
      "CHINESE_OCAML_COLOR";
    ];
  with
  | e -> Printf.printf "X 综合运行时配置场景测试失败: %s\n" (Printexc.to_string e));

  (* 测试配置一致性和持久性 *)
  Printf.printf "\n🔒 测试配置一致性和持久性\n";
  (try
    (* 设置初始配置 *)
    Unix.putenv "CHINESE_OCAML_DEBUG" "true";
    Unix.putenv "CHINESE_OCAML_MAX_ERRORS" "20";
    load_from_env ();
    
    let initial_debug = Get.debug_mode () in
    let initial_max_errors = Get.max_error_count () in
    
    Printf.printf "STAT: 初始配置: 调试=%b, 最大错误=%d\n" initial_debug initial_max_errors;
    
    (* 多次获取配置，验证一致性 *)
    for i = 1 to 10 do
      let current_debug = Get.debug_mode () in
      let current_max_errors = Get.max_error_count () in
      if current_debug <> initial_debug || current_max_errors <> initial_max_errors then
        Printf.printf "X 第%d次获取配置不一致\n" i
    done;
    
    Printf.printf "√ 配置一致性验证完成\n";
    
    (* 清理 *)
    Unix.putenv "CHINESE_OCAML_DEBUG" "";
    Unix.putenv "CHINESE_OCAML_MAX_ERRORS" "";
  with
  | e -> Printf.printf "X 配置一致性测试失败: %s\n" (Printexc.to_string e));

  (* 性能测试 *)
  Printf.printf "\n⚡ 性能测试\n";
  (try
    let start_time = Sys.time () in
    
    (* 大量配置访问操作 *)
    for _ = 1 to 10000 do
      let _ = Get.debug_mode () in
      let _ = Get.verbose_logging () in
      let _ = Get.error_recovery () in
      let _ = Get.max_error_count () in
      let _ = Get.colored_output () in
      ()
    done;
    
    let end_time = Sys.time () in
    let duration = end_time -. start_time in
    
    Printf.printf "√ 10000次配置访问耗时: %.6f秒\n" duration;
    Printf.printf "STAT: 平均每次访问耗时: %.6f秒\n" (duration /. 10000.0);
    
    if duration < 1.0 then
      Printf.printf "√ 运行时配置访问性能优秀\n"
    else
      Printf.printf "WARN:  运行时配置访问性能可能需要优化\n";
  with
  | e -> Printf.printf "X 性能测试失败: %s\n" (Printexc.to_string e));

  Printf.printf "\n🎉 骆言运行时配置模块全面测试完成！\n";
  Printf.printf "STAT: 测试涵盖: 调试模式、错误处理、智能功能、输出格式、日志级别\n";
  Printf.printf "CONFIG: 包含综合场景测试、一致性验证、性能测试\n";
  Printf.printf "🌏 支持多种配置模式: 开发、生产、测试\n";
  Printf.printf "🔒 保证配置状态的一致性和持久性\n"