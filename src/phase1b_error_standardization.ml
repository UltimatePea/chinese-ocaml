(** Phase 1-B 错误处理标准化模块

    Author: Whisky, PR Worker (修复版本) 提供统一的错误处理模式和工具函数，减少代码重复，提高错误处理一致性

    修复Delta审查问题: 1. 使用标准库Result类型，避免重复定义 2. 消除Compiler_errors循环依赖 3. 提供独立的架构设计 *)

(* 使用标准库result类型，避免重复定义 - 不重新定义类型 *)

(* 提供便捷的构造函数 *)
let ok x = Ok x
let error e = Error e

(** 标准化错误类型 - 独立于其他模块 *)
type standard_error =
  | CompilerError of string * (string * int * int) option (* filename, line, column *)
  | RuntimeError of string
  | SemanticError of string
  | SyntaxError of string * (string * int * int) option (* filename, line, column *)
  | TypeError of string
  | FileSystemError of string
  | NetworkError of string
  | ValidationError of string

(** 错误转换为中文消息 *)
let error_to_chinese_message = function
  | CompilerError (msg, pos) ->
      let pos_str =
        match pos with
        | Some (filename, line, column) -> Printf.sprintf " 在文件 %s 第%d行第%d列" filename line column
        | None -> ""
      in
      "编译错误: " ^ msg ^ pos_str
  | RuntimeError msg -> "运行时错误: " ^ msg
  | SemanticError msg -> "语义错误: " ^ msg
  | SyntaxError (msg, pos) ->
      let pos_str =
        match pos with
        | Some (filename, line, column) -> Printf.sprintf " 在文件 %s 第%d行第%d列" filename line column
        | None -> ""
      in
      "语法错误: " ^ msg ^ pos_str
  | TypeError msg -> "类型错误: " ^ msg
  | FileSystemError msg -> "文件系统错误: " ^ msg
  | NetworkError msg -> "网络错误: " ^ msg
  | ValidationError msg -> "验证错误: " ^ msg

(** 安全执行函数，捕获异常并转换为Result类型 *)
let safe_execute f =
  try Ok (f ()) with
  | Failure msg -> Error (RuntimeError msg)
  | Invalid_argument msg -> Error (ValidationError msg)
  | Sys_error msg -> Error (FileSystemError msg)
  | exn -> Error (RuntimeError ("未知错误: " ^ Printexc.to_string exn))

(** 安全执行函数，用于文件操作 *)
let safe_file_operation f filename =
  try Ok (f ()) with
  | Sys_error msg -> Error (FileSystemError (Printf.sprintf "文件操作失败 '%s': %s" filename msg))
  | exn ->
      Error (FileSystemError (Printf.sprintf "文件操作异常 '%s': %s" filename (Printexc.to_string exn)))

(** 安全执行函数，用于编译器操作 *)
let safe_compiler_operation f pos =
  try Ok (f ()) with
  | Failure msg -> Error (CompilerError (msg, pos))
  | exn -> Error (CompilerError ("编译器内部错误: " ^ Printexc.to_string exn, pos))

(** Result类型的单子操作 *)
let ( >>= ) result f = match result with Ok value -> f value | Error e -> Error e

let ( >>| ) result f = match result with Ok value -> Ok (f value) | Error e -> Error e

(** 组合多个Result操作 *)
let combine_results results =
  let rec aux acc = function
    | [] -> Ok (List.rev acc)
    | Ok value :: rest -> aux (value :: acc) rest
    | Error e :: _ -> Error e
  in
  aux [] results

(** 默认错误处理：记录错误并返回默认值 *)
let handle_error_with_default ~default ~error_handler result =
  match result with
  | Ok value -> value
  | Error e ->
      error_handler e;
      default

(** 记录错误到日志系统 *)
let log_error error =
  let msg = error_to_chinese_message error in
  Printf.eprintf "[ERROR] %s\n%!" msg

(** 验证函数：检查条件，返回Result *)
let validate condition error_value = if condition then Ok () else Error error_value

(** 验证非空字符串 *)
let validate_non_empty_string s field_name =
  validate (String.length s > 0) (ValidationError (field_name ^ "不能为空"))

(** 验证文件存在 *)
let validate_file_exists filename =
  validate (Sys.file_exists filename) (FileSystemError ("文件不存在: " ^ filename))

(** 批量验证 *)
let validate_all validations =
  let rec aux = function [] -> Ok () | validation :: rest -> validation >>= fun () -> aux rest in
  aux validations

(** 安全类型转换 *)
let safe_int_of_string s =
  try Ok (int_of_string s) with Failure _ -> Error (ValidationError ("无法将字符串转换为整数: " ^ s))

let safe_float_of_string s =
  try Ok (float_of_string s) with Failure _ -> Error (ValidationError ("无法将字符串转换为浮点数: " ^ s))

(** 错误恢复策略 *)
type 'a recovery_strategy =
  | UseDefault of 'a
  | Retry of (unit -> ('a, standard_error) result)
  | Abort

let apply_recovery_strategy strategy error =
  match strategy with
  | UseDefault default ->
      log_error error;
      Ok default
  | Retry retry_func ->
      log_error error;
      retry_func ()
  | Abort -> Error error

(** 标准化的文件读取函数 *)
let read_file_safe filename =
  safe_file_operation
    (fun () ->
      let ic = open_in filename in
      let content = really_input_string ic (in_channel_length ic) in
      close_in ic;
      content)
    filename

(** 标准化的配置解析函数 *)
let parse_config_safe content =
  safe_execute (fun () ->
      (* 这里是配置解析逻辑的示例 *)
      if String.length content = 0 then failwith "配置内容为空" else [ ("key", "value") ] (* 示例返回值 *))

(** 转换位置信息 - 用于与其他模块的互操作 *)
let make_position filename line column = (filename, line, column)

let position_to_string = function
  | Some (filename, line, column) -> Printf.sprintf "%s:%d:%d" filename line column
  | None -> "<unknown>"

(** Phase 1-B使用指南: 1. 使用 safe_execute 包装可能抛出异常的函数 2. 使用 Result.Ok/Result.Error 替代直接异常抛出 3. 使用
    validate_* 函数进行输入验证 4. 使用 combine_results 处理批量操作 5. 使用 >>= 和 >>| 进行函数式错误处理链式调用 6. 使用
    make_position 创建位置信息，避免依赖其他模块 *)
