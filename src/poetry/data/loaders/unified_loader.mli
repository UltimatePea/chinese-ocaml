(** 统一数据加载器接口 - Poetry模块重构Phase 1.2.2核心

    Author: Alpha, 主要工作代理 - 负责功能实现和技术债务处理 Phase: 1.2.2 数据加载器合并 (Poetry模块重构Phase 1) Date: 2025-07-29

    此接口统一整合16个重复数据加载器的公共API，提供一致的接口规范。 *)

(* 移除对已删除模块的依赖 *)

(** === 错误处理 === *)

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

val format_error : unified_load_error -> string

(** === 数据源和配置 === *)

type data_source =
  | JsonFile of string
  | JsonString of string
  | BinaryFile of string
  | RemoteUrl of string
  | Database of string * string
  | InMemory of string * string

type data_type =
  | RhymeData
  | ToneData
  | PoetryData
  | ArtisticData
  | WordClassData
  | CustomData of string

type load_config = {
  enable_cache : bool;
  cache_ttl : int;
  validate_data : bool;
  async_mode : bool;
  retry_count : int;
  timeout : float;
}

val default_config : load_config

(** === 核心加载API === *)

val load_data : data_source -> data_type -> ?config:load_config -> unit -> string
val load_rhyme_data_from_file : string -> string
val load_rhyme_data_from_string : string -> string
val load_multiple_files : string list -> data_type -> ?config:load_config -> unit -> string list
val merge_rhyme_databases : string list -> string

(** === 实用工具 === *)

val check_source_availability : data_source -> bool
val get_source_info : data_source -> (string * string) option
val get_cache_stats : unit -> int * int
val clear_cache : unit -> unit

(** === 向后兼容模块 === *)

module PoetryDataLoader : sig
  val read_file_safely : string -> string option
  val load_poetry_data_from_file : string -> string
end

module ExternalizedDataLoader : sig
  type externalized_data_error =
    | FileNotFound of string
    | ParseError of string * string
    | ValidationError of string

  exception ExternalizedDataError of externalized_data_error

  val load_external_data : string -> string
end

module ExpandedDataLoader : sig
  type data_load_error =
    | FileNotFound of string
    | ParseError of string * string
    | ValidationError of string
    | CacheError of string
    | NetworkError of string

  exception DataLoadError of data_load_error

  val load_expanded_data : data_source -> string
end

module RhymeDataLoader : sig
  type rhyme_data_load_error = RhymeFileNotFound of string | RhymeParseError of string

  exception RhymeDataLoadError of rhyme_data_load_error

  val load_rhyme_database : string -> string
end
