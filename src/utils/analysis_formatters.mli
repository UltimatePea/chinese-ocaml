(** 骆言编译器分析报告格式化模块接口

    此模块专门处理性能分析、诗词语言特定分析、编译统计等分析报告的格式化。

    设计原则:
    - 统计准确性：准确反映分析数据和统计结果
    - 可视化友好：使用图标和结构化显示
    - 诗词特色：支持骆言诗词语言特有的分析格式
    - 性能导向：突出性能相关的分析信息

    用途：为编译器分析阶段、性能监测、诗词语法检查提供格式化服务 *)

(** 分析报告格式化工具模块 *)
module Analysis_formatters : sig
  val stat_report_pattern : string -> string -> int -> string
  (** 统计报告模式: icon category: count 个 *)

  val stat_report_line_pattern : string -> string -> int -> string
  (** 带换行的统计报告模式 *)

  val analysis_message_pattern : string -> string -> string
  (** 分析消息模式: icon message *)

  val analysis_message_line_pattern : string -> string -> string
  (** 带换行的分析消息模式 *)

  val performance_creation_pattern : int -> string -> string
  (** 性能分析消息模式: 创建了包含X个元素的大型Y *)

  val performance_field_pattern : int -> string -> string
  (** 性能字段分析模式: 创建了包含X个字段的大型Y *)

  val poetry_char_count_pattern : int -> int -> string
  (** 诗词字符数不匹配模式: 字符数不匹配：期望X字，实际Y字 *)

  val poetry_couplet_pattern : int -> int -> string
  (** 诗词对偶不匹配模式: 对偶字数不匹配：左联X字，右联Y字 *)

  val poetry_quatrain_pattern : int -> string
  (** 绝句格式模式: 绝句包含X句，通常为4句 *)

  val context_info_pattern : string -> string
  (** 上下文信息模式: 📍 上下文: context *)

  val cache_stat_infer_pattern : int -> string
  (** 类型缓存统计模式: 推断调用: X *)

  val cache_stat_unify_pattern : int -> string
  (** 类型缓存统计模式: 合一调用: X *)

  val cache_stat_subst_pattern : int -> string
  (** 类型缓存统计模式: 替换应用: X *)

  val cache_stat_hit_pattern : int -> string
  (** 类型缓存统计模式: 缓存命中: X *)

  val cache_stat_miss_pattern : int -> string
  (** 类型缓存统计模式: 缓存未命中: X *)

  val cache_hit_rate_pattern : float -> string
  (** 缓存命中率模式: 命中率: X% *)

  val cache_size_pattern : int -> string
  (** 缓存大小模式: 缓存大小: X *)

  val semantic_report_title_pattern : string -> string
  (** 语义分析报告标题模式: === 函数「name」语义分析报告 === *)

  val recursive_feature_pattern : bool -> string
  (** 递归特性模式: 递归特性: 是/否 *)

  val complexity_level_pattern : int -> string
  (** 复杂度级别模式: 复杂度级别: X *)

  val inferred_return_type_pattern : string -> string
  (** 推断返回类型模式: 推断返回类型: X *)

  val param_analysis_pattern : string -> string
  (** 参数分析模式: 参数「name」: *)

  val recursive_context_pattern : bool -> string
  (** 递归上下文模式: 递归上下文: 是/否 *)

  val usage_pattern_pattern : string -> string
  (** 使用模式模式: 使用模式: X *)
end

(** 导出的顶层函数 *)

val stat_report_pattern : string -> string -> int -> string
(** 统计报告模式: icon category: count 个 *)

val stat_report_line_pattern : string -> string -> int -> string
(** 带换行的统计报告模式 *)

val analysis_message_pattern : string -> string -> string
(** 分析消息模式: icon message *)

val analysis_message_line_pattern : string -> string -> string
(** 带换行的分析消息模式 *)

val performance_creation_pattern : int -> string -> string
(** 性能分析消息模式: 创建了包含X个元素的大型Y *)

val performance_field_pattern : int -> string -> string
(** 性能字段分析模式: 创建了包含X个字段的大型Y *)

val poetry_char_count_pattern : int -> int -> string
(** 诗词字符数不匹配模式: 字符数不匹配：期望X字，实际Y字 *)

val poetry_couplet_pattern : int -> int -> string
(** 诗词对偶不匹配模式: 对偶字数不匹配：左联X字，右联Y字 *)

val poetry_quatrain_pattern : int -> string
(** 绝句格式模式: 绝句包含X句，通常为4句 *)

val context_info_pattern : string -> string
(** 上下文信息模式: 📍 上下文: context *)

val cache_stat_infer_pattern : int -> string
(** 类型缓存统计模式: 推断调用: X *)

val cache_stat_unify_pattern : int -> string
(** 类型缓存统计模式: 合一调用: X *)

val cache_stat_subst_pattern : int -> string
(** 类型缓存统计模式: 替换应用: X *)

val cache_stat_hit_pattern : int -> string
(** 类型缓存统计模式: 缓存命中: X *)

val cache_stat_miss_pattern : int -> string
(** 类型缓存统计模式: 缓存未命中: X *)

val cache_hit_rate_pattern : float -> string
(** 缓存命中率模式: 命中率: X% *)

val cache_size_pattern : int -> string
(** 缓存大小模式: 缓存大小: X *)

val semantic_report_title_pattern : string -> string
(** 语义分析报告标题模式: === 函数「name」语义分析报告 === *)

val recursive_feature_pattern : bool -> string
(** 递归特性模式: 递归特性: 是/否 *)

val complexity_level_pattern : int -> string
(** 复杂度级别模式: 复杂度级别: X *)

val inferred_return_type_pattern : string -> string
(** 推断返回类型模式: 推断返回类型: X *)

val param_analysis_pattern : string -> string
(** 参数分析模式: 参数「name」: *)

val recursive_context_pattern : bool -> string
(** 递归上下文模式: 递归上下文: 是/否 *)

val usage_pattern_pattern : string -> string
(** 使用模式模式: 使用模式: X *)
