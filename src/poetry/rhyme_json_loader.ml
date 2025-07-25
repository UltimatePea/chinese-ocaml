(** 韵律JSON数据加载器 - 整合版本

    经过重新整合的韵律数据加载器，使用新的统一核心模块替代原来分散的8个子模块。 本模块保持对外接口的完全兼容性，确保现有代码无需修改。

    @author 骆言诗词编程团队
    @version 3.0
    @since 2025-07-24 - Phase 7.1 JSON处理系统整合重构 *)

(* 重新导出类型定义和功能以保持兼容性 *)
include Rhyme_json_api

(** {1 主要API - 完全兼容原接口} *)

(** 获取韵律数据（兼容原有接口） *)
let get_rhyme_data = Rhyme_json_api.get_rhyme_data

(** 获取所有韵组（兼容原有接口） *)
let get_all_rhyme_groups = Rhyme_json_api.get_all_rhyme_groups

(** 获取韵组字符（兼容原有接口） *)
let get_rhyme_group_characters = Rhyme_json_api.get_rhyme_group_characters

(** 获取韵组类别（兼容原有接口） *)
let get_rhyme_group_category = Rhyme_json_api.get_rhyme_group_category

(** 获取韵律映射（兼容原有接口） *)
let get_rhyme_mappings = Rhyme_json_api.get_rhyme_mappings

(** 获取数据统计（兼容原有接口） *)
let get_data_statistics = Rhyme_json_api.get_data_statistics

(** 打印统计信息（兼容原有接口） *)
let print_statistics = Rhyme_json_api.print_statistics

(** 使用降级数据（兼容原有接口） *)
let use_fallback_data () = ignore (Rhyme_json_api.use_fallback_data ())

(** {1 子模块兼容性访问} *)

(* 为了保持完全的向后兼容性，重新导出所有原子模块接口 *)
module Types = Rhyme_json_api.Types
module Cache = Rhyme_json_api.Cache
module Parser = Rhyme_json_api.Parser
module Io = Rhyme_json_api.Io
module Access = Rhyme_json_api.Access
module Fallback = Rhyme_json_api.Fallback
