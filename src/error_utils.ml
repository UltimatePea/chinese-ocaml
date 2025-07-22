(** 骆言编译器统一错误处理工具模块 *)

(** 表达式类型错误 *)
type expression_error_context =
  | GeneralExpression
  | LiteralAndVars
  | Operations
  | MemoryOperations
  | Collections
  | StructuredData
  | ControlFlow
  | ExceptionHandling
  | AdvancedControlFlow
  | BasicExpression
  | ControlFlowExpression
  | FunctionExpression
  | DataExpression

(** 语句类型错误 *)
type statement_error_context = GeneralStatement

(** 错误上下文到中文描述的映射 *)
let expression_context_to_chinese = function
  | GeneralExpression -> "表达式"
  | LiteralAndVars -> "字面量和变量表达式"
  | Operations -> "运算表达式"
  | MemoryOperations -> "内存操作表达式"
  | Collections -> "集合表达式"
  | StructuredData -> "结构化数据表达式"
  | ControlFlow -> "控制流表达式"
  | ExceptionHandling -> "异常处理表达式"
  | AdvancedControlFlow -> "高级控制流表达式"
  | BasicExpression -> "基本表达式"
  | ControlFlowExpression -> "控制流表达式"
  | FunctionExpression -> "函数表达式"
  | DataExpression -> "数据表达式"

let statement_context_to_chinese = function GeneralStatement -> "语句"

(** 生成统一的不支持类型错误消息 *)
let unsupported_expression_error context =
  let context_desc = expression_context_to_chinese context in
  "不支持的" ^ context_desc ^ "类型"

(** 生成带函数名的不支持类型错误消息 *)
let unsupported_expression_error_with_function func_name context =
  let context_desc = expression_context_to_chinese context in
  func_name ^ ": 不支持的" ^ context_desc ^ "类型"

(** 生成带详细信息的不支持类型错误消息 *)
let unsupported_expression_error_detailed func_name context details =
  let context_desc = expression_context_to_chinese context in
  func_name ^ ": 不支持的" ^ context_desc ^ "类型: " ^ details

(** 抛出不支持的表达式类型错误 *)
let fail_unsupported_expression context =
  let error_msg = unsupported_expression_error context in
  raise (Types.TypeError error_msg)

(** 抛出带函数名的不支持的表达式类型错误 *)
let fail_unsupported_expression_with_function func_name context =
  let error_msg = unsupported_expression_error_with_function func_name context in
  raise (Types.TypeError error_msg)

(** 抛出带详细信息的不支持的表达式类型错误 *)
let fail_unsupported_expression_detailed func_name context details =
  let error_msg = unsupported_expression_error_detailed func_name context details in
  raise (Types.TypeError error_msg)

(** 生成统一的不支持语句类型错误消息 *)
let unsupported_statement_error context =
  let context_desc = statement_context_to_chinese context in
  "不支持的" ^ context_desc ^ "类型"

(** 抛出不支持的语句类型错误 *)
let fail_unsupported_statement context =
  let error_msg = unsupported_statement_error context in
  raise (Types.TypeError error_msg)
