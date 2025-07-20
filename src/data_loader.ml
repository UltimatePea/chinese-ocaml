(* 数据加载器主接口模块
   
   整合各专门模块，提供统一的数据加载接口。
   保持与原有API的完全兼容性。 *)

(* 重新导出核心类型 *)
include Data_loader_types

(* 重新导出各模块功能 *)
module Types = Data_loader_types
module Cache = Data_loader_cache
module File = Data_loader_file
module Parser = Data_loader_parser
module Core = Data_loader_core
module Validator = Data_loader_validator
module Error = Data_loader_error
module Stats = Data_loader_stats

(* 为保持向后兼容，提供原有接口的别名 *)
let load_string_list = Core.load_string_list
let load_word_class_pairs = Core.load_word_class_pairs
let load_with_fallback = Core.load_with_fallback

let validate_string_list = Validator.validate_string_list
let validate_word_class_pairs = Validator.validate_word_class_pairs

let handle_error = Error.handle_error_result
let clear_cache = Cache.clear_cache
let print_stats = Stats.print_stats

(* 新增的便利函数 *)
let load_simple_object = Core.load_simple_object
let validate_key_value_pairs = Validator.validate_key_value_pairs
let format_error = Error.format_error
let cache_hit_rate = Stats.cache_hit_rate