(** 分析报告模块接口 - 提供综合的代码质量评估报告和质量摘要生成功能

    本模块负责整合不同维度的代码分析结果，生成结构化的质量评估报告。 主要功能包括综合质量分析、多维度报告生成和统计信息汇总。 *)

(** {1 核心分析功能} *)

val comprehensive_analysis :
  Ast.stmt list ->
  Refactoring_analyzer_types.refactoring_suggestion list
  * string
  * string
  * string
  * string
  * string
(** 综合代码质量分析

    对输入的程序进行全面的质量分析，包括命名规范、代码复杂度、 重复代码检测和性能优化建议等多个维度。

    @param program 待分析的程序结构
    @return
      六元组，包含：
      - 分析建议列表
      - 命名规范报告
      - 复杂度分析报告
      - 重复代码检测报告
      - 性能优化建议报告
      - 主要重构建议报告 *)

(** {1 报告生成功能} *)

val generate_quality_assessment : Ast.stmt list -> string
(** 生成详细的质量评估报告

    基于综合分析结果，生成包含执行概要、问题分类统计和 详细改进建议的格式化文本报告。

    @param program 待分析的程序结构
    @return
      格式化的质量评估报告字符串，包含：
      - 📋 代码质量综合评估概要
      - 🎯 问题数量和优先级统计
      - 📊 按类别分组的问题清单
      - 详细的专项分析报告 *)
