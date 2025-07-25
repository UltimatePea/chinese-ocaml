(** 骆言诗词评价引擎模块接口
    
    此模块实现诗词艺术性评价的核心算法。
    
    Author: Beta, Code Reviewer
    @since 2025-07-25 - 技术债务重构Phase 3 *)

open Poetry_types_consolidated

(** {1 单维度艺术性评价函数} *)

val evaluate_rhyme_harmony : string -> float
(** 评价韵律和谐度
    @param verse 诗句字符串
    @return 韵律和谐度得分（0.0-1.0） *)

val evaluate_tonal_balance : string -> bool list option -> float
(** 评价声调平衡度
    @param verse 诗句字符串
    @param expected_pattern 期望的平仄模式（true=平声，false=仄声）
    @return 声调平衡度得分（0.0-1.0） *)

val evaluate_parallelism : string -> string -> float
(** 评价对仗工整度
    @param left_verse 左联诗句
    @param right_verse 右联诗句
    @return 对仗工整度得分（0.0-1.0） *)

val evaluate_imagery : string -> float
(** 评价意象深度
    @param verse 诗句字符串
    @return 意象深度得分（0.0-1.0） *)

val evaluate_rhythm : string -> float
(** 评价节奏感
    @param verse 诗句字符串
    @return 节奏感得分（0.0-1.0） *)

val evaluate_elegance : string -> float
(** 评价雅致程度
    @param verse 诗句字符串
    @return 雅致程度得分（0.0-1.0） *)

(** {1 综合评价函数} *)

val determine_overall_grade : artistic_scores -> evaluation_grade
(** 综合评价等级判定
    @param scores 各维度艺术性得分
    @return 总体评价等级 *)

val comprehensive_artistic_evaluation : string -> bool list option -> artistic_report
(** 全面艺术性评价
    @param verse 诗句字符串
    @param expected_pattern 期望的平仄模式（None表示不检查平仄）
    @return 全面的艺术性评价报告 *)