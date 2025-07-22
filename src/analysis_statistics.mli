(** 分析统计模块接口
    
    提供代码质量分析的统计功能和质量指标计算，支持重构建议的统计分析。
*)

open Ast
open Refactoring_analyzer_types

(** 获取建议统计信息
    
    分析重构建议列表，生成详细的统计信息，包括：
    - 总建议数量
    - 按建议类型分组的统计（命名、复杂度、重复、性能）
    - 按优先级分组的统计（高、中、低优先级）
    
    @param suggestions 重构建议列表
    @return 统计三元组：(总数, (命名数, 复杂度数, 重复数, 性能数), (高优先级数, 中优先级数, 低优先级数))
*)
val get_suggestion_statistics : refactoring_suggestion list -> 
  int * (int * int * int * int) * (int * int * int)

(** 快速质量检查
    
    对程序进行快速质量分析并生成可读性强的报告字符串。
    分析内容包括：
    - 总问题数量
    - 高优先级问题数量
    - 各类问题分布（命名、复杂度、重复代码、性能）
    
    @param program 要分析的程序（语句列表）
    @return 格式化的质量检查报告字符串
*)
val quick_quality_check : stmt list -> string