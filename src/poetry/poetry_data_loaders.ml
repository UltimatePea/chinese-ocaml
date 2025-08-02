(** Poetry_data_loaders stub module - Fix Issue #2055
 * 
 * 诗词数据加载器存根模块，解决编译依赖问题
 * Author: Whisky, PR Worker  
 * Date: 2025-08-02
 *)

module Unified_loader = struct
  (** 数据源类型 *)
  type data_source = 
    | JsonFile of string 
    | BuiltinData
    | MemoryCache
    | ExternalAPI of string

  (** 数据类型 *)
  type data_type = 
    | ToneData of unit 
    | RhymeData of unit
    | PoetryData of unit
    | WordClassData of unit
    | ArtisticData of unit

  (** 加载配置 *)
  type load_config = {
    cache_enabled: bool;
    retry_count: int;
    timeout_ms: int;
  }

  (** 默认配置 *)
  let default_config = {
    cache_enabled = true;
    retry_count = 3;
    timeout_ms = 5000;
  }

  (** 错误类型 *)
  type load_error = 
    | FileNotFound of string
    | ParseError of string * string
    | ValidationError of string
    | CacheError of string
    | NetworkError of string
    | FormatError of string * string
    | TypeMismatch of string * string
    | PermissionError of string
    | CorruptedData of string

  exception UnifiedLoadError of load_error

  (** 组数据结构 *)
  type group_data = {
    category: string;
    characters: string list;
  }

  (** 基础加载函数 *)
  let load_data ?(config=default_config) _source _data_type () = []

  (** 缓存统计 *)
  let get_cache_stats () = (0, 0)

  (** 清理缓存 *)
  let clear_cache () = ()

  (** 子模块 - 兼容性接口 *)
  module PoetryDataLoader = struct
    let load_poetry_data path = load_data (JsonFile path) (PoetryData ()) ()
  end

  module RhymeDataLoader = struct
    let load_rhyme_data path = load_data (JsonFile path) (RhymeData ()) ()
  end

  module ExternalizedDataLoader = struct
    let load_externalized_data source = load_data source (PoetryData ()) ()
  end
end