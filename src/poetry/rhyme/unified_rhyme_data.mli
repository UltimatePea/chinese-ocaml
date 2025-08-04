(** 统一韵律数据模块接口
    
    将所有分散的韵组数据文件合并到统一的数据结构中，
    消除重复代码，提供统一的韵律数据访问接口。
    
    Author: Whisky, PR Worker
    Mission: 真正的韵律数据整合，减少文件碎片化
    Date: 2025-08-04
    Consolidates: 12个*_rhyme_data.ml文件 → 1个统一文件 *)

open Poetry_core.Rhyme_core_types

(** {1 韵组数据定义} *)

(** 韵律条目类型 *)
type rhyme_entry = {
  character : string;
  category : rhyme_category;
  group : rhyme_group;
  variants : string list;
  usage_frequency : float;
}

(** 韵组数据结构类型 *)
type rhyme_group_data = {
  group_name : rhyme_group;
  group_description : string;
  entries : rhyme_entry list;
  example_poems : string list;
}

(** {1 统一访问接口} *)

(** 获取指定韵组的基础信息 (描述, 平声字, 仄声字) *)
val get_rhyme_group_info : rhyme_group -> (string * string list * string list) option

(** 获取指定韵组的平声字列表 *)
val get_ping_sheng_chars : rhyme_group -> string list

(** 获取指定韵组的仄声字列表 *)
val get_ze_sheng_chars : rhyme_group -> string list

(** 创建指定韵组的完整数据结构 *)
val get_rhyme_data : rhyme_group -> rhyme_group_data

(** 列出所有可用的韵组及其描述 *)
val list_all_rhyme_groups : unit -> (rhyme_group * string) list

(** {1 向后兼容接口} *)

(** 安韵组数据模块 *)
module An_rhyme_data : sig
  val ping_sheng_chars : string list
  val ze_sheng_chars : string list
  val an_rhyme_data : rhyme_group_data
end

(** 风韵组数据模块 *)
module Feng_rhyme_data : sig
  val ping_sheng_chars : string list
  val ze_sheng_chars : string list
  val feng_rhyme_data : rhyme_group_data
end

(** 花韵组数据模块 *)
module Hua_rhyme_data : sig
  val ping_sheng_chars : string list
  val ze_sheng_chars : string list
  val hua_rhyme_data : rhyme_group_data
end

(** 辉韵组数据模块 *)
module Hui_rhyme_data : sig
  val ping_sheng_chars : string list
  val ze_sheng_chars : string list
  val hui_rhyme_data : rhyme_group_data
end

(** 江韵组数据模块 *)
module Jiang_rhyme_data : sig
  val ping_sheng_chars : string list
  val ze_sheng_chars : string list
  val jiang_rhyme_data : rhyme_group_data
end

(** 区韵组数据模块 *)
module Qu_rhyme_data : sig
  val ping_sheng_chars : string list
  val ze_sheng_chars : string list
  val qu_rhyme_data : rhyme_group_data
end

(** 思韵组数据模块 *)
module Si_rhyme_data : sig
  val ping_sheng_chars : string list
  val ze_sheng_chars : string list
  val si_rhyme_data : rhyme_group_data
end

(** 天韵组数据模块 *)
module Tian_rhyme_data : sig
  val ping_sheng_chars : string list
  val ze_sheng_chars : string list
  val tian_rhyme_data : rhyme_group_data
end

(** 王韵组数据模块 *)
module Wang_rhyme_data : sig
  val ping_sheng_chars : string list
  val ze_sheng_chars : string list
  val wang_rhyme_data : rhyme_group_data
end

(** 鱼韵组数据模块 *)
module Yu_rhyme_data : sig
  val ping_sheng_chars : string list
  val ze_sheng_chars : string list
  val yu_rhyme_data : rhyme_group_data
end

(** 月韵组数据模块 *)
module Yue_rhyme_data : sig
  val ping_sheng_chars : string list
  val ze_sheng_chars : string list
  val yue_rhyme_data : rhyme_group_data
end

(** 韵组数据注册模块 *)
module Rhyme_data_registry : sig
  (** 注册韵组数据 *)
  val register_rhyme_group : rhyme_group -> rhyme_group_data -> unit
  
  (** 获取已注册的韵组数据 *)
  val get_registered_rhyme_group : rhyme_group -> rhyme_group_data option
  
  (** 列出所有已注册的韵组 *)
  val list_registered_groups : unit -> rhyme_group list
  
  (** 初始化韵组注册表 *)
  val initialize : unit -> unit
end