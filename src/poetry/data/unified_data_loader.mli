(** 统一数据加载器核心模块接口 - Poetry模块整合Phase 1

    此模块提供统一的诗词数据加载接口，支持多种数据源和格式，
    内置缓存机制和错误处理。

    @author Alpha, 技术债务清理专员
    @version 1.0 - Phase 1 统一核心
    @since 2025-07-29
    @fix_issue #1729 *)

(** {1 核心类型} *)

(** 数据加载错误类型 *)
type unified_load_error =
  | FileNotFound of string
  | ParseError of string * string
  | ValidationError of string
  | CacheError of string
  | NetworkError of string
  | FormatError of string * string

exception UnifiedLoadError of unified_load_error

(** 数据源类型 *)
type data_source_type =
  | JsonFile of string
  | JsonString of string
  | BinaryFile of string
  | RemoteUrl of string
  | CachedData of string

(** 数据内容类型 *)
type data_content_type =
  | RhymeData
  | ToneData
  | PoetryData
  | WordClassData
  | ArtisticData

(** 加载选项 *)
type load_options = {
  use_cache : bool;
  validate_data : bool;
  fallback_enabled : bool;
  max_retries : int;
}

(** 默认加载选项 *)
val default_load_options : load_options

(** {1 错误处理} *)

(** 格式化错误信息 *)
val format_error : unified_load_error -> string

(** 抛出加载错误 *)
val raise_load_error : unified_load_error -> 'a

(** {1 核心加载接口} *)

(** 统一数据加载函数 *)
val load_data_unified : ?options:load_options -> data_content_type -> data_source_type -> Yojson.Safe.t

(** {1 便捷加载函数} *)

(** 加载韵律数据 *)
val load_rhyme_data : ?options:load_options -> data_source_type -> Yojson.Safe.t

(** 加载声调数据 *)
val load_tone_data : ?options:load_options -> data_source_type -> Yojson.Safe.t

(** 加载诗词数据 *)
val load_poetry_data : ?options:load_options -> data_source_type -> Yojson.Safe.t

(** 加载词类数据 *)
val load_word_class_data : ?options:load_options -> data_source_type -> Yojson.Safe.t

(** 加载艺术性数据 *)
val load_artistic_data : ?options:load_options -> data_source_type -> Yojson.Safe.t

(** {1 批量操作} *)

(** 批量加载多个数据源 *)
val load_multiple_sources : ?options:load_options -> (data_content_type * data_source_type) list -> (data_content_type * Yojson.Safe.t) list

(** {1 缓存管理} *)

(** 清空所有缓存 *)
val clear_cache : unit -> unit

(** 获取缓存统计信息 *)
val get_cache_stats : unit -> int * string list

(** 预热缓存 *)
val warm_cache : (data_content_type * data_source_type) list -> unit