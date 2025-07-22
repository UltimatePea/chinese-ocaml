(** 骆言编译器底层格式化基础设施接口

    此模块提供不依赖Printf.sprintf的基础字符串格式化工具接口。 *)

(** 基础字符串格式化工具模块 *)
module Base_formatter : sig
  val concat_strings : string list -> string
  (** 基础字符串拼接函数 *)

  val join_with_separator : string -> string list -> string
  (** 带分隔符的字符串拼接 *)

  val int_to_string : int -> string
  (** 基础类型转换函数 *)

  val float_to_string : float -> string
  val bool_to_string : bool -> string
  val char_to_string : char -> string

  (** 常用格式化模式 *)

  val token_pattern : string -> string -> string
  (** Token模式: TokenType(value) *)

  val char_token_pattern : string -> char -> string
  (** Token模式: TokenType('char') *)

  val context_message_pattern : string -> string -> string
  (** 错误上下文模式: context: message *)

  val file_position_pattern : string -> int -> int -> string
  (** 位置信息模式: filename:line:column *)

  val line_col_message_pattern : int -> int -> string -> string
  (** 位置信息模式: (line:column): message *)

  val token_position_pattern : string -> int -> int -> string
  (** Token位置模式: token@line:column *)

  val param_count_pattern : int -> int -> string
  (** 参数计数模式: 期望X个参数，但获得Y个参数 *)

  val function_name_pattern : string -> string
  (** 函数名模式: 函数名函数 *)

  val function_param_error_pattern : string -> int -> int -> string
  (** 函数错误模式: 函数名函数期望X个参数，但获得Y个参数 *)

  val type_expectation_pattern : string -> string
  (** 类型期望模式: 期望X参数 *)

  val function_type_error_pattern : string -> string -> string
  (** 函数类型错误模式: 函数名函数期望X参数 *)

  val type_mismatch_pattern : string -> string -> string
  (** 类型不匹配模式: 期望 X，但得到 Y *)

  val index_out_of_bounds_pattern : int -> int -> string
  (** 索引超出范围模式: 索引 X 超出范围，数组长度为 Y *)

  val file_operation_error_pattern : string -> string -> string
  (** 文件操作错误模式: 无法X文件: Y *)

  val luoyan_function_pattern : string -> string -> string
  (** C代码生成模式: luoyan_function_name(args) *)

  val luoyan_env_bind_pattern : string -> string -> string
  (** C环境绑定模式: luoyan_env_bind(env, "var", expr); *)

  val c_code_structure_pattern : string -> string -> string -> string
  (** C代码结构模式: includes + functions + main *)

  val stat_report_pattern : string -> string -> int -> string
  (** 统计报告模式: icon category: count 个 *)

  val stat_report_line_pattern : string -> string -> int -> string
  (** 带换行的统计报告模式 *)

  val analysis_message_pattern : string -> string -> string
  (** 分析消息模式: icon message *)

  val analysis_message_line_pattern : string -> string -> string
  (** 带换行的分析消息模式 *)

  val performance_creation_pattern : int -> string -> string
  (** 性能分析消息模式: 创建了包含X个元素的大型Y *)

  val performance_field_pattern : int -> string -> string
  (** 性能字段分析模式: 创建了包含X个字段的大型Y *)

  val poetry_char_count_pattern : int -> int -> string
  (** 诗词字符数不匹配模式: 字符数不匹配：期望X字，实际Y字 *)

  val poetry_couplet_pattern : int -> int -> string
  (** 诗词对偶不匹配模式: 对偶字数不匹配：左联X字，右联Y字 *)

  val poetry_quatrain_pattern : int -> string
  (** 绝句格式模式: 绝句包含X句，通常为4句 *)

  val list_format : string list -> string
  (** 列表格式化 - 方括号包围，分号分隔 *)

  val function_call_format : string -> string list -> string
  (** 函数调用格式化: FunctionName(arg1, arg2, ...) *)

  val module_access_format : string -> string -> string
  (** 模块访问格式化: Module.member *)

  val template_replace : string -> (string * string) list -> string
  (** 高级模板替换函数（用于复杂场景） *)
end

include module type of Base_formatter
(** 导出常用函数到顶层 *)
