(** 骆言编译器分析报告格式化模块

    此模块专门处理性能分析、诗词语言特定分析、编译统计等分析报告的格式化。

    设计原则:
    - 统计准确性：准确反映分析数据和统计结果
    - 可视化友好：使用图标和结构化显示
    - 诗词特色：支持骆言诗词语言特有的分析格式
    - 性能导向：突出性能相关的分析信息

    用途：为编译器分析阶段、性能监测、诗词语法检查提供格式化服务 *)

open Base_string_ops

(** 分析报告格式化工具模块 *)
module Analysis_formatters = struct
  (** 统计报告模式: icon category: count 个 *)
  let stat_report_pattern icon category count =
    concat_strings [ "   "; icon; " "; category; ": "; int_to_string count; " 个" ]

  (** 带换行的统计报告模式 *)
  let stat_report_line_pattern icon category count =
    concat_strings [ stat_report_pattern icon category count; "\n" ]

  (** 分析消息模式: icon message *)
  let analysis_message_pattern icon message = concat_strings [ icon; " "; message ]

  (** 带换行的分析消息模式 *)
  let analysis_message_line_pattern icon message =
    concat_strings [ analysis_message_pattern icon message; "\n\n" ]

  (** 性能分析消息模式: 创建了包含X个元素的大型Y *)
  let performance_creation_pattern count item_type =
    concat_strings [ "创建了包含"; int_to_string count; "个元素的大型"; item_type ]

  (** 性能字段分析模式: 创建了包含X个字段的大型Y *)
  let performance_field_pattern field_count record_type =
    concat_strings [ "创建了包含"; int_to_string field_count; "个字段的大型"; record_type ]

  (** 诗词字符数不匹配模式: 字符数不匹配：期望X字，实际Y字 *)
  let poetry_char_count_pattern expected actual =
    concat_strings [ "字符数不匹配：期望"; int_to_string expected; "字，实际"; int_to_string actual; "字" ]

  (** 诗词对偶不匹配模式: 对偶字数不匹配：左联X字，右联Y字 *)
  let poetry_couplet_pattern left_count right_count =
    concat_strings
      [ "对偶字数不匹配：左联"; int_to_string left_count; "字，右联"; int_to_string right_count; "字" ]

  (** 绝句格式模式: 绝句包含X句，通常为4句 *)
  let poetry_quatrain_pattern verse_count =
    concat_strings [ "绝句包含"; int_to_string verse_count; "句，通常为4句" ]

  (** 上下文信息模式: 📍 上下文: context *)
  let context_info_pattern context = concat_strings [ "📍 上下文: "; context; "\n\n" ]

  (** 类型缓存统计模式: 推断调用: X *)
  let cache_stat_infer_pattern count = concat_strings [ "  推断调用: "; int_to_string count ]

  (** 类型缓存统计模式: 合一调用: X *)
  let cache_stat_unify_pattern count = concat_strings [ "  合一调用: "; int_to_string count ]

  (** 类型缓存统计模式: 替换应用: X *)
  let cache_stat_subst_pattern count = concat_strings [ "  替换应用: "; int_to_string count ]

  (** 类型缓存统计模式: 缓存命中: X *)
  let cache_stat_hit_pattern count = concat_strings [ "  缓存命中: "; int_to_string count ]

  (** 类型缓存统计模式: 缓存未命中: X *)
  let cache_stat_miss_pattern count = concat_strings [ "  缓存未命中: "; int_to_string count ]

  (** 缓存命中率模式: 命中率: X% *)
  let cache_hit_rate_pattern rate = concat_strings [ "  命中率: "; float_to_string rate; "%%" ]

  (** 缓存大小模式: 缓存大小: X *)
  let cache_size_pattern size = concat_strings [ "  缓存大小: "; int_to_string size ]

  (** 语义分析报告标题模式: === 函数「name」语义分析报告 === *)
  let semantic_report_title_pattern func_name =
    concat_strings [ "=== 函数「"; func_name; "」语义分析报告 ===\n" ]

  (** 递归特性模式: 递归特性: 是/否 *)
  let recursive_feature_pattern is_recursive =
    concat_strings [ "递归特性: "; (if is_recursive then "是" else "否"); "\n" ]

  (** 复杂度级别模式: 复杂度级别: X *)
  let complexity_level_pattern level = concat_strings [ "复杂度级别: "; int_to_string level; "\n" ]

  (** 推断返回类型模式: 推断返回类型: X *)
  let inferred_return_type_pattern return_type = concat_strings [ "推断返回类型: "; return_type; "\n" ]

  (** 参数分析模式: 参数「name」: *)
  let param_analysis_pattern param_name = concat_strings [ "  参数「"; param_name; "」:\n" ]

  (** 递归上下文模式: 递归上下文: 是/否 *)
  let recursive_context_pattern is_recursive =
    concat_strings [ "    递归上下文: "; (if is_recursive then "是" else "否"); "\n" ]

  (** 使用模式模式: 使用模式: X *)
  let usage_pattern_pattern patterns = concat_strings [ "    使用模式: "; patterns; "\n" ]
end

include Analysis_formatters
(** 导出分析格式化函数到顶层，便于使用 *)