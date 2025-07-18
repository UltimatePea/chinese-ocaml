(** 骆言统一错误处理系统 - Chinese Programming Language Unified Error Handling System *)

(** 简化错误处理辅助函数 - 保持与现有系统兼容 *)

(** 将Result转换为值，在出错时抛出异常 *)
let result_to_value = function Result.Ok value -> value | Result.Error exn -> raise exn

(** 创建位置信息 *)
let create_eval_position line_hint : Compiler_errors.position =
  { filename = "<expression_evaluator>"; line = line_hint; column = 0 }
