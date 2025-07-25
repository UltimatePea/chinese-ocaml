(** 骆言编译器位置信息格式化模块接口

    此模块专门处理源码位置、行列信息、文件路径等位置相关的格式化需求。

    设计原则:
    - 精确性：准确标识源码中的错误位置
    - 一致性：统一的位置信息显示格式
    - 可读性：易于开发者理解的位置描述
    - 调试友好：提供丰富的调试位置信息

    用途：为编译器错误报告、调试信息、源码分析提供位置格式化服务 *)

(** 位置信息格式化工具模块 *)
module Position_formatters : sig
  val file_position_pattern : string -> int -> int -> string
  (** 位置信息模式: filename:line:column *)

  val line_col_message_pattern : int -> int -> string -> string
  (** 位置信息模式: (line:column): message *)

  val token_position_pattern : string -> int -> int -> string
  (** Token位置模式: token@line:column *)

  val position_standard : string -> int -> int -> string
  (** 标准位置格式: filename:line:column *)

  val position_chinese_format : int -> int -> string
  (** 中文行列格式: 行:line 列:column *)

  val position_parentheses : int -> int -> string
  (** 括号位置格式: (行:line, 列:column) *)

  val position_range : int -> int -> int -> int -> string
  (** 位置范围格式: start_line:start_col-end_line:end_col *)

  val line_only_format : int -> string
  (** 简化行号格式: 行:line *)

  val line_with_colon_format : int -> string
  (** 行号带冒号格式: line: *)

  val position_with_offset_format : int -> int -> int -> string
  (** 带偏移的位置格式: 行:line 列:column 偏移:offset *)

  val relative_position_format : int -> int -> string
  (** 相对位置格式: 相对位置(+line_diff,+col_diff) *)

  val full_position_with_file_format : string -> int -> int -> string
  (** 完整文件位置格式: 文件:filename 行:line 列:column *)

  val same_line_range_format : int -> int -> int -> string
  (** 同行位置范围格式: 第line行 列start_col-end_col *)

  val multi_line_range_format : int -> int -> int -> int -> string
  (** 多行位置范围格式: 第start_line行第start_col列 至 第end_line行第end_col列 *)

  val error_position_marker_format : int -> int -> string
  (** 错误位置标记格式: >>> 错误位置: 行:line 列:column *)

  val debug_position_info_format : string -> int -> int -> string -> string
  (** 调试位置信息格式: [DEBUG] func_name@filename:line:column *)

  val error_type_with_position_format : string -> string -> string -> string
  (** 错误类型与位置结合格式: error_type pos_str: message *)

  val optional_position_wrapper_format : string -> string
  (** 可选位置包装格式: 如果有位置则返回 ( position )，否则返回空字符串 *)
end

(** 导出的顶层函数 *)

val file_position_pattern : string -> int -> int -> string
(** 位置信息模式: filename:line:column *)

val line_col_message_pattern : int -> int -> string -> string
(** 位置信息模式: (line:column): message *)

val token_position_pattern : string -> int -> int -> string
(** Token位置模式: token@line:column *)

val position_standard : string -> int -> int -> string
(** 标准位置格式: filename:line:column *)

val position_chinese_format : int -> int -> string
(** 中文行列格式: 行:line 列:column *)

val position_parentheses : int -> int -> string
(** 括号位置格式: (行:line, 列:column) *)

val position_range : int -> int -> int -> int -> string
(** 位置范围格式: start_line:start_col-end_line:end_col *)

val line_only_format : int -> string
(** 简化行号格式: 行:line *)

val line_with_colon_format : int -> string
(** 行号带冒号格式: line: *)

val position_with_offset_format : int -> int -> int -> string
(** 带偏移的位置格式: 行:line 列:column 偏移:offset *)

val relative_position_format : int -> int -> string
(** 相对位置格式: 相对位置(+line_diff,+col_diff) *)

val full_position_with_file_format : string -> int -> int -> string
(** 完整文件位置格式: 文件:filename 行:line 列:column *)

val same_line_range_format : int -> int -> int -> string
(** 同行位置范围格式: 第line行 列start_col-end_col *)

val multi_line_range_format : int -> int -> int -> int -> string
(** 多行位置范围格式: 第start_line行第start_col列 至 第end_line行第end_col列 *)

val error_position_marker_format : int -> int -> string
(** 错误位置标记格式: >>> 错误位置: 行:line 列:column *)

val debug_position_info_format : string -> int -> int -> string -> string
(** 调试位置信息格式: [DEBUG] func_name@filename:line:column *)

val error_type_with_position_format : string -> string -> string -> string
(** 错误类型与位置结合格式: error_type pos_str: message *)

val optional_position_wrapper_format : string -> string
(** 可选位置包装格式: 如果有位置则返回 ( position )，否则返回空字符串 *)
