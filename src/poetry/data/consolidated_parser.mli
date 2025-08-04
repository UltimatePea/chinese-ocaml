(** 简化的整合解析器接口 - 临时修复构建问题
    
    Author: Whisky, PR Worker - P0专项整合
    @version 1.0 - Phase 2.1 临时版本
    @since 2025-08-04
    @fix_issue #2174 *)

(** {1 解析错误类型} *)

type parse_error =
  | JsonParseError of string * string      
  | FileReadError of string * string       
  | ValidationError of string * string     
  | FormatError of string * string         

exception ParseError of parse_error

val format_parse_error : parse_error -> string

(** {1 解析配置} *)

type parse_options = {
  strict_mode : bool;              
  ignore_missing_fields : bool;    
  enable_caching : bool;           
  max_file_size_mb : int;          
}

val default_parse_options : parse_options

val set_parse_options : parse_options -> unit
val get_parse_options : unit -> parse_options

(** {1 文件操作接口} *)

val file_exists : string -> bool
val read_file : string -> string
val read_lines : string -> string list
val ensure_directory : string -> unit
val get_file_extension : string -> string
val normalize_path : string -> string

(** {1 通用JSON解析接口} *)

val parse_json_string : string -> Yojson.Safe.t
val parse_json_file : string -> Yojson.Safe.t
val validate_json_structure : Yojson.Safe.t -> string list -> bool
val extract_string_field : Yojson.Safe.t -> string -> string option
val extract_string_list : Yojson.Safe.t -> string -> string list
val extract_object_field : Yojson.Safe.t -> string -> Yojson.Safe.t option

(** {1 诗词专用解析接口} *)

type poetry_data = {
  characters : string list;
  rhyme_category : string;
  rhyme_group : string;
  metadata : (string * string) list;
}

val parse_poetry_json : string -> poetry_data
val parse_poetry_json_file : string -> poetry_data

type rhyme_data = {
  char : string;
  category : string;
  group : string;
  tone : string option;
}

type tone_data = {
  characters : string list;
  tone_type : string;
  description : string option;
}

type word_class_data = {
  category : string;
  words : string list;
  description : string option;
}

(** {1 缓存管理} *)

val clear_parse_cache : unit -> unit
val get_cache_stats : unit -> int * int

(** {1 兼容性接口} *)

module JsonParserCompat : sig
  val load_json : string -> Yojson.Safe.t
  val parse_string : string -> Yojson.Safe.t
  val validate_schema : Yojson.Safe.t -> bool
end

module PoetryJsonParserCompat : sig
  val parse_poetry_file : string -> poetry_data
  val extract_characters : Yojson.Safe.t -> string list
  val extract_rhyme_info : Yojson.Safe.t -> string * string
end

module FileHelperCompat : sig
  val read_text_file : string -> string
  val write_text_file : string -> string -> unit
  val list_directory : string -> string list
  val create_directory : string -> unit
end

module PoetryFileReaderCompat : sig
  val read_poetry_file : string -> string list
  val read_rhyme_file : string -> rhyme_data list
  val read_tone_file : string -> tone_data
end

(** {1 调试和工具} *)

val print_parse_stats : unit -> unit
val validate_all_parsers : unit -> bool * string list
val benchmark_parser : string -> float