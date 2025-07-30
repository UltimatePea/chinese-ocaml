(** 统一韵律核心数据模块接口 - 修复版本
    
    这个接口为修复后的韵律数据模块提供类型安全的API，
    确保O(1)性能和数据完整性。
    
    Author: Charlie, 规划代理
    @version 2.0 - 修复版：响应Issue #1801质量问题
    @since 2025-07-30 - Fix #1801 系统性质量问题修复 *)

open Poetry_core.Poetry_types

(** {1 核心数据结构} *)

type rhyme_entry = {
  character : string;
  category : rhyme_category;
  group : rhyme_group;
  frequency : float;
  variants : string list;
}

type rhyme_group_data = {
  group : rhyme_group;
  ping_sheng_chars : string list;
  ze_sheng_chars : string list;
  shang_sheng_chars : string list;
  qu_sheng_chars : string list;
  ru_sheng_chars : string list;
}

type statistics = {
  total_groups : int;
  total_characters : int;
  performance_info : string;
  data_integrity : string;
}

type integrity_report = {
  duplicate_characters : string list;
  total_characters : int;
  classification_errors : string list;
  integrity_status : string;
}

(** {1 核心API函数} *)

(** 根据韵组获取数据 *)
val get_rhyme_group_data : rhyme_group -> rhyme_group_data option

(** 根据字符查找韵组和声调 - O(1)性能 *)
val find_character_rhyme : string -> (rhyme_group * rhyme_category) option

(** 验证两个字符是否同韵 - O(1)性能 *)
val are_rhyme_matched : string -> string -> bool

(** 获取指定韵组的所有字符 *)
val get_all_characters_in_group : rhyme_group -> string list

(** 获取所有韵字总数 *)
val get_total_character_count : unit -> int

(** 获取统计信息 *)
val get_statistics : unit -> statistics

(** {1 数据完整性验证} *)

(** 检查数据重复 *)
val check_data_integrity : unit -> string list * int

(** 验证韵组分类正确性 *)
val validate_rhyme_classifications : unit -> string list

(** 运行完整性检查 *)
val run_integrity_check : unit -> integrity_report

(** {1 数据常量} *)

(** 所有韵组数据 *)
val all_rhyme_groups : rhyme_group_data list