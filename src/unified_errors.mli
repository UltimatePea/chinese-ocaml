(** 骆言统一错误处理系统接口 - Chinese Programming Language Unified Error Handling System Interface *)

(** 将Result转换为值，在出错时抛出异常 *)
val result_to_value : ('a, exn) result -> 'a

(** 创建位置信息 *)
val create_eval_position : int -> Compiler_errors.position