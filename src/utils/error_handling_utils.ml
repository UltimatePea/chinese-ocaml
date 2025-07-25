(** 通用错误处理工具模块 - 统一项目中的错误处理模式 *)

(** 错误处理结果类型 - 扩展标准Result类型 *)
type ('a, 'e) error_result = ('a, 'e) result

(** 简化的位置信息类型 - 避免循环依赖 *)
type simple_position = {
  filename : string;
  line : int;
  column : int;
}

(** 错误上下文信息 *)
type error_context = {
  function_name : string;
  module_name : string;
  position : simple_position option;
  additional_info : (string * string) list;
}

(** 格式化错误消息类型 *)
type formatted_error = {
  raw_error : string;
  context : error_context;
  formatted_message : string;
}

(** Result操作工具函数 *)

(** 安全的Result操作，带错误上下文 *)
let with_error_context context result =
  match result with
  | Ok value -> Ok value
  | Error msg -> 
      let formatted = {
        raw_error = msg;
        context = context;
        formatted_message = Printf.sprintf "[%s.%s] %s" 
          context.module_name context.function_name msg
      } in
      Error formatted

(** Result链式操作 - 类似于Result.bind但带错误累积 *)
let chain_results f result =
  match result with
  | Ok value -> f value
  | Error e -> Error e

(** 多个Result的批量处理 *)
let collect_results results =
  let rec collect acc_ok acc_err = function
    | [] -> 
        if acc_err = [] then Ok (List.rev acc_ok)
        else Error (List.rev acc_err)
    | Ok value :: rest -> collect (value :: acc_ok) acc_err rest
    | Error err :: rest -> collect acc_ok (err :: acc_err) rest
  in
  collect [] [] results

(** Result映射操作，保持错误类型 *)
let map_result f result =
  match result with
  | Ok value -> Ok (f value)
  | Error e -> Error e

(** Result错误映射操作 *)
let map_error f result =
  match result with
  | Ok value -> Ok value
  | Error e -> Error (f e)

(** Try-with异常处理工具 *)

(** 通用异常捕获器 *)
let safe_execute f =
  try
    let result = f () in
    Ok result
  with
  | exn -> Error (Printexc.to_string exn)

(** 带自定义错误消息的异常捕获 *)
let safe_execute_with_msg error_msg f =
  try
    let result = f () in
    Ok result
  with
  | _ -> Error error_msg

(** 带错误转换的异常捕获 *)
let safe_execute_with_converter error_converter f =
  try
    let result = f () in
    Ok result
  with
  | exn -> Error (error_converter exn)

(** 数值运算安全包装器 *)
let safe_numeric_op f =
  try
    let result = f () in
    Ok result
  with
  | Division_by_zero -> Error "除零错误"
  | Failure msg -> Error ("数值运算错误: " ^ msg)
  | exn -> Error ("未知数值错误: " ^ Printexc.to_string exn)

(** 错误消息构建工具 *)

(** 创建标准化错误上下文 *)
let create_error_context ?position ?(additional_info=[]) ~function_name ~module_name () =
  {
    function_name;
    module_name;
    position;
    additional_info;
  }

(** 格式化错误消息 *)
let format_error context raw_error =
  let position_str = match context.position with
    | None -> ""
    | Some pos -> Printf.sprintf " 位置 %d:%d" pos.line pos.column
  in
  let additional_str = 
    if context.additional_info = [] then ""
    else 
      let info_strs = List.map (fun (k, v) -> k ^ ": " ^ v) context.additional_info in
      " (" ^ String.concat ", " info_strs ^ ")"
  in
  let formatted_message = 
    Printf.sprintf "[%s.%s]%s %s%s" 
      context.module_name context.function_name position_str raw_error additional_str
  in
  {
    raw_error;
    context;
    formatted_message;
  }

(** 创建运行时错误消息 *)
let runtime_error_msg context msg =
  Printf.sprintf "运行时错误 [%s.%s]: %s" 
    context.module_name context.function_name msg

(** 创建类型错误消息 *)
let type_error_msg context ~expected ~actual =
  Printf.sprintf "类型错误 [%s.%s]: 期望 %s，实际 %s" 
    context.module_name context.function_name expected actual

(** 创建参数错误消息 *)
let param_error_msg context ~expected ~actual =
  Printf.sprintf "参数错误 [%s.%s]: 期望 %d 个参数，实际 %d 个" 
    context.module_name context.function_name expected actual

(** 错误累积和报告 *)

(** 错误累积器类型 *)
type 'e error_accumulator = {
  errors : 'e list;
  has_errors : bool;
}

(** 创建空的错误累积器 *)
let empty_accumulator () = {
  errors = [];
  has_errors = false;
}

(** 向累积器添加错误 *)
let add_error error acc = {
  errors = error :: acc.errors;
  has_errors = true;
}

(** 向累积器添加多个错误 *)
let add_errors errors acc = {
  errors = List.rev_append errors acc.errors;
  has_errors = true;
}

(** 从Result向累积器添加错误 *)
let accumulate_result result acc =
  match result with
  | Ok _ -> acc
  | Error err -> add_error err acc

(** 将累积器转换为Result *)
let accumulator_to_result acc =
  if acc.has_errors then Error (List.rev acc.errors)
  else Ok ()

(** 便利函数 - 常用错误处理模式 *)

(** Option到Result的转换 *)
let option_to_result ~error_msg option_val =
  match option_val with
  | Some value -> Ok value
  | None -> Error error_msg

(** 条件检查 *)
let check_condition condition ~error_msg =
  if condition then Ok ()
  else Error error_msg

(** 非空检查 *)
let check_non_empty list ~error_msg =
  match list with
  | [] -> Error error_msg
  | _ -> Ok list

(** 范围检查 *)
let check_range value ~min ~max ~error_msg =
  if value >= min && value <= max then Ok value
  else Error error_msg

(** 函数参数数量检查 *)
let check_args_count actual ~expected ~function_name =
  if actual = expected then Ok ()
  else Error (Printf.sprintf "函数 %s 期望 %d 个参数，实际 %d 个" 
    function_name expected actual)