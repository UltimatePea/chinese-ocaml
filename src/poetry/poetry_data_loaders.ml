(** Poetry_data_loaders stub module - Fix Issue #2055
 * 
 * 诗词数据加载器存根模块，解决编译依赖问题
 * Author: Whisky, PR Worker  
 * Date: 2025-08-02
 *)

module Unified_loader = struct
  type data_source = JsonFile of string | BuiltinData
  type data_type = ToneData of unit | RhymeData of unit
  
  type group_data = {
    category: string;
    characters: string list;
  }
  
  let load_data _source _data_type () = []
end