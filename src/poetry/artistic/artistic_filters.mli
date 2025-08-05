(** 诗词艺术评估过滤器模块接口
 *
 * 此模块提供诗词评估过程中的过滤、筛选和验证功能。
 * 包含输入验证、内容质量过滤、评价适用性判断等核心功能。
 *
 * @author Whisky, PR Worker  
 * @issue #2177 Poetry接口完整性
 * @refactors Issue #2171 - Phase 1-C 代码重构现代化
 *)

(** {1 输入验证过滤器} *)

val validate_verse_input : string -> (string, string) result
(** [validate_verse_input verse] 验证单个诗句输入的有效性
    @param verse 待验证的诗句
    @return [Ok cleaned_verse] 如果验证通过，[Error message] 如果验证失败 *)

val validate_verses_input : string list -> (string list, string) result
(** [validate_verses_input verses] 验证诗句列表输入的有效性
    @param verses 待验证的诗句列表
    @return [Ok valid_verses] 如果全部验证通过，[Error message] 如果存在无效输入 *)

(** {1 评价适用性过滤器} *)

val is_dimension_applicable : Artistic_core.evaluation_dimension -> Artistic_core.evaluation_context -> bool
(** [is_dimension_applicable dimension context] 检查评价维度是否适用于给定上下文
    @param dimension 评价维度
    @param context 评价上下文
    @return [true] 如果维度适用，[false] 否则 *)

val filter_applicable_dimensions : Artistic_core.evaluation_dimension list -> Artistic_core.evaluation_context -> Artistic_core.evaluation_dimension list
(** [filter_applicable_dimensions dimensions context] 过滤出适用的评价维度
    @param dimensions 候选评价维度列表
    @param context 评价上下文
    @return 适用的评价维度列表 *)

(** {1 内容质量过滤器} *)

val calculate_chinese_char_ratio : string -> float
(** [calculate_chinese_char_ratio text] 计算文本中中文字符的比例
    @param text 待分析的文本
    @return 中文字符比例 (0.0 到 1.0) *)

val filter_low_quality_content : string list -> string list
(** [filter_low_quality_content verses] 过滤低质量内容
    @param verses 诗句列表
    @return 过滤后的高质量诗句列表 *)

(** {1 评价结果过滤器} *)

val filter_low_confidence_scores : Artistic_core.dimension_score list -> Artistic_core.dimension_score list
(** [filter_low_confidence_scores scores] 过滤低置信度评分
    @param scores 评分列表
    @return 高置信度评分列表 *)

val filter_outlier_scores : Artistic_core.dimension_score list -> Artistic_core.dimension_score list
(** [filter_outlier_scores scores] 过滤异常评分
    @param scores 评分列表
    @return 正常范围内的评分列表 *)

val limit_suggestions : 'a list -> int -> 'a list
(** [limit_suggestions suggestions max_count] 限制建议数量
    @param suggestions 建议列表
    @param max_count 最大数量
    @return 限制后的建议列表 *)

(** {1 诗词形式过滤器} *)

val detect_poetry_form : string list -> string option
(** [detect_poetry_form verses] 检测诗词形式类型
    @param verses 诗句列表
    @return 诗词形式名称，如"五言绝句"、"七言律诗"等 *)

val filter_by_poetry_form : string option -> Artistic_core.evaluation_dimension list -> Artistic_core.evaluation_dimension list
(** [filter_by_poetry_form form dimensions] 基于诗词形式过滤适用的评价维度
    @param form 诗词形式
    @param dimensions 候选评价维度
    @return 适用于该形式的评价维度列表 *)

(** {1 文本预处理过滤器} *)

val clean_verse_text : string -> string
(** [clean_verse_text verse] 清理诗句文本，移除多余标点等
    @param verse 原始诗句
    @return 清理后的诗句 *)

val normalize_verses : string list -> string list
(** [normalize_verses verses] 标准化诗句列表，统一格式
    @param verses 原始诗句列表
    @return 标准化后的诗句列表 *)

(** {1 评价上下文过滤器} *)

val validate_evaluation_context : Artistic_core.evaluation_context -> (Artistic_core.evaluation_context, string) result
(** [validate_evaluation_context context] 清理和验证评价上下文
    @param context 原始评价上下文
    @return [Ok validated_context] 如果验证通过，[Error message] 如果验证失败 *)

(** {1 性能优化过滤器} *)

val should_skip_evaluation : Artistic_core.evaluation_dimension -> Artistic_core.evaluation_context -> bool
(** [should_skip_evaluation dimension context] 检查是否应该跳过某个维度的评价
    @param dimension 评价维度
    @param context 评价上下文
    @return [true] 如果应该跳过，[false] 否则 *)

val batch_filter_dimensions : Artistic_core.evaluation_dimension list -> Artistic_core.evaluation_context -> Artistic_core.evaluation_dimension list
(** [batch_filter_dimensions dimensions context] 批量过滤适用的评价维度
    @param dimensions 候选维度列表
    @param context 评价上下文
    @return 经过综合过滤的适用维度列表 *)