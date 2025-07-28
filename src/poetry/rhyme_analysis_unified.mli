(** 统一韵律分析模块接口
    
    整合基础与高级韵律分析功能的统一接口。
    提供全面的韵律分析能力，消除原有模块间的功能重复。
    
    Author: Beta, 代码审查代理
    版本: 统一重构版 v1.0 *)

(** {1 基础工具函数} *)

(** UTF-8字符列表转换函数 *)
val utf8_to_char_list : string -> string list

(** {1 基础韵律分析函数} *)

(** 查找字符韵律信息 *)
val find_rhyme_info : char -> (Poetry_core.Rhyme_core_types.rhyme_category * Poetry_core.Rhyme_core_types.rhyme_group) option

(** 检测韵律类别 *)
val detect_rhyme_category : char -> Poetry_core.Rhyme_core_types.rhyme_category
val detect_rhyme_category_by_string : string -> Poetry_core.Rhyme_core_types.rhyme_category

(** 检测韵组 *)
val detect_rhyme_group : char -> Poetry_core.Rhyme_core_types.rhyme_group

(** 字符韵律匹配 *)
val chars_rhyme : char -> char -> bool

(** 韵字建议 *)
val suggest_rhyme_characters : Poetry_core.Rhyme_core_types.rhyme_group -> string list

(** 提取韵律结尾 *)
val extract_rhyme_ending : string -> char option

(** 验证韵律一致性 *)
val validate_rhyme_consistency : string list -> bool

(** 验证韵律方案 *)
val validate_rhyme_scheme : string list -> char list -> bool

(** 生成基础韵律报告 *)
val generate_rhyme_report : string -> Poetry_types_consolidated.verse_rhyme_analysis

(** {1 高级韵律分析函数} *)

(** 分析文本韵律模式
    @param text 要分析的文本
    @return (韵类分布, 韵组分布) *)
val analyze_rhyme_pattern : string -> (Poetry_core.Rhyme_core_types.rhyme_category * int) list * (Poetry_core.Rhyme_core_types.rhyme_group * int) list

(** 获取韵律数据统计信息
    @return (总字符数, 总韵组数, 韵类统计) *)
val get_rhyme_stats : unit -> int * int * (Poetry_core.Rhyme_core_types.rhyme_category * int) list

(** {1 统一分析接口} *)

(** 综合韵律分析结果类型 *)
type comprehensive_analysis = {
  basic_report : Poetry_types_consolidated.verse_rhyme_analysis;
  pattern_analysis : (Poetry_core.Rhyme_core_types.rhyme_category * int) list * (Poetry_core.Rhyme_core_types.rhyme_group * int) list;
  stats : int * int * (Poetry_core.Rhyme_core_types.rhyme_category * int) list;
  analysis_version : string;
  timestamp : float;
}

(** 综合韵律分析 - 新的统一接口 *)
val comprehensive_rhyme_analysis : string -> comprehensive_analysis

(** {1 向后兼容性接口} *)

(** 基础韵律模式分析（兼容原 rhyme_analysis） *)
val analyze_rhyme_pattern_basic : string -> Poetry_types_consolidated.verse_rhyme_analysis

(** 高级韵律模式分析（兼容原 rhyme_advanced_analysis） *)
val analyze_rhyme_pattern_advanced : string -> (Poetry_core.Rhyme_core_types.rhyme_category * int) list * (Poetry_core.Rhyme_core_types.rhyme_group * int) list

(** 韵律质量评估 - 统一评估标准 *)
val evaluate_rhyme_quality : string -> Poetry_types_consolidated.verse_rhyme_analysis