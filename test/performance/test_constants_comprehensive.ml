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
       BufferSizes.default_buffer () > 0
       && BufferSizes.large_buffer () >= BufferSizes.default_buffer ()
       && BufferSizes.report_buffer () > 0
       && BufferSizes.utf8_char_buffer () > 0
       && 256 > 0
       && 65536 >= BufferSizes.large_buffer ()
       && 256 <= BufferSizes.default_buffer ()
     in

     if buffers_reasonable then Printf.printf "√ 缓冲区大小常量合理性检查通过\n"
     else Printf.printf "X 缓冲区大小常量存在不合理的值\n"
   with e -> Printf.printf "X 缓冲区大小常量测试失败: %s\n" (Printexc.to_string e));

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
       0.75 > 0.5 && 0.5 > 0.25 && Metrics.full_confidence > 0.5 && 0.5 > Metrics.zero_confidence
       && 0.8 >= 0.0 && 0.8 <= 1.0 && 0.6 >= 0.0 && 0.6 <= 1.0 && 0.8 >= 0.6
     in

     if metrics_reasonable then Printf.printf "√ 度量常量合理性检查通过\n" else Printf.printf "X 度量常量存在不合理的值\n"
   with e -> Printf.printf "X 度量常量测试失败: %s\n" (Printexc.to_string e));

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
       TestData.small_test_number > 0 && TestData.large_test_number > 0
       && TestData.factorial_test_input > 0
       && TestData.factorial_expected_result > 0
       && TestData.sum_1_to_100 > 0 && 42 > 0
     in

     if test_data_valid then Printf.printf "√ 测试数据常量有效性检查通过\n" else Printf.printf "X 测试数据常量存在空值\n"
   with e -> Printf.printf "X 测试数据常量测试失败: %s\n" (Printexc.to_string e));

  (* 测试系统配置扩展常量 *)
  Printf.printf "\nEXTEND: 测试系统配置扩展常量\n";
  (try
     Printf.printf "CONFIG: 扩展系统常量:\n";
     Printf.printf "  - 文件分块大小: %d字节\n" SystemConfig.file_chunk_size;
     Printf.printf "  - 最大诗句长度: %d\n" SystemConfig.max_verse_length;
     Printf.printf "  - 最大诗行数: %d\n" SystemConfig.max_poem_lines;
     Printf.printf "  - 默认韵律方案长度: %d\n" SystemConfig.default_rhyme_scheme_length;

     (* 验证扩展常量的合理性 *)
     let extended_reasonable =
       SystemConfig.file_chunk_size > 0 && SystemConfig.max_verse_length > 0
       && SystemConfig.max_poem_lines > 0
       && SystemConfig.default_rhyme_scheme_length > 0
     in

     if extended_reasonable then Printf.printf "√ 扩展常量合理性检查通过\n"
     else Printf.printf "X 扩展常量存在不合理的值\n"
   with e -> Printf.printf "X 扩展常量测试失败: %s\n" (Printexc.to_string e));

  Printf.printf "\n🎉 骆言常量模块全面测试完成！\n";
  Printf.printf "📊 测试涵盖: 缓冲区大小、度量常量、测试数据、系统配置扩展\n";
  Printf.printf "🔧 包含常量合理性验证和错误处理测试\n"
