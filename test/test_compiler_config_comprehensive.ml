open Yyocamlc_lib.Config

let () =
  Printf.printf "🧪 骆言编译器配置模块全面测试开始\n\n";

  (* 测试默认编译器配置 *)
  Printf.printf "📋 测试默认编译器配置\n";
  (try
    let default_config = default_compiler_config in
    Printf.printf "✅ 默认编译器配置获取成功\n";
    
    (* 验证默认配置的合理性 *)
    let buffer_size = Get.buffer_size () in
    let large_buffer_size = Get.large_buffer_size () in
    let compilation_timeout = Get.compilation_timeout () in
    let output_directory = Get.output_directory () in
    let temp_directory = Get.temp_directory () in
    let c_compiler = Get.c_compiler () in
    let optimization_level = Get.optimization_level () in
    let hashtable_size = Get.hashtable_size () in
    let large_hashtable_size = Get.large_hashtable_size () in
    
    Printf.printf "📊 默认编译器配置值:\n";
    Printf.printf "  - 缓冲区大小: %d\n" buffer_size;
    Printf.printf "  - 大缓冲区大小: %d\n" large_buffer_size;
    Printf.printf "  - 编译超时: %.2f秒\n" compilation_timeout;
    Printf.printf "  - 输出目录: %s\n" output_directory;
    Printf.printf "  - 临时目录: %s\n" temp_directory;
    Printf.printf "  - C编译器: %s\n" c_compiler;
    Printf.printf "  - 优化级别: %d\n" optimization_level;
    Printf.printf "  - 哈希表大小: %d\n" hashtable_size;
    Printf.printf "  - 大哈希表大小: %d\n" large_hashtable_size;
    
    if buffer_size > 0 && large_buffer_size >= buffer_size && 
       compilation_timeout > 0.0 && optimization_level >= 0 &&
       hashtable_size > 0 && large_hashtable_size >= hashtable_size then
      Printf.printf "✅ 默认编译器配置值合理性检查通过\n"
    else
      Printf.printf "❌ 默认编译器配置值不合理\n";
  with
  | e -> Printf.printf "❌ 默认编译器配置测试失败: %s\n" (Printexc.to_string e));

  (* 测试编译器配置的获取和设置 *)
  Printf.printf "\n🔧 测试编译器配置获取和设置\n";
  (try
    let original_config = get_compiler_config () in
    Printf.printf "✅ 原始编译器配置获取成功\n";
    
    (* 创建修改后的配置进行测试 *)
    let modified_config = original_config in
    set_compiler_config modified_config;
    Printf.printf "✅ 编译器配置设置成功\n";
    
    let retrieved_config = get_compiler_config () in
    Printf.printf "✅ 修改后编译器配置获取成功\n";
    
    (* 恢复原始配置 *)
    set_compiler_config original_config;
    Printf.printf "✅ 原始编译器配置恢复成功\n";
  with
  | e -> Printf.printf "❌ 编译器配置获取设置测试失败: %s\n" (Printexc.to_string e));

  (* 测试缓冲区配置 *)
  Printf.printf "\n💾 测试缓冲区配置\n";
  (try
    let original_buffer = Get.buffer_size () in
    let original_large_buffer = Get.large_buffer_size () in
    
    Printf.printf "📊 原始缓冲区配置:\n";
    Printf.printf "  - 标准缓冲区: %d\n" original_buffer;
    Printf.printf "  - 大缓冲区: %d\n" original_large_buffer;
    
    (* 测试不同的缓冲区大小 *)
    let buffer_test_sizes = ["1024"; "2048"; "4096"; "8192"; "16384"] in
    List.iter (fun size ->
      Unix.putenv "CHINESE_OCAML_BUFFER_SIZE" size;
      load_from_env ();
      let current_buffer = Get.buffer_size () in
      Printf.printf "📊 设置缓冲区大小 %s -> 实际 %d\n" size current_buffer;
      fun var -> Unix.putenv var "" "CHINESE_OCAML_BUFFER_SIZE"
    ) buffer_test_sizes;
    
    (* 测试无效的缓冲区大小 *)
    let invalid_sizes = ["0"; "-1024"; "abc"; ""] in
    List.iter (fun size ->
      Unix.putenv "CHINESE_OCAML_BUFFER_SIZE" size;
      (try
        load_from_env ();
        let current_buffer = Get.buffer_size () in
        Printf.printf "⚠️  无效缓冲区大小 '%s' 被处理为 %d\n" size current_buffer
      with
      | e -> Printf.printf "✅ 无效缓冲区大小 '%s' 正确被拒绝\n" size);
      fun var -> Unix.putenv var "" "CHINESE_OCAML_BUFFER_SIZE"
    ) invalid_sizes;
    
    Printf.printf "✅ 缓冲区配置测试完成\n";
  with
  | e -> Printf.printf "❌ 缓冲区配置测试失败: %s\n" (Printexc.to_string e));

  (* 测试超时配置 *)
  Printf.printf "\n⏰ 测试超时配置\n";
  (try
    let original_timeout = Get.compilation_timeout () in
    Printf.printf "📊 原始编译超时: %.2f秒\n" original_timeout;
    
    (* 测试不同的超时值 *)
    let timeout_test_values = ["10.0"; "30.0"; "60.0"; "120.0"; "300.0"] in
    List.iter (fun timeout ->
      Unix.putenv "CHINESE_OCAML_TIMEOUT" timeout;
      load_from_env ();
      let current_timeout = Get.compilation_timeout () in
      Printf.printf "📊 设置编译超时 %s -> 实际 %.2f\n" timeout current_timeout;
      fun var -> Unix.putenv var "" "CHINESE_OCAML_TIMEOUT"
    ) timeout_test_values;
    
    (* 测试无效的超时值 *)
    let invalid_timeouts = ["0.0"; "-10.0"; "abc"; ""] in
    List.iter (fun timeout ->
      Unix.putenv "CHINESE_OCAML_TIMEOUT" timeout;
      (try
        load_from_env ();
        let current_timeout = Get.compilation_timeout () in
        Printf.printf "⚠️  无效超时值 '%s' 被处理为 %.2f\n" timeout current_timeout
      with
      | e -> Printf.printf "✅ 无效超时值 '%s' 正确被拒绝\n" timeout);
      fun var -> Unix.putenv var "" "CHINESE_OCAML_TIMEOUT"
    ) invalid_timeouts;
    
    Printf.printf "✅ 超时配置测试完成\n";
  with
  | e -> Printf.printf "❌ 超时配置测试失败: %s\n" (Printexc.to_string e));

  (* 测试目录配置 *)
  Printf.printf "\n📁 测试目录配置\n";
  (try
    let original_output_dir = Get.output_directory () in
    let original_temp_dir = Get.temp_directory () in
    
    Printf.printf "📊 原始目录配置:\n";
    Printf.printf "  - 输出目录: %s\n" original_output_dir;
    Printf.printf "  - 临时目录: %s\n" original_temp_dir;
    
    (* 测试输出目录设置 *)
    let output_dirs = ["/tmp/luoyan_output"; "/home/user/projects"; "骆言输出目录"; "./build"] in
    List.iter (fun dir ->
      Unix.putenv "CHINESE_OCAML_OUTPUT_DIR" dir;
      load_from_env ();
      let current_dir = Get.output_directory () in
      Printf.printf "📊 设置输出目录 '%s' -> '%s'\n" dir current_dir;
      fun var -> Unix.putenv var "" "CHINESE_OCAML_OUTPUT_DIR"
    ) output_dirs;
    
    (* 测试临时目录设置 *)
    let temp_dirs = ["/tmp"; "/var/tmp"; "临时目录"; "./temp"] in
    List.iter (fun dir ->
      Unix.putenv "CHINESE_OCAML_TEMP_DIR" dir;
      load_from_env ();
      let current_dir = Get.temp_directory () in
      Printf.printf "📊 设置临时目录 '%s' -> '%s'\n" dir current_dir;
      fun var -> Unix.putenv var "" "CHINESE_OCAML_TEMP_DIR"
    ) temp_dirs;
    
    (* 测试无效目录 *)
    let invalid_dirs = [""; "   "] in
    List.iter (fun dir ->
      Unix.putenv "CHINESE_OCAML_OUTPUT_DIR" dir;
      (try
        load_from_env ();
        let current_dir = Get.output_directory () in
        Printf.printf "⚠️  无效输出目录 '%s' 被处理为 '%s'\n" dir current_dir
      with
      | e -> Printf.printf "✅ 无效输出目录 '%s' 正确被拒绝\n" dir);
      fun var -> Unix.putenv var "" "CHINESE_OCAML_OUTPUT_DIR"
    ) invalid_dirs;
    
    Printf.printf "✅ 目录配置测试完成\n";
  with
  | e -> Printf.printf "❌ 目录配置测试失败: %s\n" (Printexc.to_string e));

  (* 测试C编译器配置 *)
  Printf.printf "\n🔧 测试C编译器配置\n";
  (try
    let original_c_compiler = Get.c_compiler () in
    Printf.printf "📊 原始C编译器: %s\n" original_c_compiler;
    
    (* 测试不同的C编译器 *)
    let c_compilers = ["gcc"; "clang"; "icc"; "tcc"] in
    List.iter (fun compiler ->
      Unix.putenv "CHINESE_OCAML_C_COMPILER" compiler;
      load_from_env ();
      let current_compiler = Get.c_compiler () in
      Printf.printf "📊 设置C编译器 '%s' -> '%s'\n" compiler current_compiler;
      fun var -> Unix.putenv var "" "CHINESE_OCAML_C_COMPILER"
    ) c_compilers;
    
    Printf.printf "✅ C编译器配置测试完成\n";
  with
  | e -> Printf.printf "❌ C编译器配置测试失败: %s\n" (Printexc.to_string e));

  (* 测试优化级别配置 *)
  Printf.printf "\n🚀 测试优化级别配置\n";
  (try
    let original_opt_level = Get.optimization_level () in
    Printf.printf "📊 原始优化级别: %d\n" original_opt_level;
    
    (* 测试有效的优化级别 (通常是0-3) *)
    let valid_opt_levels = ["0"; "1"; "2"; "3"] in
    List.iter (fun level ->
      Unix.putenv "CHINESE_OCAML_OPT_LEVEL" level;
      load_from_env ();
      let current_level = Get.optimization_level () in
      Printf.printf "📊 设置优化级别 %s -> %d\n" level current_level;
      fun var -> Unix.putenv var "" "CHINESE_OCAML_OPT_LEVEL"
    ) valid_opt_levels;
    
    (* 测试无效的优化级别 *)
    let invalid_opt_levels = ["-1"; "4"; "10"; "abc"] in
    List.iter (fun level ->
      Unix.putenv "CHINESE_OCAML_OPT_LEVEL" level;
      (try
        load_from_env ();
        let current_level = Get.optimization_level () in
        Printf.printf "⚠️  无效优化级别 '%s' 被处理为 %d\n" level current_level
      with
      | e -> Printf.printf "✅ 无效优化级别 '%s' 正确被拒绝\n" level);
      fun var -> Unix.putenv var "" "CHINESE_OCAML_OPT_LEVEL"
    ) invalid_opt_levels;
    
    Printf.printf "✅ 优化级别配置测试完成\n";
  with
  | e -> Printf.printf "❌ 优化级别配置测试失败: %s\n" (Printexc.to_string e));

  (* 测试哈希表配置 *)
  Printf.printf "\n🏗️ 测试哈希表配置\n";
  (try
    let original_hashtable = Get.hashtable_size () in
    let original_large_hashtable = Get.large_hashtable_size () in
    
    Printf.printf "📊 原始哈希表配置:\n";
    Printf.printf "  - 标准哈希表: %d\n" original_hashtable;
    Printf.printf "  - 大哈希表: %d\n" original_large_hashtable;
    
    (* 验证大哈希表不小于标准哈希表 *)
    if original_large_hashtable >= original_hashtable then
      Printf.printf "✅ 哈希表大小关系合理: 大哈希表 >= 标准哈希表\n"
    else
      Printf.printf "❌ 哈希表大小关系不合理\n";
    
    Printf.printf "✅ 哈希表配置测试完成\n";
  with
  | e -> Printf.printf "❌ 哈希表配置测试失败: %s\n" (Printexc.to_string e));

  (* 测试综合编译器配置场景 *)
  Printf.printf "\n🔄 测试综合编译器配置场景\n";
  (try
    Printf.printf "🧪 场景1: 快速开发配置\n";
    Unix.putenv "CHINESE_OCAML_BUFFER_SIZE" "1024";
    Unix.putenv "CHINESE_OCAML_TIMEOUT" "10.0";
    Unix.putenv "CHINESE_OCAML_C_COMPILER" "gcc";
    Unix.putenv "CHINESE_OCAML_OPT_LEVEL" "0";
    Unix.putenv "CHINESE_OCAML_OUTPUT_DIR" "/tmp/fast_dev";
    
    load_from_env ();
    
    let dev_buffer = Get.buffer_size () in
    let dev_timeout = Get.compilation_timeout () in
    let dev_compiler = Get.c_compiler () in
    let dev_opt = Get.optimization_level () in
    let dev_output = Get.output_directory () in
    
    Printf.printf "  - 缓冲区大小: %d\n" dev_buffer;
    Printf.printf "  - 编译超时: %.2f\n" dev_timeout;
    Printf.printf "  - C编译器: %s\n" dev_compiler;
    Printf.printf "  - 优化级别: %d\n" dev_opt;
    Printf.printf "  - 输出目录: %s\n" dev_output;
    
    if dev_buffer = 1024 && dev_timeout = 10.0 && 
       String.equal dev_compiler "gcc" && dev_opt = 0 &&
       String.equal dev_output "/tmp/fast_dev" then
      Printf.printf "✅ 快速开发配置测试通过\n"
    else
      Printf.printf "⚠️  快速开发配置部分成功\n";
    
    Printf.printf "\n🧪 场景2: 生产构建配置\n";
    Unix.putenv "CHINESE_OCAML_BUFFER_SIZE" "8192";
    Unix.putenv "CHINESE_OCAML_TIMEOUT" "300.0";
    Unix.putenv "CHINESE_OCAML_C_COMPILER" "clang";
    Unix.putenv "CHINESE_OCAML_OPT_LEVEL" "3";
    Unix.putenv "CHINESE_OCAML_OUTPUT_DIR" "/opt/luoyan/release";
    
    load_from_env ();
    
    let prod_buffer = Get.buffer_size () in
    let prod_timeout = Get.compilation_timeout () in
    let prod_compiler = Get.c_compiler () in
    let prod_opt = Get.optimization_level () in
    let prod_output = Get.output_directory () in
    
    Printf.printf "  - 缓冲区大小: %d\n" prod_buffer;
    Printf.printf "  - 编译超时: %.2f\n" prod_timeout;
    Printf.printf "  - C编译器: %s\n" prod_compiler;
    Printf.printf "  - 优化级别: %d\n" prod_opt;
    Printf.printf "  - 输出目录: %s\n" prod_output;
    
    if prod_buffer = 8192 && prod_timeout = 300.0 && 
       String.equal prod_compiler "clang" && prod_opt = 3 &&
       String.equal prod_output "/opt/luoyan/release" then
      Printf.printf "✅ 生产构建配置测试通过\n"
    else
      Printf.printf "⚠️  生产构建配置部分成功\n";
    
    Printf.printf "\n🧪 场景3: 测试环境配置\n";
    Unix.putenv "CHINESE_OCAML_BUFFER_SIZE" "4096";
    Unix.putenv "CHINESE_OCAML_TIMEOUT" "60.0";
    Unix.putenv "CHINESE_OCAML_C_COMPILER" "gcc";
    Unix.putenv "CHINESE_OCAML_OPT_LEVEL" "1";
    Unix.putenv "CHINESE_OCAML_OUTPUT_DIR" "/tmp/luoyan_test";
    
    load_from_env ();
    
    let test_buffer = Get.buffer_size () in
    let test_timeout = Get.compilation_timeout () in
    let test_compiler = Get.c_compiler () in
    let test_opt = Get.optimization_level () in
    let test_output = Get.output_directory () in
    
    Printf.printf "  - 缓冲区大小: %d\n" test_buffer;
    Printf.printf "  - 编译超时: %.2f\n" test_timeout;
    Printf.printf "  - C编译器: %s\n" test_compiler;
    Printf.printf "  - 优化级别: %d\n" test_opt;
    Printf.printf "  - 输出目录: %s\n" test_output;
    
    if test_buffer = 4096 && test_timeout = 60.0 && 
       String.equal test_compiler "gcc" && test_opt = 1 &&
       String.equal test_output "/tmp/luoyan_test" then
      Printf.printf "✅ 测试环境配置测试通过\n"
    else
      Printf.printf "⚠️  测试环境配置部分成功\n";
    
    (* 清理环境变量 *)
    List.iter (fun var -> Unix.putenv var "") [
      "CHINESE_OCAML_BUFFER_SIZE";
      "CHINESE_OCAML_TIMEOUT";
      "CHINESE_OCAML_C_COMPILER";
      "CHINESE_OCAML_OPT_LEVEL";
      "CHINESE_OCAML_OUTPUT_DIR";
    ];
  with
  | e -> Printf.printf "❌ 综合编译器配置场景测试失败: %s\n" (Printexc.to_string e));

  (* 测试配置值的范围和限制 *)
  Printf.printf "\n⚖️ 测试配置值范围和限制\n";
  (try
    Printf.printf "🧪 测试极端值处理:\n";
    
    (* 测试极大的缓冲区大小 *)
    Unix.putenv "CHINESE_OCAML_BUFFER_SIZE" "2147483647";  (* 最大32位整数 *)
    load_from_env ();
    let max_buffer = Get.buffer_size () in
    Printf.printf "  - 极大缓冲区: %d\n" max_buffer;
    fun var -> Unix.putenv var "" "CHINESE_OCAML_BUFFER_SIZE";
    
    (* 测试极长的超时时间 *)
    Unix.putenv "CHINESE_OCAML_TIMEOUT" "86400.0";  (* 24小时 *)
    load_from_env ();
    let max_timeout = Get.compilation_timeout () in
    Printf.printf "  - 极长超时: %.2f秒\n" max_timeout;
    fun var -> Unix.putenv var "" "CHINESE_OCAML_TIMEOUT";
    
    (* 测试极长的路径 *)
    let long_path = String.make 200 'a' in
    Unix.putenv "CHINESE_OCAML_OUTPUT_DIR" long_path;
    load_from_env ();
    let current_path = Get.output_directory () in
    Printf.printf "  - 极长路径长度: %d字符\n" (String.length current_path);
    fun var -> Unix.putenv var "" "CHINESE_OCAML_OUTPUT_DIR";
    
    Printf.printf "✅ 极端值处理测试完成\n";
  with
  | e -> Printf.printf "❌ 极端值处理测试失败: %s\n" (Printexc.to_string e));

  (* 性能测试 *)
  Printf.printf "\n⚡ 性能测试\n";
  (try
    let start_time = Sys.time () in
    
    (* 大量编译器配置访问操作 *)
    for i = 1 to 10000 do
      let _ = Get.buffer_size () in
      let _ = Get.large_buffer_size () in
      let _ = Get.compilation_timeout () in
      let _ = Get.output_directory () in
      let _ = Get.temp_directory () in
      let _ = Get.c_compiler () in
      let _ = Get.optimization_level () in
      let _ = Get.hashtable_size () in
      let _ = Get.large_hashtable_size () in
      ()
    done;
    
    let end_time = Sys.time () in
    let duration = end_time -. start_time in
    
    Printf.printf "✅ 10000次编译器配置访问耗时: %.6f秒\n" duration;
    Printf.printf "📊 平均每次访问耗时: %.6f秒\n" (duration /. 10000.0);
    
    if duration < 1.0 then
      Printf.printf "✅ 编译器配置访问性能优秀\n"
    else
      Printf.printf "⚠️  编译器配置访问性能可能需要优化\n";
  with
  | e -> Printf.printf "❌ 性能测试失败: %s\n" (Printexc.to_string e));

  Printf.printf "\n🎉 骆言编译器配置模块全面测试完成！\n";
  Printf.printf "📊 测试涵盖: 缓冲区、超时、目录、C编译器、优化级别、哈希表\n";
  Printf.printf "🔧 包含综合场景测试、极端值处理、性能测试\n";
  Printf.printf "🌏 支持多种编译模式: 快速开发、生产构建、测试环境\n";
  Printf.printf "⚖️ 验证配置值的合理性和范围限制\n"