(** 统一韵律数据模块接口 - 整合所有韵组数据
    
    此模块整合了分散在多个rhyme_groups_*.ml文件中的韵组数据，
    提供统一的访问接口，减少模块数量和维护复杂度。
    
    @author Alpha, 主要工作代理
    @version 1.0 - Phase 2.1 韵组数据整合
    @since 2025-07-30
    @fix_issue #1753 *)

(** {1 统一韵组数据访问模块} *)

(** 所有韵组数据的统一访问模块 *)
module Unified_rhyme_data : sig
  
  (** 获取所有韵组数据 
      @return 包含所有韵组字符数据的列表 *)
  val get_all_rhyme_data : unit -> (string * Poetry_core.Types.rhyme_category * Poetry_core.Types.rhyme_group) list
  
  (** 按韵组获取数据
      @param group 目标韵组
      @return 该韵组的所有字符数据 *)
  val get_rhyme_data_by_group : Poetry_core.Types.rhyme_group -> (string * Poetry_core.Types.rhyme_category * Poetry_core.Types.rhyme_group) list
  
  (** 获取韵组统计信息
      @return (总字符数, 平声字符数, 仄声字符数) *)
  val get_rhyme_stats : unit -> int * int * int
  
end

(** {1 向后兼容性接口} *)

(** 安韵组数据 *)
val an_rhyme_data : (string * Poetry_core.Types.rhyme_category * Poetry_core.Types.rhyme_group) list

(** 思韵组数据 *)
val si_rhyme_data : (string * Poetry_core.Types.rhyme_category * Poetry_core.Types.rhyme_group) list

(** 天韵组数据 *)
val tian_rhyme_data : (string * Poetry_core.Types.rhyme_category * Poetry_core.Types.rhyme_group) list

(** 王韵组数据 *)
val wang_rhyme_data : (string * Poetry_core.Types.rhyme_category * Poetry_core.Types.rhyme_group) list

(** 曲韵组数据 *)
val qu_rhyme_data : (string * Poetry_core.Types.rhyme_category * Poetry_core.Types.rhyme_group) list

(** 鱼韵组数据 *)
val yu_rhyme_data : (string * Poetry_core.Types.rhyme_category * Poetry_core.Types.rhyme_group) list

(** 花韵组数据 *)
val hua_rhyme_data : (string * Poetry_core.Types.rhyme_category * Poetry_core.Types.rhyme_group) list

(** 风韵组数据 *)
val feng_rhyme_data : (string * Poetry_core.Types.rhyme_category * Poetry_core.Types.rhyme_group) list

(** 月韵组数据 *)
val yue_rhyme_data : (string * Poetry_core.Types.rhyme_category * Poetry_core.Types.rhyme_group) list

(** 江韵组数据 *)
val jiang_rhyme_data : (string * Poetry_core.Types.rhyme_category * Poetry_core.Types.rhyme_group) list

(** 会韵组数据 *)
val hui_rhyme_data : (string * Poetry_core.Types.rhyme_category * Poetry_core.Types.rhyme_group) list

(** {1 统一访问函数} *)

(** 获取所有韵组数据 *)
val get_all_rhyme_data : unit -> (string * Poetry_core.Types.rhyme_category * Poetry_core.Types.rhyme_group) list

(** 按韵组获取数据 *)
val get_rhyme_data_by_group : Poetry_core.Types.rhyme_group -> (string * Poetry_core.Types.rhyme_category * Poetry_core.Types.rhyme_group) list

(** 获取韵组统计信息 *)
val get_rhyme_stats : unit -> int * int * int