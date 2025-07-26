(** Token转换系统性能基准测试 - Phase 4重构验证
    
    专门用于验证Token转换系统重构的性能效果
    对比原版本与重构版本的执行时间和内存使用
    
    @author Alpha, 主要工作代理
    @version 1.0
    @since 2025-07-25
    @refactors Issue #1333 Phase 4 *)

open Token_mapping.Token_definitions_unified

(** 创建测试用的Token样本数据 *)
let create_test_tokens () =
  [
    (* 基础语言关键字 - 高频使用 *)
    LetKeyword;
    FunKeyword;
    IfKeyword;
    ThenKeyword;
    ElseKeyword;
    MatchKeyword;
    WithKeyword;
    InKeyword;
    RecKeyword;
    AndKeyword;
    (* 语义关键字 *)
    AsKeyword;
    CombineKeyword;
    WithOpKeyword;
    WhenKeyword;
    (* 错误恢复关键字 *)
    ExceptionKeyword;
    RaiseKeyword;
    TryKeyword;
    CatchKeyword;
    (* 模块系统关键字 *)
    ModuleKeyword;
    TypeKeyword;
    RefKeyword;
    IncludeKeyword;
    (* 自然语言关键字 *)
    DefineKeyword;
    AcceptKeyword;
    MultiplyKeyword;
    DivideKeyword;
    (* 文言文关键字 *)
    HaveKeyword;
    SetKeyword;
    AsForKeyword;
    NumberKeyword;
    (* 古雅体关键字 - 低频使用 *)
    IfWenyanKeyword;
    ThenWenyanKeyword;
    AncientDefineKeyword;
    AncientEndKeyword;
  ]

(** 运行原版本转换函数的性能测试 *)
let benchmark_original_version tokens iterations =
  let start_time = Sys.time () in
  let start_memory = Gc.allocated_bytes () in

  for _i = 1 to iterations do
    List.iter
      (fun token ->
        try ignore (Token_conversion_keywords.convert_basic_keyword_token token) with _ -> ())
      tokens
  done;

  let end_time = Sys.time () in
  let end_memory = Gc.allocated_bytes () in

  let execution_time = end_time -. start_time in
  let memory_used = int_of_float (end_memory -. start_memory) in

  (execution_time, memory_used)

(** 运行重构版本转换函数的性能测试 *)
let benchmark_refactored_version tokens iterations =
  let start_time = Sys.time () in
  let start_memory = Gc.allocated_bytes () in

  for _i = 1 to iterations do
    List.iter
      (fun token ->
        try ignore (Token_conversion_keywords_refactored.convert_basic_keyword_token token)
        with _ -> ())
      tokens
  done;

  let end_time = Sys.time () in
  let end_memory = Gc.allocated_bytes () in

  let execution_time = end_time -. start_time in
  let memory_used = int_of_float (end_memory -. start_memory) in

  (execution_time, memory_used)

(** 运行优化版本转换函数的性能测试 *)
let benchmark_optimized_version tokens iterations =
  let start_time = Sys.time () in
  let start_memory = Gc.allocated_bytes () in

  for _i = 1 to iterations do
    List.iter
      (fun token ->
        try
          ignore (Token_conversion_keywords_refactored.convert_basic_keyword_token_optimized token)
        with _ -> ())
      tokens
  done;

  let end_time = Sys.time () in
  let end_memory = Gc.allocated_bytes () in

  let execution_time = end_time -. start_time in
  let memory_used = int_of_float (end_memory -. start_memory) in

  (execution_time, memory_used)

(** 生成性能测试报告 *)
let generate_performance_report () =
  let test_tokens = create_test_tokens () in
  let iterations = 10000 in

  Printf.printf "🚀 Token转换系统性能基准测试 - Phase 4重构验证\n";
  Printf.printf "================================================\n\n";

  Printf.printf "📋 测试配置:\n";
  Printf.printf "  • Token样本数量: %d个\n" (List.length test_tokens);
  Printf.printf "  • 测试迭代次数: %d次\n" iterations;
  Printf.printf "  • 总测试操作数: %d次\n" (List.length test_tokens * iterations);
  Printf.printf "\n";

  (* 运行原版本测试 *)
  Printf.printf "🔍 测试原版本 (异常驱动长函数)...\n";
  let original_time, original_memory = benchmark_original_version test_tokens iterations in
  Printf.printf "  ⏱️  执行时间: %.6f秒\n" original_time;
  Printf.printf "  💾 内存使用: %d字节\n" original_memory;
  Printf.printf "\n";

  (* 运行重构版本测试 *)
  Printf.printf "🔍 测试重构版本 (模块化函数)...\n";
  let refactored_time, refactored_memory = benchmark_refactored_version test_tokens iterations in
  Printf.printf "  ⏱️  执行时间: %.6f秒\n" refactored_time;
  Printf.printf "  💾 内存使用: %d字节\n" refactored_memory;
  Printf.printf "\n";

  (* 运行优化版本测试 *)
  Printf.printf "🔍 测试优化版本 (直接模式匹配)...\n";
  let optimized_time, optimized_memory = benchmark_optimized_version test_tokens iterations in
  Printf.printf "  ⏱️  执行时间: %.6f秒\n" optimized_time;
  Printf.printf "  💾 内存使用: %d字节\n" optimized_memory;
  Printf.printf "\n";

  (* 性能对比分析 *)
  Printf.printf "📊 性能对比分析:\n";
  Printf.printf "================================================\n";

  let refactored_speedup = original_time /. refactored_time in
  let optimized_speedup = original_time /. optimized_time in
  let memory_saving_refactored =
    (float_of_int original_memory -. float_of_int refactored_memory)
    /. float_of_int original_memory *. 100.0
  in
  let memory_saving_optimized =
    (float_of_int original_memory -. float_of_int optimized_memory)
    /. float_of_int original_memory *. 100.0
  in

  Printf.printf "\n⚡ 执行时间对比:\n";
  Printf.printf "  • 重构版本 vs 原版本: %.2fx %s\n" refactored_speedup
    (if refactored_speedup > 1.0 then "更快" else "更慢");
  Printf.printf "  • 优化版本 vs 原版本: %.2fx %s\n" optimized_speedup
    (if optimized_speedup > 1.0 then "更快" else "更慢");
  Printf.printf "  • 优化版本 vs 重构版本: %.2fx %s\n"
    (refactored_time /. optimized_time)
    (if optimized_time < refactored_time then "更快" else "更慢");

  Printf.printf "\n💾 内存使用对比:\n";
  Printf.printf "  • 重构版本节省: %.1f%%\n" memory_saving_refactored;
  Printf.printf "  • 优化版本节省: %.1f%%\n" memory_saving_optimized;

  Printf.printf "\n🎯 重构效果评估:\n";
  if refactored_speedup > 1.05 && optimized_speedup > 1.1 then Printf.printf "  ✅ 重构成功! 显著提升了性能\n"
  else if refactored_speedup > 0.95 && optimized_speedup > 1.0 then
    Printf.printf "  ✅ 重构良好! 保持或改善了性能\n"
  else Printf.printf "  ⚠️  需要进一步优化\n";

  Printf.printf "\n📈 建议:\n";
  if optimized_speedup > refactored_speedup *. 1.2 then Printf.printf "  • 建议逐步迁移到优化版本以获得最佳性能\n";
  Printf.printf "  • 重构版本提供了更好的可维护性\n";
  Printf.printf "  • 优化版本提供了最佳的运行时性能\n";

  Printf.printf "\n================================================\n";
  Printf.printf "✅ Token转换系统性能基准测试完成!\n";

  (* 返回结果用于记录 *)
  (original_time, refactored_time, optimized_time, refactored_speedup, optimized_speedup)

(** 公共接口函数 *)
let run_token_conversion_benchmark () = generate_performance_report ()
