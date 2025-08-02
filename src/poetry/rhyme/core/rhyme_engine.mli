(** 骆言韵律系统统一引擎接口 - Phase 1整合版本
    
    Author: Whisky, PR Worker  
    Date: 2025-08-02
    Issue: #2084 Poetry模块架构整合计划
    
    此模块提供统一的韵律系统核心功能接口，整合了原有分散的韵律模块。
    *)

open Poetry_core.Poetry_types

(** {1 配置和状态类型} *)

type rhyme_engine_config = {
  strict_mode: bool;           (** 严格模式 - 更严格的韵律要求 *)
  cache_enabled: bool;         (** 启用缓存 *)
  custom_groups: (string * rhyme_group) list; (** 自定义韵组 *)
}

type rhyme_lookup_result = {
  character: string;
  category: rhyme_category;
  group: rhyme_group;
  confidence: float;
  variants: string list;
}

type rhyme_match_assessment = {
  char1: string;
  char2: string;
  is_match: bool;
  match_quality: float;
  match_reason: string;
}

(** {2 核心韵律查找功能} *)

val find_rhyme_info : string -> rhyme_lookup_result option
(** [find_rhyme_info character] 查找字符的完整韵律信息 *)

val detect_rhyme_category : string -> rhyme_category
(** [detect_rhyme_category character] 检测字符的韵类，未找到时返回平声 *)

val detect_rhyme_group : string -> rhyme_group  
(** [detect_rhyme_group character] 检测字符的韵组，未找到时返回UnknownRhyme *)

(** {3 韵律匹配和验证} *)

val chars_rhyme : string -> string -> rhyme_match_assessment
(** [chars_rhyme char1 char2] 判断两个字符是否押韵，返回详细评估结果 *)

val validate_rhyme_consistency : string list -> float * string list
(** [validate_rhyme_consistency characters] 检查字符列表的韵律一致性 *)

(** {4 批量韵律分析} *)

val analyze_verse_rhyme : string -> verse_rhyme_analysis
(** [analyze_verse_rhyme verse_text] 分析一句诗的韵律结构 *)

(** {5 引擎配置和状态管理} *)

val default_config : rhyme_engine_config
(** 默认引擎配置 *)

val update_config : rhyme_engine_config -> unit
(** [update_config new_config] 更新引擎配置 *)

val get_engine_stats : unit -> string
(** [get_engine_stats ()] 获取引擎运行统计信息 *)

val reset_engine : unit -> unit
(** [reset_engine ()] 重置引擎状态 *)

val initialize_engine : ?config:rhyme_engine_config -> unit -> unit
(** [initialize_engine ~config ()] 初始化引擎，可选配置参数 *)

(** {6 向后兼容接口} *)

val rhyme_category_from_char : string -> rhyme_category
(** 兼容旧版本的韵类检测接口 *)

val rhyme_group_from_char : string -> rhyme_group  
(** 兼容旧版本的韵组检测接口 *)

val check_rhyme_match : string -> string -> rhyme_match_assessment
(** 兼容旧版本的韵律匹配接口 *)

(** {7 引擎信息} *)

val engine_version : string
(** 引擎版本号 *)

val engine_description : string  
(** 引擎描述信息 *)