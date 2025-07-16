(** 骆言解释器表达式求值模块接口 - Chinese Programming Language Interpreter Expression Evaluator Interface *)

open Value_operations

(** 求值表达式
    @param env 环境
    @param expr 表达式
    @return 求值结果
    @raise RuntimeError 当求值失败时 *)
val eval_expr : runtime_env -> Ast.expr -> runtime_value