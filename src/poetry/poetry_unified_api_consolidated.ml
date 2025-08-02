(** Poetry Unified API Consolidated Module - Issue #1999
 * 
 * 对外统一API接口模块
 * Author: Whisky, PR Worker
 * 
 * 整合所有Poetry模块功能，提供简洁统一的对外接口
 * 
 * 目标：
 * - 隐藏内部实现复杂性
 * - 提供高性能的统一接口
 * - 保持100%向后兼容性
 * - 支持现代化的编程接口
 *)

(** {1 统一类型导出} *)

(* 重新导出核心类型 *)
include Poetry_core_consolidated

(** {1 统一初始化接口} *)

(** 初始化Poetry模块 - 一键式初始化 *)
let initialize_poetry_system ?(performance_mode=true) () =
  Printf.printf "Initializing Poetry System...\\n";
  
  (* 初始化核心数据 *)
  Poetry_core_consolidated.preload_rhyme_data ();
  
  (* 初始化韵律引擎 *)
  Poetry_rhyme_engine_consolidated.initialize_engine ~performance_mode ();
  
  (* 预加载统一数据 *)
  Poetry_data_unified_consolidated.load_data_to_cache ();
  
  (* 预热缓存 *)
  Poetry_data_unified_consolidated.warm_up_cache ();
  
  Printf.printf "Poetry System initialized successfully!\\n";
  let stats = Poetry_data_unified_consolidated.get_data_statistics () in
  Printf.printf "Loaded %d rhyme entries across %d groups\\n" 
    stats.total_rhyme_entries stats.rhyme_groups_count

(** 检查系统是否已初始化 *)
let is_system_ready () = 
  Poetry_rhyme_engine_consolidated.is_initialized () && 
  Poetry_data_unified_consolidated.is_data_loaded ()

(** {1 核心查询接口} *)

(** 查找韵律信息 - 高性能版本 *)
let find_rhyme (char: string) : rhyme_info option =
  if Poetry_rhyme_engine_consolidated.is_initialized () then
    Poetry_rhyme_engine_consolidated.find_rhyme_info_fast char
  else
    Poetry_core_consolidated.find_rhyme_info char

(** 检查两字是否押韵 *)
let check_rhyme (char1: string) (char2: string) : bool =
  Poetry_core_consolidated.check_rhyme_match char1 char2

(** 批量韵律查询 *)
let batch_find_rhyme (chars: string list) : (string * rhyme_info option) list =
  if Poetry_rhyme_engine_consolidated.is_initialized () then
    Poetry_rhyme_engine_consolidated.batch_find_rhyme_info chars
  else
    List.map (fun char -> (char, find_rhyme char)) chars

(** 查找同韵字 *)
let find_rhyme_partners (char: string) (max_results: int) : string list =
  Poetry_data_unified_consolidated.find_similar_rhyme_characters char max_results

(** {1 诗词评价接口} *)

(** 全面诗词评价 - 推荐使用 *)
let evaluate_poem (poem_lines: string list) : evaluation_result =
  let rhyme_validation = Poetry_rhyme_engine_consolidated.validate_poem_rhyme poem_lines in
  let successful_rhymes = List.filter (fun (_, result) -> result.is_match) rhyme_validation in
  let rhyme_score = 
    if List.length rhyme_validation > 0 then
      float_of_int (List.length successful_rhymes) /. float_of_int (List.length rhyme_validation)
    else 0.5
  in
  
  let artistic_evaluation = Poetry_artistic_engine_consolidated.comprehensive_artistic_evaluation poem_lines in
  let artistic_score = artistic_evaluation.overall_score in
  
  let form_score = 
    match List.find_opt (fun (dim, _) -> dim = Form) artistic_evaluation.dimension_scores with
    | Some (_, score) -> score
    | None -> 0.6
  in
  
  let overall_score = (rhyme_score +. artistic_score +. form_score) /. 3.0 in
  
  let rhyme_suggestions = Poetry_rhyme_engine_consolidated.suggest_rhyme_improvements poem_lines in
  let artistic_suggestions = Poetry_artistic_engine_consolidated.generate_improvement_guidance artistic_evaluation in
  
  {
    overall_score = overall_score;
    dimension_scores = [
      (Rhyme, rhyme_score);
      (Artistic, artistic_score);
      (Form, form_score);
    ];
    rhyme_quality = rhyme_score;
    artistic_quality = artistic_score;
    form_compliance = form_score;
    recommendations = rhyme_suggestions @ artistic_suggestions;
  }

(** 快速诗词评分 - 性能优化版本 *)
let quick_evaluate (poem_lines: string list) : float =
  let basic_eval = Poetry_core_consolidated.evaluate_poem_basic poem_lines in
  let artistic_score = Poetry_artistic_engine_consolidated.quick_artistic_score poem_lines in
  (basic_eval.overall_score +. artistic_score) /. 2.0

(** {1 韵律分析接口} *)

(** 分析诗词韵律模式 *)
let analyze_rhyme_pattern (poem_lines: string list) : (int * rhyme_match_result) list =
  Poetry_rhyme_engine_consolidated.validate_poem_rhyme poem_lines

(** 获取韵律改进建议 *)
let get_rhyme_suggestions (poem_lines: string list) : string list =
  Poetry_rhyme_engine_consolidated.suggest_rhyme_improvements poem_lines

(** 验证诗词格律 *)
let validate_poetry_form (poem_lines: string list) : (bool * string list) =
  let line_count = List.length poem_lines in
  let line_lengths = List.map String.length poem_lines in
  let is_consistent = List.for_all (fun len -> len = List.hd line_lengths) line_lengths in
  
  let is_valid, suggestions = 
    match (line_count, List.hd line_lengths) with
    | (4, 5) -> (true, ["符合五言绝句格律"])
    | (4, 7) -> (true, ["符合七言绝句格律"])
    | (8, 5) -> (true, ["符合五言律诗格律"])
    | (8, 7) -> (true, ["符合七言律诗格律"])
    | _ when is_consistent -> (false, ["行数或字数不符合传统格律，但长度一致"])
    | _ -> (false, ["行长度不一致，建议统一字数"])
  in
  
  (is_valid, suggestions)

(** {1 艺术性分析接口} *)

(** 分析诗词意象 *)
let analyze_imagery (poem_lines: string list) : Poetry_artistic_engine_consolidated.imagery_element list =
  Poetry_artistic_engine_consolidated.analyze_poem_imagery poem_lines

(** 获取艺术性改进建议 *)
let get_artistic_suggestions (poem_lines: string list) : string list =
  let evaluation = Poetry_artistic_engine_consolidated.comprehensive_artistic_evaluation poem_lines in
  Poetry_artistic_engine_consolidated.generate_improvement_guidance evaluation

(** {1 数据查询接口} *)

(** 获取韵部字符列表 *)
let get_rhyme_group_chars (group: rhyme_group) : string list =
  Poetry_data_unified_consolidated.get_rhyme_group_characters group

(** 按声调查找字符 *)
let find_chars_by_tone (tone: int) : (string * rhyme_info) list =
  Poetry_data_unified_consolidated.get_characters_by_tone tone

(** 按声调分类查找字符 *)
let find_chars_by_category (category: rhyme_category) : (string * rhyme_info) list =
  Poetry_data_unified_consolidated.get_characters_by_category category

(** 获取所有可用韵部 *)
let get_available_rhyme_groups () : rhyme_group list =
  Poetry_data_unified_consolidated.get_all_rhyme_groups ()

(** {1 性能监控接口} *)

(** 获取系统性能统计 *)
let get_performance_stats () : string =
  let rhyme_stats = Poetry_rhyme_engine_consolidated.get_query_stats () in
  let data_stats = Poetry_data_unified_consolidated.get_data_statistics () in
  
  Printf.sprintf 
    "=== Poetry System Performance ===\\n\
     韵律查询统计:\\n\
     - 总查询: %d次\\n\
     - 缓存命中: %d次 (%.1f%%)\\n\
     - 平均查询时间: %.6f秒\\n\\n\
     数据统计:\\n\
     - 韵律条目: %d个\\n\
     - 韵部数量: %d个\\n\
     - 内存使用: %d bytes\\n\
     - 数据加载时间: %.3f秒\\n\
     ================================="
    rhyme_stats.total_queries
    rhyme_stats.cache_hits
    (if rhyme_stats.total_queries > 0 then 
       float_of_int rhyme_stats.cache_hits /. float_of_int rhyme_stats.total_queries *. 100.0 
     else 0.0)
    rhyme_stats.avg_query_time
    data_stats.total_rhyme_entries
    data_stats.rhyme_groups_count
    data_stats.memory_usage
    data_stats.load_time

(** 打印性能报告 *)
let print_performance_report () : unit =
  print_endline (get_performance_stats ());
  Poetry_rhyme_engine_consolidated.print_performance_report ()

(** {1 系统管理接口} *)

(** 重置系统统计 *)
let reset_system_stats () : unit =
  Poetry_rhyme_engine_consolidated.reset_stats ()

(** 清理系统缓存 *)
let cleanup_system () : unit =
  Poetry_core_consolidated.cleanup_cache ();
  Poetry_rhyme_engine_consolidated.cleanup_engine ();
  Poetry_data_unified_consolidated.clear_data_cache ()

(** 重新加载数据 *)
let reload_data () : unit =
  Poetry_data_unified_consolidated.force_reload_data ();
  initialize_poetry_system ()

(** {1 向后兼容接口} *)

(** 兼容旧的查询接口 *)
module Compatibility = struct
  let find_rhyme_info = find_rhyme
  let detect_rhyme_category = Poetry_core_consolidated.detect_rhyme_category  
  let check_rhyme_match = check_rhyme
  let evaluate_poem_quality = evaluate_poem
  let preload_rhyme_data = Poetry_core_consolidated.preload_rhyme_data
  let cleanup_cache = Poetry_core_consolidated.cleanup_cache
  
  (* 模拟旧模块接口 *)
  module Rhyme_api_core = struct
    let find_rhyme_info = find_rhyme
    let detect_rhyme_category = Poetry_core_consolidated.detect_rhyme_category
  end
  
  module Poetry_rhyme_engine = struct
    let initialize_engine = Poetry_rhyme_engine_consolidated.initialize_engine
    let validate_poem_rhyme = Poetry_rhyme_engine_consolidated.validate_poem_rhyme
    let suggest_rhyme_improvements = Poetry_rhyme_engine_consolidated.suggest_rhyme_improvements
  end
  
  module Poetry_artistic_engine = struct
    let comprehensive_artistic_evaluation = Poetry_artistic_engine_consolidated.comprehensive_artistic_evaluation
    let generate_improvement_guidance = Poetry_artistic_engine_consolidated.generate_improvement_guidance
  end
  
  module Unified_rhyme_data = struct
    let load_rhyme_data_to_cache = Poetry_data_unified_consolidated.load_data_to_cache
  end
  
  module Rhyme_cache = struct
    let clear_cache_global = Poetry_data_unified_consolidated.clear_data_cache
  end
end

(** {1 高级功能接口} *)

(** 诗词创作辅助 *)
let suggest_next_line_rhyme (current_lines: string list) (target_length: int) : string list =
  if List.length current_lines = 0 then []
  else
    let last_line = List.hd (List.rev current_lines) in
    if String.length last_line > 0 then
      let last_char = String.make 1 (String.get last_line (String.length last_line - 1)) in
      let partners = find_rhyme_partners last_char 10 in
      List.take 5 partners
    else []

(** 批量诗词评价 *)
let batch_evaluate_poems (poems_list: string list list) : (string list * evaluation_result) list =
  List.map (fun poem -> (poem, evaluate_poem poem)) poems_list

(** 生成系统状态报告 *)
let generate_system_report () : string =
  let is_ready = is_system_ready () in
  let perf_stats = get_performance_stats () in
  let data_report = Poetry_data_unified_consolidated.generate_data_report () in
  
  Printf.sprintf 
    "=== Poetry System Status Report ===\\n\
     系统状态: %s\\n\\n\
     %s\\n\\n\
     %s\\n\
     ====================================="
    (if is_ready then "就绪" else "未就绪")
    perf_stats
    data_report