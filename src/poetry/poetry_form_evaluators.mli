(** 骆言诗词形式评价器模块接口
    
    此模块提供针对不同诗词形式的专用评价器。
    
    Author: Beta, Code Reviewer
    @since 2025-07-25 - 技术债务重构Phase 3 *)

open Poetry_types_consolidated

(** {1 诗词形式专项评价函数} *)

val evaluate_siyan_parallel_prose : string array -> artistic_report
(** 四言骈体专项评价
    @param verses 四言骈体诗句数组
    @return 四言骈体专项评价报告 *)

val evaluate_wuyan_lushi : string array -> artistic_report
(** 五言律诗专项评价
    @param verses 五言律诗八句诗句数组
    @return 五言律诗专项评价报告 *)

val evaluate_qiyan_jueju : string array -> artistic_report
(** 七言绝句专项评价
    @param verses 七言绝句四句诗句数组
    @return 七言绝句专项评价报告 *)

val evaluate_poetry_by_form : poetry_form -> string array -> artistic_report
(** 根据诗词形式进行相应的艺术性评价
    @param form 诗词形式
    @param verses 诗句数组
    @return 对应形式的艺术性评价报告 *)

(** {1 传统诗词品评函数} *)

val poetic_critique : string -> poetry_form -> artistic_report
(** 诗词品评
    @param verse 诗句字符串
    @param form 诗词类型
    @return 艺术性评价报告，包含传统品评风格的建议 *)

val poetic_aesthetics_guidance : string -> poetry_form -> artistic_report
(** 诗词美学指导系统
    @param verse 诗句字符串
    @param form 诗词类型
    @return 美学指导分析报告 *)

(** {1 高阶艺术性分析函数} *)

val analyze_artistic_progression : string array -> float list
(** 分析艺术性递进
    @param verses 诗句数组
    @return 每句的艺术性得分列表 *)

val compare_artistic_quality : string -> string -> int
(** 比较艺术性质量
    @param verse1 第一句诗
    @param verse2 第二句诗
    @return 比较结果（1=第一句更优，0=相等，-1=第二句更优） *)

val detect_artistic_flaws : string -> string list
(** 检测艺术性缺陷
    @param verse 诗句字符串
    @return 发现的缺陷描述列表 *)