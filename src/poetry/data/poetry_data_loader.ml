(** 统一诗词数据加载器 - 重构后的协调模块

    此模块现在作为协调中心，使用分离的子模块提供统一的诗词数据加载和管理接口。
    通过模块化设计，提高代码可维护性和可测试性。

    设计改进：
    1. 模块化架构：功能分离到专门的子模块
    2. 保持向后兼容：现有接口完全不变
    3. 提升性能：更好的缓存和加载机制
    4. 增强可测试性：独立模块便于单元测试

    @author 骆言诗词编程团队 - Phase 15 超长文件重构
    @version 2.0
    @since 2025-07-21 *)

(** {1 重新导出的类型定义} *)

(** 从数据源管理器重新导出类型 *)
type data_source = Data_source_manager.data_source
type data_source_entry = Data_source_manager.data_source_entry

(** {1 数据源管理接口} *)

(** 注册数据源 - 委托给数据源管理器 *)
let register_data_source name source ?(priority = 0) description =
  Data_source_manager.register_data_source name source ~priority description;
  Cache_manager.clear_cache () (* 清除缓存 *)

(** 从JSON文件加载韵律数据 *)
let load_rhyme_data_from_file = Data_source_manager.load_rhyme_data_from_file

(** 从数据源加载数据 *)
let load_from_source = Data_source_manager.load_from_source

(** 获取所有注册的数据源名称 *)
let get_registered_source_names = Data_source_manager.get_registered_source_names

(** {1 数据库操作接口} *)

(** 获取统一数据库 (带缓存) *)
let get_unified_database = Cache_manager.get_unified_database

(** 构建统一数据库 *)
let build_unified_database = Cache_manager.build_unified_database

(** 合并多个数据源，去除重复项 *)
let merge_data_sources = Cache_manager.merge_data_sources

(** {1 查询接口} *)

(** 检查字符是否在数据库中 *)
let is_char_in_database = Cache_manager.is_char_in_database

(** 获取字符的韵律信息 *)
let get_char_rhyme_info = Cache_manager.get_char_rhyme_info

(** 按韵组查询字符 *)
let get_chars_by_rhyme_group = Cache_manager.get_chars_by_rhyme_group

(** 按韵类查询字符 *)
let get_chars_by_rhyme_category = Cache_manager.get_chars_by_rhyme_category

(** {1 统计信息} *)

(** 获取数据库统计信息 *)
let get_database_stats = Cache_manager.get_database_stats

(** 数据完整性验证 *)
let validate_database = Cache_manager.validate_database

(** {1 向后兼容性接口} *)

(** 获取扩展韵律数据库 - 兼容原 expanded_rhyme_data.ml 接口 *)
let get_expanded_rhyme_database = Cache_manager.get_expanded_rhyme_database

(** 检查字符是否在扩展韵律数据库中 - 兼容原接口 *)
let is_in_expanded_rhyme_database = Cache_manager.is_in_expanded_rhyme_database

(** 获取扩展韵律字符列表 - 兼容原接口 *)
let get_expanded_char_list = Cache_manager.get_expanded_char_list

(** 扩展韵律字符总数 - 兼容原接口 *)
let expanded_rhyme_char_count = Cache_manager.expanded_rhyme_char_count

(** {1 调试和监控} *)

(** 打印数据源注册信息 *)
let print_registered_sources = Data_source_manager.print_registered_sources

(** 清除所有缓存 *)
let clear_cache = Cache_manager.clear_cache

(** 重新加载数据库 *)
let reload_database = Cache_manager.reload_database

(** {1 高级功能接口} *)

(** 获取缓存状态信息 *)
let get_cache_info = Cache_manager.get_cache_info

(** 强制刷新缓存 *)
let force_refresh_cache = Cache_manager.force_refresh_cache

(** 查找指定名称的数据源 *)
let find_data_source = Data_source_manager.find_data_source

(** 删除指定名称的数据源 *)
let remove_data_source name =
  let result = Data_source_manager.remove_data_source name in
  if result then Cache_manager.clear_cache (); (* 清除缓存 *)
  result
