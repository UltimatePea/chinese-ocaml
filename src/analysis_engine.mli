(** 分析引擎模块接口

    提供代码质量分析的核心功能，协调各种分析器对表达式、语句和程序进行深度分析。 *)

open Ast
open Refactoring_analyzer_types

val analyze_expression : expr -> analysis_context -> refactoring_suggestion list
(** 分析表达式并返回重构建议列表

    @param expr 要分析的表达式
    @param context 分析上下文，包含当前的函数环境和表达式计数等信息
    @return 重构建议列表，按照置信度排序 *)

val analyze_statement : stmt -> analysis_context -> refactoring_suggestion list
(** 分析语句并返回重构建议列表

    @param stmt 要分析的语句
    @param context 分析上下文
    @return 重构建议列表，包括命名质量、函数复杂度等建议 *)

val analyze_program : stmt list -> refactoring_suggestion list
(** 分析整个程序并返回综合的重构建议列表

    对程序进行全面分析，包括：
    - 各个语句的分析
    - 重复代码检测
    - 程序整体结构分析

    @param program 要分析的程序（语句列表）
    @return 综合的重构建议列表，按置信度从高到低排序 *)
