open Yyocamlc_lib.Constants

let () =
  Printf.printf "🧪 骆言常量模块全面测试开始\n\n";

  (* 测试缓冲区大小常量 *)
  Printf.printf "💾 测试缓冲区大小常量模块\n";
  (try
    Printf.printf "📊 缓冲区大小常量:\n";
    Printf.printf "  - 默认缓冲区: %d\n" BufferSizes.default_buffer_size;
    Printf.printf "  - 大缓冲区: %d\n" BufferSizes.large_buffer_size;
    Printf.printf "  - 报告缓冲区: %d\n" BufferSizes.report_buffer_size;
    Printf.printf "  - UTF8字符缓冲区: %d\n" BufferSizes.utf8_char_buffer_size;
    Printf.printf "  - 最小缓冲区: %d\n" BufferSizes.min_buffer_size;
    Printf.printf "  - 最大缓冲区: %d\n" BufferSizes.max_buffer_size;
    
    (* 验证缓冲区大小的合理性 *)
    let buffers_reasonable = 
      BufferSizes.default_buffer_size > 0 &&
      BufferSizes.large_buffer_size >= BufferSizes.default_buffer_size &&
      BufferSizes.report_buffer_size > 0 &&
      BufferSizes.utf8_char_buffer_size > 0 &&
      BufferSizes.min_buffer_size > 0 &&
      BufferSizes.max_buffer_size >= BufferSizes.large_buffer_size &&
      BufferSizes.min_buffer_size <= BufferSizes.default_buffer_size
    in
    
    if buffers_reasonable then
      Printf.printf "✅ 缓冲区大小常量合理性检查通过\n"
    else
      Printf.printf "❌ 缓冲区大小常量存在不合理的值\n";
  with
  | e -> Printf.printf "❌ 缓冲区大小常量测试失败: %s\n" (Printexc.to_string e));

  (* 测试度量常量 *)
  Printf.printf "\n📊 测试度量常量模块\n";
  (try
    Printf.printf "📈 度量常量:\n";
    Printf.printf "  - 高百分比阈值: %.2f%%\n" (Metrics.high_percentage_threshold *. 100.0);
    Printf.printf "  - 中百分比阈值: %.2f%%\n" (Metrics.medium_percentage_threshold *. 100.0);
    Printf.printf "  - 低百分比阈值: %.2f%%\n" (Metrics.low_percentage_threshold *. 100.0);
    Printf.printf "  - 高置信度: %.2f%%\n" (Metrics.high_confidence *. 100.0);
    Printf.printf "  - 中置信度: %.2f%%\n" (Metrics.medium_confidence *. 100.0);
    Printf.printf "  - 低置信度: %.2f%%\n" (Metrics.low_confidence *. 100.0);
    Printf.printf "  - 覆盖率目标: %.2f%%\n" (Metrics.coverage_target *. 100.0);
    Printf.printf "  - 最小覆盖率: %.2f%%\n" (Metrics.minimum_coverage *. 100.0);
    
    (* 验证度量常量的合理性 *)
    let metrics_reasonable = 
      Metrics.high_percentage_threshold > Metrics.medium_percentage_threshold &&
      Metrics.medium_percentage_threshold > Metrics.low_percentage_threshold &&
      Metrics.high_confidence > Metrics.medium_confidence &&
      Metrics.medium_confidence > Metrics.low_confidence &&
      Metrics.coverage_target >= 0.0 && Metrics.coverage_target <= 1.0 &&
      Metrics.minimum_coverage >= 0.0 && Metrics.minimum_coverage <= 1.0 &&
      Metrics.coverage_target >= Metrics.minimum_coverage
    in
    
    if metrics_reasonable then
      Printf.printf "✅ 度量常量合理性检查通过\n"
    else
      Printf.printf "❌ 度量常量存在不合理的值\n";
  with
  | e -> Printf.printf "❌ 度量常量测试失败: %s\n" (Printexc.to_string e));

  (* 测试测试数据常量 *)
  Printf.printf "\n🧪 测试测试数据常量模块\n";
  (try
    Printf.printf "🔧 测试数据常量:\n";
    Printf.printf "  - 示例输入1: %s\n" TestData.sample_input_1;
    Printf.printf "  - 示例输入2: %s\n" TestData.sample_input_2;
    Printf.printf "  - 示例输入3: %s\n" TestData.sample_input_3;
    Printf.printf "  - 预期输出1: %s\n" TestData.expected_output_1;
    Printf.printf "  - 预期输出2: %s\n" TestData.expected_output_2;
    Printf.printf "  - 预期输出3: %s\n" TestData.expected_output_3;
    Printf.printf "  - 错误输入1: %s\n" TestData.error_input_1;
    Printf.printf "  - 错误输入2: %s\n" TestData.error_input_2;
    Printf.printf "  - 边界输入1: %s\n" TestData.boundary_input_1;
    Printf.printf "  - 边界输入2: %s\n" TestData.boundary_input_2;
    
    (* 验证测试数据的有效性 *)
    let test_data_valid = 
      String.length TestData.sample_input_1 > 0 &&
      String.length TestData.sample_input_2 > 0 &&
      String.length TestData.sample_input_3 > 0 &&
      String.length TestData.expected_output_1 > 0 &&
      String.length TestData.expected_output_2 > 0 &&
      String.length TestData.expected_output_3 > 0
    in
    
    if test_data_valid then
      Printf.printf "✅ 测试数据常量有效性检查通过\n"
    else
      Printf.printf "❌ 测试数据常量存在空值\n";
  with
  | e -> Printf.printf "❌ 测试数据常量测试失败: %s\n" (Printexc.to_string e));

  (* 测试编译器常量 *)
  Printf.printf "\n🔧 测试编译器常量模块\n";
  (try
    Printf.printf "⚙️ 编译器常量:\n";
    Printf.printf "  - 默认超时: %.2f秒\n" Compiler.default_timeout;
    Printf.printf "  - 测试超时: %.2f秒\n" Compiler.test_timeout;
    Printf.printf "  - 最大迭代: %d\n" Compiler.max_iterations;
    Printf.printf "  - 最大递归深度: %d\n" Compiler.max_recursion_depth;
    Printf.printf "  - 默认优化级别: %d\n" Compiler.default_optimization_level;
    Printf.printf "  - 最大优化级别: %d\n" Compiler.max_optimization_level;
    Printf.printf "  - 编译器版本: %s\n" Compiler.compiler_version;
    Printf.printf "  - 目标架构: %s\n" Compiler.target_arch;
    
    (* 验证编译器常量的合理性 *)
    let compiler_reasonable = 
      Compiler.default_timeout > 0.0 &&
      Compiler.test_timeout > 0.0 &&
      Compiler.max_iterations > 0 &&
      Compiler.max_recursion_depth > 0 &&
      Compiler.default_optimization_level >= 0 &&
      Compiler.max_optimization_level >= Compiler.default_optimization_level &&
      String.length Compiler.compiler_version > 0 &&
      String.length Compiler.target_arch > 0
    in
    
    if compiler_reasonable then
      Printf.printf "✅ 编译器常量合理性检查通过\n"
    else
      Printf.printf "❌ 编译器常量存在不合理的值\n";
  with
  | e -> Printf.printf "❌ 编译器常量测试失败: %s\n" (Printexc.to_string e));

  (* 测试颜色常量 *)
  Printf.printf "\n🎨 测试颜色常量模块\n";
  (try
    Printf.printf "🌈 ANSI颜色常量测试:\n";
    Printf.printf "  %s红色文本%s\n" Colors.red Colors.reset;
    Printf.printf "  %s绿色文本%s\n" Colors.green Colors.reset;
    Printf.printf "  %s蓝色文本%s\n" Colors.blue Colors.reset;
    Printf.printf "  %s黄色文本%s\n" Colors.yellow Colors.reset;
    Printf.printf "  %s紫色文本%s\n" Colors.magenta Colors.reset;
    Printf.printf "  %s青色文本%s\n" Colors.cyan Colors.reset;
    Printf.printf "  %s白色文本%s\n" Colors.white Colors.reset;
    Printf.printf "  %s粗体文本%s\n" Colors.bold Colors.reset;
    Printf.printf "  %s斜体文本%s\n" Colors.italic Colors.reset;
    Printf.printf "  %s下划线文本%s\n" Colors.underline Colors.reset;
    
    (* 验证颜色代码格式 *)
    let color_codes = [
      ("红色", Colors.red);
      ("绿色", Colors.green);
      ("蓝色", Colors.blue);
      ("黄色", Colors.yellow);
      ("紫色", Colors.magenta);
      ("青色", Colors.cyan);
      ("白色", Colors.white);
      ("重置", Colors.reset);
      ("粗体", Colors.bold);
      ("斜体", Colors.italic);
      ("下划线", Colors.underline);
    ] in
    
    let all_codes_valid = List.for_all (fun (name, code) ->
      String.length code > 0 && String.get code 0 = '\027'
    ) color_codes in
    
    if all_codes_valid then
      Printf.printf "✅ ANSI颜色代码格式检查通过\n"
    else
      Printf.printf "❌ 部分ANSI颜色代码格式不正确\n";
  with
  | e -> Printf.printf "❌ 颜色常量测试失败: %s\n" (Printexc.to_string e));

  (* 测试错误消息常量 *)
  Printf.printf "\n❌ 测试错误消息常量模块\n";
  (try
    Printf.printf "📝 错误消息模板:\n";
    Printf.printf "  - 语法错误: %s\n" ErrorMessages.syntax_error_template;
    Printf.printf "  - 类型错误: %s\n" ErrorMessages.type_error_template;
    Printf.printf "  - 运行时错误: %s\n" ErrorMessages.runtime_error_template;
    Printf.printf "  - 编译错误: %s\n" ErrorMessages.compilation_error_template;
    Printf.printf "  - 文件未找到: %s\n" ErrorMessages.file_not_found_template;
    Printf.printf "  - 权限错误: %s\n" ErrorMessages.permission_error_template;
    Printf.printf "  - 内存错误: %s\n" ErrorMessages.memory_error_template;
    Printf.printf "  - 网络错误: %s\n" ErrorMessages.network_error_template;
    Printf.printf "  - 配置错误: %s\n" ErrorMessages.config_error_template;
    Printf.printf "  - 验证错误: %s\n" ErrorMessages.validation_error_template;
    
    (* 验证错误消息模板包含占位符 *)
    let templates_with_placeholders = [
      ("语法错误", ErrorMessages.syntax_error_template);
      ("类型错误", ErrorMessages.type_error_template);
      ("运行时错误", ErrorMessages.runtime_error_template);
      ("编译错误", ErrorMessages.compilation_error_template);
    ] in
    
    let templates_valid = List.for_all (fun (name, template) ->
      String.length template > 0 && 
      (String.contains template '%' || String.contains template '{')
    ) templates_with_placeholders in
    
    if templates_valid then
      Printf.printf "✅ 错误消息模板格式检查通过\n"
    else
      Printf.printf "⚠️  部分错误消息模板可能缺少占位符\n";
  with
  | e -> Printf.printf "❌ 错误消息常量测试失败: %s\n" (Printexc.to_string e));

  (* 测试消息常量 *)
  Printf.printf "\n💬 测试消息常量模块\n";
  (try
    Printf.printf "📢 消息常量:\n";
    Printf.printf "  - 启动消息: %s\n" Messages.startup_message;
    Printf.printf "  - 完成消息: %s\n" Messages.completion_message;
    Printf.printf "  - 进度消息: %s\n" Messages.progress_message;
    Printf.printf "  - 警告消息: %s\n" Messages.warning_message;
    Printf.printf "  - 信息消息: %s\n" Messages.info_message;
    Printf.printf "  - 成功消息: %s\n" Messages.success_message;
    Printf.printf "  - 失败消息: %s\n" Messages.failure_message;
    Printf.printf "  - 统计消息: %s\n" Messages.statistics_message;
    Printf.printf "  - 帮助消息: %s\n" Messages.help_message;
    Printf.printf "  - 版本消息: %s\n" Messages.version_message;
    
    (* 验证消息内容的完整性 *)
    let messages = [
      ("启动", Messages.startup_message);
      ("完成", Messages.completion_message);
      ("进度", Messages.progress_message);
      ("警告", Messages.warning_message);
      ("信息", Messages.info_message);
      ("成功", Messages.success_message);
      ("失败", Messages.failure_message);
      ("统计", Messages.statistics_message);
      ("帮助", Messages.help_message);
      ("版本", Messages.version_message);
    ] in
    
    let all_messages_valid = List.for_all (fun (name, msg) ->
      String.length msg > 0
    ) messages in
    
    if all_messages_valid then
      Printf.printf "✅ 消息常量完整性检查通过\n"
    else
      Printf.printf "❌ 部分消息常量为空\n";
  with
  | e -> Printf.printf "❌ 消息常量测试失败: %s\n" (Printexc.to_string e));

  (* 测试系统配置常量 *)
  Printf.printf "\n🔧 测试系统配置常量模块\n";
  (try
    Printf.printf "⚙️ 系统配置常量:\n";
    Printf.printf "  - 默认哈希表大小: %d\n" SystemConfig.default_hashtable_size;
    Printf.printf "  - 大哈希表大小: %d\n" SystemConfig.large_hashtable_size;
    Printf.printf "  - 最大文件大小: %d字节\n" SystemConfig.max_file_size;
    Printf.printf "  - 默认编码: %s\n" SystemConfig.default_encoding;
    Printf.printf "  - 行结束符: %s\n" (String.escaped SystemConfig.line_ending);
    Printf.printf "  - 路径分隔符: %s\n" (String.make 1 SystemConfig.path_separator);
    Printf.printf "  - 临时目录: %s\n" SystemConfig.temp_dir;
    Printf.printf "  - 配置目录: %s\n" SystemConfig.config_dir;
    Printf.printf "  - 缓存目录: %s\n" SystemConfig.cache_dir;
    Printf.printf "  - 日志目录: %s\n" SystemConfig.log_dir;
    
    (* 验证系统配置的合理性 *)
    let system_config_reasonable = 
      SystemConfig.default_hashtable_size > 0 &&
      SystemConfig.large_hashtable_size >= SystemConfig.default_hashtable_size &&
      SystemConfig.max_file_size > 0 &&
      String.length SystemConfig.default_encoding > 0 &&
      String.length SystemConfig.temp_dir > 0 &&
      String.length SystemConfig.config_dir > 0 &&
      String.length SystemConfig.cache_dir > 0 &&
      String.length SystemConfig.log_dir > 0
    in
    
    if system_config_reasonable then
      Printf.printf "✅ 系统配置常量合理性检查通过\n"
    else
      Printf.printf "❌ 系统配置常量存在不合理的值\n";
  with
  | e -> Printf.printf "❌ 系统配置常量测试失败: %s\n" (Printexc.to_string e));

  (* 测试数值常量 *)
  Printf.printf "\n🔢 测试数值常量模块\n";
  (try
    Printf.printf "🧮 数值常量:\n";
    Printf.printf "  - π: %.6f\n" Numbers.pi;
    Printf.printf "  - e: %.6f\n" Numbers.e;
    Printf.printf "  - 黄金比例: %.6f\n" Numbers.golden_ratio;
    Printf.printf "  - 最大整数: %d\n" Numbers.max_int_value;
    Printf.printf "  - 最小整数: %d\n" Numbers.min_int_value;
    Printf.printf "  - 最大浮点数: %g\n" Numbers.max_float_value;
    Printf.printf "  - 最小浮点数: %g\n" Numbers.min_float_value;
    Printf.printf "  - 浮点精度: %g\n" Numbers.float_precision;
    Printf.printf "  - 零阈值: %g\n" Numbers.zero_threshold;
    Printf.printf "  - 无穷大: %g\n" Numbers.infinity;
    
    (* 验证数学常量的准确性 *)
    let math_constants_accurate = 
      abs_float (Numbers.pi -. 3.141592653589793) < 1e-10 &&
      abs_float (Numbers.e -. 2.718281828459045) < 1e-10 &&
      abs_float (Numbers.golden_ratio -. 1.618033988749895) < 1e-10 &&
      Numbers.max_int_value > 0 &&
      Numbers.min_int_value < 0 &&
      Numbers.max_float_value > 0.0 &&
      Numbers.min_float_value < 0.0 &&
      Numbers.float_precision > 0.0 &&
      Numbers.zero_threshold > 0.0 &&
      Numbers.infinity > Numbers.max_float_value
    in
    
    if math_constants_accurate then
      Printf.printf "✅ 数学常量准确性检查通过\n"
    else
      Printf.printf "❌ 数学常量存在不准确的值\n";
  with
  | e -> Printf.printf "❌ 数值常量测试失败: %s\n" (Printexc.to_string e));

  (* 测试运行时函数常量 *)
  Printf.printf "\n🔧 测试运行时函数常量模块\n";
  (try
    Printf.printf "🛠️ C运行时函数名称:\n";
    Printf.printf "  - 打印函数: %s\n" RuntimeFunctions.print_function_name;
    Printf.printf "  - 读取函数: %s\n" RuntimeFunctions.read_function_name;
    Printf.printf "  - 内存分配: %s\n" RuntimeFunctions.malloc_function_name;
    Printf.printf "  - 内存释放: %s\n" RuntimeFunctions.free_function_name;
    Printf.printf "  - 字符串比较: %s\n" RuntimeFunctions.strcmp_function_name;
    Printf.printf "  - 字符串复制: %s\n" RuntimeFunctions.strcpy_function_name;
    Printf.printf "  - 字符串长度: %s\n" RuntimeFunctions.strlen_function_name;
    Printf.printf "  - 数学库前缀: %s\n" RuntimeFunctions.math_lib_prefix;
    Printf.printf "  - 系统调用前缀: %s\n" RuntimeFunctions.syscall_prefix;
    Printf.printf "  - 异常处理函数: %s\n" RuntimeFunctions.exception_handler_name;
    
    (* 验证函数名称的有效性 *)
    let function_names = [
      ("打印", RuntimeFunctions.print_function_name);
      ("读取", RuntimeFunctions.read_function_name);
      ("分配", RuntimeFunctions.malloc_function_name);
      ("释放", RuntimeFunctions.free_function_name);
      ("比较", RuntimeFunctions.strcmp_function_name);
      ("复制", RuntimeFunctions.strcpy_function_name);
      ("长度", RuntimeFunctions.strlen_function_name);
      ("异常", RuntimeFunctions.exception_handler_name);
    ] in
    
    let all_names_valid = List.for_all (fun (desc, name) ->
      String.length name > 0 && 
      String.for_all (function 
        | 'a'..'z' | 'A'..'Z' | '0'..'9' | '_' -> true 
        | _ -> false
      ) name
    ) function_names in
    
    if all_names_valid then
      Printf.printf "✅ 运行时函数名称格式检查通过\n"
    else
      Printf.printf "❌ 部分运行时函数名称格式不正确\n";
  with
  | e -> Printf.printf "❌ 运行时函数常量测试失败: %s\n" (Printexc.to_string e));

  (* 测试常量的不可变性 *)
  Printf.printf "\n🔒 测试常量不可变性\n";
  (try
    let original_buffer_size = BufferSizes.default_buffer_size in
    let original_timeout = Compiler.default_timeout in
    let original_pi = Numbers.pi in
    
    (* 尝试多次访问相同常量，验证其一致性 *)
    let consistency_check = ref true in
    for i = 1 to 100 do
      if BufferSizes.default_buffer_size <> original_buffer_size ||
         Compiler.default_timeout <> original_timeout ||
         Numbers.pi <> original_pi then
        consistency_check := false
    done;
    
    if !consistency_check then
      Printf.printf "✅ 常量不可变性检查通过\n"
    else
      Printf.printf "❌ 发现常量值发生变化\n";
  with
  | e -> Printf.printf "❌ 常量不可变性测试失败: %s\n" (Printexc.to_string e));

  (* 性能测试：常量访问 *)
  Printf.printf "\n⚡ 常量访问性能测试\n";
  (try
    let start_time = Sys.time () in
    
    (* 大量常量访问操作 *)
    for i = 1 to 100000 do
      let _ = BufferSizes.default_buffer_size in
      let _ = Metrics.high_confidence in
      let _ = Colors.red in
      let _ = Numbers.pi in
      let _ = SystemConfig.temp_dir in
      let _ = RuntimeFunctions.print_function_name in
      ()
    done;
    
    let end_time = Sys.time () in
    let duration = end_time -. start_time in
    
    Printf.printf "✅ 100000次常量访问耗时: %.6f秒\n" duration;
    Printf.printf "📊 平均每次访问耗时: %.6f秒\n" (duration /. 100000.0);
    
    if duration < 0.1 then
      Printf.printf "✅ 常量访问性能优秀\n"
    else
      Printf.printf "⚠️  常量访问性能可能需要优化\n";
  with
  | e -> Printf.printf "❌ 常量访问性能测试失败: %s\n" (Printexc.to_string e));

  Printf.printf "\n🎉 骆言常量模块全面测试完成！\n";
  Printf.printf "📊 测试涵盖: 缓冲区、度量、测试数据、编译器、颜色、错误消息、系统配置、数值、运行时函数\n";
  Printf.printf "🔧 包含合理性检查、格式验证、不可变性测试、性能测试\n";
  Printf.printf "🌏 支持中文错误消息和Unicode字符处理\n";
  Printf.printf "🔒 验证常量的完整性、一致性和不可变性\n"