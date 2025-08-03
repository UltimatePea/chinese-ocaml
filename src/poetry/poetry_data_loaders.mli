(** Poetry数据加载器统一接口模块
    
    Author: Whisky, PR Worker
    
    此模块提供Poetry模块所需的统一数据加载接口，
    整合并重新导出现有的数据加载功能。
    主要解决tone_data.ml中引用错误的问题。
*)

(** Unified_loader子模块 - 统一数据加载器接口 *)
module Unified_loader : sig
  
  (** 数据源类型定义 *)
  type data_source =
    | JsonFile of string  (** JSON文件路径 *)
    | JsonString of string  (** JSON字符串内容 *)
    | BinaryFile of string  (** 二进制文件路径 *)
    | RemoteUrl of string  (** 远程URL *)
    | Database of string * string  (** 数据库连接串 * 表名 *)
    | InMemory of string * string  (** 数据类型 * 序列化内容 *)

  (** 数据类型标识 *)
  type data_type =
    | RhymeData  (** 韵律数据 *)
    | ToneData  (** 声调数据 *)
    | PoetryData  (** 诗词数据 *)
    | ArtisticData  (** 艺术性评价数据 *)
    | WordClassData  (** 词类数据 *)
    | CustomData of string  (** 自定义数据类型 *)

  (** 加载配置 *)
  type load_config = {
    enable_cache : bool;  (** 是否启用缓存 *)
    cache_ttl : int;  (** 缓存生存时间（秒） *)
    validate_data : bool;  (** 是否验证数据格式 *)
    async_mode : bool;  (** 是否启用异步加载 *)
    retry_count : int;  (** 重试次数 *)
    timeout : float;  (** 超时时间（秒） *)
  }

  (** 统一加载错误类型 *)
  type unified_load_error =
    | FileNotFound of string
    | ParseError of string * string
    | ValidationError of string
    | CacheError of string
    | NetworkError of string
    | FormatError of string * string
    | TypeMismatch of string * string
    | PermissionError of string
    | CorruptedData of string

  exception UnifiedLoadError of unified_load_error

  (** 默认配置 *)
  val default_config : load_config

  (** 主加载函数 
      @param data_source 数据源
      @param data_type 数据类型
      @param config 加载配置（可选）
      @return 加载的数据
  *)
  val load_data : data_source -> data_type -> ?config:load_config -> unit -> Poetry_core.Types.rhyme_data_file

  (** 错误格式化函数 *)
  val format_error : unified_load_error -> string

  (** 检查数据源可用性 *)
  val check_source_availability : data_source -> bool

  (** 获取缓存统计信息 *)
  val get_cache_stats : unit -> int * int

  (** 清理缓存 *)
  val clear_cache : unit -> unit

  (** Poetry数据加载器兼容性模块 *)
  module PoetryDataLoader : sig
    val read_file_safely : string -> string option
    val load_poetry_data_from_file : string -> Poetry_core.Types.rhyme_data_file
  end

  (** 外化数据加载器兼容性模块 *)
  module ExternalizedDataLoader : sig
    type externalized_data_error =
      | FileNotFound of string
      | ParseError of string * string
      | ValidationError of string

    exception ExternalizedDataError of externalized_data_error

    val load_external_data : string -> Poetry_core.Types.rhyme_data_file
  end

  (** 扩展数据加载器兼容性模块 *)
  module ExpandedDataLoader : sig
    type data_load_error =
      | FileNotFound of string
      | ParseError of string * string
      | ValidationError of string
      | CacheError of string
      | NetworkError of string

    exception DataLoadError of data_load_error

    val load_expanded_data : data_source -> Poetry_core.Types.rhyme_data_file
  end

  (** 韵律数据加载器兼容性模块 *)
  module RhymeDataLoader : sig
    type rhyme_data_load_error = RhymeFileNotFound of string | RhymeParseError of string

    exception RhymeDataLoadError of rhyme_data_load_error

    val load_rhyme_database : string -> Poetry_core.Types.rhyme_data_file
  end
end