(** 整合JSON和文件解析功能模块接口 - P0专项整合
    
    整合json_parser、poetry_json_parser、file_helper、poetry_file_reader等
    重复的解析和文件操作功能，提供统一的解析接口。
    
    Author: Whisky, PR Worker - P0专项整合
    @version 1.0 - Phase 2.1
    @since 2025-08-04
    @fix_issue #2174 *)

(** {1 解析错误类型} *)

(** 统一解析错误类型 *)
type parse_error =
  | JsonParseError of string * string      (** JSON解析错误: (消息, 详细信息) *)
  | FileReadError of string * string       (** 文件读取错误: (文件路径, 错误信息) *)
  | ValidationError of string * string     (** 数据验证错误: (字段名, 错误信息) *)
  | FormatError of string * string         (** 格式错误: (预期格式, 实际内容) *)

exception ParseError of parse_error

val format_parse_error : parse_error -> string
(** 格式化解析错误信息 *)

(** {1 文件操作接口} *)

val file_exists : string -> bool
(** 检查文件是否存在 *)

val read_file : string -> string
(** 读取文件内容为字符串 *)

val read_lines : string -> string list
(** 读取文件内容为行列表 *)

val ensure_directory : string -> unit
(** 确保目录存在，不存在则创建 *)

val get_file_extension : string -> string
(** 获取文件扩展名 *)

val normalize_path : string -> string
(** 规范化文件路径 *)

(** {1 通用JSON解析接口} *)

val parse_json_string : string -> Yojson.Safe.t
(** 解析JSON字符串 *)

val parse_json_file : string -> Yojson.Safe.t
(** 解析JSON文件 *)

val validate_json_structure : Yojson.Safe.t -> string list -> bool
(** 验证JSON结构是否包含必需字段
    @param json JSON数据
    @param required_fields 必需字段列表
    @return 验证结果 *)

val extract_string_field : Yojson.Safe.t -> string -> string option
(** 提取JSON中的字符串字段 *)

val extract_string_list : Yojson.Safe.t -> string -> string list
(** 提取JSON中的字符串列表字段 *)

val extract_object_field : Yojson.Safe.t -> string -> Yojson.Safe.t option
(** 提取JSON中的对象字段 *)

(** {1 诗词专用解析接口} *)

(** 诗词数据结构 *)
type poetry_data = {
  characters : string list;
  rhyme_category : string;
  rhyme_group : string;
  metadata : (string * string) list;
}

val parse_poetry_json : string -> poetry_data
(** 解析诗词JSON数据
    @param json_content JSON字符串内容
    @return 解析后的诗词数据结构 *)

val parse_poetry_json_file : string -> poetry_data
(** 解析诗词JSON文件
    @param file_path 文件路径
    @return 解析后的诗词数据结构 *)

(** 韵律数据结构 *)
type rhyme_data = {
  char : string;
  category : string;
  group : string;
  tone : string option;
}

val parse_rhyme_data_json : Yojson.Safe.t -> rhyme_data list
(** 解析韵律数据JSON *)

val parse_rhyme_data_file : string -> rhyme_data list
(** 解析韵律数据文件 *)

(** 声调数据结构 *)
type tone_data = {
  characters : string list;
  tone_type : string;
  description : string option;
}

val parse_tone_data_json : Yojson.Safe.t -> tone_data
(** 解析声调数据JSON *)

val parse_tone_data_file : string -> tone_data
(** 解析声调数据文件 *)

(** 词类数据结构 *)
type word_class_data = {
  category : string;
  words : string list;
  description : string option;
}

val parse_word_class_json : Yojson.Safe.t -> word_class_data list
(** 解析词类数据JSON *)

val parse_word_class_file : string -> word_class_data list
(** 解析词类数据文件 *)

(** {1 批量解析接口} *)

val parse_multiple_json_files : string list -> (string * Yojson.Safe.t) list
(** 批量解析多个JSON文件
    @param file_paths 文件路径列表
    @return (文件路径, JSON数据) 列表 *)

val parse_directory_json_files : string -> (string * Yojson.Safe.t) list
(** 解析目录下所有JSON文件
    @param directory_path 目录路径
    @return (文件路径, JSON数据) 列表 *)

(** {1 数据转换接口} *)

val poetry_data_to_json : poetry_data -> Yojson.Safe.t
(** 将诗词数据转换为JSON *)

val rhyme_data_to_json : rhyme_data list -> Yojson.Safe.t
(** 将韵律数据转换为JSON *)

val tone_data_to_json : tone_data -> Yojson.Safe.t
(** 将声调数据转换为JSON *)

val word_class_data_to_json : word_class_data list -> Yojson.Safe.t
(** 将词类数据转换为JSON *)

(** {1 配置和选项} *)

(** 解析选项 *)
type parse_options = {
  strict_mode : bool;           (** 严格模式：遇到错误立即停止 *)
  ignore_missing_fields : bool; (** 忽略缺失字段 *)
  enable_caching : bool;        (** 启用解析结果缓存 *)
  max_file_size_mb : int;       (** 最大文件大小限制(MB) *)
}

val default_parse_options : parse_options
(** 默认解析选项 *)

val set_parse_options : parse_options -> unit
(** 设置全局解析选项 *)

val get_parse_options : unit -> parse_options
(** 获取当前解析选项 *)

(** {1 缓存管理} *)

val clear_parse_cache : unit -> unit
(** 清空解析缓存 *)

val get_cache_stats : unit -> int * int
(** 获取缓存统计信息
    @return (缓存项目数, 缓存命中次数) *)

(** {1 兼容性接口} *)

(** 兼容json_parser模块 *)
module JsonParserCompat : sig
  val load_json : string -> Yojson.Safe.t
  val parse_string : string -> Yojson.Safe.t
  val validate_schema : Yojson.Safe.t -> bool
end

(** 兼容poetry_json_parser模块 *)
module PoetryJsonParserCompat : sig
  val parse_poetry_file : string -> poetry_data
  val extract_characters : Yojson.Safe.t -> string list
  val extract_rhyme_info : Yojson.Safe.t -> string * string
end

(** 兼容file_helper模块 *)
module FileHelperCompat : sig
  val read_text_file : string -> string
  val write_text_file : string -> string -> unit
  val list_directory : string -> string list
  val create_directory : string -> unit
end

(** 兼容poetry_file_reader模块 *)
module PoetryFileReaderCompat : sig
  val read_poetry_file : string -> string list
  val read_rhyme_file : string -> rhyme_data list
  val read_tone_file : string -> tone_data
end

(** {1 调试和工具} *)

val print_parse_stats : unit -> unit
(** 打印解析统计信息 *)

val validate_all_parsers : unit -> bool * string list
(** 验证所有解析器功能
    @return (验证结果, 错误列表) *)

val benchmark_parser : string -> float
(** 基准测试解析器性能
    @param file_path 测试文件路径
    @return 解析时间(秒) *)