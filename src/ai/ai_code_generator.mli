(** AI代码生成助手接口 - AI Code Generator Assistant Interface *)

type generation_request = {
  description : string; (* 自然语言描述 *)
  context : string option; (* 上下文代码 *)
  target_type : generation_target; (* 生成目标类型 *)
  constraints : generation_constraint list; (* 生成约束 *)
}
(** 生成请求类型 *)

(** 生成目标类型 *)
and generation_target =
  | Function (* 函数生成 *)
  | Algorithm of algorithm_type (* 算法实现 *)
  | DataProcessing of data_operation list (* 数据处理 *)
  | PatternApplication (* 模式应用 *)

(** 算法类型 *)
and algorithm_type =
  | Sorting (* 排序算法 *)
  | Searching (* 搜索算法 *)
  | Recursive (* 递归算法 *)
  | Mathematical (* 数学算法 *)

(** 数据操作类型 *)
and data_operation =
  | Filter (* 过滤 *)
  | Map (* 映射 *)
  | Reduce (* 归约 *)
  | Sort (* 排序 *)
  | Group (* 分组 *)

(** 生成约束 *)
and generation_constraint =
  | MaxComplexity of int (* 最大复杂度 *)
  | PreferRecursive (* 偏好递归 *)
  | PreferIterative (* 偏好迭代 *)
  | MustInclude of string list (* 必须包含的关键字 *)
  | AvoidFeatures of string list (* 避免的特性 *)

type generation_result = {
  generated_code : string; (* 生成的代码 *)
  explanation : string; (* 解释说明 *)
  confidence : float; (* 置信度 0.0-1.0 *)
  alternatives : generation_alternative list; (* 替代方案 *)
  quality_metrics : quality_metrics; (* 质量指标 *)
}
(** 生成结果 *)

and generation_alternative = {
  alt_code : string; (* 替代代码 *)
  alt_description : string; (* 方案描述 *)
  alt_confidence : float; (* 置信度 *)
}
(** 替代方案 *)

and quality_metrics = {
  syntax_correctness : float; (* 语法正确性 *)
  chinese_compliance : float; (* 中文编程规范符合度 *)
  readability : float; (* 可读性 *)
  efficiency : float; (* 效率预估 *)
}
(** 质量指标 *)

type code_template = {
  name : string;
  pattern : string list;
  template : string;
  explanation : string;
  category : string;
  complexity : int;
}
(** 代码模板定义 *)

val generate_function : generation_request -> generation_result
(** 主要生成函数 *)

val intelligent_code_generation :
  string ->
  ?context:string option ->
  ?constraints:generation_constraint list ->
  unit ->
  generation_result
(** 智能代码生成接口 *)

val generate_multiple_candidates : string -> int -> generation_result list
(** 批量生成多个候选方案 *)

val evaluate_generated_code : string -> quality_metrics
(** 代码质量评估 *)

val suggest_optimizations : string -> string list
(** 代码优化建议 *)

val generate_code_explanation : string -> string -> string
(** 生成解释文档 *)

val analyze_generation_intent : string -> generation_target * string list
(** 自然语言意图分析器 *)

val generate_function_code : string -> string option -> generation_result
(** 生成函数代码 *)

val generate_algorithm_code : algorithm_type -> string -> generation_result
(** 生成算法代码 *)

val generate_data_processing_code : data_operation list -> string -> generation_result
(** 生成数据处理代码 *)

val match_templates : string list -> code_template list -> (code_template * float) list
(** 模板匹配算法 *)

val function_templates : code_template list
(** 预定义函数模板库 *)

