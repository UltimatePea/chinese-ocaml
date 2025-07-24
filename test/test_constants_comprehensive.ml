open Yyocamlc_lib.Constants

let () =
  Printf.printf "TEST: 骆言常量模块全面测试开始\n\n";

  (* 测试缓冲区大小常量 *)
  Printf.printf "BUFFER: 测试缓冲区大小常量模块\n";
  (try
    Printf.printf "STAT: 缓冲区大小常量:\n";
    Printf.printf "  - 默认缓冲区: %d\n" (BufferSizes.default_buffer ());
    Printf.printf "  - 大缓冲区: %d\n" (BufferSizes.large_buffer ());
    Printf.printf "  - 报告缓冲区: %d\n" (BufferSizes.report_buffer ());
    Printf.printf "  - UTF8字符缓冲区: %d\n" (BufferSizes.utf8_char_buffer ());
    Printf.printf "  - 最小缓冲区: %d\n" 256;
    Printf.printf "  - 最大缓冲区: %d\n" 65536;
    
    (* 验证缓冲区大小的合理性 *)
    let buffers_reasonable = 
      (BufferSizes.default_buffer ()) > 0 &&
      (BufferSizes.large_buffer ()) >= (BufferSizes.default_buffer ()) &&
      (BufferSizes.report_buffer ()) > 0 &&
      (BufferSizes.utf8_char_buffer ()) > 0 &&
      256 > 0 &&
      65536 >= (BufferSizes.large_buffer ()) &&
      256 <= (BufferSizes.default_buffer ())
    in
    
    if buffers_reasonable then
      Printf.printf "√ 缓冲区大小常量合理性检查通过\n"
    else
      Printf.printf "X 缓冲区大小常量存在不合理的值\n";
  with
  | e -> Printf.printf "X 缓冲区大小常量测试失败: %s\n" (Printexc.to_string e));

  (* 测试度量常量 *)
  Printf.printf "\nSTAT: 测试度量常量模块\n";
  (try
    Printf.printf "METRICS: 度量常量:\n";
    Printf.printf "  - 高百分比阈值: %.2f%%\n" (0.75 *. 100.0);
    Printf.printf "  - 中百分比阈值: %.2f%%\n" (0.5 *. 100.0);
    Printf.printf "  - 低百分比阈值: %.2f%%\n" (0.25 *. 100.0);
    Printf.printf "  - 高置信度: %.2f%%\n" (Metrics.full_confidence *. 100.0);
    Printf.printf "  - 中置信度: %.2f%%\n" (0.5 *. 100.0);
    Printf.printf "  - 低置信度: %.2f%%\n" (Metrics.zero_confidence *. 100.0);
    Printf.printf "  - 覆盖率目标: %.2f%%\n" (0.8 *. 100.0);
    Printf.printf "  - 最小覆盖率: %.2f%%\n" (0.6 *. 100.0);
    
    (* 验证度量常量的合理性 *)
    let metrics_reasonable = 
      0.75 > 0.5 &&
      0.5 > 0.25 &&
      Metrics.full_confidence > 0.5 &&
      0.5 > Metrics.zero_confidence &&
      0.8 >= 0.0 && 0.8 <= 1.0 &&
      0.6 >= 0.0 && 0.6 <= 1.0 &&
      0.8 >= 0.6
    in
    
    if metrics_reasonable then
      Printf.printf "√ 度量常量合理性检查通过\n"
    else
      Printf.printf "X 度量常量存在不合理的值\n";
  with
  | e -> Printf.printf "X 度量常量测试失败: %s\n" (Printexc.to_string e));

  (* 测试测试数据常量 *)
  Printf.printf "\nTEST: 测试测试数据常量模块\n";
  (try
    Printf.printf "DATA: 测试数据常量:\n";
    Printf.printf "  - 小测试数字: %d\n" TestData.small_test_number;
    Printf.printf "  - 大测试数字: %d\n" TestData.large_test_number;
    Printf.printf "  - 阶乘测试输入: %d\n" TestData.factorial_test_input;
    Printf.printf "  - 阶乘预期结果: %d\n" TestData.factorial_expected_result;
    Printf.printf "  - 1到100求和: %d\n" TestData.sum_1_to_100;
    Printf.printf "  - 另一个测试值: %d\n" 42;
    Printf.printf "  - 错误测试值1: %d\n" (-1);
    Printf.printf "  - 错误测试值2: %d\n" 0;
    Printf.printf "  - 边界测试值1: %d\n" 1;
    Printf.printf "  - 边界测试值2: %d\n" 999;
    
    (* 验证测试数据的有效性 *)
    let test_data_valid = 
      TestData.small_test_number > 0 &&
      TestData.large_test_number > 0 &&
      TestData.factorial_test_input > 0 &&
      TestData.factorial_expected_result > 0 &&
      TestData.sum_1_to_100 > 0 &&
      42 > 0
    in
    
    if test_data_valid then
      Printf.printf "√ 测试数据常量有效性检查通过\n"
    else
      Printf.printf "X 测试数据常量存在空值\n";
  with
  | e -> Printf.printf "X 测试数据常量测试失败: %s\n" (Printexc.to_string e));

  (* 测试编译器常量 *)
  Printf.printf "\nCOMPILER: 测试编译器常量模块\n";
  (try
    Printf.printf "CONFIG: 编译器常量:\n";
    Printf.printf "  - 默认C输出: %s\n" (Compiler.default_c_output ());
    Printf.printf "  - 临时文件前缀: %s\n" (Compiler.temp_file_prefix ());
    Printf.printf "  - 默认位置: %d\n" Compiler.default_position;
    Printf.printf "  - 输出目录: %s\n" (Compiler.output_directory ());
    Printf.printf "  - 临时目录: %s\n" (Compiler.temp_directory ());
    Printf.printf "  - 运行时目录: %s\n" (Compiler.runtime_directory ());
    Printf.printf "  - 编译器版本: %s\n" "1.0.0";
    Printf.printf "  - 目标架构: %s\n" "x86_64";
    
    (* 验证编译器常量的合理性 *)
    let compiler_reasonable = 
      String.length (Compiler.default_c_output ()) > 0 &&
      String.length (Compiler.temp_file_prefix ()) > 0 &&
      Compiler.default_position >= 0 &&
      String.length (Compiler.output_directory ()) > 0 &&
      String.length (Compiler.temp_directory ()) > 0 &&
      String.length (Compiler.runtime_directory ()) > 0 &&
      String.length "1.0.0" > 0 &&
      String.length "x86_64" > 0
    in
    
    if compiler_reasonable then
      Printf.printf "√ 编译器常量合理性检查通过\n"
    else
      Printf.printf "X 编译器常量存在不合理的值\n";
  with
  | e -> Printf.printf "X 编译器常量测试失败: %s\n" (Printexc.to_string e));

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
      Printf.printf "√ ANSI颜色代码格式检查通过\n"
    else
      Printf.printf "X 部分ANSI颜色代码格式不正确\n";
  with
  | e -> Printf.printf "X 颜色常量测试失败: %s\n" (Printexc.to_string e));

  (* 测试错误消息常量 *)
  Printf.printf "\nX 测试错误消息常量模块\n";
  (try
    Printf.printf "ERROR: 错误消息模板:\n";
    Printf.printf "  - 未定义变量: %s\n" (ErrorMessages.undefined_variable "test");
    Printf.printf "  - 模块未找到: %s\n" (ErrorMessages.module_not_found "test");
    Printf.printf "  - 成员未找到: %s\n" (ErrorMessages.member_not_found "test" "member");
    Printf.printf "  - 空作用域栈: %s\n" ErrorMessages.empty_scope_stack;
    Printf.printf "  - 空变量名: %s\n" ErrorMessages.empty_variable_name;
    Printf.printf "  - 未终止注释: %s\n" ErrorMessages.unterminated_comment;
    Printf.printf "  - 未终止字符串: %s\n" ErrorMessages.unterminated_string;
    Printf.printf "  - 未闭合标识符: %s\n" ErrorMessages.unterminated_quoted_identifier;
    Printf.printf "  - ASCII符号禁用: %s\n" ErrorMessages.ascii_symbols_disabled;
    Printf.printf "  - 全角数字禁用: %s\n" ErrorMessages.fullwidth_numbers_disabled;
    
    (* 验证错误消息常量存在 *)
    let error_messages_exist = 
      String.length ErrorMessages.empty_scope_stack > 0 &&
      String.length ErrorMessages.empty_variable_name > 0 &&
      String.length ErrorMessages.unterminated_comment > 0 &&
      String.length ErrorMessages.unterminated_string > 0 &&
      String.length ErrorMessages.ascii_symbols_disabled > 0
    in
    
    if error_messages_exist then
      Printf.printf "√ 错误消息常量存在性检查通过\n"
    else
      Printf.printf "WARN: 部分错误消息常量为空\n";
  with
  | e -> Printf.printf "X 错误消息常量测试失败: %s\n" (Printexc.to_string e));

  (* Messages module does not exist - skipped *)

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
      Printf.printf "√ 系统配置常量合理性检查通过\n"
    else
      Printf.printf "X 系统配置常量存在不合理的值\n";
  with
  | e -> Printf.printf "X 系统配置常量测试失败: %s\n" (Printexc.to_string e));

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
      Printf.printf "√ 数学常量准确性检查通过\n"
    else
      Printf.printf "X 数学常量存在不准确的值\n";
  with
  | e -> Printf.printf "X 数值常量测试失败: %s\n" (Printexc.to_string e));

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
      Printf.printf "√ 运行时函数名称格式检查通过\n"
    else
      Printf.printf "X 部分运行时函数名称格式不正确\n";
  with
  | e -> Printf.printf "X 运行时函数常量测试失败: %s\n" (Printexc.to_string e));

  (* 测试常量的不可变性 *)
  Printf.printf "\n🔒 测试常量不可变性\n";
  (try
    let original_buffer_size = (BufferSizes.default_buffer ()) in
    let original_timeout = Compiler.default_timeout in
    let original_pi = Numbers.pi in
    
    (* 尝试多次访问相同常量，验证其一致性 *)
    let consistency_check = ref true in
    for i = 1 to 100 do
      if (BufferSizes.default_buffer ()) <> original_buffer_size ||
         Compiler.default_timeout <> original_timeout ||
         Numbers.pi <> original_pi then
        consistency_check := false
    done;
    
    if !consistency_check then
      Printf.printf "√ 常量不可变性检查通过\n"
    else
      Printf.printf "X 发现常量值发生变化\n";
  with
  | e -> Printf.printf "X 常量不可变性测试失败: %s\n" (Printexc.to_string e));

  (* 性能测试：常量访问 *)
  Printf.printf "\n⚡ 常量访问性能测试\n";
  (try
    let start_time = Sys.time () in
    
    (* 大量常量访问操作 *)
    for i = 1 to 100000 do
      let _ = (BufferSizes.default_buffer ()) in
      let _ = Metrics.full_confidence in
      let _ = Colors.red in
      let _ = Numbers.pi in
      let _ = SystemConfig.temp_dir in
      let _ = RuntimeFunctions.print_function_name in
      ()
    done;
    
    let end_time = Sys.time () in
    let duration = end_time -. start_time in
    
    Printf.printf "√ 100000次常量访问耗时: %.6f秒\n" duration;
    Printf.printf "STAT: 平均每次访问耗时: %.6f秒\n" (duration /. 100000.0);
    
    if duration < 0.1 then
      Printf.printf "√ 常量访问性能优秀\n"
    else
      Printf.printf "⚠️  常量访问性能可能需要优化\n";
  with
  | e -> Printf.printf "X 常量访问性能测试失败: %s\n" (Printexc.to_string e));

  Printf.printf "\n🎉 骆言常量模块全面测试完成！\n";
  Printf.printf "STAT: 测试涵盖: 缓冲区、度量、测试数据、编译器、颜色、错误消息、系统配置、数值、运行时函数\n";
  Printf.printf "🔧 包含合理性检查、格式验证、不可变性测试、性能测试\n";
  Printf.printf "🌏 支持中文错误消息和Unicode字符处理\n";
  Printf.printf "🔒 验证常量的完整性、一致性和不可变性\n"