(** 韵律模块向后兼容接口
    
    Author: Whisky, PR Worker
    Issue: #1999 - Poetry韵律模块统一整合实施 *)

open Rhyme_core_unified

(** {1 传统韵律数据接口} *)

module Legacy_Rhyme_Data : sig
  type legacy_rhyme_entry = {
    character: string;
    category: rhyme_category;
    group: rhyme_group;
    variants: string list;
    usage_frequency: float;
  }
  
  type legacy_rhyme_group_data = {
    group_name: string;
    group_description: string;
    entries: legacy_rhyme_entry list;
    example_poems: string list;
  }
  
  val to_legacy_entry : rhyme_character_info -> legacy_rhyme_entry
  val to_legacy_group_data : rhyme_group -> legacy_rhyme_group_data
end

(** {1 各韵组兼容模块} *)

module An_Rhyme_Data_Compat : sig
  val an_rhyme_data : Legacy_Rhyme_Data.legacy_rhyme_group_data
  val get_an_characters : unit -> string list
  val is_an_rhyme : string -> bool
end

module Si_Rhyme_Data_Compat : sig
  val si_rhyme_data : Legacy_Rhyme_Data.legacy_rhyme_group_data
  val get_si_characters : unit -> string list
  val is_si_rhyme : string -> bool
end

module Tian_Rhyme_Data_Compat : sig
  val tian_rhyme_data : Legacy_Rhyme_Data.legacy_rhyme_group_data
  val get_tian_characters : unit -> string list
  val is_tian_rhyme : string -> bool
end

module Wang_Rhyme_Data_Compat : sig
  val wang_rhyme_data : Legacy_Rhyme_Data.legacy_rhyme_group_data
  val get_wang_characters : unit -> string list
  val is_wang_rhyme : string -> bool
end

module Feng_Rhyme_Data_Compat : sig
  val feng_rhyme_data : Legacy_Rhyme_Data.legacy_rhyme_group_data
  val get_feng_characters : unit -> string list
  val is_feng_rhyme : string -> bool
end

module Yu_Rhyme_Data_Compat : sig
  val yu_rhyme_data : Legacy_Rhyme_Data.legacy_rhyme_group_data
  val get_yu_characters : unit -> string list
  val is_yu_rhyme : string -> bool
end

module Hua_Rhyme_Data_Compat : sig
  val hua_rhyme_data : Legacy_Rhyme_Data.legacy_rhyme_group_data
  val get_hua_characters : unit -> string list
  val is_hua_rhyme : string -> bool
end

module Qu_Rhyme_Data_Compat : sig
  val qu_rhyme_data : Legacy_Rhyme_Data.legacy_rhyme_group_data
  val get_qu_characters : unit -> string list
  val is_qu_rhyme : string -> bool
end

module Yue_Rhyme_Data_Compat : sig
  val yue_rhyme_data : Legacy_Rhyme_Data.legacy_rhyme_group_data
  val get_yue_characters : unit -> string list
  val is_yue_rhyme : string -> bool
end

module Jiang_Rhyme_Data_Compat : sig
  val jiang_rhyme_data : Legacy_Rhyme_Data.legacy_rhyme_group_data
  val get_jiang_characters : unit -> string list
  val is_jiang_rhyme : string -> bool
end

module Hui_Rhyme_Data_Compat : sig
  val hui_rhyme_data : Legacy_Rhyme_Data.legacy_rhyme_group_data
  val get_hui_characters : unit -> string list
  val is_hui_rhyme : string -> bool
end

(** {1 传统查询接口} *)

module Legacy_Query_Compat : sig
  val lookup_rhyme_group : string -> rhyme_group option
  val lookup_tone : string -> rhyme_category option
  val check_rhyme_compatibility : string -> string -> bool
  val batch_lookup_rhymes : string list -> (string * rhyme_group) list
  val get_rhyme_group_characters : rhyme_group -> string list
end

(** {1 声调兼容模块} *)

module Ping_Sheng_Compat : sig
  val ping_sheng_an_rhyme : rhyme_character_info list
  val ping_sheng_si_rhyme : rhyme_character_info list
  val ping_sheng_tian_rhyme : rhyme_character_info list
  val ping_sheng_wang_rhyme : rhyme_character_info list
  val ping_sheng_yu_rhyme : rhyme_character_info list
  val ping_sheng_feng_rhyme : rhyme_character_info list
  val is_ping_sheng : string -> bool
  val get_all_ping_sheng_chars : unit -> string list
end

module Ze_Sheng_Compat : sig
  val ze_sheng_qu_rhyme : rhyme_character_info list
  val ze_sheng_hua_rhyme : rhyme_character_info list
  val ze_sheng_jiang_rhyme : rhyme_character_info list
  val ze_sheng_hui_rhyme : rhyme_character_info list
  val is_ze_sheng : string -> bool
  val get_all_ze_sheng_chars : unit -> string list
end

module Ru_Sheng_Compat : sig
  val ru_sheng_yue_rhyme : rhyme_character_info list
  val ru_sheng_xue_rhyme : rhyme_character_info list
  val is_ru_sheng : string -> bool
  val get_all_ru_sheng_chars : unit -> string list
end

(** {1 缓存兼容} *)

module Legacy_Cache_Compat : sig
  val initialize_rhyme_cache : unit -> unit
  val clear_rhyme_cache : unit -> unit
  val get_cache_statistics : unit -> float * int * int
end

(** {1 统一兼容API} *)

module Legacy_API : sig
  module An_Rhyme : module type of An_Rhyme_Data_Compat
  module Si_Rhyme : module type of Si_Rhyme_Data_Compat
  module Tian_Rhyme : module type of Tian_Rhyme_Data_Compat
  module Wang_Rhyme : module type of Wang_Rhyme_Data_Compat
  module Feng_Rhyme : module type of Feng_Rhyme_Data_Compat
  module Yu_Rhyme : module type of Yu_Rhyme_Data_Compat
  module Hua_Rhyme : module type of Hua_Rhyme_Data_Compat
  module Qu_Rhyme : module type of Qu_Rhyme_Data_Compat
  module Yue_Rhyme : module type of Yue_Rhyme_Data_Compat
  module Jiang_Rhyme : module type of Jiang_Rhyme_Data_Compat
  module Hui_Rhyme : module type of Hui_Rhyme_Data_Compat
  
  module Ping_Sheng : module type of Ping_Sheng_Compat
  module Ze_Sheng : module type of Ze_Sheng_Compat
  module Ru_Sheng : module type of Ru_Sheng_Compat
  
  module Query : module type of Legacy_Query_Compat
  module Cache : module type of Legacy_Cache_Compat
  
  val rhyme_lookup : string -> rhyme_group option
  val tone_lookup : string -> rhyme_category option
  val rhyme_match : string -> string -> bool
  val is_ping_sheng : string -> bool
  val is_ze_sheng : string -> bool
  val is_ru_sheng : string -> bool
end

(** {1 兼容性验证} *)

val validate_backward_compatibility : unit -> bool
val print_compatibility_summary : unit -> unit