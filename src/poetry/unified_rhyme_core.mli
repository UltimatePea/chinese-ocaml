(** 统一韵律核心模块接口 - Poetry模块整合优化
    
    此模块提供整合后的统一韵律数据访问接口，替代原有的98个分散文件。
    
    Author: Alpha, 主要工作代理
    @version 1.0 - Poetry模块整合优化版本  
    @since 2025-07-29 - Fix #1744 Poetry模块整合优化 *)

open Poetry_core.Poetry_types

(** {1 统一韵律数据类型} *)

type unified_rhyme_entry = {
  character : string;        (** 韵字 *)
  category : rhyme_category; (** 韵类：平声、仄声、入声 *)
  group : rhyme_group;       (** 韵组 *)
  variants : string list;    (** 同韵异形字 *)
  frequency : float;         (** 使用频率 *)
}
(** 统一韵律条目类型 *)

type unified_rhyme_group = {
  group_id : rhyme_group;    (** 韵组标识符 *)
  group_name : string;       (** 韵组名称 *)
  entries : unified_rhyme_entry list; (** 韵组内的所有字符 *)
  description : string;      (** 韵组描述 *)
}
(** 统一韵组类型 *)

type database_stats = {
  total_characters : int;    (** 总字符数 *)
  total_groups : int;        (** 总韵组数 *)
  ping_sheng_count : int;    (** 平声字数 *)
  ze_sheng_count : int;      (** 仄声字数 *)
  ru_sheng_count : int;      (** 入声字数 *)
}
(** 数据库统计信息 *)

type unified_rhyme_database = {
  version : string;                                    (** 数据库版本 *)
  groups : unified_rhyme_group list;                   (** 所有韵组 *)
  index : (string, unified_rhyme_entry) Hashtbl.t;    (** 字符索引 *)
  stats : database_stats;                              (** 统计信息 *)
}
(** 统一韵律数据库类型 *)

(** {2 核心API接口} *)

val find_rhyme_info : string -> unified_rhyme_entry option
(** 查找字符的韵律信息
    @param character 要查找的字符
    @return 韵律信息，如果找不到则返回None *)

val check_rhyme : string -> string -> bool
(** 检查两个字符是否押韵
    @param char1 第一个字符
    @param char2 第二个字符
    @return 如果两字符属于同一韵组则返回true *)

val get_rhyme_group_characters : rhyme_group -> string list
(** 获取指定韵组的所有字符
    @param group_id 韵组标识符
    @return 该韵组包含的所有字符列表 *)

val get_database_stats : unit -> database_stats
(** 获取数据库统计信息
    @return 包含字符数、韵组数等统计的记录 *)

val get_available_rhyme_groups : unit -> (rhyme_group * string * string) list
(** 获取所有可用韵组列表
    @return (韵组ID, 韵组名称, 描述)的列表 *)

(** {3 向后兼容性接口} *)

val get_an_rhyme_data : unit -> unified_rhyme_entry list
(** 获取安韵组数据 - 兼容旧API *)

val get_si_rhyme_data : unit -> unified_rhyme_entry list  
(** 获取思韵组数据 - 兼容旧API *)

val get_tian_rhyme_data : unit -> unified_rhyme_entry list
(** 获取天韵组数据 - 兼容旧API *)

val get_yu_rhyme_data : unit -> unified_rhyme_entry list
(** 获取鱼韵组数据 - 兼容旧API *)

val get_hua_rhyme_data : unit -> unified_rhyme_entry list
(** 获取花韵组数据 - 兼容旧API *)

val get_unified_database : unit -> unified_rhyme_database
(** 获取完整的统一数据库
    @return 整合后的统一韵律数据库 *)