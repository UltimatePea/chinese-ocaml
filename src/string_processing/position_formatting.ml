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
