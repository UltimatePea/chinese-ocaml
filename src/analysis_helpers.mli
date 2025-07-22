(** 分析辅助函数模块接口
    
    提供表达式和语句分析的基础工具函数，支持各种AST节点的重构分析。
*)

open Ast
open Refactoring_analyzer_types

(** 统一的建议添加函数，将新建议添加到建议引用中
    
    @param new_suggestions 新的重构建议列表
    @param suggestions_ref 现有建议列表的引用
*)
val add_suggestions_to_ref : refactoring_suggestion list -> refactoring_suggestion list ref -> unit

(** 创建带有增加嵌套层级的上下文
    
    @param ctx 原始分析上下文
    @return 嵌套级别增加1的新上下文
*)
val create_nested_context : analysis_context -> analysis_context

(** 分析变量表达式
    
    @param name 变量名
    @param suggestions 建议列表引用，用于添加命名质量建议
*)
val analyze_variable_expression : string -> refactoring_suggestion list ref -> unit

(** 分析Let表达式
    
    @param name 变量名
    @param val_expr 赋值表达式
    @param in_expr 作用域内表达式
    @param new_ctx 分析上下文
    @param analyze 递归分析函数
    @param suggestions 建议列表引用
*)
val analyze_let_expression : 
  string -> expr -> expr -> analysis_context -> 
  (expr -> analysis_context -> unit) -> refactoring_suggestion list ref -> unit

(** 分析函数表达式
    
    @param params 参数列表
    @param body 函数体
    @param new_ctx 分析上下文
    @param analyze 递归分析函数
    @param suggestions 建议列表引用
*)
val analyze_function_expression : 
  string list -> expr -> analysis_context -> 
  (expr -> analysis_context -> unit) -> refactoring_suggestion list ref -> unit

(** 分析条件表达式
    
    @param cond 条件表达式
    @param then_expr then分支表达式
    @param else_expr else分支表达式
    @param new_ctx 分析上下文
    @param analyze 递归分析函数
    @param suggestions 建议列表引用
*)
val analyze_conditional_expression : 
  expr -> expr -> expr -> analysis_context -> 
  (expr -> analysis_context -> unit) -> refactoring_suggestion list ref -> unit

(** 分析函数调用表达式
    
    @param func 被调用的函数表达式
    @param args 参数列表
    @param new_ctx 分析上下文
    @param analyze 递归分析函数
*)
val analyze_function_call_expression : 
  expr -> expr list -> analysis_context -> 
  (expr -> analysis_context -> unit) -> unit

(** 分析模式匹配表达式
    
    @param matched_expr 被匹配的表达式
    @param branches 匹配分支列表
    @param new_ctx 分析上下文
    @param analyze 递归分析函数
*)
val analyze_match_expression : 
  expr -> match_branch list -> analysis_context -> 
  (expr -> analysis_context -> unit) -> unit

(** 分析二元运算表达式
    
    @param left 左操作数
    @param right 右操作数
    @param new_ctx 分析上下文
    @param analyze 递归分析函数
*)
val analyze_binary_operation_expression : 
  expr -> expr -> analysis_context -> 
  (expr -> analysis_context -> unit) -> unit

(** 分析一元运算表达式
    
    @param expr 操作数表达式
    @param new_ctx 分析上下文
    @param analyze 递归分析函数
*)
val analyze_unary_operation_expression : 
  expr -> analysis_context -> 
  (expr -> analysis_context -> unit) -> unit