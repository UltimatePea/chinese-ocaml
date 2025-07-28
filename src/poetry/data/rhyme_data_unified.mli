(** 统一韵律数据管理器接口 - Phase 2 架构修正韵律数据专用模块
    
    整合所有分散的韵律数据模块，提供统一的韵律数据访问接口，
    解决当前15个rhyme_data模块职责重叠的问题。
                                                           
    @author Alpha, 主要工作代理 - 负责功能实现和技术债务处理
    @version 2.0 - 架构修正版本
    @since 2025-07-28 - Phase 2A 韵律数据统一
    @fix_issue #1572 *)

(** {1 韵律数据核心类型} *)

type rhyme_data_item = {
  character : string;
  rhyme_group : Poetry_core.Json_core.rhyme_group;
  rhyme_category : Poetry_core.Json_core.rhyme_category;
  tone : [ `PingSheng | `ShangSheng | `QuSheng | `RuSheng ];
  phonetic_info : (string * string) list; (* 音韵信息键值对 *)
  source_priority : int;
}
(** 统一韵律数据项 *)

(** 韵律数据源类型 *)
type rhyme_source =
  | AnYunData (* 安韵数据 *)
  | FengRhymeData (* 风韵数据 *)
  | HuaRhymeData (* 华韵数据 *)
  | YuRhymeData (* 余韵数据 *)
  | HuiRhymeData (* 辉韵数据 *)
  | JiangRhymeData (* 江韵数据 *)
  | YueRhymeData (* 月韵数据 *)
  | UnifiedRhymeDatabase (* 统一韵律数据库 *)
  | ExpandedRhymeData (* 扩展韵律数据 *)
  | RhymeDataEngine (* 韵律数据引擎 *)
  | CustomSource of string (* 自定义数据源 *)

(** 韵律查询类型 *)
type rhyme_query =
  | QueryByCharacter of string
  | QueryByRhymeGroup of Poetry_core.Json_core.rhyme_group
  | QueryByRhymeCategory of Poetry_core.Json_core.rhyme_category
  | QueryByTone of [ `PingSheng | `ShangSheng | `QuSheng | `RuSheng ]
  | QueryBySource of rhyme_source
  | QueryBySimilarSound of string (* 音近字查询 *)
  | RhymeCompatibilityQuery of string * string (* 韵律兼容性查询 *)

(** 韵律操作结果 *)
type 'a rhyme_result =
  | RhymeSuccess of 'a
  | RhymeError of string
  | RhymeWarning of 'a * string (* 数据 + 警告信息 *)

(** {1 韵律数据源管理} *)

val register_rhyme_source :
  rhyme_source ->
  (unit -> rhyme_data_item list rhyme_result) ->
  ?priority:int ->
  string ->
  unit rhyme_result
(** 注册韵律数据源

    @param source 韵律数据源类型
    @param loader 数据加载函数
    @param priority 优先级（高优先级覆盖低优先级的重复字符）
    @param description 数据源描述
    @return 注册结果 *)

val get_available_sources : unit -> (rhyme_source * string * int) list
(** 获取所有可用的韵律数据源 (源类型, 描述, 优先级) *)

val remove_rhyme_source : rhyme_source -> unit rhyme_result
(** 移除韵律数据源 *)

(** {1 统一韵律查询接口} *)

val query_rhyme_data : rhyme_query -> rhyme_data_item list rhyme_result
(** 统一韵律数据查询接口 *)

val find_rhyme_character : string -> rhyme_data_item option rhyme_result
(** 查找单个字符的韵律信息 - O(1)性能 *)

val find_rhyme_group_characters : Poetry_core.Json_core.rhyme_group -> string list rhyme_result
(** 查找韵组内所有字符 - O(1)性能 *)

val find_characters_by_tone :
  [ `PingSheng | `ShangSheng | `QuSheng | `RuSheng ] -> rhyme_data_item list rhyme_result
(** 按声调查找字符 *)

(** {1 韵律兼容性和分析} *)

val check_rhyme_compatibility : string -> string -> bool rhyme_result
(** 检查两个字符是否押韵兼容 *)

val find_rhyming_characters : string -> ?max_results:int -> unit -> string list rhyme_result
(** 查找与指定字符押韵的其他字符

    @param char 目标字符
    @param max_results 最大结果数量（默认无限制）
    @return 押韵字符列表 *)

val analyze_rhyme_pattern :
  string list -> (Poetry_core.Json_core.rhyme_group * string list) list rhyme_result
(** 分析字符列表的韵律模式 *)

val suggest_rhyme_alternatives : string -> (string * float) list rhyme_result
(** 建议韵律替代字符

    @param char 原字符
    @return (替代字符, 相似度评分) 列表 *)

(** {1 韵律数据统计和验证} *)

val get_rhyme_statistics : unit -> (int * int * int * int * int) rhyme_result
(** 获取韵律数据统计

    @return (总字符数, 韵组数, 韵类数, 数据源数, 冲突数) *)

val validate_rhyme_data : unit -> (bool * string list) rhyme_result
(** 验证韵律数据完整性

    @return (是否有效, 错误信息列表) *)

val find_data_conflicts : unit -> (string * rhyme_source * rhyme_source) list rhyme_result
(** 查找数据源间的冲突

    @return (冲突字符, 数据源1, 数据源2) 列表 *)

val resolve_conflicts_automatically : unit -> (string * rhyme_data_item) list rhyme_result
(** 自动解决数据冲突（基于优先级）

    @return (字符, 最终选择的数据项) 列表 *)

(** {1 高性能查询优化} *)

module FastRhyme : sig
  val build_rhyme_index : rhyme_source list -> unit rhyme_result
  (** 为指定数据源构建快速查询索引 *)

  val lookup_character_fast : string -> rhyme_data_item option
  (** O(1) 字符查找 - 不返回Result类型，用于高性能场景 *)

  val lookup_rhyme_group_fast : Poetry_core.Json_core.rhyme_group -> string list
  (** O(1) 韵组查找 - 高性能版本 *)

  val is_rhyme_compatible_fast : string -> string -> bool
  (** O(1) 韵律兼容性检查 - 高性能版本 *)

  val rebuild_index : unit -> unit rhyme_result
  (** 重建所有索引 *)

  val get_index_status : unit -> (rhyme_source * bool * float) list
  (** 获取索引状态 (数据源, 是否已建索引, 最后更新时间) *)
end

(** {1 传统韵律系统支持} *)

module TraditionalRhyme : sig
  val get_ping_sheng_characters : unit -> string list rhyme_result
  (** 获取平声字符 *)

  val get_ze_sheng_characters : unit -> string list rhyme_result
  (** 获取仄声字符 (上声+去声+入声) *)

  val classify_tone :
    string -> [ `PingSheng | `ShangSheng | `QuSheng | `RuSheng ] option rhyme_result
  (** 声调分类 *)

  val check_ping_ze_pattern : string list -> [ `Ping | `Ze ] list rhyme_result
  (** 检查平仄模式 *)

  val suggest_ping_ze_correction : string list -> (int * string * string) list rhyme_result
  (** 建议平仄修正

      @return (位置索引, 原字符, 建议字符) 列表 *)
end

(** {1 现代韵律系统支持} *)

module ModernRhyme : sig
  val get_modern_rhyme_mapping : string -> string list rhyme_result
  (** 获取现代韵律映射 *)

  val check_modern_rhyme_compatibility : string -> string -> float rhyme_result
  (** 检查现代韵律兼容性（返回相似度0.0-1.0） *)

  val convert_traditional_to_modern : Poetry_core.Json_core.rhyme_group -> string list rhyme_result
  (** 传统韵组到现代韵律的转换 *)
end

(** {1 导入导出功能} *)

val export_rhyme_data : rhyme_query -> format:[ `JSON | `CSV | `XML | `YAML ] -> string rhyme_result
(** 导出韵律数据到不同格式 *)

val import_rhyme_data :
  rhyme_source -> format:[ `JSON | `CSV | `XML ] -> string -> unit rhyme_result
(** 从外部格式导入韵律数据 *)

val backup_rhyme_data : unit -> string rhyme_result
(** 备份当前韵律数据到JSON格式 *)

val restore_rhyme_data : string -> unit rhyme_result
(** 从备份恢复韵律数据 *)

(** {1 向后兼容性接口} *)

module Compatibility : sig
  val get_expanded_rhyme_database :
    unit -> (string * Poetry_core.Json_core.rhyme_category * Poetry_core.Json_core.rhyme_group) list
  (** 兼容 expanded_rhyme_data.ml 接口 *)

  val is_in_expanded_rhyme_database : string -> bool
  (** 兼容 expanded_rhyme_data.ml 接口 *)

  val get_an_yun_data : unit -> (string * string * string) list
  (** 兼容 an_yun_data.ml 接口 *)

  val get_feng_rhyme_data : unit -> (string * string) list
  (** 兼容 feng_rhyme_data.ml 接口 *)

  val get_unified_database :
    unit -> (string * Poetry_core.Json_core.rhyme_category * Poetry_core.Json_core.rhyme_group) list
  (** 兼容 unified_rhyme_database.ml 接口 *)
end

(** {1 调试和监控} *)

val print_rhyme_report : unit -> unit
(** 打印韵律数据报告 *)

val get_memory_usage : unit -> int
(** 获取内存使用量（字节） *)

val optimize_memory : unit -> unit
(** 优化内存使用 *)

val set_debug_mode : bool -> unit
(** 设置调试模式 *)

val get_performance_metrics : unit -> float * float * int * int
(** 获取性能指标 (平均查询时间ms, 索引构建时间ms, 总查询次数, 缓存命中次数) *)
