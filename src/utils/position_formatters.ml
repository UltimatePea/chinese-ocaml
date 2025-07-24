(** 骆言编译器位置信息格式化模块

    此模块专门处理源码位置、行列信息、文件路径等位置相关的格式化需求。

    设计原则:
    - 精确性：准确标识源码中的错误位置
    - 一致性：统一的位置信息显示格式
    - 可读性：易于开发者理解的位置描述
    - 调试友好：提供丰富的调试位置信息

    用途：为编译器错误报告、调试信息、源码分析提供位置格式化服务 *)

open Base_string_ops

(** 位置信息格式化工具模块 *)
module Position_formatters = struct
  (** 位置信息模式: filename:line:column *)
  let file_position_pattern filename line column =
    concat_strings [ filename; ":"; int_to_string line; ":"; int_to_string column ]

  (** 位置信息模式: (line:column): message *)
  let line_col_message_pattern line col message =
    concat_strings [ "("; int_to_string line; ":"; int_to_string col; "): "; message ]

  (** Token位置模式: token@line:column *)
  let token_position_pattern token line column =
    concat_strings [ token; "@"; int_to_string line; ":"; int_to_string column ]

  (** 标准位置格式: filename:line:column *)
  let position_standard filename line column =
    concat_strings [ filename; ":"; int_to_string line; ":"; int_to_string column ]

  (** 中文行列格式: 行:line 列:column *)
  let position_chinese_format line column =
    concat_strings [ "行:"; int_to_string line; " 列:"; int_to_string column ]

  (** 括号位置格式: (行:line, 列:column) *)
  let position_parentheses line column =
    concat_strings [ "(行:"; int_to_string line; ", 列:"; int_to_string column; ")" ]

  (** 位置范围格式: start_line:start_col-end_line:end_col *)
  let position_range start_line start_col end_line end_col =
    concat_strings
      [
        int_to_string start_line;
        ":";
        int_to_string start_col;
        "-";
        int_to_string end_line;
        ":";
        int_to_string end_col;
      ]

  (** 简化行号格式: 行:line *)
  let line_only_format line = concat_strings [ "行:"; int_to_string line ]

  (** 行号带冒号格式: line: *)
  let line_with_colon_format line = concat_strings [ int_to_string line; ":" ]

  (** 带偏移的位置格式: 行:line 列:column 偏移:offset *)
  let position_with_offset_format line column offset =
    concat_strings
      [ "行:"; int_to_string line; " 列:"; int_to_string column; " 偏移:"; int_to_string offset ]

  (** 相对位置格式: 相对位置(+line_diff,+col_diff) *)
  let relative_position_format line_diff col_diff =
    concat_strings [ "相对位置(+"; int_to_string line_diff; ",+"; int_to_string col_diff; ")" ]

  (** 完整文件位置格式: 文件:filename 行:line 列:column *)
  let full_position_with_file_format filename line column =
    concat_strings [ "文件:"; filename; " 行:"; int_to_string line; " 列:"; int_to_string column ]

  (** 同行位置范围格式: 第line行 列start_col-end_col *)
  let same_line_range_format line start_col end_col =
    concat_strings
      [ "第"; int_to_string line; "行 列"; int_to_string start_col; "-"; int_to_string end_col ]

  (** 多行位置范围格式: 第start_line行第start_col列 至 第end_line行第end_col列 *)
  let multi_line_range_format start_line start_col end_line end_col =
    concat_strings
      [
        "第";
        int_to_string start_line;
        "行第";
        int_to_string start_col;
        "列 至 第";
        int_to_string end_line;
        "行第";
        int_to_string end_col;
        "列";
      ]

  (** 错误位置标记格式: >>> 错误位置: 行:line 列:column *)
  let error_position_marker_format line column =
    concat_strings [ ">>> 错误位置: 行:"; int_to_string line; " 列:"; int_to_string column ]

  (** 调试位置信息格式: [DEBUG] func_name@filename:line:column *)
  let debug_position_info_format filename line column func_name =
    concat_strings
      [ "[DEBUG] "; func_name; "@"; filename; ":"; int_to_string line; ":"; int_to_string column ]

  (** 错误类型与位置结合格式: error_type pos_str: message *)
  let error_type_with_position_format error_type pos_str message =
    concat_strings [ error_type; pos_str; ": "; message ]

  (** 可选位置包装格式: 如果有位置则返回 ( position )，否则返回空字符串 *)
  let optional_position_wrapper_format position_str =
    if position_str = "" then "" else concat_strings [ " ("; position_str; ")" ]
end

include Position_formatters
(** 导出位置格式化函数到顶层，便于使用 *)