(** 骆言编译器统一错误处理工具模块接口 *)

(** 表达式错误上下文类型
    用于标识不同类型的表达式处理错误 *)
type expression_error_context = 
  | GeneralExpression          (** 通用表达式类型 *)
  | LiteralAndVars            (** 字面量和变量表达式 *)
  | Operations                (** 运算表达式 *)
  | MemoryOperations          (** 内存操作表达式 *)
  | Collections               (** 集合表达式 *)
  | StructuredData            (** 结构化数据表达式 *)
  | ControlFlow               (** 控制流表达式 *)
  | ExceptionHandling         (** 异常处理表达式 *)
  | AdvancedControlFlow       (** 高级控制流表达式 *)
  | BasicExpression           (** 基本表达式 *)
  | ControlFlowExpression     (** 控制流表达式（语义分析） *)
  | FunctionExpression        (** 函数表达式 *)
  | DataExpression            (** 数据表达式 *)

(** 语句错误上下文类型
    用于标识不同类型的语句处理错误 *)
type statement_error_context = 
  | GeneralStatement          (** 通用语句类型 *)

(** 生成统一的不支持表达式类型错误消息
    @param context 表达式错误上下文
    @return 格式化的中文错误消息 *)
val unsupported_expression_error : expression_error_context -> string

(** 生成带函数名的不支持表达式类型错误消息
    @param func_name 函数名称
    @param context 表达式错误上下文
    @return 格式化的中文错误消息 *)
val unsupported_expression_error_with_function : string -> expression_error_context -> string

(** 生成带详细信息的不支持表达式类型错误消息
    @param func_name 函数名称
    @param context 表达式错误上下文
    @param details 详细错误信息
    @return 格式化的中文错误消息 *)
val unsupported_expression_error_detailed : string -> expression_error_context -> string -> string

(** 抛出不支持的表达式类型错误
    @param context 表达式错误上下文
    @raise Failure 带有统一格式的中文错误消息 *)
val fail_unsupported_expression : expression_error_context -> 'a

(** 抛出带函数名的不支持的表达式类型错误
    @param func_name 函数名称
    @param context 表达式错误上下文
    @raise Failure 带有统一格式的中文错误消息 *)
val fail_unsupported_expression_with_function : string -> expression_error_context -> 'a

(** 抛出带详细信息的不支持的表达式类型错误
    @param func_name 函数名称
    @param context 表达式错误上下文
    @param details 详细错误信息
    @raise Failure 带有统一格式的中文错误消息 *)
val fail_unsupported_expression_detailed : string -> expression_error_context -> string -> 'a

(** 生成统一的不支持语句类型错误消息
    @param context 语句错误上下文
    @return 格式化的中文错误消息 *)
val unsupported_statement_error : statement_error_context -> string

(** 抛出不支持的语句类型错误
    @param context 语句错误上下文
    @raise Failure 带有统一格式的中文错误消息 *) 
val fail_unsupported_statement : statement_error_context -> 'a