(** 骆言诗词艺术性评价核心函数模块接口 *)

open Poetry_types_consolidated

(** {1 内部辅助函数} *)

(** 高效子串搜索
    @param text 目标文本
    @param pattern 搜索模式
    @return 是否包含子串 *)
val contains_substring : string -> string -> bool

(** 统计意象关键词出现次数
    @param verse 诗句
    @return 意象关键词数量 *)
val count_imagery_words : string -> int

(** 统计雅致词汇出现次数
    @param verse 诗句
    @return 雅致词汇数量 *)
val count_elegant_words : string -> int

(** {1 单维度艺术性评价函数} *)

(** 评估诗句的韵律和谐度
    @param verse 待评估的诗句字符串
    @return 韵律和谐度评分，范围0.0-1.0 *)
val evaluate_rhyme_harmony : string -> float

(** 评估诗句的声调平衡度
    @param verse 待评估的诗句字符串
    @param expected_pattern 期望的声调模式（可选）
    @return 声调平衡度评分，范围0.0-1.0 *)
val evaluate_tonal_balance : string -> bool list option -> float

(** 评估两句诗的对仗质量
    @param left_verse 左句
    @param right_verse 右句
    @return 对仗质量评分，范围0.0-1.0 *)
val evaluate_parallelism : string -> string -> float

(** 评估诗句的意象密度和艺术表现力
    @param verse 待评估的诗句字符串
    @return 意象密度评分，范围0.0-1.0 *)
val evaluate_imagery : string -> float

(** 评估诗句的节奏感
    @param verse 待评估的诗句字符串
    @return 节奏感评分，范围0.0-1.0 *)
val evaluate_rhythm : string -> float

(** 评估诗句的雅致程度
    @param verse 待评估的诗句字符串
    @return 雅致程度评分，范围0.0-1.0 *)
val evaluate_elegance : string -> float

(** {1 综合艺术性评价函数} *)

(** 确定综合评价等级
    @param scores 各维度评分
    @return 综合评价等级 *)
val determine_overall_grade : artistic_scores -> evaluation_grade

(** 综合艺术性评价函数
    @param verse 待评估的诗句字符串
    @param expected_pattern 期望的声调模式（可选）
    @return 综合艺术性评价报告 *)
val comprehensive_artistic_evaluation : string -> bool list option -> artistic_report