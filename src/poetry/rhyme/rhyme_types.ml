(** 韵律模块统一类型定义 - Phase 1-A 整合版
    
    Phase 1-A 重构：移除重复类型定义，改为引用poetry_types_consolidated权威源。
    消除技术债务，统一韵律类型系统。
    
    Author: Whisky, PR Worker
    Issue: #2158 - Phase 1-A 韵律系统整合
    
    重构成果:
    - 移除所有重复类型定义
    - 统一使用 Poetry_types_consolidated 权威源
    - 保持向后兼容性
    
    @since 2025-08-03 
    @updated 2025-08-04 - Phase 1-A 实施 *)

(** Phase 1-A: 引用统一权威类型源 *)
(* Accessing consolidated types from parent poetry library *)
include Poetry_types.Poetry_types_consolidated

(** {1 基础韵律类型 - 从权威源导入} *)

(** Phase 1-A: 向后兼容映射实现 *)
type tone_category = rhyme_category

(** 所有重复类型定义已移除，统一使用 Poetry_types_consolidated 权威源 *)

(** Phase 1-A: rhyme_group_data 和 query_result 现从权威源导入 *)

(** 韵律统计信息 *)
type rhyme_statistics = {
  total_characters: int;          (** 总字符数 *)
  total_groups: int;              (** 总韵组数 *)
  ping_sheng_count: int;          (** 平声字符数 *)
  ze_sheng_count: int;            (** 仄声字符数（上去入） *)
  group_distribution: (rhyme_group * int) list; (** 各韵组字符分布 *)
  most_frequent_group: rhyme_group; (** 字符最多的韵组 *)
  least_frequent_group: rhyme_group; (** 字符最少的韵组 *)
}

(** {1 辅助类型和函数} *)

(** 韵组到字符串的映射 *)
let string_of_rhyme_group = function
  | AnRhyme -> "安韵"
  | SiRhyme -> "思韵"
  | TianRhyme -> "天韵"
  | WangRhyme -> "王韵"
  | QuRhyme -> "去韵"
  | YuRhyme -> "鱼韵"
  | HuaRhyme -> "花韵"
  | FengRhyme -> "风韵"
  | YueRhyme -> "月韵"
  | JiangRhyme -> "江韵"
  | HuiRhyme -> "灰韵"
  | UnknownRhyme -> "未知韵组"

(** 声调到字符串的映射 *)
let string_of_tone_category = function
  | PingSheng -> "平声"
  | ShangSheng -> "上声"
  | QuSheng -> "去声"
  | RuSheng -> "入声"
  | ZeSheng -> "仄声"

(** 判断是否为仄声 *)
let is_ze_sheng = function
  | ShangSheng | QuSheng | RuSheng | ZeSheng -> true
  | PingSheng -> false

(** 获取所有韵组列表 *)
let all_rhyme_groups = [
  AnRhyme; SiRhyme; TianRhyme; WangRhyme; QuRhyme; 
  YuRhyme; HuaRhyme; FengRhyme; YueRhyme; JiangRhyme; HuiRhyme
]

(** 获取所有声调类别 *)
let all_tone_categories = [PingSheng; ShangSheng; QuSheng; RuSheng]

(** 创建韵律字符的辅助函数 *)
let make_rhyme_character ?(variants=[]) ?(usage_freq=1.0) ?(is_common=true) 
                         ?(pinyin=None) ?(confidence=1.0) char tone group =
  {
    character = char;
    rhyme_category = tone;
    rhyme_group = group;
    confidence = confidence;
    variants = variants;
    usage_frequency = usage_freq;
    is_common = is_common;
    pinyin = pinyin;
  }

(** 创建简单平声字符 *)
let make_ping_char char group = 
  make_rhyme_character char PingSheng group

(** 创建简单仄声字符（默认为去声） *)
let make_ze_char char group = 
  make_rhyme_character char QuSheng group