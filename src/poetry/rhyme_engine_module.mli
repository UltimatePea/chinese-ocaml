(** 韵律引擎模块接口 - 统一引擎接口

    此模块提供统一的韵律引擎功能，支持技术债务清理过程中的回归测试。 作为过渡模块，将现有的引擎功能封装为统一接口。

    Author: Alpha, 主要工作代理
    @version 1.0 - 技术债务清理版本
    @since 2025-07-28 - Fix #1576 技术债务清理 *)

open Poetry_core.Poetry_types

val check_rhyme_match : string -> string -> bool
(** 检查两个字符是否押韵
    @param char1 第一个字符
    @param char2 第二个字符
    @return 是否押韵 *)

val analyze_pattern : string -> (rhyme_category * int) list * (rhyme_group * int) list
(** 分析文本的韵律模式
    @param text 文本
    @return 韵律模式分析结果 *)

val evaluate_quality : string -> float
(** 评估韵律质量
    @param text 文本
    @return 质量评分 *)

val detect_scheme : string list -> (int * rhyme_group) list
(** 检测押韵方案
    @param lines 诗句列表
    @return 押韵方案 *)

val suggest_rhyming_chars : string -> string list -> string list
(** 建议押韵字符
    @param reference_char 参考字符
    @param exclude_chars 排除字符列表
    @return 建议字符列表 *)
