(** 韵律模块统一类型定义接口
    
    本接口定义了韵律模块的所有核心类型，为韵律数据整合提供统一的类型基础。
    
    Author: Whisky, PR Worker
    Issue: #1999 - Poetry韵律模块统一整合实施 *)

(** {1 基础韵律类型} *)

(** 声调类型 - 基于传统四声系统 *)
type tone_category = 
  | PingSheng    (** 平声：第一、二声 *)
  | ShangSheng   (** 上声：第三声 *)
  | QuSheng      (** 去声：第四声 *)
  | RuSheng      (** 入声：古代汉语特有 *)

(** 韵组枚举 - 基于《平水韵》韵组体系 *)
type rhyme_group = 
  | AnRhyme | SiRhyme | TianRhyme | WangRhyme | QuRhyme 
  | YuRhyme | HuaRhyme | FengRhyme | YueRhyme | JiangRhyme 
  | HuiRhyme | UnknownRhyme

(** 韵律字符信息 *)
type rhyme_character = {
  character: string;
  tone: tone_category;
  rhyme_group: rhyme_group;
  variants: string list;
  usage_frequency: float;
  is_common: bool;
  pinyin: string option;
}

(** 韵组数据结构 *)
type rhyme_group_data = {
  group_id: rhyme_group;
  group_name: string;
  description: string;
  ping_sheng_chars: string list;
  ze_sheng_chars: string list;
  all_characters: rhyme_character list;
  example_poems: string list;
}

(** 韵律查询结果 *)
type query_result = 
  | Found of rhyme_character
  | NotFound of string
  | MultipleMatches of rhyme_character list

(** 韵律统计信息 *)
type rhyme_statistics = {
  total_characters: int;
  total_groups: int;
  ping_sheng_count: int;
  ze_sheng_count: int;
  group_distribution: (rhyme_group * int) list;
  most_frequent_group: rhyme_group;
  least_frequent_group: rhyme_group;
}

(** {1 辅助函数} *)

val string_of_rhyme_group : rhyme_group -> string
val string_of_tone_category : tone_category -> string
val is_ze_sheng : tone_category -> bool
val all_rhyme_groups : rhyme_group list
val all_tone_categories : tone_category list

(** {1 创建函数} *)

val make_rhyme_character : 
  ?variants:string list -> 
  ?usage_freq:float -> 
  ?is_common:bool -> 
  ?pinyin:string option -> 
  string -> tone_category -> rhyme_group -> rhyme_character

val make_ping_char : string -> rhyme_group -> rhyme_character
val make_ze_char : string -> rhyme_group -> rhyme_character