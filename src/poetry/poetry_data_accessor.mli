(** 诗歌数据访问器 - Phase 2.3.2 专用诗歌数据访问模块

    本模块专门处理诗歌相关的数据访问，包括韵律数据、声调数据、韵脚数据等。 基于统一数据引擎构建，提供高级的诗歌数据查询和操作接口。

    @author Alpha, 主要工作代理 - Phase 2.3.2 数据加载器系统整合
    @version 2.3.2
    @since 2025-07-30 *)

(** {1 诗歌数据类型定义} *)

(** 韵组类型 *)
type rhyme_group = UnknownRhyme | RhymeGroup of string

(** 韵类型 *)
type rhyme_category = PingRhyme  (** 平韵 *) | ZeRhyme  (** 仄韵 *) | UnknownCategory

(** 声调类型 *)
type tone_type = Ping  (** 平声 *) | Shang  (** 上声 *) | Qu  (** 去声 *) | Ru  (** 入声 *) | UnknownTone

type char_info = {
  character : string;  (** 汉字字符 *)
  tone : tone_type;  (** 声调 *)
  rhyme_group : rhyme_group;  (** 韵组 *)
  rhyme_category : rhyme_category;  (** 韵类 *)
  pinyin : string option;  (** 拼音（可选） *)
}
(** 诗歌字符信息 *)

type rhyme_ending_info = {
  char : string;  (** 韵脚字符 *)
  rhyme_group : rhyme_group;  (** 所属韵组 *)
  usage_frequency : int;  (** 使用频率 *)
  example_poems : string list;  (** 示例诗句 *)
}
(** 韵脚信息 *)

type poetry_pattern = {
  name : string;  (** 格律名称 *)
  tone_pattern : bool list;  (** 平仄模式 (true=平, false=仄) *)
  rhyme_positions : int list;  (** 韵脚位置 *)
  line_length : int;  (** 句长 *)
}
(** 诗词格律模式 *)

(** 查询结果类型 *)
type 'a query_result = Found of 'a | NotFound | QueryError of string

(** {1 初始化和配置} *)

val initialize : unit -> unit
(** 初始化诗歌数据访问器

    自动注册必要的数据源到统一引擎 *)

val is_initialized : unit -> bool
(** 检查是否已初始化 *)

val register_custom_data_source : string -> string -> unit
(** 注册自定义数据源

    @param name 数据源名称
    @param filepath 数据文件路径 *)

(** {1 基础字符查询} *)

val get_char_info : string -> char_info query_result
(** 获取字符的完整信息

    @param char 汉字字符
    @return 字符信息查询结果 *)

val get_char_tone : string -> tone_type query_result
(** 获取字符的声调

    @param char 汉字字符
    @return 声调查询结果 *)

val get_char_rhyme_group : string -> rhyme_group query_result
(** 获取字符的韵组

    @param char 汉字字符
    @return 韵组查询结果 *)

val get_char_rhyme_category : string -> rhyme_category query_result
(** 获取字符的韵类

    @param char 汉字字符
    @return 韵类查询结果 *)

(** {1 韵律相关查询} *)

val get_chars_by_rhyme_group : rhyme_group -> string list query_result
(** 按韵组查询字符列表

    @param rhyme_group 韵组
    @return 字符列表查询结果 *)

val get_chars_by_tone : tone_type -> string list query_result
(** 按声调查询字符列表

    @param tone 声调类型
    @return 字符列表查询结果 *)

val get_rhyme_endings : rhyme_group -> rhyme_ending_info list query_result
(** 获取指定韵组的韵脚信息

    @param rhyme_group 韵组
    @return 韵脚信息列表 *)

val find_rhyming_chars : string -> string list query_result
(** 查找与指定字符同韵的字符

    @param char 参考字符
    @return 同韵字符列表 *)

(** {1 声调模式分析} *)

val analyze_tone_pattern : string -> bool list query_result
(** 分析文本的声调模式

    @param text 待分析文本
    @return 声调模式 (true=平声, false=仄声) *)

val validate_tone_pattern : string -> bool list -> bool query_result
(** 验证文本是否符合指定的声调模式

    @param text 待验证文本
    @param expected_pattern 期望的声调模式
    @return 验证结果 *)

val get_poetry_patterns : string -> poetry_pattern list query_result
(** 获取指定诗体的格律模式

    @param poetry_type 诗体类型（如"五言律诗"、"七言绝句"）
    @return 格律模式列表 *)

(** {1 高级查询功能} *)

val search_chars_by_criteria :
  ?tone:tone_type ->
  ?rhyme_group:rhyme_group ->
  ?rhyme_category:rhyme_category ->
  unit ->
  string list query_result
(** 按多重条件搜索字符

    @param tone 可选的声调条件
    @param rhyme_group 可选的韵组条件
    @param rhyme_category 可选的韵类条件
    @return 符合条件的字符列表 *)

val get_popular_rhyme_chars : int -> (string * int) list query_result
(** 获取最受欢迎的韵脚字符

    @param limit 返回数量限制
    @return (字符, 使用频率) 列表 *)

val analyze_poem_rhyme_scheme : string list -> (int * rhyme_group) list query_result
(** 分析诗歌的押韵方案

    @param lines 诗句列表
    @return (行号, 韵组) 列表 *)

(** {1 数据统计和分析} *)

val get_rhyme_group_statistics : unit -> (rhyme_group * int) list query_result
(** 获取韵组统计信息

    @return (韵组, 字符数量) 列表 *)

val get_tone_distribution : unit -> (tone_type * int) list query_result
(** 获取声调分布统计

    @return (声调, 字符数量) 列表 *)

val get_data_source_info : unit -> (string * string * int) list
(** 获取数据源信息

    @return (数据源名称, 类型, 条目数量) 列表 *)

(** {1 兼容性接口} *)

val load_rhyme_data : unit -> (string * rhyme_category * rhyme_group) list
(** 兼容性接口：加载韵律数据

    保持与旧接口的兼容性
    @deprecated 建议使用新的查询接口 *)

val load_tone_data : unit -> string list * string list * string list * string list
(** 兼容性接口：加载声调数据

    @deprecated 建议使用新的查询接口
    @return (平声, 上声, 去声, 入声) 四元组 *)

val is_char_available : string -> bool
(** 兼容性接口：检查字符是否可用

    @param char 汉字字符
    @return 是否在数据库中 *)

(** {1 错误处理和诊断} *)

val format_query_error : string -> string
(** 格式化查询错误信息

    @param error_msg 错误信息
    @return 格式化的错误字符串 *)

val validate_data_integrity : unit -> (string * bool * string option) list
(** 验证数据完整性

    @return (数据源名称, 验证通过, 错误信息) 列表 *)

val get_cache_status : unit -> (string * bool * int) list
(** 获取缓存状态

    @return (数据源名称, 是否缓存, 缓存大小) 列表 *)
