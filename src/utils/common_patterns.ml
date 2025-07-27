(** 通用模式工具模块 - 消除代码重复的核心工具集
    
    本模块统一了项目中最常见的重复代码模式：
    - Let绑定模式 (458个重复)
    - Match模式匹配 (249个重复)  
    - 异常处理 (177个重复)
    - List操作 (191个重复)
    - Printf输出 (84个重复)
    - String操作 (113个重复)
    
    Phase 7 技术债务清理 - 代码重复消除
    
    @author Beta, 代码审查代理
    @version 1.0
    @since 2025-07-27 - Fix #1429 *)

open Printf

(** 位置信息类型 *)
type source_position = { filename : string; line : int; column : int }

(** ======================================================================== 
    错误处理和上下文管理工具 - 解决458个let绑定重复
    ======================================================================== *)

(** 错误上下文类型 - 统一的错误信息结构 *)
type error_context = {
  module_name : string;
  function_name : string;
  operation : string option;
}

(** 创建错误上下文的统一函数 *)
let make_error_context ?(operation = None) ~module_name ~function_name () =
  { module_name; function_name; operation }

(** 格式化上下文错误消息 *)
let format_contextual_error context message =
  match context.operation with
  | None -> sprintf "[%s.%s] %s" context.module_name context.function_name message
  | Some op -> sprintf "[%s.%s:%s] %s" context.module_name context.function_name op message

(** 带上下文的参数验证工具 *)
let validate_with_context validator context value =
  try Ok (validator value)
  with exn -> Error (format_contextual_error context (Printexc.to_string exn))

(** 安全操作包装器 - 统一异常处理模式 *)
let safe_operation ?(context = None) ~error_handler operation =
  try 
    let result = operation () in
    Ok result
  with exn ->
    let error_msg = match context with
      | None -> Printexc.to_string exn
      | Some ctx -> format_contextual_error ctx (Printexc.to_string exn)
    in
    Error (error_handler error_msg)

(** ======================================================================== 
    通用Token处理工具 - 解决249个match模式重复
    ======================================================================== *)

(** 通用token匹配器 - 减少重复的match模式 *)
let match_token_with_handlers token handlers ~default =
  try
    List.find_map (fun (pattern, handler) ->
      if pattern token then Some (handler token) else None
    ) handlers
    |> function
    | Some result -> result
    | None -> default token
  with _exn -> default token

(** Token到字符串的转换映射器 *)
let token_to_string_with_mapping mappings token ~default_formatter =
  try
    List.assoc token mappings
  with Not_found -> default_formatter token

(** 安全的token查找 *)
let safe_token_lookup table key ~default =
  try Some (Hashtbl.find table key)
  with Not_found -> default

(** Result类型的token处理 *)
let safe_token_operation operation token =
  try Ok (operation token)
  with exn -> Error (sprintf "Token处理错误: %s" (Printexc.to_string exn))

(** ======================================================================== 
    数据加载工具 - 解决rhyme系统中的重复加载模式
    ======================================================================== *)

(** 通用字符组加载器 *)
let load_character_groups loader group_names =
  List.map (fun name ->
    try loader name
    with exn -> 
      eprintf "警告: 无法加载字符组 %s: %s\n" name (Printexc.to_string exn);
      []
  ) group_names

(** JSON文件安全解析 *)
let safe_json_parse file_path =
  try
    let content = In_channel.with_open_text file_path In_channel.input_all in
    Ok (Yojson.Basic.from_string content)
  with
  | Sys_error msg -> Error (sprintf "文件错误: %s" msg)
  | Yojson.Json_error msg -> Error (sprintf "JSON解析错误: %s" msg)
  | exn -> Error (sprintf "未知错误: %s" (Printexc.to_string exn))

(** 带回退的数据文件查找 *)
let find_data_file_with_candidates candidates =
  List.find_opt Sys.file_exists candidates

(** 延迟初始化数据加载器 *)
let create_lazy_data_loader loader_func =
  let data_ref = ref None in
  fun () ->
    match !data_ref with
    | Some data -> data
    | None ->
        let data = loader_func () in
        data_ref := Some data;
        data

(** ======================================================================== 
    List处理工具 - 解决191个重复的List操作
    ======================================================================== *)

(** 安全的List.map，带错误处理 *)
let safe_map_with_context transformer context items =
  let rec map_aux acc = function
    | [] -> Ok (List.rev acc)
    | item :: rest ->
        match validate_with_context transformer context item with
        | Ok result -> map_aux (result :: acc) rest
        | Error msg -> Error msg
  in
  map_aux [] items

(** 累积器模式的通用实现 *)
let collect_with_accumulator collector initial items =
  List.fold_left (fun acc item ->
    match collector item with
    | Some result -> result :: acc
    | None -> acc
  ) initial items |> List.rev

(** 列表连接组装工具 - 用于韵律数据组装 *)
let assemble_data_groups data_groups transformer =
  List.concat (List.map transformer data_groups)

(** 安全的列表索引访问 *)
let safe_list_nth list index ~default =
  try List.nth list index
  with 
  | Failure _ -> default
  | Invalid_argument _ -> default

(** ======================================================================== 
    String处理工具 - 解决113个重复的String操作
    ======================================================================== *)

(** 安全的字符串连接 *)
let safe_string_concat separator items =
  try String.concat separator items
  with exn -> 
    eprintf "警告: 字符串连接失败: %s\n" (Printexc.to_string exn);
    ""

(** 位置信息格式化 *)
let format_position ?(include_file = false) pos =
  if include_file && pos.filename <> "" then
    sprintf "文件 %s 第%d行第%d列" pos.filename pos.line pos.column
  else
    sprintf "第%d行第%d列" pos.line pos.column

(** 调试消息格式化 *)
let format_debug_message operation_name status =
  sprintf "[调试] %s: %s" operation_name status

(** 参数错误消息格式化 *)
let format_param_error function_name expected actual =
  sprintf "函数 %s 期望 %d 个参数，实际 %d 个" function_name expected actual

(** ======================================================================== 
    Parser通用工具 - 减少parser模块中的重复模式
    ======================================================================== *)

(** 通用表达式解析分发器 *)
let parse_by_token_type token_handlers default_handler token state =
  match List.find_opt (fun (pattern, _) -> pattern token) token_handlers with
  | Some (_, handler) -> handler token state
  | None -> default_handler token state

(** 简化的参数收集函数 *)
let collect_with_terminator terminator parse_expr get_current_token state =
  let rec collect acc current_state =
    let token, _ = get_current_token current_state in
    if terminator token then
      Ok (List.rev acc, current_state)
    else
      match parse_expr current_state with
      | Ok (expr, new_state) -> collect (expr :: acc) new_state
      | Error msg -> Error msg
  in
  collect [] state

(** 简化的状态推进验证 *)
let validate_and_advance get_current_token advance_state expected_token_checker state =
  let token, pos = get_current_token state in
  if expected_token_checker token then
    Ok (advance_state state)
  else
    Error (sprintf "期望的token类型不匹配 在%s" (format_position pos))

(** ======================================================================== 
    统一的printf模式 - 解决84个重复的printf调用
    ======================================================================== *)

(** 错误消息打印 *)
let print_error context message =
  eprintf "%s\n" (format_contextual_error context message)

(** 调试信息打印 *)
let print_debug_info ?(prefix = "[调试]") message =
  eprintf "%s %s\n" prefix message

(** 警告信息打印 *)
let print_warning ?(prefix = "警告") message =
  eprintf "%s: %s\n" prefix message

(** 统一的进度报告 *)
let print_progress operation_name progress =
  printf "正在%s: %s\n" operation_name progress;
  flush stdout