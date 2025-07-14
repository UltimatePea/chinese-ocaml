(** 智能代码重构建议模块接口 - Intelligent Code Refactoring Analyzer Interface *)

(** 建议类型分类 *)
type suggestion_type =
  | DuplicatedCode of string list    (** 重复代码片段，包含重复的函数名或标识符 *)
  | FunctionComplexity of int        (** 函数复杂度，包含计算得出的复杂度值 *)
  | NamingImprovement of string      (** 命名改进建议，包含建议的新名称 *)
  | PerformanceHint of string        (** 性能优化提示，包含具体建议 *)

(** 重构建议 *)
type refactoring_suggestion = {
  suggestion_type: suggestion_type;  (** 建议类型 *)
  message: string;                  (** 建议消息 *)
  confidence: float;                (** 置信度 0.0-1.0 *)
  location: string option;          (** 代码位置 *)
  suggested_fix: string option;     (** 建议的修复方案 *)
}

(** 代码分析上下文 *)
type analysis_context = {
  current_function: string option;    (** 当前分析的函数名 *)
  defined_vars: (string * Ast.type_expr option) list;  (** 已定义变量及其类型 *)
  function_calls: string list;        (** 函数调用历史 *)
  nesting_level: int;                (** 嵌套层级 *)
  expression_count: int;              (** 表达式计数 *)
}

(** 主要功能函数 *)

(** 分析整个程序并生成重构建议
    @param program 程序AST
    @return 重构建议列表 *)
val analyze_program : Ast.program -> refactoring_suggestion list

(** 生成重构分析报告
    @param suggestions 重构建议列表
    @return 格式化的报告字符串 *)
val generate_refactoring_report : refactoring_suggestion list -> string

(** 分析表达式并生成建议
    @param expr 表达式AST
    @param context 分析上下文
    @return 重构建议列表 *)
val analyze_expression : Ast.expr -> analysis_context -> refactoring_suggestion list

(** 分析语句并生成建议
    @param stmt 语句AST
    @param context 分析上下文
    @return 重构建议列表 *)
val analyze_statement : Ast.stmt -> analysis_context -> refactoring_suggestion list

(** 辅助功能函数 *)

(** 计算表达式复杂度
    @param expr 表达式AST
    @param context 分析上下文
    @return 复杂度值 *)
val calculate_expression_complexity : Ast.expr -> analysis_context -> int

(** 分析命名质量
    @param name 要分析的名称
    @return 重构建议列表 *)
val analyze_naming_quality : string -> refactoring_suggestion list

(** 分析性能优化建议
    @param expr 表达式AST
    @param context 分析上下文
    @return 性能优化建议列表 *)
val analyze_performance_hints : Ast.expr -> analysis_context -> refactoring_suggestion list

(** 空分析上下文 *)
val empty_context : analysis_context

(** 分析函数复杂度
    @param name 函数名
    @param expr 函数表达式
    @param context 分析上下文
    @return 重构建议选项 *)
val analyze_function_complexity : string -> Ast.expr -> analysis_context -> refactoring_suggestion option

(** 检测代码重复
    @param exprs 表达式列表
    @return 重构建议列表 *)
val detect_code_duplication : Ast.expr list -> refactoring_suggestion list

(** 格式化重构建议
    @param suggestion 重构建议
    @return 格式化的字符串 *)
val format_suggestion : refactoring_suggestion -> string