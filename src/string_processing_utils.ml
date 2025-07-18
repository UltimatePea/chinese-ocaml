(** 通用字符串处理工具函数 *)

(** 字符串处理的通用模板 *)
let process_string_with_skip line skip_logic =
  let result = ref "" in
  let i = ref 0 in
  let len = String.length line in
  while !i < len do
    let should_skip, skip_length = skip_logic !i line len in
    if should_skip then i := !i + skip_length
    else (
      result := !result ^ String.make 1 (String.get line !i);
      i := !i + 1)
  done;
  !result

(** 块注释跳过逻辑 *)
let block_comment_skip_logic i line len =
  if i < len - 1 && String.get line i = '(' && String.get line (i + 1) = '*' then
    let rec skip_to_end pos =
      if pos < len - 1 && String.get line pos = '*' && String.get line (pos + 1) = ')' then pos + 2
      else if pos < len then skip_to_end (pos + 1)
      else len
    in
    let end_pos = skip_to_end (i + 2) in
    (true, end_pos - i)
  else (false, 0)

(** 骆言字符串跳过逻辑 *)
let luoyan_string_skip_logic i line len =
  if
    i + 2 < len
    && String.get line i = '\xe3'
    && String.get line (i + 1) = '\x80'
    && String.get line (i + 2) = '\x8e'
  then
    let rec skip_to_end pos =
      if
        pos + 2 < len
        && String.get line pos = '\xe3'
        && String.get line (pos + 1) = '\x80'
        && String.get line (pos + 2) = '\x8f'
      then pos + 3
      else if pos < len then skip_to_end (pos + 1)
      else len
    in
    let end_pos = skip_to_end (i + 3) in
    (true, end_pos - i)
  else (false, 0)

(** 英文字符串跳过逻辑 *)
let english_string_skip_logic i line len =
  let c = String.get line i in
  if c = '"' || c = '\'' then
    let quote = c in
    let rec skip_to_end pos =
      if pos < len && String.get line pos = quote then pos + 1
      else if pos < len then skip_to_end (pos + 1)
      else len
    in
    let end_pos = skip_to_end (i + 1) in
    (true, end_pos - i)
  else (false, 0)

(** 双斜杠注释处理 *)
let remove_double_slash_comment line =
  let rec find_index i =
    if i >= String.length line - 1 then String.length line
    else if String.get line i = '/' && String.get line (i + 1) = '/' then i
    else find_index (i + 1)
  in
  let index = find_index 0 in
  String.sub line 0 index

(** 井号注释处理 *)
let remove_hash_comment line =
  let index = try String.index line '#' with Not_found -> String.length line in
  String.sub line 0 index

(** 重构后的字符串处理函数 *)
let remove_block_comments line = process_string_with_skip line block_comment_skip_logic

let remove_luoyan_strings line = process_string_with_skip line luoyan_string_skip_logic
let remove_english_strings line = process_string_with_skip line english_string_skip_logic

(** ======================================================================= 统一字符串格式化工具模块 -
    为解决字符串处理重复问题 ======================================================================= *)

(** 通用错误消息模板 *)
module ErrorMessageTemplates = struct
  (** 函数参数错误模板 *)
  let function_param_error function_name expected_count actual_count =
    Printf.sprintf "%s函数期望%d个参数，但获得%d个参数" function_name expected_count actual_count

  let function_param_type_error function_name expected_type =
    Printf.sprintf "%s函数期望%s参数" function_name expected_type

  let function_single_param_error function_name = Printf.sprintf "%s函数期望一个参数" function_name

  let function_double_param_error function_name = Printf.sprintf "%s函数期望两个参数" function_name

  let function_no_param_error function_name = Printf.sprintf "%s函数不需要参数" function_name

  (** 类型错误模板 *)
  let type_mismatch_error expected_type actual_type =
    Printf.sprintf "类型不匹配: 期望 %s，但得到 %s" expected_type actual_type

  let undefined_variable_error var_name = Printf.sprintf "未定义的变量: %s" var_name

  let index_out_of_bounds_error index length = Printf.sprintf "索引 %d 超出范围，数组长度为 %d" index length

  (** 文件操作错误模板 *)
  let file_operation_error operation filename = Printf.sprintf "无法%s文件: %s" operation filename

  (** 通用功能错误模板 *)
  let generic_function_error function_name error_desc =
    Printf.sprintf "%s函数：%s" function_name error_desc
end

(** 位置信息格式化模块 *)
module PositionFormatting = struct
  (** 标准位置格式 - 通用函数式方法 *)
  let format_position_with_fields ~filename ~line ~column =
    Printf.sprintf "%s:%d:%d" filename line column

  (** 标准位置格式 - 使用提取函数 *)
  let format_position_with_extractor pos ~get_filename ~get_line ~get_column =
    Printf.sprintf "%s:%d:%d" (get_filename pos) (get_line pos) (get_column pos)

  (** 常用的位置格式化函数 - 为编译器错误模块准备 *)
  let format_compiler_error_position_from_fields filename line column =
    format_position_with_fields ~filename ~line ~column

  (** 可选位置格式 - 使用提取函数 *)
  let format_optional_position_with_extractor pos_opt ~get_filename ~get_line ~get_column =
    match pos_opt with
    | Some pos ->
        " (" ^ format_position_with_extractor pos ~get_filename ~get_line ~get_column ^ ")"
    | None -> ""

  (** 带位置的错误消息 - 使用提取函数 *)
  let error_with_position_extractor pos_opt error_type msg ~get_filename ~get_line ~get_column =
    let pos_str =
      format_optional_position_with_extractor pos_opt ~get_filename ~get_line ~get_column
    in
    Printf.sprintf "%s%s: %s" error_type pos_str msg
end

(** C代码生成格式化模块 *)
module CCodegenFormatting = struct
  (** 函数调用格式 *)
  let function_call func_name args =
    let args_str = String.concat ", " args in
    Printf.sprintf "%s(%s)" func_name args_str

  (** 双参数函数调用 *)
  let binary_function_call func_name e1_code e2_code =
    Printf.sprintf "%s(%s, %s)" func_name e1_code e2_code

  (** 字符串相等性检查 *)
  let string_equality_check expr_var escaped_string =
    Printf.sprintf "luoyan_equals(%s, luoyan_string(\"%s\"))" expr_var escaped_string

  (** 类型转换 *)
  let type_conversion target_type expr = Printf.sprintf "(%s)%s" target_type expr
end

(** 列表和集合格式化模块 *)
module CollectionFormatting = struct
  (** 中文逗号分隔 *)
  let join_chinese items = String.concat "、" items

  (** 英文逗号分隔 *)
  let join_english items = String.concat ", " items

  (** 分号分隔 *)
  let join_semicolon items = String.concat "; " items

  (** 换行分隔 *)
  let join_newline items = String.concat "\n" items

  (** 带缩进的项目列表 *)
  let indented_list items = String.concat "\n" (List.map (fun s -> "  - " ^ s) items)

  (** 数组/元组格式 *)
  let array_format items = "[" ^ join_semicolon items ^ "]"

  let tuple_format items = "(" ^ join_english items ^ ")"

  (** 类型签名格式 *)
  let type_signature_format types = String.concat " * " types
end

(** 报告生成格式化模块 *)
module ReportFormatting = struct
  (** 统计信息格式 *)
  let stats_line icon category count = Printf.sprintf "   %s %s: %d 个\n" icon category count

  (** 分析结果格式 *)
  let analysis_result_line icon message = Printf.sprintf "%s %s\n\n" icon message

  (** 上下文信息格式 *)
  let context_line context = Printf.sprintf "📍 上下文: %s\n\n" context

  (** 建议信息格式 *)
  let suggestion_line current suggestion = Printf.sprintf "建议将「%s」改为「%s」" current suggestion

  (** 相似度建议格式 *)
  let similarity_suggestion match_name score =
    Printf.sprintf "可能想使用：「%s」(相似度: %.0f%%)" match_name (score *. 100.0)
end

(** 颜色和样式格式化模块 *)
module StyleFormatting = struct
  (** ANSI颜色代码 *)
  let with_color color_code message = color_code ^ message ^ "\027[0m"

  (** 预定义颜色 *)
  let red_text message = with_color "\027[31m" message

  let green_text message = with_color "\027[32m" message
  let yellow_text message = with_color "\027[33m" message
  let blue_text message = with_color "\027[34m" message
  let bold_text message = with_color "\027[1m" message
end

(** Buffer累积辅助模块 *)
module BufferHelpers = struct
  (** 安全地向Buffer添加格式化字符串 *)
  let add_formatted_string buffer format_fn = Buffer.add_string buffer (format_fn ())

  (** 批量添加统计信息 *)
  let add_stats_batch buffer stats_list =
    List.iter
      (fun (icon, category, count) ->
        Buffer.add_string buffer (ReportFormatting.stats_line icon category count))
      stats_list

  (** 添加带上下文的错误信息 *)
  let add_error_with_context buffer error_msg context_opt =
    Buffer.add_string buffer (ReportFormatting.analysis_result_line "🚨" error_msg);
    match context_opt with
    | Some ctx -> Buffer.add_string buffer (ReportFormatting.context_line ctx)
    | None -> ()
end
