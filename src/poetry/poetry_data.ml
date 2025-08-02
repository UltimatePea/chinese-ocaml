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

module Externalized_data_loader = struct
  type tone_data = {
    character : string;
    tone : string;
    category : string;
  }
  
  type tone_record = {
    char : string;
    tone_value : int;
    tone_name : string;
  }
  
  let load_tone_data () = []
  let get_character_tone _char = "平声"
  let validate_tone_data _data = true
end