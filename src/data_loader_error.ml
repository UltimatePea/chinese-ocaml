(* 数据加载器错误处理模块
   
   统一处理各种错误情况，提供错误格式化和日志记录功能。 *)

open Data_loader_types
open Printf

(** 格式化错误信息 *)
let format_error = function
  | FileNotFound file -> sprintf "文件未找到: %s" file
  | ParseError (file, msg) -> sprintf "解析文件 %s 失败: %s" file msg
  | ValidationError (dtype, msg) -> sprintf "验证数据类型 %s 失败: %s" dtype msg

(** 记录错误日志 *)
let log_error error =
  let error_msg = format_error error in
  Unified_logging.error "DataLoader" error_msg

(** 处理错误结果 *)
let handle_error_result = function
  | Success data -> data
  | Error error ->
      log_error error;
      raise (Failure (format_error error))

(** 将结果转换为选项类型 *)
let result_to_option = function Success data -> Some data | Error _ -> None

(** 组合多个结果 *)
let combine_results results =
  let rec go acc = function
    | [] -> Success (List.rev acc)
    | Success x :: rest -> go (x :: acc) rest
    | Error e :: _ -> Error e
  in
  go [] results
