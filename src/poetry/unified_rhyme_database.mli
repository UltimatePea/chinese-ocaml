(** 统一韵律数据库接口 - Phase 2.1 深度整合核心模块
    
    提供统一、高效的韵律数据访问接口，整合所有分散的韵律数据源。
    这是韵律模块整合Phase 2.1的核心API。
    
    @author Whisky, PR Worker
    @version 1.0 - 韵律模块深度整合Phase 2.1
    @since 2025-07-31
    @github_issue #1903 *)

open Poetry_core.Rhyme_core_types

(** {1 核心数据类型} *)

(** 韵律数据来源标识 *)
type rhyme_source = 
  | Traditional_Poetry   (** 传统诗词韵律 *)
  | Modern_Poetry       (** 现代诗词韵律 *)
  | Classical_Texts     (** 古典文献韵律 *)
  | Dialect_Variant     (** 方言变体韵律 *)

(** 增强的韵律数据条目 *)
type enhanced_rhyme_entry = {
  character: string;                    (** 字符 *)
  pinyin: string;                      (** 拼音 *)
  tone: int;                           (** 声调 1-4 *)
  rhyme_group: rhyme_group;            (** 韵组分类 *)
  rhyme_category: rhyme_category;      (** 韵律类别 *)
  source: rhyme_source;                (** 数据来源 *)
  frequency: float;                    (** 使用频率 0.0-1.0 *)
  variants: string list;               (** 变体字符 *)
  examples: string list;               (** 诗词例句 *)
  metadata: (string * string) list;   (** 扩展元数据 *)
}

(** 数据库元数据 *)
type database_metadata = {
  total_entries: int;                  (** 总条目数 *)
  last_updated: float;                 (** 最后更新时间 *)
  version: string;                     (** 数据库版本 *)
  sources: rhyme_source list;          (** 数据来源列表 *)
  group_distribution: (rhyme_group * int) list; (** 韵组分布统计 *)
  category_distribution: (rhyme_category * int) list; (** 类别分布统计 *)
}

(** {2 数据库访问接口} *)

(** 数据库索引结构 - 不透明类型 *)
type database_indices

(** 统一韵律数据库 - 不透明类型 *)
type unified_rhyme_database

(** 获取统一数据库实例 *)
val get_database : unit -> unified_rhyme_database

(** {3 基础查询接口} *)

(** 根据字符查找韵律信息 *)
val lookup_character : string -> enhanced_rhyme_entry option

(** 根据韵组获取所有字符 *)
val get_characters_by_group : rhyme_group -> string list

(** 根据声调获取所有字符 *)
val get_characters_by_tone : int -> string list

(** 根据韵律类别获取所有字符 *)
val get_characters_by_category : rhyme_category -> string list

(** {4 高级查询接口} *)

(** 检查两个字符是否同韵 *)
val are_characters_rhyming : string -> string -> bool

(** 查找与指定字符同韵的所有字符 *)
val find_rhyming_characters : string -> string list

(** {5 统计和管理接口} *)

(** 获取数据库统计信息 *)
val get_database_statistics : unit -> database_metadata

(** 打印数据库信息 *)
val print_database_info : unit -> unit

(** 获取所有韵律条目 *)
val get_all_entries : unit -> enhanced_rhyme_entry list

(** 数据库健康检查 *)
val health_check : unit -> unit

(** {6 向后兼容接口} *)

(** 兼容性模块 - 保持与原有代码的100%兼容 *)
module Compatibility : sig
  
  (** 兼容consolidated_rhyme_data.ml的接口 *)
  val find_rhyme_info : string -> (rhyme_category * rhyme_group) option
  
  (** 兼容rhyme_data_core.ml的接口 *)
  val get_rhyme_entry : string -> enhanced_rhyme_entry option
  
  (** 兼容各种group数据访问 *)
  val get_chars_by_rhyme_group : rhyme_group -> string list
  val get_chars_by_category : rhyme_category -> string list
  
  (** 兼容检查函数 *)
  val is_char_in_database : string -> bool
end