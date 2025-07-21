(** 骆言统一错误格式化工具模块实现 - Unified Error Formatting Implementation *)

(** 错误类型定义 *)
type error_severity = 
  | Fatal    (** 致命错误 *)
  | Error    (** 错误 *)
  | Warning  (** 警告 *)
  | Info     (** 信息 *)

(** 位置信息类型 *)
type position_info = {
  filename: string;
  line: int;
  column: int option;
}

(** 错误消息格式化工具 *)
module Message = struct
  (** 获取错误严重性的中文描述 *)
  let severity_to_chinese = function
    | Fatal -> "致命错误"
    | Error -> "错误"
    | Warning -> "警告"
    | Info -> "信息"

  (** 格式化基本错误消息 *)
  let format_error severity message =
    Printf.sprintf "%s：%s" (severity_to_chinese severity) message

  (** 格式化位置信息 *)
  let format_position pos =
    match pos.column with
    | Some col -> Printf.sprintf "%s:%d:%d" pos.filename pos.line col
    | None -> Printf.sprintf "%s:%d" pos.filename pos.line

  (** 格式化带位置的错误消息 *)
  let format_error_with_position severity message pos =
    Printf.sprintf "%s - %s：%s" (format_position pos) (severity_to_chinese severity) message

  (** 格式化词法错误 *)
  let format_lexical_error error_type details =
    Printf.sprintf "词法错误：%s '%s'" error_type details

  (** 格式化语法错误 *)
  let format_parse_error error_type details =
    Printf.sprintf "解析错误：%s '%s'" error_type details

  (** 格式化语义错误 *)
  let format_semantic_error error_type details =
    Printf.sprintf "语义错误：%s '%s'" error_type details

  (** 格式化类型错误 *)
  let format_type_error error_type details =
    Printf.sprintf "类型错误：%s '%s'" error_type details

  (** 格式化运行时错误 *)
  let format_runtime_error error_type details =
    Printf.sprintf "运行时错误：%s '%s'" error_type details
end

(** 错误恢复建议工具 *)
module Recovery = struct
  (** 生成错误恢复建议 *)
  let suggest_recovery error_message =
    let suggestions = ref [] in
    
    (* 基于错误消息关键词生成建议 *)
    if Str.string_match (Str.regexp ".*未.*") error_message 0 then
      suggestions := "检查语法是否完整" :: !suggestions;
    
    if Str.string_match (Str.regexp ".*无效.*") error_message 0 then
      suggestions := "检查标识符或关键字拼写" :: !suggestions;
    
    if Str.string_match (Str.regexp ".*缺少.*") error_message 0 then
      suggestions := "补充缺失的语法元素" :: !suggestions;
    
    if Str.string_match (Str.regexp ".*类型.*") error_message 0 then
      suggestions := "检查变量类型是否匹配" :: !suggestions;
    
    if List.length !suggestions = 0 then
      ["检查代码语法和语义"]
    else
      List.rev !suggestions

  (** 格式化恢复建议 *)
  let format_suggestions suggestions =
    match suggestions with
    | [] -> ""
    | [single] -> Printf.sprintf "建议：%s" single
    | multiple ->
        let numbered_suggestions = List.mapi (fun i suggestion -> 
          Printf.sprintf "  %d. %s" (i + 1) suggestion
        ) multiple in
        "建议：\n" ^ String.concat "\n" numbered_suggestions

  (** 组合错误消息和建议 *)
  let combine_error_and_suggestions error_msg suggestions =
    let suggestion_text = format_suggestions suggestions in
    if String.length suggestion_text = 0 then
      error_msg
    else
      error_msg ^ "\n" ^ suggestion_text
end

(** 错误统计和报告工具 *)
module Statistics = struct
  (** 错误统计信息 *)
  type error_stats = {
    fatal_count: int;
    error_count: int;
    warning_count: int;
    info_count: int;
  }

  (** 格式化错误统计报告 *)
  let format_error_summary stats =
    let parts = [] in
    let parts = if stats.fatal_count > 0 then
      Printf.sprintf "%d个致命错误" stats.fatal_count :: parts
    else parts in
    let parts = if stats.error_count > 0 then
      Printf.sprintf "%d个错误" stats.error_count :: parts
    else parts in
    let parts = if stats.warning_count > 0 then
      Printf.sprintf "%d个警告" stats.warning_count :: parts
    else parts in
    let parts = if stats.info_count > 0 then
      Printf.sprintf "%d个信息" stats.info_count :: parts
    else parts in
    
    if List.length parts = 0 then
      "编译成功，无错误或警告"
    else
      "编译完成：" ^ String.concat "，" (List.rev parts)

  (** 判断是否有阻塞性错误 *)
  let has_blocking_errors stats =
    stats.fatal_count > 0 || stats.error_count > 0
end

(** 用户友好的错误消息工具 *)
module UserFriendly = struct
  (** 将技术错误消息转换为用户友好的描述 *)
  let make_user_friendly technical_message =
    (* 简化技术术语为用户友好的描述 *)
    let message = String.lowercase_ascii technical_message in
    if Str.string_match (Str.regexp ".*failwith.*") message 0 then
      "程序遇到了意外情况"
    else if Str.string_match (Str.regexp ".*not_found.*") message 0 then
      "找不到指定的内容"
    else if Str.string_match (Str.regexp ".*invalid_argument.*") message 0 then
      "提供的参数无效"
    else if Str.string_match (Str.regexp ".*end_of_file.*") message 0 then
      "文件意外结束"
    else
      technical_message

  (** 添加解决方案提示 *)
  let add_solution_hint error_message hint =
    Printf.sprintf "%s\n💡 提示：%s" error_message hint

  (** 格式化详细错误报告 *)
  let format_detailed_report error_message position_opt suggestions =
    let header = match position_opt with
      | Some pos -> Message.format_position pos ^ " - " ^ error_message
      | None -> error_message
    in
    
    let friendly_message = make_user_friendly error_message in
    let suggestion_text = Recovery.format_suggestions suggestions in
    
    if String.length suggestion_text = 0 then
      header ^ "\n" ^ friendly_message
    else
      header ^ "\n" ^ friendly_message ^ "\n" ^ suggestion_text
end