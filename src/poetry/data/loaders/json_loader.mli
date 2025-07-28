(** JSON数据加载器接口 - 统一数据源加载
    
    此模块提供从JSON文件加载韵律数据的功能，支持：
    - 标准化JSON格式解析
    - 数据验证和错误处理
    - 批量数据加载
    - 增量数据更新
    
    技术债务修复：统一分散的JSON处理逻辑，建立标准化数据加载机制。
    
    @author Alpha, 主要开发代理 - Poetry模块重构团队
    @version 2.0 (统一架构版)
    @since 2025-07-27
    @fix_issue #1501 *)

(* 使用统一核心类型 *)
type rhyme_category = Poetry_core.Json_core.rhyme_category
type rhyme_group = Poetry_core.Json_core.rhyme_group

(** {1 异常定义} *)

exception JsonLoaderError of string
(** JSON加载器异常 *)

(** {1 主要加载功能} *)

val load_rhyme_database_from_file : string -> Poetry_core.Json_core.rhyme_data_file
(** 从JSON文件加载韵律数据库
    @param filename JSON文件路径
    @return 解析的韵律数据库
    @raise JsonLoaderError 当文件不存在、格式错误或解析失败时 *)

val load_rhyme_database_from_string : string -> string -> Poetry_core.Json_core.rhyme_data_file
(** 从JSON字符串加载韵律数据库
    @param content JSON字符串内容
    @param source 数据源标识
    @return 解析的韵律数据库
    @raise JsonLoaderError 当JSON格式错误或解析失败时 *)

(** {1 批量加载功能} *)

val load_multiple_files : string list -> Poetry_core.Json_core.rhyme_data_file list
(** 批量加载多个JSON文件
    @param filenames 文件路径列表
    @return 成功加载的韵律数据库列表（失败的文件会被忽略并打印警告） *)

val merge_databases :
  Poetry_core.Json_core.rhyme_data_file list -> Poetry_core.Json_core.rhyme_data_file
(** 合并多个韵律数据库
    @param databases 数据库列表
    @return 合并后的数据库 *)

(** {1 验证功能} *)

val validate_json_format : Yojson.Safe.t -> bool
(** 验证JSON格式
    @param json Yojson.Safe.t对象
    @return 格式是否有效 *)

val validate_file_format : string -> bool
(** 验证文件格式
    @param filename 文件路径
    @return 文件格式是否有效 *)

(** {1 示例数据生成} *)

val generate_sample_json : unit -> Yojson.Safe.t
(** 生成示例JSON结构
    @return 示例JSON对象 *)

val create_sample_file : string -> unit
(** 生成示例JSON文件
    @param filename 输出文件路径 *)

(** {1 实用工具} *)

val analyze_json_database : string -> (string * string) list
(** 分析JSON数据库信息
    @param filename JSON文件路径
    @return 数据库统计信息键值对列表 *)
