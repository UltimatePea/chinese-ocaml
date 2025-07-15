(** 代码模式学习系统接口 - Code Pattern Learning System Interface *)

(** 简化的AST表示用于模式学习 *)
type simple_expr =
  | SLiteral of string
  | SVariable of string
  | SBinaryOp of string * simple_expr * simple_expr
  | SUnaryOp of string * simple_expr
  | SFunctionCall of string * simple_expr list
  | SIfThenElse of simple_expr * simple_expr * simple_expr
  | SLetIn of string * simple_expr * simple_expr
  | SFunctionDef of string list * simple_expr
  | SRecursiveFunctionDef of string * string list * simple_expr
  | SMatch of simple_expr * (string * simple_expr) list
  | STuple of simple_expr list
  | SList of simple_expr list
  | SRecord of (string * simple_expr) list

type code_pattern = {
  pattern_id : string; (* 模式唯一标识 *)
  pattern_type : pattern_type; (* 模式类型 *)
  structure : simple_expr; (* 简化AST结构 *)
  frequency : int; (* 使用频率 *)
  confidence : float; (* 置信度 *)
  examples : string list; (* 示例代码 *)
  variations : code_pattern list; (* 变体模式 *)
  context_tags : string list; (* 上下文标签 *)
  semantic_meaning : string; (* 语义含义 *)
}
(** 代码模式类型 *)

(** 模式类型分类 *)
and pattern_type =
  | FunctionPattern (* 函数定义模式 *)
  | ConditionalPattern (* 条件表达式模式 *)
  | LoopPattern (* 循环模式 *)
  | MatchPattern (* 模式匹配模式 *)
  | RecursionPattern (* 递归模式 *)
  | DataProcessingPattern (* 数据处理模式 *)
  | ErrorHandlingPattern (* 错误处理模式 *)
  | AlgorithmPattern (* 算法模式 *)
  | NamingPattern (* 命名模式 *)
  | ModulePattern (* 模块组织模式 *)

and learning_stats = {
  total_patterns : int; (* 总模式数 *)
  new_patterns_found : int; (* 新发现模式数 *)
  pattern_confidence_avg : float; (* 平均置信度 *)
  learning_accuracy : float; (* 学习准确率 *)
  analysis_time : float; (* 分析用时 *)
  memory_usage : int; (* 内存使用量 *)
}
(** 学习统计信息 *)

and pattern_storage = {
  mutable patterns : code_pattern list; (* 模式库 *)
  mutable pattern_count : (string, int) Hashtbl.t; (* 使用计数 *)
  mutable learning_history : learning_stats list; (* 学习历史 *)
}
(** 模式存储结构 *)

val pattern_store : pattern_storage
(** 全局模式存储 *)

type complexity_metrics = {
  cyclomatic_complexity : int; (* 圈复杂度 *)
  nesting_depth : int; (* 嵌套深度 *)
  function_length : int; (* 函数长度 *)
  parameter_count : int; (* 参数数量 *)
}
(** 复杂度指标 *)

type analysis_result = {
  patterns_found : code_pattern list; (* 发现的模式 *)
  complexity_metrics : complexity_metrics; (* 复杂度指标 *)
  quality_score : float; (* 代码质量分数 *)
  suggestions : string list; (* 改进建议 *)
}
(** 代码分析结果 *)

val extract_pattern : simple_expr -> code_pattern
(** 提取代码模式 *)

val calculate_complexity : simple_expr -> complexity_metrics
(** 计算复杂度指标 *)

val analyze_codebase : string list -> code_pattern list
(** 分析代码库 *)

val learn_from_code : simple_expr list -> unit
(** 从代码学习 *)

val get_pattern_suggestions : simple_expr -> code_pattern list
(** 获取模式建议 *)

val export_learning_data : unit -> learning_stats
(** 导出学习数据 *)

val format_learning_stats : learning_stats -> string
(** 格式化学习统计 *)

val cleanup_patterns : int -> unit
(** 清理过时模式 *)

val calculate_pattern_similarity : code_pattern -> code_pattern -> float
(** 模式相似度计算 *)

val cluster_similar_patterns : unit -> unit
(** 聚类相似模式 *)

val test_pattern_learning_system : unit -> unit
(** 测试模式学习系统 *)
