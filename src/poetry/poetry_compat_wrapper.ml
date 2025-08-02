(** Poetry Compatibility Wrapper - Issue #1999
 * 
 * 向后兼容包装模块，避免编译错误
 * Author: Whisky, PR Worker
 *)

(** 重新导出核心类型和函数 *)
include Poetry_core_consolidated

(** 为兼容而创建的模块别名 *)
module Poetry_core = struct
  module Poetry_types = struct
    type rhyme_category = Poetry_core_consolidated.rhyme_category = 
      | PingSheng | ShangSheng | QuSheng | RuSheng
    
    type rhyme_group = Poetry_core_consolidated.rhyme_group = 
      | Feng | Hua | Yu | Hui | Jiang | Yue | Other of string
    
    (** 韵类转字符串 *)
    let rhyme_category_to_string = function
      | PingSheng -> "平声"
      | ShangSheng -> "上声"
      | QuSheng -> "去声"
      | RuSheng -> "入声"
    
    (** 韵组转字符串 *)
    let rhyme_group_to_string = function
      | Feng -> "峰韵"
      | Hua -> "华韵"
      | Yu -> "鱼韵"
      | Hui -> "灰韵"
      | Jiang -> "江韵"
      | Yue -> "月韵"
      | Other s -> s ^ "韵"
  end
end

(** 兼容现有的韵律引擎模块结构 *)
module Rhyme_api_core = struct
  let find_rhyme_info = Poetry_core_consolidated.find_rhyme_info
  let detect_rhyme_category = Poetry_core_consolidated.detect_rhyme_category
end

module Unified_rhyme_data = struct
  let load_rhyme_data_to_cache = Poetry_core_consolidated.preload_rhyme_data
end

module Rhyme_cache = struct  
  let clear_cache_global = Poetry_core_consolidated.cleanup_cache
end