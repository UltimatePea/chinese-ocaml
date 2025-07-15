(** 智能代码补全引擎接口 - Intelligent Code Completion Engine Interface *)

(** 语法上下文类型 *)
type syntax_context =
  | GlobalContext (* 全局上下文 *)
  | FunctionDefContext (* 函数定义上下文 *)
  | FunctionBodyContext (* 函数体上下文 *)
  | PatternMatchContext (* 模式匹配上下文 *)
  | ConditionalContext (* 条件表达式上下文 *)
  | ListContext (* 列表上下文 *)
  | RecordContext (* 记录类型上下文 *)
  | VariableDefContext (* 变量定义上下文 *)
  | ParameterContext of string list (* 参数上下文，包含参数类型信息 *)

type context = {
  current_scope : string; (* 当前作用域 *)
  syntax_context : syntax_context; (* 语法上下文 *)
  available_vars : (string * string) list; (* 可用变量及其类型 *)
  available_functions : (string * string list * string) list; (* 函数名、参数、返回类型 *)
  imported_modules : string list; (* 导入的模块 *)
  recent_patterns : string list; (* 最近使用的模式 *)
  nesting_level : int; (* 嵌套层级 *)
}
(** 上下文信息 *)

(** 补全类型 *)
type completion_type =
  | FunctionCompletion of string * string list (* 函数补全：名称，参数 *)
  | VariableCompletion of string (* 变量补全 *)
  | KeywordCompletion of string (* 关键字补全 *)
  | PatternCompletion of string (* 模式补全 *)
  | ExpressionCompletion of string (* 表达式补全 *)

type completion_result = {
  text : string; (* 补全文本 *)
  display_text : string; (* 显示文本 *)
  completion_type : completion_type;
  score : float; (* 评分 0.0-1.0 *)
  documentation : string; (* 文档说明 *)
}
(** 补全结果 *)

val create_default_context : unit -> context
(** 创建默认上下文 *)

val analyze_syntax_context : string -> int -> syntax_context
(** 分析语法上下文 *)

val complete_code : string -> int -> context -> completion_result list
(** 主要补全函数 *)

val update_context : context -> string -> string -> context
(** 更新上下文 *)

val add_function_to_context : context -> string -> string list -> string -> context
(** 添加函数到上下文 *)

val add_recent_pattern : context -> string -> context
(** 添加最近使用的模式 *)

val format_completion : completion_result -> string
(** 格式化补全结果 *)

val format_completions : completion_result list -> string
(** 批量格式化补全结果 *)

val get_parameter_suggestions : string -> context -> string list
(** 获取参数建议 *)

val intent_based_completion : string -> completion_result list
(** 基于意图的智能补全 *)

val test_code_completion : unit -> unit
(** 测试代码补全功能 *)
