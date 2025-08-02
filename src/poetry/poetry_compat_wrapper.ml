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