(** 骆言解释器二元运算模块接口 - Chinese Programming Language Interpreter Binary Operations Interface *)

open Value_operations

val execute_binary_op : Ast.binary_op -> runtime_value -> runtime_value -> runtime_value
(** 二元运算执行函数
    @param op 二元运算符
    @param left_val 左操作数
    @param right_val 右操作数
    @return 运算结果值
    @raise RuntimeError 当运算不支持或遇到错误时 *)

val execute_unary_op : Ast.unary_op -> runtime_value -> runtime_value
(** 一元运算执行函数
    @param op 一元运算符
    @param value 操作数
    @return 运算结果值
    @raise RuntimeError 当运算不支持或遇到错误时 *)
