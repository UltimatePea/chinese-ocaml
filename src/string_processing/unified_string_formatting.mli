(** 
 * 统一字符串格式化模块接口
 * 提供项目中常用的字符串格式化功能，减少代码重复
 * 2025年7月21日 - 技术债务改进
 *)

(** 错误消息格式化模块 *)
module Error : sig
  (** 函数参数数量不匹配错误 *)
  val function_param_count_mismatch : string -> int -> int -> string

  (** 类型不匹配错误 *)
  val type_mismatch : string -> string -> string

  (** 运行时错误（带错误类别） *)
  val runtime_error_with_category : string -> string -> string

  (** 未定义变量错误 *)
  val undefined_variable : string -> string

  (** 数组索引越界错误 *)
  val array_bounds_error : int -> int -> string

  (** 解析错误（带位置信息） *)
  val parse_error_with_position : int -> int -> string -> string

  (** 通用错误模板 *)
  val error_template : string -> string -> string

  (** 错误类型模板 *)
  val error_type_template : string -> string -> string
end

(** 位置和源码位置格式化模块 *)
module Position : sig
  (** 文件位置格式 filename:line:column *)
  val file_position : string -> int -> int -> string

  (** 行列位置格式 *)
  val line_column : int -> int -> string

  (** 带上下文的位置格式 *)
  val position_with_context : string -> string -> int -> string
end

(** C代码生成格式化模块 *)
module CCodegen : sig
  (** 环境变量绑定 *)
  val env_bind : string -> string -> string

  (** 骆言运行时值创建器 *)
  module Value : sig
    val int : int -> string
    val float : float -> string
    val string : string -> string
    val bool : bool -> string
  end

  (** 数组操作 *)
  module Array : sig
    val create : int -> string -> string
    val get : string -> string -> string
    val set : string -> string -> string -> string
  end

  (** 函数调用格式化 *)
  val function_call : string -> string list -> string

  (** 变量声明 *)
  val variable_declaration : string -> string -> string

  (** 头文件包含 *)
  val include_system : string -> string
  val include_local : string -> string

  (** 注释格式 *)
  val comment : string -> string
  val line_comment : string -> string
end

(** 报告和进度格式化模块 *)
module Report : sig
  (** 带图标的统计信息 *)
  val stats_with_icon : string -> string -> int -> string

  (** 操作计时信息 *)
  val operation_timing : string -> float -> string

  (** 分类计数（自动选择图标） *)
  val categorized_count : string -> int -> string

  (** 简单的总数统计 *)
  val total_count : string -> int -> string

  (** 进度指示器 *)
  val progress_indicator : int -> int -> string -> string
end

(** 诗词和语言处理格式化模块 *)
module Poetry : sig
  (** 字符数不匹配错误 *)
  val character_count_mismatch : int -> int -> string

  (** 诗句数量提示 *)
  val verse_count_warning : int -> int -> string -> string

  (** 韵律分析结果 *)
  val rhyme_analysis : string -> string -> string

  (** 平仄模式 *)
  val tone_pattern : string -> string
end

(** Token和解析格式化模块 *)
module Token : sig
  (** 整数Token *)
  val int_token : int -> string

  (** 字符串Token *)
  val string_token : string -> string

  (** 布尔Token *)
  val bool_token : bool -> string

  (** 标识符Token *)
  val identifier_token : string -> string

  (** 关键字Token *)
  val keyword_token : string -> string
end

(** 数据加载和验证格式化模块 *)
module Data : sig
  (** 数据加载失败 *)
  val loading_failure : string -> string -> string -> string

  (** 数据验证失败 *)
  val validation_failure : string -> string -> string -> string

  (** JSON解析错误 *)
  val json_parse_error : string -> string -> string

  (** 数据缓存信息 *)
  val cache_status : string -> string -> string
end

(** 通用格式化工具 *)
module Common : sig
  (** 简单的键值对格式 *)
  val key_value : string -> string -> string

  (** 列表格式化 *)
  val list_format : string list -> string -> string

  (** 带括号的格式 *)
  val parenthesized : string -> string

  (** 带方括号的格式 *)
  val bracketed : string -> string

  (** 带大括号的格式 *)
  val braced : string -> string
end