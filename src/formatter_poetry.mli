(** 骆言编译器诗词格式化模块接口

    本模块专注于诗词分析和格式化功能，提供统一的诗词相关格式化接口。 包含诗词评价、韵律分析、古典诗词格式化和文学分析工具。

    从unified_formatter.ml中拆分而来，专注于骆言项目的文学编程特色功能。

    @author 骆言AI代理
    @version 1.0
    @since 2025-07-22 *)

(** 诗词分析格式化模块 *)
module PoetryFormatting : sig
  val evaluation_report : string -> string -> float -> string
  (** 诗词评价报告 *)

  val rhyme_group : string -> string
  (** 韵组格式化 *)

  val tone_error : int -> string -> string -> string
  (** 字调错误格式化 *)

  val verse_analysis : int -> string -> string -> string -> string
  (** 诗句分析 *)

  val poetry_structure_analysis : string -> int -> int -> string
  (** 诗词结构分析 *)

  val format_text_length_info : int -> string
  (** 文本分析格式化 *)

  val format_category_count : string -> int -> string
  val format_rhyme_group_count : string -> int -> string

  val format_character_lookup_error : string -> string -> string
  (** 错误处理格式化 *)

  val format_rhyme_data_stats : int -> int -> string

  val format_evaluation_detailed_report : string -> string -> float -> string -> string
  (** 详细评价报告 *)

  val format_dimension_score : string -> float -> string

  val format_rhyme_validation_error : int -> string -> string
  (** 韵律验证 *)

  val format_cache_duplicate_error : string -> int -> string
  (** 缓存和数据管理 *)

  val format_data_loading_error : string -> string -> string
  val format_group_not_found_error : string -> string
  val format_json_parse_error : string -> string -> string

  val format_hui_rhyme_stats : string -> int -> int -> string -> string
  (** 灰韵组数据统计 *)

  val format_data_integrity_success : int -> string
  (** 数据完整性验证 *)

  val format_data_integrity_failure : int -> int -> string
  val format_data_integrity_exception : string -> string
end

(** 古典诗词格式化模块 *)
module ClassicalFormatting : sig
  val format_regulated_verse : string -> string -> string list -> string
  (** 律诗格式化 *)

  val format_quatrain : string -> string -> string list -> string
  (** 绝句格式化 *)

  val format_ci_poem : string -> string -> string -> string list list -> string
  (** 词牌格式化 *)

  val format_prosody_analysis : string list -> string -> string -> string
  (** 韵律分析格式化 *)

  val format_parallelism_analysis : (string * string) list -> string
  (** 对仗分析 *)
end

(** 古雅体格式化模块 *)
module AncientStyleFormatting : sig
  val format_classical_chinese : string -> string -> string list -> string
  (** 文言文格式化 *)

  val format_ancient_verse : string -> string list -> string list -> string
  (** 古体诗格式化 *)

  val format_parallel_prose : string -> string list -> string
  (** 骈体文格式化 *)

  val format_fu_poem : string -> string -> (string * string) list -> string
  (** 辞赋格式化 *)
end

(** 诗词分析工具模块 *)
module PoetryAnalysisTools : sig
  val format_character_frequency : (string * int) list -> string
  (** 字符统计 *)

  val format_rhyme_pattern_analysis : string list -> string
  (** 韵律模式分析 *)

  val format_prosody_check_report : string list -> string list -> string
  (** 声律检查报告 *)

  val format_style_analysis_report : string -> string list -> (string * float) list -> string
  (** 风格分析报告 *)

  val format_thematic_vocabulary_analysis : (string * string list) list -> string
  (** 主题词汇分析 *)
end
