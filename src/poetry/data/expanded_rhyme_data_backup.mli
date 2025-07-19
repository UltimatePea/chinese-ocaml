(** 扩展音韵数据模块接口 - 骆言诗词编程特性 Phase 16 重构版
    
    重构说明：原1249行的硬编码韵律数据已迁移至JSON文件，通过数据加载器动态加载。
    实现数据与代码分离，提高维护性和可扩展性。
    
    @author 骆言技术债务清理团队 Phase 16
    @version 2.0
    @since 2025-07-19 
    @refactored_from expanded_rhyme_data_backup.ml *)

(** 韵律分类类型 *)
type rhyme_category = Rhyme_data_loader.rhyme_category

(** 韵组分类类型 *)
type rhyme_group = Rhyme_data_loader.rhyme_group

(** ========== 分组字符数据接口 ========== *)

(** 鱼韵组核心常用字 *)
val yu_yun_core_chars : string list Lazy.t

(** 鱼韵组贾价系列 *)
val yu_yun_jia_chars : string list Lazy.t

(** 鱼韵组棋期系列 *)
val yu_yun_qi_chars : string list Lazy.t

(** 鱼韵组扩展鱼类字符 *)
val yu_yun_fish_chars : string list Lazy.t

(** 花韵组基础字符 *)
val hua_yun_basic_chars : string list Lazy.t

(** 风韵组基础字符 *)
val feng_yun_basic_chars : string list Lazy.t

(** 月韵组基础字符 *)
val yue_yun_basic_chars : string list Lazy.t

(** 灰韵组核心字符 *)
val hui_yun_core_chars : string list Lazy.t

(** 灰韵组剩余字符 *)
val hui_yun_remaining_chars : string list Lazy.t

(** ========== 韵组数据组装接口 ========== *)

(** 创建韵律数据项的辅助函数 
    @param chars 字符列表
    @param category 韵律分类
    @param group 韵组
    @return 韵律数据三元组列表 *)
val create_rhyme_data : string list -> rhyme_category -> rhyme_group -> 
  (string * rhyme_category * rhyme_group) list

(** 鱼韵组平声数据 *)
val yu_yun_ping_sheng : (string * rhyme_category * rhyme_group) list Lazy.t

(** 花韵组平声数据 *)
val hua_yun_ping_sheng : (string * rhyme_category * rhyme_group) list Lazy.t

(** 风韵组平声数据 *)
val feng_yun_ping_sheng : (string * rhyme_category * rhyme_group) list Lazy.t

(** 月韵组仄声数据 *)
val yue_yun_ze_sheng : (string * rhyme_category * rhyme_group) list Lazy.t

(** 江韵组仄声数据 *)
val jiang_yun_ze_sheng : (string * rhyme_category * rhyme_group) list Lazy.t

(** 灰韵组仄声数据 *)
val hui_yun_ze_sheng : (string * rhyme_category * rhyme_group) list Lazy.t

(** ========== 完整数据库接口 ========== *)

(** 扩展音韵数据库 - 合并所有韵组的完整数据库 *)
val expanded_rhyme_database : (string * rhyme_category * rhyme_group) list Lazy.t

(** 扩展音韵数据库字符统计
    @return 数据库中字符总数 *)
val expanded_rhyme_char_count : unit -> int

(** 获取扩展音韵数据库
    @return 完整的韵律数据库 *)
val get_expanded_rhyme_database : unit -> (string * rhyme_category * rhyme_group) list

(** 检查字符是否在扩展音韵数据库中
    @param char 要检查的字符
    @return 是否在数据库中 *)
val is_in_expanded_rhyme_database : string -> bool

(** 获取扩展音韵数据库中的字符列表
    @return 纯字符列表 *)
val get_expanded_char_list : unit -> string list

(** ========== 性能优化和诊断接口 ========== *)

(** 获取韵律数据库加载状态
    @return 数据库状态描述 *)
val get_database_load_status : unit -> string

(** 强制重新加载韵律数据库
    @return 重新加载后的状态描述 *)
val reload_rhyme_database : unit -> string

(** 获取韵组统计信息
    @return 各韵组的字符数量统计 *)
val get_rhyme_group_statistics : unit -> (rhyme_group * int) list

(** 模块初始化函数 - 预热韵律数据库 *)
val initialize_module : unit -> unit