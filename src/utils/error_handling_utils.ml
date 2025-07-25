(** 通用错误处理工具模块 - 统一项目中的错误处理模式 *)

(** 错误上下文信息 - 简化设计 *)
type error_context = {
  function_name : string;
  module_name : string;
}

(** 核心Result操作工具函数 *)

(** Result错误映射操作，添加模块上下文 *)
let map_error_with_context context result =
  match result with
  | Ok value -> Ok value
  | Error msg -> Error (Printf.sprintf "[%s.%s] %s" 
    context.module_name context.function_name msg)

(** 核心异常处理工具 *)

(** 通用异常捕获器 *)
let safe_execute f =
  try
    let result = f () in
    Ok result
  with
  | exn -> Error (Printexc.to_string exn)

(** 数值运算安全包装器 *)
let safe_numeric_op f =
  try
    let result = f () in
    Ok result
  with
  | Division_by_zero -> Error "除零错误"
  | Failure msg -> Error ("数值运算错误: " ^ msg)
  | exn -> Error ("未知数值错误: " ^ Printexc.to_string exn)

(** 核心错误消息构建工具 *)

(** 创建错误上下文 *)
let create_error_context ~function_name ~module_name =
  {
    function_name;
    module_name;
  }

(** 格式化错误消息 *)
let format_error_msg context raw_error =
  Printf.sprintf "[%s.%s] %s" 
    context.module_name context.function_name raw_error

(** 创建参数错误消息 *)
let param_error_msg context ~expected ~actual =
  Printf.sprintf "参数错误 [%s.%s]: 期望 %d 个参数，实际 %d 个" 
    context.module_name context.function_name expected actual

(** 核心便利函数 - 最常用的错误处理模式 *)

(** Option到Result的转换 *)
let option_to_result ~error_msg option_val =
  match option_val with
  | Some value -> Ok value
  | None -> Error error_msg

(** 条件检查 *)
let check_condition condition ~error_msg =
  if condition then Ok ()
  else Error error_msg

(** 函数参数数量检查 *)
let check_args_count actual ~expected ~function_name =
  if actual = expected then Ok ()
  else Error (Printf.sprintf "函数 %s 期望 %d 个参数，实际 %d 个" 
    function_name expected actual)