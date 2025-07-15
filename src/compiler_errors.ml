(** 统一错误处理系统 - 骆言编译器 *)

open Lexer

(** 编译器错误类型 *)
type compiler_error =
  | ParseError of string * position  (** 语法分析错误 *)
  | TypeError of string * position  (** 类型错误 *)
  | CodegenError of string * string  (** 代码生成错误：错误信息和上下文 *)
  | UnimplementedFeature of string * string  (** 未实现功能：功能名和上下文 *)
  | InternalError of string  (** 内部错误 *)
  | RuntimeError of string  (** 运行时错误 *)

(** 错误严重级别 *)
type error_severity = Warning | Error | Fatal

type error_info = {
  error : compiler_error;
  severity : error_severity;
  context : string option;
  suggestions : string list;
}
(** 错误信息记录 *)

(** 错误处理结果 *)
type 'a error_result = Ok of 'a | Error of error_info

(** 创建错误信息 *)
let make_error_info ?(severity = (Error : error_severity)) ?(context = None) ?(suggestions = [])
    error =
  { error; severity; context; suggestions }

(** 错误消息格式化 *)
let format_position (pos : Lexer.position) =
  Printf.sprintf "%s:%d:%d" pos.filename pos.line pos.column

let format_error_message error =
  match error with
  | ParseError (msg, pos) -> Printf.sprintf "语法错误 (%s): %s" (format_position pos) msg
  | TypeError (msg, pos) -> Printf.sprintf "类型错误 (%s): %s" (format_position pos) msg
  | CodegenError (msg, context) -> Printf.sprintf "代码生成错误 [%s]: %s" context msg
  | UnimplementedFeature (feature, context) -> Printf.sprintf "未实现功能 [%s]: %s" context feature
  | InternalError msg -> Printf.sprintf "内部错误: %s" msg
  | RuntimeError msg -> Printf.sprintf "运行时错误: %s" msg

(** 格式化完整错误信息 *)
let format_error_info info =
  let severity_str = match info.severity with Warning -> "警告" | Error -> "错误" | Fatal -> "严重错误" in
  let main_msg = Printf.sprintf "[%s] %s" severity_str (format_error_message info.error) in
  let context_msg =
    match info.context with Some ctx -> Printf.sprintf "\n上下文: %s" ctx | None -> ""
  in
  let suggestions_msg =
    if List.length info.suggestions > 0 then
      "\n建议:\n" ^ String.concat "\n" (List.map (fun s -> "  - " ^ s) info.suggestions)
    else ""
  in
  main_msg ^ context_msg ^ suggestions_msg

(** 输出错误信息 *)
let print_error_info info =
  Printf.eprintf "%s\n" (format_error_info info);
  flush stderr

(** 常用错误创建函数 *)
let parse_error ?(suggestions = []) msg pos =
  let error_info = make_error_info ~suggestions (ParseError (msg, pos)) in
  (Error error_info : 'a error_result)

let type_error ?(suggestions = []) msg pos =
  let error_info = make_error_info ~suggestions (TypeError (msg, pos)) in
  (Error error_info : 'a error_result)

let codegen_error ?(suggestions = []) ?(context = "unknown") msg =
  let error_info = make_error_info ~suggestions (CodegenError (msg, context)) in
  (Error error_info : 'a error_result)

let unimplemented_feature ?(suggestions = []) ?(context = "C代码生成") feature =
  let default_suggestions = [ "此功能目前尚未在C后端实现"; "您可以在Issue中请求实现此功能"; "或考虑使用解释器模式运行代码" ] in
  let all_suggestions = suggestions @ default_suggestions in
  let error_info =
    make_error_info ~suggestions:all_suggestions (UnimplementedFeature (feature, context))
  in
  (Error error_info : 'a error_result)

let internal_error ?(suggestions = []) msg =
  let default_suggestions = [ "这是编译器内部错误，请报告此问题"; "请在GitHub上创建Issue并包含重现步骤" ] in
  let all_suggestions = suggestions @ default_suggestions in
  let error_info =
    make_error_info ~severity:Fatal ~suggestions:all_suggestions (InternalError msg)
  in
  (Error error_info : 'a error_result)

let runtime_error ?(suggestions = []) msg =
  let error_info = make_error_info ~suggestions (RuntimeError msg) in
  (Error error_info : 'a error_result)

(** 错误处理工具函数 *)
let map_error f = function Ok x -> Ok (f x) | Error e -> Error e

let bind_error f = function Ok x -> f x | Error e -> Error e
let ( >>= ) x f = bind_error f x
let ( >>| ) x f = map_error f x

type error_collector = { mutable errors : error_info list; mutable has_fatal : bool }
(** 错误收集器 - 用于收集多个错误 *)

let create_error_collector () = { errors = []; has_fatal = false }

let add_error collector error_info =
  collector.errors <- error_info :: collector.errors;
  if error_info.severity = Fatal then collector.has_fatal <- true

let has_errors collector = List.length collector.errors > 0
let get_errors collector = List.rev collector.errors
let get_error_count collector = List.length collector.errors

type error_handling_config = {
  continue_on_error : bool;  (** 遇到错误时是否继续 *)
  max_errors : int;  (** 最大错误数量 *)
  show_suggestions : bool;  (** 是否显示建议 *)
  colored_output : bool;  (** 是否使用彩色输出 *)
}
(** 错误处理策略配置 *)

let default_error_config =
  { continue_on_error = true; max_errors = 10; show_suggestions = true; colored_output = false }

let error_config = ref default_error_config

(** 设置错误处理配置 *)
let set_error_config new_config = error_config := new_config

(** 检查是否应该继续处理 *)
let should_continue collector =
  !error_config.continue_on_error && (not collector.has_fatal)
  && get_error_count collector < !error_config.max_errors
