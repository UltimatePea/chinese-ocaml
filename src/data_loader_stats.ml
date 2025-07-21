(* 数据加载器统计模块
   
   收集和报告数据加载的统计信息，
   帮助监控系统性能和缓存效率。 *)

open Printf

(** 统计计数器 *)
let load_count = ref 0

let cache_hits = ref 0
let cache_misses = ref 0
let error_count = ref 0

(** 增加统计计数 *)
let increment_load () = incr load_count

let increment_cache_hit () = incr cache_hits
let increment_cache_miss () = incr cache_misses
let increment_error () = incr error_count

(** 重置统计信息 *)
let reset_stats () =
  load_count := 0;
  cache_hits := 0;
  cache_misses := 0;
  error_count := 0

(** 获取统计信息 *)
let get_stats () = (!load_count, !cache_hits, !cache_misses, !error_count)

(** 计算缓存命中率 *)
let cache_hit_rate () =
  if !load_count > 0 then float_of_int !cache_hits /. float_of_int !load_count *. 100.0 else 0.0

(** 打印统计信息 *)
let print_stats () =
  printf "数据加载器统计:\n";
  printf "  总加载次数: %d\n" !load_count;
  printf "  缓存命中: %d\n" !cache_hits;
  printf "  缓存未命中: %d\n" !cache_misses;
  printf "  错误次数: %d\n" !error_count;
  printf "  缓存命中率: %.2f%%\n" (cache_hit_rate ())

(** 生成统计报告 *)
let generate_report () =
  sprintf "数据加载器统计报告:\n- 总加载次数: %d\n- 缓存命中: %d (%.2f%%)\n- 缓存未命中: %d\n- 错误次数: %d\n" !load_count
    !cache_hits (cache_hit_rate ()) !cache_misses !error_count
