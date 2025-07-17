(** 统一错误处理系统 - 骆言编译器 *)

type position = { filename : string; line : int; column : int } [@@deriving show, eq]
(** 通用位置类型 - 避免循环依赖 *)

(** 编译器错误类型 *)
type compiler_error =
  | LexError of string * position  (** 词法分析错误 *)
  | ParseError of string * position  (** 语法分析错误 *)
  | SyntaxError of string * position  (** 语法错误 *)
  | PoetryParseError of string * position option  (** 诗词解析错误 *)
  | TypeError of string * position option  (** 类型错误 *)
  | SemanticError of string * position option  (** 语义分析错误 *)
  | CodegenError of string * string  (** 代码生成错误：错误信息和上下文 *)
  | RuntimeError of string * position option  (** 运行时错误 *)
  | ExceptionRaised of string * position option  (** 异常抛出 *)
  | UnimplementedFeature of string * string  (** 未实现功能：功能名和上下文 *)
  | InternalError of string  (** 内部错误 *)
  | IOError of string * string  (** IO错误：错误信息和文件路径 *)

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
let format_position (pos : position) = Printf.sprintf "%s:%d:%d" pos.filename pos.line pos.column

let format_error_message error =
  match error with
  | LexError (msg, pos) -> Printf.sprintf "词法错误 (%s): %s" (format_position pos) msg
  | ParseError (msg, pos) -> Printf.sprintf "语法错误 (%s): %s" (format_position pos) msg
  | SyntaxError (msg, pos) -> Printf.sprintf "语法错误 (%s): %s" (format_position pos) msg
  | PoetryParseError (msg, pos_opt) ->
      let pos_str =
        match pos_opt with Some pos -> " (" ^ format_position pos ^ ")" | None -> ""
      in
      Printf.sprintf "诗词解析错误%s: %s" pos_str msg
  | TypeError (msg, pos_opt) ->
      let pos_str =
        match pos_opt with Some pos -> " (" ^ format_position pos ^ ")" | None -> ""
      in
      Printf.sprintf "类型错误%s: %s" pos_str msg
  | SemanticError (msg, pos_opt) ->
      let pos_str =
        match pos_opt with Some pos -> " (" ^ format_position pos ^ ")" | None -> ""
      in
      Printf.sprintf "语义错误%s: %s" pos_str msg
  | CodegenError (msg, context) -> Printf.sprintf "代码生成错误 [%s]: %s" context msg
  | RuntimeError (msg, pos_opt) ->
      let pos_str =
        match pos_opt with Some pos -> " (" ^ format_position pos ^ ")" | None -> ""
      in
      Printf.sprintf "运行时错误%s: %s" pos_str msg
  | ExceptionRaised (msg, pos_opt) ->
      let pos_str =
        match pos_opt with Some pos -> " (" ^ format_position pos ^ ")" | None -> ""
      in
      Printf.sprintf "异常%s: %s" pos_str msg
  | UnimplementedFeature (feature, context) -> Printf.sprintf "未实现功能 [%s]: %s" context feature
  | InternalError msg -> Printf.sprintf "内部错误: %s" msg
  | IOError (msg, filepath) -> Printf.sprintf "IO错误 [%s]: %s" filepath msg

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

(** 输出错误信息 - 使用统一错误处理系统 *)
let print_error_info info =
  (* 使用配置系统决定输出方式 *)
  let runtime_cfg = Config.get_runtime_config () in
  if runtime_cfg.colored_output then
    let color_code =
      match info.severity with Warning -> "\027[33m" | Error -> "\027[31m" | Fatal -> "\027[91m"
    in
    Printf.eprintf "%s%s\027[0m\n" color_code (format_error_info info)
  else Printf.eprintf "%s\n" (format_error_info info);
  flush stderr

(** 常用错误创建函数 *)
let lex_error ?(suggestions = []) msg pos =
  let error_info = make_error_info ~suggestions (LexError (msg, pos)) in
  (Error error_info : 'a error_result)

let parse_error ?(suggestions = []) msg pos =
  let error_info = make_error_info ~suggestions (ParseError (msg, pos)) in
  (Error error_info : 'a error_result)

let syntax_error ?(suggestions = []) msg pos =
  let error_info = make_error_info ~suggestions (SyntaxError (msg, pos)) in
  (Error error_info : 'a error_result)

let poetry_parse_error ?(suggestions = []) msg pos_opt =
  let error_info = make_error_info ~suggestions (PoetryParseError (msg, pos_opt)) in
  (Error error_info : 'a error_result)

let type_error ?(suggestions = []) msg pos_opt =
  let error_info = make_error_info ~suggestions (TypeError (msg, pos_opt)) in
  (Error error_info : 'a error_result)

let semantic_error ?(suggestions = []) msg pos_opt =
  let error_info = make_error_info ~suggestions (SemanticError (msg, pos_opt)) in
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

let runtime_error ?(suggestions = []) msg pos_opt =
  let error_info = make_error_info ~suggestions (RuntimeError (msg, pos_opt)) in
  (Error error_info : 'a error_result)

let exception_raised ?(suggestions = []) msg pos_opt =
  let error_info = make_error_info ~suggestions (ExceptionRaised (msg, pos_opt)) in
  (Error error_info : 'a error_result)

let io_error ?(suggestions = []) msg filepath =
  let error_info = make_error_info ~suggestions (IOError (msg, filepath)) in
  (Error error_info : 'a error_result)

exception CompilerError of error_info
(** 兼容性函数：从现有异常类型转换 *)

(** 从统一错误系统抛出异常 *)
let raise_compiler_error error_info = raise (CompilerError error_info)

(** 从现有异常类型转换的辅助函数 *)
let wrap_legacy_exception f =
  try match f () with Ok x -> Ok x | Error e -> Error e with
  | Types.TypeError msg -> type_error msg None
  | Types.ParseError (msg, line, col) ->
      let pos = { filename = ""; line; column = col } in
      parse_error msg pos
  | Types.CodegenError (msg, context) -> codegen_error ~context msg
  | Types.SemanticError (msg, _context) -> semantic_error msg None
  | Parser_utils.SyntaxError (msg, pos) ->
      let compiler_pos = { filename = pos.filename; line = pos.line; column = pos.column } in
      syntax_error msg compiler_pos
  | Parser_poetry.PoetryParseError msg -> poetry_parse_error msg None
  | Value_operations.RuntimeError msg -> runtime_error msg None
  | Lexer.LexError (msg, pos) ->
      let compiler_pos = { filename = pos.filename; line = pos.line; column = pos.column } in
      lex_error msg compiler_pos
  | Sys_error msg -> io_error msg "系统"
  | exn -> internal_error ("未知异常: " ^ Printexc.to_string exn)

(** 辅助函数：从错误结果中提取错误信息 *)
let extract_error_info = function
  | Error error_info -> error_info
  | Ok _ -> failwith "Unexpected Ok from error function"

(** 安全执行函数，捕获异常并转换为统一错误格式 *)
let safe_execute f =
  try
    let result = f () in
    Ok result
  with
  | CompilerError error_info -> Error error_info
  | Types.TypeError msg -> Error (extract_error_info (type_error msg None))
  | Types.ParseError (msg, line, col) ->
      let pos = { filename = ""; line; column = col } in
      Error (extract_error_info (parse_error msg pos))
  | Types.CodegenError (msg, context) -> Error (extract_error_info (codegen_error ~context msg))
  | Types.SemanticError (msg, _context) -> Error (extract_error_info (semantic_error msg None))
  | Parser_utils.SyntaxError (msg, pos) ->
      let compiler_pos = { filename = pos.filename; line = pos.line; column = pos.column } in
      Error (extract_error_info (syntax_error msg compiler_pos))
  | Parser_poetry.PoetryParseError msg -> Error (extract_error_info (poetry_parse_error msg None))
  | Value_operations.RuntimeError msg -> Error (extract_error_info (runtime_error msg None))
  | Lexer.LexError (msg, pos) ->
      let compiler_pos = { filename = pos.filename; line = pos.line; column = pos.column } in
      Error (extract_error_info (lex_error msg compiler_pos))
  | Sys_error msg -> Error (extract_error_info (io_error msg "系统"))
  | exn -> Error (extract_error_info (internal_error ("未知异常: " ^ Printexc.to_string exn)))

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

(** 获取错误处理配置 - 从统一配置系统 *)
let get_error_config () =
  let runtime_cfg = Config.get_runtime_config () in
  {
    continue_on_error = runtime_cfg.continue_on_error;
    max_errors = runtime_cfg.max_error_count;
    show_suggestions = runtime_cfg.show_suggestions;
    colored_output = runtime_cfg.colored_output;
  }

(** 设置错误处理配置 - 通过统一配置系统 *)
let set_error_config new_config =
  let current_runtime = Config.get_runtime_config () in
  let updated_runtime =
    {
      current_runtime with
      continue_on_error = new_config.continue_on_error;
      max_error_count = new_config.max_errors;
      show_suggestions = new_config.show_suggestions;
      colored_output = new_config.colored_output;
    }
  in
  Config.set_runtime_config updated_runtime

(** 检查是否应该继续处理 *)
let should_continue collector =
  let config = get_error_config () in
  config.continue_on_error && (not collector.has_fatal)
  && get_error_count collector < config.max_errors

(** 替换failwith的便捷函数 *)
let failwith_to_error ?(suggestions = []) ?(context = None) msg =
  let error_info = make_error_info ~suggestions ~context (InternalError msg) in
  Error error_info

(** 常用错误消息的便捷函数 *)
let unsupported_keyword_error ?(suggestions = []) keyword pos =
  let msg = Printf.sprintf "不支持的关键字: %s" keyword in
  let default_suggestions = ["请检查关键字拼写"; "查看文档了解支持的关键字"] in
  let all_suggestions = suggestions @ default_suggestions in
  let error_info = make_error_info ~suggestions:all_suggestions (LexError (msg, pos)) in
  Error error_info

let unsupported_feature_error ?(suggestions = []) ?(context = "词法分析") feature _pos =
  let msg = Printf.sprintf "不支持的功能: %s" feature in
  let default_suggestions = ["该功能可能在未来版本中实现"; "请查看项目路线图"] in
  let all_suggestions = suggestions @ default_suggestions in
  let error_info = make_error_info ~suggestions:all_suggestions (UnimplementedFeature (msg, context)) in
  Error error_info

let invalid_character_error ?(suggestions = []) char pos =
  let msg = Printf.sprintf "无效字符: %c" char in
  let default_suggestions = ["请检查字符编码"; "确保使用UTF-8编码"] in
  let all_suggestions = suggestions @ default_suggestions in
  let error_info = make_error_info ~suggestions:all_suggestions (LexError (msg, pos)) in
  Error error_info

let unexpected_state_error ?(suggestions = []) state context =
  let msg = Printf.sprintf "意外的状态: %s (上下文: %s)" state context in
  let default_suggestions = ["这可能是编译器内部错误"; "请报告此问题"] in
  let all_suggestions = suggestions @ default_suggestions in
  let error_info = make_error_info ~severity:Fatal ~suggestions:all_suggestions (InternalError msg) in
  Error error_info

(** 位置信息创建辅助函数 *)
let make_position ?(filename = "") line column = { filename; line; column }

(** 从选项值创建错误的辅助函数 *)
let option_to_error ?(suggestions = []) error_msg = function
  | Some x -> Ok x
  | None -> failwith_to_error ~suggestions error_msg

(** 链式错误处理 - 用于替换嵌套的match表达式 *)
let chain_errors f_list initial_value =
  let rec process value = function
    | [] -> Ok value
    | f :: rest ->
        (match f value with
         | Ok new_value -> process new_value rest
         | Error e -> Error e)
  in
  process initial_value f_list

(** 收集错误结果 - 用于处理多个可能失败的操作 *)
let collect_error_results results =
  let collector = create_error_collector () in
  let successful_results = ref [] in
  List.iter
    (function
      | Ok value -> successful_results := value :: !successful_results
      | Error error_info -> add_error collector error_info)
    results;
  if has_errors collector then
    Error (List.hd (get_errors collector))
  else
    Ok (List.rev !successful_results)

(** 安全的Option.get替代 *)
let safe_option_get ?(error_msg = "选项值为None") = function
  | Some x -> Ok x
  | None -> failwith_to_error error_msg

(** 安全的列表访问 *)
let safe_list_head ?(error_msg = "列表为空") = function
  | [] -> failwith_to_error error_msg
  | h :: _ -> Ok h

let safe_list_nth ?(error_msg = "列表索引越界") list index =
  try Ok (List.nth list index)
  with Invalid_argument _ -> failwith_to_error error_msg

(** 安全的字符串到整数转换 *)
let safe_int_of_string ?(error_msg = "无效的整数格式") str =
  try Ok (int_of_string str)
  with Failure _ -> failwith_to_error error_msg

(** 安全的字符串到浮点数转换 *)
let safe_float_of_string ?(error_msg = "无效的浮点数格式") str =
  try Ok (float_of_string str)
  with Failure _ -> failwith_to_error error_msg

(** 验证函数 - 用于参数验证 *)
let validate_non_empty_string ?(error_msg = "字符串不能为空") str =
  if String.length str = 0 then failwith_to_error error_msg
  else Ok str

let validate_positive_int ?(error_msg = "数值必须为正数") n =
  if n <= 0 then failwith_to_error error_msg
  else Ok n

(** 操作符重载 - 便于链式调用 *)
let ( let* ) x f = bind_error f x
let ( let+ ) x f = map_error f x
let ( >>? ) x f = match x with Ok v -> f v | Error e -> Error e

(** 模式匹配错误处理 - 用于替换failwith的模式匹配 *)
let match_error ?(suggestions = []) ?(context = None) pattern_desc =
  let msg = Printf.sprintf "模式匹配失败: %s" pattern_desc in
  let default_suggestions = ["请检查模式匹配的完整性"; "确保所有情况都已覆盖"] in
  let all_suggestions = suggestions @ default_suggestions in
  let error_info = make_error_info ~suggestions:all_suggestions ~context (InternalError msg) in
  Error error_info
