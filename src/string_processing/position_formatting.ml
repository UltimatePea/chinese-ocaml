(** 位置信息格式化模块

    本模块专门处理源代码位置信息的格式化， 提供统一的位置信息显示格式。

    @author 骆言技术债务清理团队
    @version 1.0
    @since 2025-07-20 Issue #708 重构 *)

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
  | Some pos -> " (" ^ format_position_with_extractor pos ~get_filename ~get_line ~get_column ^ ")"
  | None -> ""

(** 带位置的错误消息 - 使用提取函数 *)
let error_with_position_extractor pos_opt error_type msg ~get_filename ~get_line ~get_column =
  let pos_str =
    format_optional_position_with_extractor pos_opt ~get_filename ~get_line ~get_column
  in
  Printf.sprintf "%s%s: %s" error_type pos_str msg

(** 位置信息格式化器扩展 - 第九阶段代码重复消除 *)
module Position_formatter = struct
  (** 标准文件行列格式 *)
  let file_line_column filename line column = Printf.sprintf "%s:%d:%d" filename line column

  (** 中文行列格式 *)
  let line_column_chinese line column = Printf.sprintf "行:%d 列:%d" line column

  (** 带括号的位置格式 *)
  let position_parentheses line column = Printf.sprintf "(行:%d, 列:%d)" line column

  (** 范围格式化 *)
  let range_format start_line start_col end_line end_col =
    Printf.sprintf "%d:%d-%d:%d" start_line start_col end_line end_col

  (** 简化位置格式（只有行号） *)
  let line_only line = Printf.sprintf "行:%d" line

  let line_only_with_colon line = Printf.sprintf "%d:" line

  (** 位置偏移格式 *)
  let position_with_offset line column offset = Printf.sprintf "行:%d 列:%d 偏移:%d" line column offset

  (** 相对位置格式 *)
  let relative_position base_line base_col line column =
    let line_diff = line - base_line in
    let col_diff = column - base_col in
    Printf.sprintf "相对位置(+%d,+%d)" line_diff col_diff

  (** 带文件名的完整位置 *)
  let full_position_with_file filename line column =
    Printf.sprintf "文件:%s 行:%d 列:%d" filename line column

  (** 位置范围描述 *)
  let position_range_description start_line start_col end_line end_col =
    if start_line = end_line then Printf.sprintf "第%d行 列%d-%d" start_line start_col end_col
    else Printf.sprintf "第%d行第%d列 至 第%d行第%d列" start_line start_col end_line end_col

  (** 错误位置标记 *)
  let error_position_marker line column = Printf.sprintf ">>> 错误位置: 行:%d 列:%d" line column

  (** 调试位置信息 *)
  let debug_position_info filename line column func_name =
    Printf.sprintf "[DEBUG] %s@%s:%d:%d" func_name filename line column

  (** 位置比较描述 *)
  let position_comparison pos1_line pos1_col pos2_line pos2_col =
    if pos1_line < pos2_line || (pos1_line = pos2_line && pos1_col < pos2_col) then "位置1在位置2之前"
    else if pos1_line = pos2_line && pos1_col = pos2_col then "位置1与位置2相同"
    else "位置1在位置2之后"
end
