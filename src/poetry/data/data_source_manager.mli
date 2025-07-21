(** 数据源管理模块接口 - 统一管理各种诗词数据源

    @author 骆言诗词编程团队 - Phase 15 超长文件重构
    @version 1.0
    @since 2025-07-21 *)

open Rhyme_groups.Rhyme_group_types

(** {1 数据源类型定义} *)

(** 数据源类型 - 支持多种数据来源 *)
type data_source =
  | ModuleData of (string * rhyme_category * rhyme_group) list
  | FileData of string
  | LazyData of (unit -> (string * rhyme_category * rhyme_group) list)

type data_source_entry = {
  name : string;
  source : data_source;
  priority : int;
  description : string;
}
(** 数据源注册项 *)

(** {1 数据源管理函数} *)

(** 注册数据源

    将新的数据源注册到全局注册表中。高优先级的数据源会覆盖低优先级的重复数据。

    @param name 数据源名称
    @param source 数据源
    @param priority 优先级 (数字越大优先级越高)
    @param description 描述信息 *)
val register_data_source : string -> data_source -> ?priority:int -> string -> unit

(** 从JSON文件加载韵律数据 - 重构后的模块化版本 *)
val load_rhyme_data_from_file : string -> (string * rhyme_category * rhyme_group) list

(** 从数据源加载数据 *)
val load_from_source : data_source -> (string * rhyme_category * rhyme_group) list

(** 获取所有注册的数据源名称 *)
val get_registered_source_names : unit -> string list

(** {1 数据源查询和管理} *)

(** 查找指定名称的数据源
    
    @param name 数据源名称
    @return 如果找到返回Some entry，否则返回None *)
val find_data_source : string -> data_source_entry option

(** 删除指定名称的数据源
    
    @param name 要删除的数据源名称
    @return 如果删除成功返回true，否则返回false *)
val remove_data_source : string -> bool

(** 获取按优先级排序的数据源列表
    
    @return 按优先级从高到低排序的数据源列表 *)
val get_sorted_sources : unit -> data_source_entry list

(** 清空所有注册的数据源 *)
val clear_all_sources : unit -> unit

(** {1 数据源统计} *)

(** 获取注册的数据源总数 *)
val get_source_count : unit -> int

(** 获取按优先级分组的数据源数量
    
    @return (高优先级数量, 中优先级数量, 低优先级数量) *)
val get_priority_distribution : unit -> int * int * int

(** {1 调试和监控} *)

(** 打印数据源注册信息 *)
val print_registered_sources : unit -> unit