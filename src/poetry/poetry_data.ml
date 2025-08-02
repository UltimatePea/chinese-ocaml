(** Poetry_data stub module - Fix Issue #2055
 * 
 * 诗词数据存根模块，解决编译依赖问题
 * Author: Whisky, PR Worker  
 * Date: 2025-08-02
 *)

module Word_class_types = struct
  type word_class = 
    | Noun | Verb | Adjective | Adverb | Other
  
  type word_info = {
    word: string;
    class_type: word_class;
    meaning: string;
  }
end