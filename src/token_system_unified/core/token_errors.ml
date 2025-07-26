(** 骆言编译器 - Token系统错误处理
    
    统一Token系统的错误定义和处理机制，
    替代原有的failwith和异常抛出，使用Result类型进行错误处理。
    
    @author Alpha, 技术债务清理专员
    @version 2.0
    @since 2025-07-25
    @issue #1353 *)

open Yyocamlc_lib.Token_types

(** Token错误类型定义 *)
type token_error =
  | UnknownToken of string * position option  (** 未知Token *)
  | InvalidTokenFormat of string * string * position  (** Token格式错误 *)
  | ConversionError of string * string  (** 转换错误 *)
  | RegistryError of string  (** 注册表错误 *)
  | TokenMismatch of token * token * position  (** Token不匹配 *)
  | EmptyTokenStream  (** 空Token流 *)
  | InvalidPosition of position  (** 无效位置信息 *)
  | ParsingError of string * position  (** 解析错误 *)
  | TokenizationError of string * int * int  (** Token化错误 *)

type 'a token_result = ('a, token_error) result
(** Token操作结果类型 *)

(** 错误严重程度 *)
type error_severity =
  | Warning  (** 警告 - 可以继续处理 *)
  | Error  (** 错误 - 需要处理但可恢复 *)
  | Fatal  (** 致命错误 - 无法继续处理 *)

type error_context = {
  source_file : string option;  (** 源文件名 *)
  function_name : string option;  (** 发生错误的函数名 *)
  additional_info : string option;  (** 额外信息 *)
}
(** 错误上下文信息 *)

type detailed_error = {
  error : token_error;  (** 错误类型 *)
  severity : error_severity;  (** 严重程度 *)
  context : error_context;  (** 错误上下文 *)
  timestamp : float;  (** 错误发生时间 *)
}
(** 完整错误信息 *)

type error_collector = {
  errors : detailed_error list;  (** 收集的错误列表 *)
  max_errors : int;  (** 最大错误数量 *)
  stop_on_fatal : bool;  (** 遇到致命错误时是否停止 *)
}
(** 错误收集器 *)

(** 创建空的错误收集器 *)
let create_error_collector ?(max_errors = 100) ?(stop_on_fatal = true) () =
  { errors = []; max_errors; stop_on_fatal }

(** 错误转字符串函数 *)
let error_to_string = function
  | UnknownToken (text, pos_opt) ->
      let pos_str =
        match pos_opt with
        | Some pos -> Printf.sprintf " 在第%d行第%d列" pos.line pos.column
        | None -> ""
      in
      Printf.sprintf "未知Token: '%s'%s" text pos_str
  | InvalidTokenFormat (token_type, text, pos) ->
      Printf.sprintf "无效的%s格式: '%s' 在第%d行第%d列" token_type text pos.line pos.column
  | ConversionError (from_type, to_type) -> Printf.sprintf "Token转换错误: 无法从%s转换为%s" from_type to_type
  | RegistryError msg -> Printf.sprintf "Token注册表错误: %s" msg
  | TokenMismatch (expected, actual, pos) ->
      Printf.sprintf "Token不匹配: 期望%s但得到%s 在第%d行第%d列" 
        (show_token expected) (show_token actual) pos.line pos.column
  | EmptyTokenStream -> "Token流为空"
  | InvalidPosition pos -> Printf.sprintf "无效位置: 第%d行第%d列(文件%s)" pos.line pos.column pos.filename
  | ParsingError (msg, pos) -> Printf.sprintf "解析错误: %s 在第%d行第%d列" msg pos.line pos.column
  | TokenizationError (msg, line, col) -> Printf.sprintf "Token化错误: %s 在第%d行第%d列" msg line col

(** 获取错误的严重程度 *)
let get_error_severity = function
  | UnknownToken _ -> Warning
  | InvalidTokenFormat _ -> Error
  | ConversionError _ -> Error
  | RegistryError _ -> Error
  | TokenMismatch _ -> Error
  | EmptyTokenStream -> Warning
  | InvalidPosition _ -> Warning
  | ParsingError _ -> Error
  | TokenizationError _ -> Fatal

(** 创建错误结果 *)
let error_result error = Result.Error error

(** 创建成功结果 *)
let ok_result value = Result.Ok value

(** 错误结果的bind操作 *)
let bind_result result f =
  match result with Result.Ok value -> f value | Result.Error err -> Result.Error err

(** 错误结果的map操作 *)
let map_result f result =
  match result with Result.Ok value -> Result.Ok (f value) | Result.Error err -> Result.Error err

(** 收集错误到错误收集器 *)
let collect_error collector error context =
  let severity = get_error_severity error in
  let detailed_error = { error; severity; context; timestamp = Unix.time () } in
  let new_errors = detailed_error :: collector.errors in
  let should_stop =
    (collector.stop_on_fatal && severity = Fatal) || List.length new_errors >= collector.max_errors
  in
  let new_collector = { collector with errors = new_errors } in
  (new_collector, should_stop)

(** 获取收集器中的所有错误 *)
let get_all_errors collector = List.rev collector.errors

(** 获取指定严重程度的错误 *)
let get_errors_by_severity collector severity =
  collector.errors |> List.filter (fun err -> err.severity = severity) |> List.rev

(** 检查是否有致命错误 *)
let has_fatal_errors collector = List.exists (fun err -> err.severity = Fatal) collector.errors

(** 格式化错误报告 *)
let format_error_report collector =
  let errors = get_all_errors collector in
  let format_error err =
    let severity_str =
      match err.severity with Warning -> "警告" | Error -> "错误" | Fatal -> "致命错误"
    in
    let context_str =
      match err.context.function_name with Some func -> Printf.sprintf " [%s]" func | None -> ""
    in
    Printf.sprintf "[%s]%s %s" severity_str context_str (error_to_string err.error)
  in
  let error_strings = List.map format_error errors in
  String.concat "\n" error_strings

(** 创建默认错误上下文 *)
let default_context = { source_file = None; function_name = None; additional_info = None }

(** 创建带函数名的错误上下文 *)
let context_with_function func_name = { default_context with function_name = Some func_name }

(** 创建带源文件的错误上下文 *)
let context_with_file file_name = { default_context with source_file = Some file_name }

(** Token操作的安全包装器 *)
module SafeOps = struct
  (** 安全的Token查找 - 使用默认Token注册表 *)
  let safe_lookup_token text =
    let registry = Token_registry.get_default_registry () in
    match Token_registry.lookup_token registry text with
    | Some token -> ok_result token
    | None -> error_result (UnknownToken (text, None))

  (** 安全的Token文本获取 *)
  let safe_get_token_text token =
    match Token_registry.get_token_text token with
    | Some text -> ok_result text
    | None -> error_result (RegistryError "Token未注册")

  (** 安全的位置创建 *)
  let safe_create_position line column _offset =
    if line >= 1 && column >= 1 then ok_result { line; column; filename = "unknown" }
    else error_result (InvalidPosition { line; column; filename = "invalid" })

  (** 安全的Token流处理 *)
  let safe_process_token_stream stream f =
    match stream with
    | [] -> error_result EmptyTokenStream
    | tokens -> (
        try ok_result (f tokens)
        with exn ->
          error_result (ParsingError (Printexc.to_string exn, { line = 0; column = 0; filename = "error" }))
        )
end
