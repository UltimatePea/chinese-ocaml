(** 字符串处理工具函数模块 - String Processing Utilities Module

    这个模块提供了骆言编程语言中常用的字符串处理工具函数，主要用于 词法分析、语法分析和代码预处理阶段。该模块通过提供通用的字符串 处理功能，减少代码重复，提高代码的可维护性和可复用性。

    该模块的主要职责包括：
    - 提供字符串处理的通用模板和框架
    - 实现各种注释的移除功能
    - 处理不同类型的字符串字面量
    - 支持复杂的字符串扫描和跳过逻辑
    - 优化字符串处理的性能和内存使用

    支持的字符串处理功能：
    - 通用字符串扫描框架
    - 块注释处理 (* ... *)
    - 行注释处理 (// 和 # 风格)
    - 骆言字符串字面量处理 『...』
    - 英文字符串字面量处理 "..." 和 '...'
    - 嵌套结构的正确处理
    - 转义字符的支持

    @author 骆言项目组
    @since 0.1.0 *)

(** 保留被直接使用的字符串处理函数 *)
val remove_hash_comment : string -> string
(** 移除Shell/Python风格的井号注释 # *)

val remove_double_slash_comment : string -> string
(** 移除C++/Java风格的双斜杠注释 // *)

val remove_block_comments : string -> string
(** 移除OCaml风格的块注释 (* ... *) *)

val remove_luoyan_strings : string -> string
(** 移除骆言风格的字符串字面量 『...』 *)

val remove_english_strings : string -> string
(** 移除英文风格的字符串字面量 *)

(** 统一字符串格式化工具模块 - 为解决字符串处理重复问题而设计的统一接口

    该模块提供了一系列子模块来统一处理骆言编程语言中常见的字符串格式化需求， 旨在消除代码重复，提高代码的可维护性和一致性。 *)

(** 通用错误消息模板模块 *)
module ErrorMessageTemplates : sig
  val function_param_error : string -> int -> int -> string
  (** 函数参数数量错误消息 *)

  val function_param_type_error : string -> string -> string
  (** 函数参数类型错误消息 *)

  val function_single_param_error : string -> string
  (** 单参数函数错误消息 *)

  val function_double_param_error : string -> string
  (** 双参数函数错误消息 *)

  val function_no_param_error : string -> string
  (** 无参数函数错误消息 *)

  val type_mismatch_error : string -> string -> string
  (** 类型不匹配错误消息 *)

  val undefined_variable_error : string -> string
  (** 未定义变量错误消息 *)

  val generic_function_error : string -> string -> string
  (** 通用函数错误消息 *)

  val file_operation_error : string -> string -> string
  (** 文件操作错误消息 *)
end

(** 位置信息格式化模块 *)
module PositionFormatting : sig
  val format_position_with_fields : filename:string -> line:int -> column:int -> string
  (** 通用位置格式化函数，使用命名参数 *)

  val format_optional_position_with_extractor :
    'a option ->
    get_filename:('a -> string) ->
    get_line:('a -> int) ->
    get_column:('a -> int) ->
    string
  (** 格式化可选位置信息，使用提取函数 *)
end

(** C代码生成格式化模块 - 当前未使用，保留为空以备将来使用 *)
module CCodegenFormatting : sig
  (* 所有函数签名已移除以避免编译警告 *)
end

(** 列表和集合格式化模块 *)
module CollectionFormatting : sig
  val join_chinese : string list -> string
  (** 中文顿号分隔 *)
end

(** 报告生成格式化模块 *)
module ReportFormatting : sig
  val suggestion_line : string -> string -> string
  (** 建议信息格式化 *)

  val similarity_suggestion : string -> float -> string
  (** 相似度建议格式化 *)
end

(** 颜色和样式格式化模块 - 当前未使用，保留为空以备将来使用 *)
module StyleFormatting : sig
  (* 所有函数签名已移除以避免编译警告 *)
end

(** Buffer累积辅助模块 - 当前未使用，保留为空以备将来使用 *)
module BufferHelpers : sig
  (* 所有函数签名已移除以避免编译警告 *)
end
