(** 统一错误处理系统 - 骆言编译器 (重构版本) *)

(* 重新导出所有子模块的功能 *)

(* 类型定义 *)
include Compiler_errors_types

(* 错误创建函数 *)
include Compiler_errors_creation

(* 错误格式化函数 *)
include Compiler_errors_formatter

(** 从统一错误系统抛出异常 *)
let raise_compiler_error error_info = raise (CompilerError error_info)

(** 辅助函数：从错误结果中提取错误信息 *)
let extract_error_info = function
  | Error error_info -> error_info
  | Ok _ -> failwith "Unexpected Ok from error function"

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

(** 错误收集器函数 *)
let create_error_collector () = { errors = []; has_fatal = false }

let add_error collector error_info =
  collector.errors <- error_info :: collector.errors;
  if error_info.severity = Fatal then collector.has_fatal <- true

let has_errors collector = List.length collector.errors > 0
let get_errors collector = List.rev collector.errors
let get_error_count collector = List.length collector.errors

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

(** 从选项值创建错误的辅助函数 *)
let option_to_error ?(suggestions = []) error_msg = function
  | Some x -> Ok x
  | None -> failwith_to_error ~suggestions error_msg

(** 链式错误处理 - 用于替换嵌套的match表达式 *)
let chain_errors f_list initial_value =
  let rec process value = function
    | [] -> Ok value
    | f :: rest -> (
        match f value with Ok new_value -> process new_value rest | Error e -> Error e)
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
    match get_errors collector with
    | [] -> Error (make_error_info (InternalError "错误收集器状态不一致：has_errors为true但无错误"))
    | first_error :: _ -> Error first_error
  else Ok (List.rev !successful_results)

(** 安全的Option.get替代 *)
let safe_option_get ?(error_msg = "选项值为None") = function
  | Some x -> Ok x
  | None -> failwith_to_error error_msg

(** 安全的列表访问 *)
let safe_list_head ?(error_msg = "列表为空") = function
  | [] -> failwith_to_error error_msg
  | h :: _ -> Ok h

let safe_list_nth ?(error_msg = "列表索引越界") list index =
  try Ok (List.nth list index) with Invalid_argument _ -> failwith_to_error error_msg

(** 安全的字符串到整数转换 *)
let safe_int_of_string ?(error_msg = "无效的整数格式") str =
  try Ok (int_of_string str) with Failure _ -> failwith_to_error error_msg

(** 安全的字符串到浮点数转换 *)
let safe_float_of_string ?(error_msg = "无效的浮点数格式") str =
  try Ok (float_of_string str) with Failure _ -> failwith_to_error error_msg

(** 验证函数 - 用于参数验证 *)
let validate_non_empty_string ?(error_msg = "字符串不能为空") str =
  if String.length str = 0 then failwith_to_error error_msg else Ok str

let validate_positive_int ?(error_msg = "数值必须为正数") n =
  if n <= 0 then failwith_to_error error_msg else Ok n

(** 操作符重载 - 便于链式调用 *)
let ( let* ) x f = bind_error f x

let ( let+ ) x f = map_error f x
let ( >>? ) x f = match x with Ok v -> f v | Error e -> Error e
