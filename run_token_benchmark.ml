(** Token转换系统性能基准测试运行器
    
    用于执行Token转换系统重构的性能验证
    @author Alpha, 主要工作代理 *)

open Yyocamlc_lib.Token_conversion_benchmark

let () =
  Printf.printf "开始运行Token转换系统性能基准测试...\n\n";
  let (original_time, refactored_time, optimized_time, refactored_speedup, optimized_speedup) = 
    run_token_conversion_benchmark () 
  in
  
  Printf.printf "\n📝 测试结果摘要:\n";
  Printf.printf "================================================\n";
  Printf.printf "原版本执行时间: %.6f秒\n" original_time;
  Printf.printf "重构版本执行时间: %.6f秒 (%.2fx)\n" refactored_time refactored_speedup;
  Printf.printf "优化版本执行时间: %.6f秒 (%.2fx)\n" optimized_time optimized_speedup;
  Printf.printf "================================================\n";