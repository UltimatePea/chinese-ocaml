(** 骆言解释器函数调用模块接口 - Chinese Programming Language Interpreter Function Caller Interface *)

open Value_operations

val call_function :
  runtime_value -> runtime_value list -> (runtime_env -> Ast.expr -> runtime_value) -> runtime_value
(** 调用函数
    @param func_val 函数值
    @param arg_vals 参数值列表
    @param eval_expr_func 表达式求值函数
    @return 函数调用结果
    @raise RuntimeError 当函数调用失败时 *)

val call_labeled_function :
  runtime_value ->
  Ast.label_arg list ->
  runtime_env ->
  (runtime_env -> Ast.expr -> runtime_value) ->
  runtime_value
(** 调用带标签的函数
    @param func_val 函数值
    @param label_args 带标签的参数列表
    @param caller_env 调用环境
    @param eval_expr_func 表达式求值函数
    @return 函数调用结果
    @raise RuntimeError 当函数调用失败时 *)

val handle_recursive_let : runtime_env -> string -> Ast.expr -> runtime_env * runtime_value
(** 处理递归let绑定
    @param env 环境
    @param func_name 函数名
    @param expr 表达式
    @return 更新后的环境和函数值
    @raise RuntimeError 当处理失败时 *)
