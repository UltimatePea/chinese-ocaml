(** 韵律JSON数据加载器 - 重构版本

    经过模块化重构的韵律数据加载器，将原来的单一大文件拆分为多个专门的子模块。 本模块作为主要的对外接口，集成所有子模块功能。

    @author 骆言诗词编程团队
    @version 2.0
    @since 2025-07-20 - Phase 29 大型文件重构 *)

(* 重新导出类型定义 *)
module Types = Rhyme_json_types
include Types

(* 重新导出所有子模块功能 *)
module Cache = Rhyme_json_cache
module Parser = Rhyme_json_parser
module Io = Rhyme_json_io
module Access = Rhyme_json_access
module Fallback = Rhyme_json_fallback

(** {1 主要API - 兼容性接口} *)

(** 获取韵律数据（兼容原有接口） *)
let get_rhyme_data ?(force_reload = false) () =
  try Some (Io.get_rhyme_data ~force_reload ())
  with Rhyme_data_not_found _ | Json_parse_error _ -> Some (Fallback.use_fallback_data ())

(** 获取所有韵组（兼容原有接口） *)
let get_all_rhyme_groups = Access.get_all_rhyme_groups

(** 获取韵组字符（兼容原有接口） *)
let get_rhyme_group_characters = Access.get_rhyme_group_characters

(** 获取韵组类别（兼容原有接口） *)
let get_rhyme_group_category = Access.get_rhyme_group_category

(** 获取韵律映射（兼容原有接口） *)
let get_rhyme_mappings = Access.get_rhyme_mappings

(** 获取数据统计（兼容原有接口） *)
let get_data_statistics = Access.get_data_statistics

(** 打印统计信息（兼容原有接口） *)
let print_statistics = Access.print_statistics

(** 使用降级数据（兼容原有接口） *)
let use_fallback_data () = ignore (Fallback.use_fallback_data ())

(** {1 新增功能} *)

(* 这些功能可以通过子模块直接访问:
   - Cache.clear_cache : 清理缓存
   - Cache.is_cache_valid : 检查缓存状态  
   - Io.default_data_file : 默认数据文件路径 *)
