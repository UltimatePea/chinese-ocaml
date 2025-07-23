(** 位置信息格式化模块 - Printf.sprintf统一化重构

    本模块专门处理源代码位置信息的格式化， 提供统一的位置信息显示格式。
    
    重构说明：完全消除Printf.sprintf依赖，使用Base_formatter底层基础设施，
    实现零重复的位置信息格式化。

    @author 骆言技术债务清理团队
    @version 2.0 - Printf.sprintf统一化第三阶段
    @since 2025-07-20 Issue #708 重构
    @updated 2025-07-22 Issue #860 Printf.sprintf统一化 *)

open Utils.Base_formatter

(** 标准位置格式 - 通用函数式方法 *)
let format_position_with_fields ~filename ~line ~column = position_standard filename line column

(** 标准位置格式 - 使用提取函数 *)
let format_position_with_extractor pos ~get_filename ~get_line ~get_column =
  position_standard (get_filename pos) (get_line pos) (get_column pos)

(** 常用的位置格式化函数 - 为编译器错误模块准备 *)
let format_compiler_error_position_from_fields filename line column =
  format_position_with_fields ~filename ~line ~column

(** 可选位置格式 - 使用提取函数 *)
let format_optional_position_with_extractor pos_opt ~get_filename ~get_line ~get_column =
  match pos_opt with
  | Some pos ->
      let position_str = format_position_with_extractor pos ~get_filename ~get_line ~get_column in
      optional_position_wrapper_format position_str
  | None -> ""

(** 带位置的错误消息 - 使用提取函数 *)
let error_with_position_extractor pos_opt error_type msg ~get_filename ~get_line ~get_column =
  let pos_str =
    format_optional_position_with_extractor pos_opt ~get_filename ~get_line ~get_column
  in
  error_type_with_position_format error_type pos_str msg

(** 位置信息格式化器扩展 - Printf.sprintf统一化第三阶段 *)
module Position_formatter = struct
  (** 标准文件行列格式 *)
  let file_line_column filename line column = position_standard filename line column

  (** 中文行列格式 *)
  let line_column_chinese line column = position_chinese_format line column

  (** 带括号的位置格式 *)
  let position_parentheses line column = Base_formatter.position_parentheses line column

  (** 范围格式化 *)
  let range_format start_line start_col end_line end_col =
    position_range start_line start_col end_line end_col

  (** 简化位置格式（只有行号） *)
  let line_only line = line_only_format line

  let line_only_with_colon line = line_with_colon_format line

  (** 位置偏移格式 *)
  let position_with_offset line column offset = position_with_offset_format line column offset

  (** 相对位置格式 *)
  let relative_position base_line base_col line column =
    let line_diff = line - base_line in
    let col_diff = column - base_col in
    relative_position_format line_diff col_diff

  (** 带文件名的完整位置 *)
  let full_position_with_file filename line column =
    full_position_with_file_format filename line column

  (** 位置范围描述 *)
  let position_range_description start_line start_col end_line end_col =
    if start_line = end_line then same_line_range_format start_line start_col end_col
    else multi_line_range_format start_line start_col end_line end_col

  (** 错误位置标记 *)
  let error_position_marker line column = error_position_marker_format line column

  (** 调试位置信息 *)
  let debug_position_info filename line column func_name =
    debug_position_info_format filename line column func_name

  (** 位置比较描述 *)
  let position_comparison pos1_line pos1_col pos2_line pos2_col =
    if pos1_line < pos2_line || (pos1_line = pos2_line && pos1_col < pos2_col) then "位置1在位置2之前"
    else if pos1_line = pos2_line && pos1_col = pos2_col then "位置1与位置2相同"
    else "位置1在位置2之后"
end
