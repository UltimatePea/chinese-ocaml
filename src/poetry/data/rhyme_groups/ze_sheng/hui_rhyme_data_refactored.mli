(** 灰韵组数据模块 - 重构版本（技术债务修复 Fix #724）

    灰回推开，灰飞烟灭韵苍茫。

    此模块已重构为使用JSON外部数据，大幅简化代码结构。 原339行硬编码数据已外化到JSON配置文件，提升可维护性。

    @author 骆言诗词编程团队
    @version 2.0 - 技术债务重构版
    @since 2025-07-20 - Fix #724 诗词数据模块重构 *)

(** {1 韵律类型定义} *)

(** 韵律类别 - 使用统一的韵律类型定义，保持向后兼容 *)
type rhyme_category = Rhyme_json_data_loader.rhyme_category =
  | PingSheng  (** 平声 *)
  | ZeSheng  (** 仄声 *)
  | ShangSheng  (** 上声 *)
  | QuSheng  (** 去声 *)
  | RuSheng  (** 入声 *)

(** 韵母组别 - 使用统一的韵律类型定义，保持向后兼容 *)
type rhyme_group = Rhyme_json_data_loader.rhyme_group =
  | AnRhyme  (** 安韵 *)
  | SiRhyme  (** 思韵 *)
  | TianRhyme  (** 天韵 *)
  | WangRhyme  (** 王韵 *)
  | QuRhyme  (** 屈韵 *)
  | YuRhyme  (** 鱼韵 *)
  | HuaRhyme  (** 花韵 *)
  | FengRhyme  (** 风韵 *)
  | YueRhyme  (** 月韵 *)
  | XueRhyme  (** 雪韵 *)
  | JiangRhyme  (** 江韵 *)
  | HuiRhyme  (** 灰韵 *)
  | UnknownRhyme  (** 未知韵 *)

(** {1 兼容性接口 - 保持与原模块相同的API} *)

val get_hui_rhyme_data : unit -> (string * rhyme_category * rhyme_group) list
(** 获取灰韵组所有数据 - 从JSON加载
    @return 包含(字符, 韵律类别, 韵母组)三元组的列表 *)

val get_hui_rhyme_count : unit -> int
(** 获取灰韵组字符数量
    @return 灰韵组中包含的字符总数 *)

val is_hui_rhyme_char : string -> bool
(** 检查字符是否属于灰韵组
    @param char 要检查的字符
    @return 如果字符属于灰韵组则返回true，否则返回false *)

val get_hui_rhyme_chars : unit -> string list
(** 获取所有灰韵组字符列表
    @return 灰韵组中所有字符的列表 *)

(** {1 增强功能 - 利用JSON数据的优势} *)

val get_hui_rhyme_series : unit -> Rhyme_json_data_loader.character_series list
(** 按系列获取字符数据
    @return 灰韵组的所有字符系列列表 *)

val get_hui_rhyme_metadata : unit -> Rhyme_json_data_loader.rhyme_metadata
(** 获取韵律元信息
    @return 灰韵组数据的元信息 *)

val get_series_characters : string -> string list
(** 获取特定系列的字符
    @param series_name 系列名称
    @return 指定系列中的所有字符列表 *)

val find_character_series : string -> Rhyme_json_data_loader.character_series list
(** 搜索包含特定字符的系列
    @param char 要搜索的字符
    @return 包含该字符的所有系列列表 *)

(** {1 调试和统计功能} *)

val get_data_statistics : unit -> string
(** 获取数据统计信息
    @return 格式化的统计信息字符串 *)

val validate_data_integrity : unit -> string
(** 验证数据完整性
    @return 数据完整性验证结果字符串 *)

(** {1 性能优化} *)

val is_hui_rhyme_char_fast : string -> bool
(** 高性能字符检查 - 使用哈希表优化查找性能
    @param char 要检查的字符
    @return 如果字符属于灰韵组则返回true，否则返回false *)

val reset_all_caches : unit -> unit
(** 重置所有缓存 - 用于数据更新后的重新加载 注意：某些lazy数据需要重启程序来重新加载 *)
