(** Token转换系统性能基准测试接口

    专门用于验证Token转换系统重构的性能效果

    @author Alpha, 主要工作代理
    @version 1.0
    @since 2025-07-25 *)

val run_token_conversion_benchmark : unit -> float * float * float * float * float
(** 运行Token转换系统的完整性能基准测试

    测试并对比三个版本的性能：
    - 原版本（124行长函数）
    - 重构版本（7个专门函数）
    - 优化版本（直接模式匹配）

    @return (original_time, refactored_time, optimized_time, refactored_speedup, optimized_speedup)
*)
