(** 骆言诗词形式专项评价模块接口 *)

open Poetry_types_consolidated

(** {1 改进建议生成} *)

(** 根据评价报告生成改进建议
    @param report 艺术性评价报告
    @return 改进建议列表 *)
val generate_improvement_suggestions : artistic_report -> string list

(** {1 诗词形式专项评价函数} *)

(** 评价四言骈体诗的艺术性
    @param verses 诗句数组
    @return 艺术性评价报告 *)
val evaluate_siyan_parallel_prose : string array -> artistic_report

(** 评价五言律诗的艺术性
    @param verses 诗句数组（应为8句）
    @return 艺术性评价报告 *)
val evaluate_wuyan_lushi : string array -> artistic_report

(** 评价七言绝句的艺术性
    @param verses 诗句数组（应为4句）
    @return 艺术性评价报告 *)
val evaluate_qiyan_jueju : string array -> artistic_report

(** 根据诗词形式评价艺术性
    @param form 诗词形式
    @param verses 诗句数组
    @return 艺术性评价报告 *)
val evaluate_poetry_by_form : poetry_form -> string array -> artistic_report