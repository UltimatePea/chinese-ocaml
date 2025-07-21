(** 统计信息显示消息常量模块 *)

(** 性能统计消息 *)
let performance_stats_header = "类型推断性能统计:"

let infer_calls_format = "  推断调用: %d\n"
let unify_calls_format = "  合一调用: %d\n"
let subst_apps_format = "  替换应用: %d\n"
let cache_hits_format = "  缓存命中: %d\n"
let cache_misses_format = "  缓存未命中: %d\n"
let hit_rate_format = "  命中率: %.2f%%\n"
let cache_size_format = "  缓存大小: %d\n"

(** 通用消息模板 *)
let debug_prefix = "[DEBUG] "

let info_prefix = "[INFO] "
let warning_prefix = "[WARNING] "
let error_prefix = "[ERROR] "
let fatal_prefix = "[FATAL] "

(** 编译过程消息 *)
let compiling_file filename = "正在编译文件: " ^ filename

let compilation_complete = "编译完成"
let compilation_failed = "编译失败"
let parsing_started = "开始解析"
let parsing_complete = "解析完成"
let type_checking_started = "开始类型检查"
let type_checking_complete = "类型检查完成"
