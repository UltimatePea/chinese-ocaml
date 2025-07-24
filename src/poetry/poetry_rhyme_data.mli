(** 骆言诗词韵律数据管理模块 - 整合版本
    
    此模块整合了原有30+个数据加载和管理模块的功能，
    提供统一的韵律数据访问、缓存和管理接口。
    
    技术债务改进：将分散在data/目录下的数据加载器、
    JSON解析器、缓存管理器等模块整合，简化数据访问架构。
    
    原模块映射：
    - rhyme_data.ml -> 核心数据定义
    - data/json_parser.ml -> JSON解析功能
    - data/cache_manager.ml -> 缓存管理
    - data/data_source_manager.ml -> 数据源管理
    - data/rhyme_data_loader.ml -> 数据加载
    - data/tone_data_loader.ml -> 声调数据
    
    @author 骆言诗词编程团队
    @version 2.0 - 整合版本
    @since 2025-07-24 *)

open Poetry_types_consolidated

(** {1 核心数据访问接口} *)

val get_all_rhyme_data : unit -> (char * rhyme_category * rhyme_group) list
(** 获取所有韵律数据
    
    @return 完整的韵律数据库列表，包含字符、韵类、韵组信息 *)

val get_rhyme_by_category : rhyme_category -> (char * rhyme_group) list
(** 按韵类获取韵律数据
    
    @param category 指定的韵类（平声、仄声等）
    @return 该韵类下的字符和韵组列表 *)

val get_rhyme_by_group : rhyme_group -> (char * rhyme_category) list
(** 按韵组获取韵律数据
    
    @param group 指定的韵组（安韵、思韵等）
    @return 该韵组下的字符和韵类列表 *)

val lookup_char_info : char -> (rhyme_category * rhyme_group) option
(** 查询单个字符的韵律信息
    
    这是最核心的查询函数，提供高效的字符韵律信息查询。
    
    @param char 待查询的汉字字符
    @return 韵类和韵组的选项类型，None表示未找到 *)

val batch_lookup : char list -> (char * rhyme_category * rhyme_group) list
(** 批量查询字符韵律信息
    
    @param chars 待查询的字符列表
    @return 查询结果列表，未找到的字符将被跳过 *)

(** {1 韵组数据管理} *)

val get_rhyme_group_chars : rhyme_group -> char list
(** 获取韵组包含的所有字符
    
    @param group 韵组
    @return 该韵组的字符列表 *)

val get_rhyme_group_size : rhyme_group -> int
(** 获取韵组字符数量
    
    @param group 韵组
    @return 字符数量 *)

val list_all_rhyme_groups : unit -> rhyme_group list
(** 列出所有可用的韵组
    
    @return 韵组列表 *)

val is_rhyme_group_empty : rhyme_group -> bool
(** 检查韵组是否为空
    
    @param group 韵组
    @return 空则返回true，否则返回false *)

(** {1 声调数据管理} *)

val get_ping_sheng_chars : unit -> char list
(** 获取所有平声字符
    
    @return 平声字符列表 *)

val get_ze_sheng_chars : unit -> char list
(** 获取所有仄声字符
    
    @return 仄声字符列表 *)

val get_category_distribution : unit -> (rhyme_category * int) list
(** 获取韵类分布统计
    
    @return 每个韵类及其字符数量的列表 *)

(** {1 数据加载和初始化} *)

val initialize_data : unit -> unit
(** 初始化韵律数据库
    
    加载所有必要的韵律数据到内存中，建立索引和缓存。 *)

val reload_data : unit -> unit
(** 重新加载韵律数据
    
    清除缓存并重新加载数据，用于数据更新后的刷新。 *)

val is_data_loaded : unit -> bool
(** 检查数据是否已加载
    
    @return 已加载返回true，否则返回false *)

(** {1 JSON数据解析} *)

module JsonParser : sig
  val parse_rhyme_data : string -> (char * rhyme_category * rhyme_group) list
  (** 从JSON字符串解析韵律数据
      
      @param json_content JSON格式的韵律数据
      @return 解析后的韵律数据列表 *)

  val parse_single_entry : string -> char * rhyme_category * rhyme_group
  (** 解析单个韵律数据条目
      
      @param entry_str JSON条目字符串
      @return 解析后的韵律数据三元组 *)

  val export_to_json : (char * rhyme_category * rhyme_group) list -> string
  (** 将韵律数据导出为JSON格式
      
      @param data 韵律数据列表
      @return JSON格式字符串 *)
end

(** {1 数据缓存管理} *)

module CacheManager : sig
  val enable_cache : unit -> unit
  (** 启用数据缓存 *)

  val disable_cache : unit -> unit
  (** 禁用数据缓存 *)

  val clear_cache : unit -> unit
  (** 清除所有缓存数据 *)

  val get_cache_stats : unit -> int * int * float
  (** 获取缓存统计信息
      
      @return (命中次数, 总查询次数, 命中率) *)

  val is_cache_enabled : unit -> bool
  (** 检查缓存是否启用
      
      @return 启用返回true，否则返回false *)
end

(** {1 数据验证和统计} *)

val validate_data_integrity : unit -> bool
(** 验证数据完整性
    
    检查韵律数据是否存在重复、缺失或错误。
    
    @return 数据完整则返回true，否则返回false *)

val get_data_statistics : unit -> (string * int) list
(** 获取数据统计信息
    
    @return 统计项目和数值的列表
    例如：[("总字符数", 1200); ("韵组数", 12)] *)

val find_data_conflicts : unit -> (char * string) list
(** 查找数据冲突
    
    检测数据中可能存在的冲突或异常。
    
    @return 冲突字符和描述的列表 *)

(** {1 扩展数据源支持} *)

val load_from_file : string -> unit
(** 从文件加载韵律数据
    
    @param filepath 数据文件路径
    @raises Sys_error 如果文件不存在或无法读取 *)

val save_to_file : string -> unit
(** 将当前数据保存到文件
    
    @param filepath 目标文件路径 *)

val merge_external_data : (char * rhyme_category * rhyme_group) list -> unit
(** 合并外部韵律数据
    
    将外部数据源的韵律数据合并到当前数据库中。
    
    @param external_data 外部韵律数据列表 *)