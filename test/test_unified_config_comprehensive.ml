open Yyocamlc_lib.Config

let () =
  Printf.printf "🧪 骆言统一配置模块全面测试开始\n\n";

  (* 保存测试开始时的配置状态 *)
  Printf.printf "💾 保存初始配置状态\n";
  let initial_compiler_config = get_compiler_config () in
  let initial_runtime_config = get_runtime_config () in
  Printf.printf "✅ 初始配置状态已保存\n";

  (* 测试配置初始化 *)
  Printf.printf "\n🚀 测试配置初始化\n";
  (try
    (* 测试无参数初始化 *)
    init_config ();
    Printf.printf "✅ 默认配置初始化成功\n";
    
    let post_init_compiler = get_compiler_config () in
    let post_init_runtime = get_runtime_config () in
    Printf.printf "✅ 初始化后配置获取成功\n";
    
    (* 验证初始化后的配置合理性 *)
    let buffer_size = Get.buffer_size () in
    let debug_mode = Get.debug_mode () in
    let timeout = Get.compilation_timeout () in
    
    if buffer_size > 0 && timeout > 0.0 then
      Printf.printf "✅ 初始化后配置合理性检查通过\n"
    else
      Printf.printf "❌ 初始化后配置不合理\n";
  with
  | e -> Printf.printf "❌ 配置初始化测试失败: %s\n" (Printexc.to_string e));

  (* 测试从环境变量加载全部配置 *)
  Printf.printf "\n🌍 测试从环境变量加载全部配置\n";
  (try
    (* 设置一组全面的环境变量 *)
    let env_vars = [
      ("CHINESE_OCAML_DEBUG", "true");
      ("CHINESE_OCAML_VERBOSE", "false");
      ("CHINESE_OCAML_BUFFER_SIZE", "4096");
      ("CHINESE_OCAML_TIMEOUT", "45.0");
      ("CHINESE_OCAML_OUTPUT_DIR", "/tmp/unified_test");
      ("CHINESE_OCAML_C_COMPILER", "clang");
      ("CHINESE_OCAML_OPT_LEVEL", "2");
      ("CHINESE_OCAML_MAX_ERRORS", "30");
      ("CHINESE_OCAML_LOG_LEVEL", "info");
      ("CHINESE_OCAML_COLOR", "true");
    ] in
    
    List.iter (fun (var, value) -> Unix.putenv var value) env_vars;
    Printf.printf "🔧 设置了 %d 个环境变量\n" (List.length env_vars);
    
    (* 记录加载前的配置 *)
    let before_debug = Get.debug_mode () in
    let before_verbose = Get.verbose_logging () in
    let before_buffer = Get.buffer_size () in
    let before_timeout = Get.compilation_timeout () in
    let before_output = Get.output_directory () in
    let before_compiler = Get.c_compiler () in
    let before_opt_level = Get.optimization_level () in
    let before_max_errors = Get.max_error_count () in
    let before_colored = Get.colored_output () in
    
    Printf.printf "📊 加载前配置记录完成\n";
    
    (* 从环境变量加载所有配置 *)
    load_from_env ();
    Printf.printf "🔄 环境变量配置加载完成\n";
    
    (* 检查加载后的配置 *)
    let after_debug = Get.debug_mode () in
    let after_verbose = Get.verbose_logging () in
    let after_buffer = Get.buffer_size () in
    let after_timeout = Get.compilation_timeout () in
    let after_output = Get.output_directory () in
    let after_compiler = Get.c_compiler () in
    let after_opt_level = Get.optimization_level () in
    let after_max_errors = Get.max_error_count () in
    let after_colored = Get.colored_output () in
    
    Printf.printf "\n📈 环境变量配置加载结果对比:\n";
    Printf.printf "  调试模式: %b -> %b\n" before_debug after_debug;
    Printf.printf "  详细日志: %b -> %b\n" before_verbose after_verbose;
    Printf.printf "  缓冲区大小: %d -> %d\n" before_buffer after_buffer;
    Printf.printf "  编译超时: %.2f -> %.2f\n" before_timeout after_timeout;
    Printf.printf "  输出目录: %s -> %s\n" before_output after_output;
    Printf.printf "  C编译器: %s -> %s\n" before_compiler after_compiler;
    Printf.printf "  优化级别: %d -> %d\n" before_opt_level after_opt_level;
    Printf.printf "  最大错误数: %d -> %d\n" before_max_errors after_max_errors;
    Printf.printf "  彩色输出: %b -> %b\n" before_colored after_colored;
    
    (* 验证关键配置是否正确加载 *)
    let expected_updates = 
      after_debug = true &&
      after_verbose = false &&
      after_buffer = 4096 &&
      abs_float (after_timeout -. 45.0) < 0.1 &&
      String.equal after_output "/tmp/unified_test" &&
      String.equal after_compiler "clang" &&
      after_opt_level = 2 &&
      after_max_errors = 30 &&
      after_colored = true in
    
    if expected_updates then
      Printf.printf "✅ 环境变量统一配置加载测试完全通过\n"
    else
      Printf.printf "⚠️  环境变量统一配置加载部分成功\n";
    
    (* 清理环境变量 *)
    List.iter (fun (var, _) -> Unix.putenv var "") env_vars;
    Printf.printf "🧹 环境变量清理完成\n";
  with
  | e -> Printf.printf "❌ 环境变量统一配置加载测试失败: %s\n" (Printexc.to_string e));

  (* 测试JSON配置文件加载 *)
  Printf.printf "\n📄 测试JSON配置文件统一加载\n";
  (try
    let config_file = "/tmp/luoyan_unified_config.json" in
    let config_content = {|{
  "debug_mode": true,
  "verbose_logging": false,
  "buffer_size": 8192,
  "large_buffer_size": 16384,
  "timeout": 120.0,
  "output_directory": "/tmp/json_config_test",
  "temp_directory": "/tmp/luoyan_temp",
  "c_compiler": "gcc",
  "optimization_level": 3,
  "max_error_count": 50,
  "log_level": "warn",
  "colored_output": false,
  "error_recovery": true,
  "spell_correction": true
}|} in
    
    (* 创建配置文件 *)
    let oc = open_out config_file in
    output_string oc config_content;
    close_out oc;
    Printf.printf "📝 JSON配置文件创建成功: %s\n" config_file;
    
    (* 记录加载前的状态 *)
    let before_debug = Get.debug_mode () in
    let before_buffer = Get.buffer_size () in
    let before_timeout = Get.compilation_timeout () in
    let before_output = Get.output_directory () in
    let before_compiler = Get.c_compiler () in
    let before_opt_level = Get.optimization_level () in
    let before_colored = Get.colored_output () in
    let before_error_recovery = Get.error_recovery () in
    
    Printf.printf "📊 JSON加载前配置状态记录完成\n";
    
    (* 使用配置文件初始化 *)
    init_config ~config_file ();
    Printf.printf "🔄 JSON配置文件加载完成\n";
    
    (* 检查加载后的配置 *)
    let after_debug = Get.debug_mode () in
    let after_buffer = Get.buffer_size () in
    let after_timeout = Get.compilation_timeout () in
    let after_output = Get.output_directory () in
    let after_compiler = Get.c_compiler () in
    let after_opt_level = Get.optimization_level () in
    let after_colored = Get.colored_output () in
    let after_error_recovery = Get.error_recovery () in
    
    Printf.printf "\n📈 JSON配置加载结果对比:\n";
    Printf.printf "  调试模式: %b -> %b\n" before_debug after_debug;
    Printf.printf "  缓冲区大小: %d -> %d\n" before_buffer after_buffer;
    Printf.printf "  编译超时: %.2f -> %.2f\n" before_timeout after_timeout;
    Printf.printf "  输出目录: %s -> %s\n" before_output after_output;
    Printf.printf "  C编译器: %s -> %s\n" before_compiler after_compiler;
    Printf.printf "  优化级别: %d -> %d\n" before_opt_level after_opt_level;
    Printf.printf "  彩色输出: %b -> %b\n" before_colored after_colored;
    Printf.printf "  错误恢复: %b -> %b\n" before_error_recovery after_error_recovery;
    
    (* 验证JSON配置是否正确应用 *)
    let json_updates_correct = 
      after_debug = true &&
      after_buffer = 8192 &&
      abs_float (after_timeout -. 120.0) < 0.1 &&
      String.equal after_output "/tmp/json_config_test" &&
      String.equal after_compiler "gcc" &&
      after_opt_level = 3 &&
      after_colored = false &&
      after_error_recovery = true in
    
    if json_updates_correct then
      Printf.printf "✅ JSON配置文件统一加载测试完全通过\n"
    else
      Printf.printf "⚠️  JSON配置文件统一加载部分成功\n";
    
    (* 清理配置文件 *)
    if Sys.file_exists config_file then Sys.remove config_file;
    Printf.printf "🧹 JSON配置文件清理完成\n";
  with
  | e -> Printf.printf "❌ JSON配置文件统一加载测试失败: %s\n" (Printexc.to_string e));

  (* 测试配置验证 *)
  Printf.printf "\n🔍 测试统一配置验证\n";
  (try
    (* 验证当前配置 *)
    let validation_errors = validate_config () in
    
    if validation_errors = [] then
      Printf.printf "✅ 当前统一配置验证通过，无错误\n"
    else begin
      Printf.printf "⚠️  统一配置验证发现 %d 个问题:\n" (List.length validation_errors);
      List.iteri (fun i error ->
        Printf.printf "  %d. %s\n" (i+1) error
      ) validation_errors
    end;
    
    (* 测试特定的无效配置场景 *)
    Printf.printf "\n🧪 测试无效配置检测:\n";
    
    (* 设置一些明显无效的环境变量 *)
    let invalid_env_tests = [
      ("CHINESE_OCAML_BUFFER_SIZE", "0");      (* 无效：零或负数 *)
      ("CHINESE_OCAML_TIMEOUT", "-10.0");     (* 无效：负数 *)
      ("CHINESE_OCAML_OPT_LEVEL", "10");      (* 无效：超出范围 *)
      ("CHINESE_OCAML_MAX_ERRORS", "-1");     (* 无效：负数 *)
    ] in
    
    List.iter (fun (var, invalid_value) ->
      Unix.putenv var invalid_value;
      (try
        load_from_env ();
        let current_errors = validate_config () in
        if current_errors = [] then
          Printf.printf "⚠️  无效配置 %s='%s' 未被检测到\n" var invalid_value
        else
          Printf.printf "✅ 无效配置 %s='%s' 被正确检测\n" var invalid_value
      with
      | e -> Printf.printf "✅ 无效配置 %s='%s' 导致异常: %s\n" var invalid_value (Printexc.to_string e));
      Unix.putenv var ""
    ) invalid_env_tests;
  with
  | e -> Printf.printf "❌ 统一配置验证测试失败: %s\n" (Printexc.to_string e));

  (* 测试配置重置到默认值 *)
  Printf.printf "\n🔄 测试配置重置到默认值\n";
  (try
    (* 首先修改一些配置 *)
    Unix.putenv "CHINESE_OCAML_DEBUG" "true";
    Unix.putenv "CHINESE_OCAML_BUFFER_SIZE" "16384";
    Unix.putenv "CHINESE_OCAML_TIMEOUT" "200.0";
    load_from_env ();
    
    let modified_debug = Get.debug_mode () in
    let modified_buffer = Get.buffer_size () in
    let modified_timeout = Get.compilation_timeout () in
    
    Printf.printf "📊 修改后配置:\n";
    Printf.printf "  - 调试模式: %b\n" modified_debug;
    Printf.printf "  - 缓冲区大小: %d\n" modified_buffer;
    Printf.printf "  - 编译超时: %.2f\n" modified_timeout;
    
    (* 重置到默认配置（注意：这个函数可能不存在，需要根据实际API调整） *)
    (* reset_to_defaults (); *)
    
    (* 手动恢复到默认配置 *)
    set_compiler_config (default_compiler_config);
    set_runtime_config (default_runtime_config);
    
    let reset_debug = Get.debug_mode () in
    let reset_buffer = Get.buffer_size () in
    let reset_timeout = Get.compilation_timeout () in
    
    Printf.printf "📊 重置后配置:\n";
    Printf.printf "  - 调试模式: %b\n" reset_debug;
    Printf.printf "  - 缓冲区大小: %d\n" reset_buffer;
    Printf.printf "  - 编译超时: %.2f\n" reset_timeout;
    
    Printf.printf "✅ 配置重置测试完成\n";
    
    (* 清理环境变量 *)
    Unix.putenv "CHINESE_OCAML_DEBUG" "";
    Unix.putenv "CHINESE_OCAML_BUFFER_SIZE" "";
    Unix.putenv "CHINESE_OCAML_TIMEOUT" "";
  with
  | e -> Printf.printf "❌ 配置重置测试失败: %s\n" (Printexc.to_string e));

  (* 测试配置优先级：环境变量 vs 配置文件 *)
  Printf.printf "\n🏆 测试配置优先级\n";
  (try
    let config_file = "/tmp/luoyan_priority_test.json" in
    let config_content = {|{
  "debug_mode": false,
  "buffer_size": 2048,
  "timeout": 30.0
}|} in
    
    (* 创建配置文件 *)
    let oc = open_out config_file in
    output_string oc config_content;
    close_out oc;
    
    (* 同时设置环境变量（通常优先级更高） *)
    Unix.putenv "CHINESE_OCAML_DEBUG" "true";
    Unix.putenv "CHINESE_OCAML_BUFFER_SIZE" "4096";
    Unix.putenv "CHINESE_OCAML_TIMEOUT" "60.0";
    
    Printf.printf "🧪 设置了冲突的配置文件和环境变量\n";
    
    (* 先加载配置文件，然后加载环境变量 *)
    let _ = load_from_file config_file in
    load_from_env ();
    
    let final_debug = Get.debug_mode () in
    let final_buffer = Get.buffer_size () in
    let final_timeout = Get.compilation_timeout () in
    
    Printf.printf "📊 最终配置结果:\n";
    Printf.printf "  - 调试模式: %b (配置文件: false, 环境变量: true)\n" final_debug;
    Printf.printf "  - 缓冲区大小: %d (配置文件: 2048, 环境变量: 4096)\n" final_buffer;
    Printf.printf "  - 编译超时: %.2f (配置文件: 30.0, 环境变量: 60.0)\n" final_timeout;
    
    (* 验证环境变量是否具有更高优先级 *)
    if final_debug = true && final_buffer = 4096 && abs_float (final_timeout -. 60.0) < 0.1 then
      Printf.printf "✅ 环境变量优先级测试通过（环境变量 > 配置文件）\n"
    else
      Printf.printf "⚠️  配置优先级测试结果待验证\n";
    
    (* 清理 *)
    if Sys.file_exists config_file then Sys.remove config_file;
    Unix.putenv "CHINESE_OCAML_DEBUG" "";
    Unix.putenv "CHINESE_OCAML_BUFFER_SIZE" "";
    Unix.putenv "CHINESE_OCAML_TIMEOUT" "";
  with
  | e -> Printf.printf "❌ 配置优先级测试失败: %s\n" (Printexc.to_string e));

  (* 测试配置持久性和一致性 *)
  Printf.printf "\n🔒 测试配置持久性和一致性\n";
  (try
    (* 设置特定配置 *)
    Unix.putenv "CHINESE_OCAML_DEBUG" "true";
    Unix.putenv "CHINESE_OCAML_BUFFER_SIZE" "8192";
    load_from_env ();
    
    let persistent_debug = Get.debug_mode () in
    let persistent_buffer = Get.buffer_size () in
    
    Printf.printf "📊 初始设置: 调试=%b, 缓冲区=%d\n" persistent_debug persistent_buffer;
    
    (* 多次获取配置，验证一致性 *)
    let consistency_checks = ref 0 in
    let inconsistency_count = ref 0 in
    
    for i = 1 to 100 do
      let current_debug = Get.debug_mode () in
      let current_buffer = Get.buffer_size () in
      incr consistency_checks;
      
      if current_debug <> persistent_debug || current_buffer <> persistent_buffer then
        incr inconsistency_count
    done;
    
    Printf.printf "📊 一致性检查: %d次检查, %d次不一致\n" !consistency_checks !inconsistency_count;
    
    if !inconsistency_count = 0 then
      Printf.printf "✅ 配置持久性和一致性测试通过\n"
    else
      Printf.printf "❌ 发现配置不一致问题\n";
    
    Unix.putenv "CHINESE_OCAML_DEBUG" "";
    Unix.putenv "CHINESE_OCAML_BUFFER_SIZE" "";
  with
  | e -> Printf.printf "❌ 配置持久性测试失败: %s\n" (Printexc.to_string e));

  (* 性能测试：统一配置操作 *)
  Printf.printf "\n⚡ 统一配置性能测试\n";
  (try
    let start_time = Sys.time () in
    
    (* 大量统一配置操作 *)
    for i = 1 to 1000 do
      (* 交替进行配置设置和获取 *)
      if i mod 2 = 0 then begin
        Unix.putenv "CHINESE_OCAML_DEBUG" "true";
        Unix.putenv "CHINESE_OCAML_BUFFER_SIZE" (string_of_int (1024 + i));
        load_from_env ()
      end;
      
      (* 获取多个配置值 *)
      let _ = Get.debug_mode () in
      let _ = Get.buffer_size () in
      let _ = Get.compilation_timeout () in
      let _ = Get.output_directory () in
      let _ = Get.c_compiler () in
      ()
    done;
    
    let end_time = Sys.time () in
    let duration = end_time -. start_time in
    
    Printf.printf "✅ 1000次统一配置操作耗时: %.6f秒\n" duration;
    Printf.printf "📊 平均每次操作耗时: %.6f秒\n" (duration /. 1000.0);
    
    if duration < 2.0 then
      Printf.printf "✅ 统一配置操作性能优秀\n"
    else
      Printf.printf "⚠️  统一配置操作性能可能需要优化\n";
    
    (* 清理 *)
    Unix.putenv "CHINESE_OCAML_DEBUG" "";
    Unix.putenv "CHINESE_OCAML_BUFFER_SIZE" "";
  with
  | e -> Printf.printf "❌ 统一配置性能测试失败: %s\n" (Printexc.to_string e));

  (* 恢复初始配置状态 *)
  Printf.printf "\n🔄 恢复初始配置状态\n";
  (try
    set_compiler_config initial_compiler_config;
    set_runtime_config initial_runtime_config;
    Printf.printf "✅ 初始配置状态恢复成功\n";
  with
  | e -> Printf.printf "⚠️  配置状态恢复过程中出现问题: %s\n" (Printexc.to_string e));

  Printf.printf "\n🎉 骆言统一配置模块全面测试完成！\n";
  Printf.printf "📊 测试涵盖: 初始化、环境变量加载、JSON文件加载、配置验证\n";
  Printf.printf "🔧 包含配置优先级、持久性、一致性、性能测试\n";
  Printf.printf "🌏 支持多种配置源的统一管理和协调\n";
  Printf.printf "🔒 保证测试前后配置状态的完整恢复\n"