(** 骆言诗词分析工具模块接口
    
    此模块提供诗词艺术性分析所需的工具函数。
    
    Author: Beta, Code Reviewer
    @since 2025-07-25 - 技术债务重构Phase 3 *)

open Poetry_types_consolidated

(** {1 字符串处理工具} *)

val contains_substring : string -> string -> bool
(** 高效子串搜索
    @param text 待搜索的文本
    @param pattern 要查找的模式
    @return 是否包含该子串 *)

(** {1 词汇计数分析} *)

val count_imagery_words : string -> int
(** 计算诗句中意象词汇的数量
    @param verse 诗句字符串
    @return 意象词汇数量 *)

val count_elegant_words : string -> int
(** 计算诗句中雅致词汇的数量
    @param verse 诗句字符串
    @return 雅致词汇数量 *)

(** {1 改进建议生成} *)

val generate_improvement_suggestions : artistic_report -> string list
(** 生成改进建议
    @param report 艺术性评价报告
    @return 改进建议列表 *)

(** {1 高阶分析工具} *)

val detect_artistic_flaws : string -> artistic_report -> string list
(** 检测艺术性缺陷
    @param verse 诗句字符串
    @param report 艺术性评价报告
    @return 发现的缺陷描述列表 *)

val calculate_overall_score : artistic_report -> float
(** 计算综合艺术性得分
    @param report 艺术性评价报告
    @return 综合得分 *)