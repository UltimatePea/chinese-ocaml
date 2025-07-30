(* 艺术数据统一注册表模块 *)

open Unified_data_engine

(** {1 数据源配置} *)

let initialized = ref false
let imagery_data_source = "artistic_imagery_data"
let elegant_data_source = "artistic_elegant_data"
let evaluation_standards_source = "artistic_evaluation_standards"
let templates_source = "artistic_templates"
let word_info_source = "artistic_word_info"

(** {1 初始化和注册管理} *)

let initialize () =
  if not (Unified_data_engine.is_initialized ()) then Unified_data_engine.initialize ();

  if not !initialized then (
    Unified_data_engine.register_data_source imagery_data_source Artistic
      (JsonFile "data/artistic/imagery_words.json") Cached;

    Unified_data_engine.register_data_source elegant_data_source Artistic
      (JsonFile "data/artistic/elegant_words.json") Cached;

    Unified_data_engine.register_data_source evaluation_standards_source Artistic
      (JsonFile "data/artistic/evaluation_standards.json") Preloaded;

    Unified_data_engine.register_data_source templates_source Artistic
      (JsonFile "data/artistic/templates.json") Cached;

    Unified_data_engine.register_data_source word_info_source Artistic
      (JsonFile "data/artistic/word_info.json") Preloaded;

    initialized := true)

let is_initialized () = !initialized

let register_custom_word_source (name : string) (filepath : string) =
  if not !initialized then initialize ();
  Unified_data_engine.register_data_source name Artistic (JsonFile filepath) Cached

(** {1 错误处理和诊断} *)

let format_query_error (error_msg : string) : string = "艺术数据查询错误: " ^ error_msg

let validate_data_integrity () : (string * bool * string option) list =
  if not !initialized then initialize ();
  Unified_data_engine.validate_all_sources ()

let get_cache_status () : (string * bool * int) list =
  if not !initialized then initialize ();
  let cache_info = Unified_data_engine.get_cache_info () in
  List.map (fun (name, size_bytes, _) -> (name, true, size_bytes)) cache_info

let diagnose_performance () : string =
  if not !initialized then initialize ();
  let stats = Unified_data_engine.get_engine_stats () in
  Printf.sprintf "艺术数据访问器性能报告:\n总请求数: %d\n缓存命中率: %.2f%%\n平均加载时间: %.2f ms\n数据源数量: %d"
    stats.total_requests
    (if stats.total_requests > 0 then
       float_of_int stats.cache_hits /. float_of_int stats.total_requests *. 100.0
     else 0.0)
    stats.average_load_time stats.data_sources_count
