(** 性能分析器公共基础模块接口 *)

open Ast
open Refactoring_analyzer_types

(** 通用表达式分析器类型 *)
type expression_analyzer = expr -> refactoring_suggestion list

(** 递归表达式分析的公共实现
    @param specific_analyzer 特定的分析器函数
    @param expr 要分析的表达式
    @return 分析建议列表 *)
val analyze_expr_recursively : expression_analyzer -> expr -> refactoring_suggestion list

(** 构建性能优化建议的辅助函数
    @param hint_type 提示类型
    @param message 建议消息
    @param confidence 置信度
    @param location 位置信息
    @param fix 修复建议
    @return 格式化的建议 *)
val make_performance_suggestion : 
  hint_type:string ->
  message:string ->
  confidence:float ->
  location:string ->
  fix:string ->
  refactoring_suggestion

(** 常用的建议生成器模块 *)
module SuggestionBuilder : sig
  
  (** 列表操作优化建议
      @param operation_name 操作名称
      @param specific_message 具体消息
      @return 列表优化建议 *)
  val list_optimization_suggestion : string -> string -> refactoring_suggestion
  
  (** 模式匹配优化建议
      @param branch_count 分支数量
      @param severity 严重程度
      @return 模式匹配优化建议 *)
  val pattern_matching_suggestion : int -> string -> refactoring_suggestion
  
  (** 复杂度优化建议
      @param nesting_level 嵌套层级
      @return 复杂度优化建议 *)
  val complexity_suggestion : int -> refactoring_suggestion
  
end

(** 创建标准化的性能分析器
    @param specific_analysis 特定的分析逻辑
    @param expr 要分析的表达式
    @return 分析建议列表 *)
val create_performance_analyzer : expression_analyzer -> expr -> refactoring_suggestion list