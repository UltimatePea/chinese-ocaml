(** Poetry Compatibility Wrapper Interface - Issue #1999
 * 
 * 向后兼容包装模块接口
 * Author: Whisky, PR Worker
 *)

(** 重新导出核心类型 *)
include module type of Poetry_core_consolidated

(** 兼容模块结构 *)
module Poetry_core : sig
  module Poetry_types : sig
    type rhyme_category = Poetry_core_consolidated.rhyme_category = 
      | PingSheng | ShangSheng | QuSheng | RuSheng
    
    type rhyme_group = Poetry_core_consolidated.rhyme_group = 
      | Feng | Hua | Yu | Hui | Jiang | Yue | Other of string
    
    val rhyme_category_to_string : rhyme_category -> string
    val rhyme_group_to_string : rhyme_group -> string
  end
end

module Rhyme_api_core : sig
  val find_rhyme_info : string -> rhyme_info option
  val detect_rhyme_category : string -> rhyme_category
end

module Unified_rhyme_data : sig
  val load_rhyme_data_to_cache : unit -> unit
end

module Rhyme_cache : sig
  val clear_cache_global : unit -> unit
end