(** 骆言编译器核心格式化模块接口

    本模块提供通用格式化工具和基础功能，包含多个专业化的格式化子模块。 主要用于替代Printf.sprintf模式，提供类型安全和性能优化的格式化操作。

    从unified_formatter.ml中拆分而来，专注于核心格式化功能的模块化设计。

    @author 骆言AI代理
    @version 1.0
    @since 2025-07-22 *)

(** 通用格式化工具模块 *)
module General : sig
  val format_identifier : string -> string
  (** 格式化标识符，添加中文引号标记 *)

  val format_function_signature : string -> string list -> string
  (** 格式化函数签名 *)

  val format_type_signature : string -> string list -> string
  (** 格式化类型签名，包含类型参数 *)

  val format_module_path : string list -> string
  (** 格式化模块路径，使用点号分隔 *)

  val format_list : string list -> string -> string
  (** 通用列表格式化，使用指定分隔符 *)

  val format_key_value : string -> string -> string
  (** 格式化键值对 *)

  val format_chinese_list : string list -> string
  (** 中文语法相关格式化 *)

  val format_variable_definition : string -> string
  (** 格式化变量定义的中文表示 *)

  val format_context_info : int -> string -> string
  (** 格式化上下文信息，显示可用项目数量 *)

  val format_range : int -> int -> string
  (** 扩展通用格式化功能 *)

  val format_percentage : float -> string
  val format_size_info : int -> string
  val format_duration_ms : int -> string
  val format_duration_sec : float -> string
end

(** 索引和数组操作格式化模块 *)
module Collections : sig
  val index_out_of_bounds : int -> int -> string
  (** 数组索引越界错误消息 *)

  val array_access_error : string -> int -> string
  (** 数组访问错误消息 *)

  val array_bounds_error : int -> int -> string
  (** 数组边界错误消息 *)

  val list_operation_error : string -> string
  (** 列表操作错误消息 *)

  val empty_collection_error : string -> string -> string
  (** 扩展集合操作错误处理 *)

  val collection_size_mismatch : int -> int -> string
  val format_collection_info : string -> int -> int -> string
end

(** 转换和类型转换格式化模块 *)
module Conversions : sig
  val type_conversion : string -> string -> string
  (** 类型转换表达式格式化 *)

  val casting_error : string -> string -> string
  (** 类型转换错误消息 *)

  val format_conversion_attempt : string -> string -> string
  (** 扩展转换功能 *)

  val format_conversion_success : string -> string -> string -> string
  val format_conversion_failure : string -> string -> string -> string
end

(** 类型系统格式化模块 *)
module TypeFormatter : sig
  val format_function_type : string -> string -> string
  (** 函数类型格式化 *)

  val format_list_type : string -> string
  (** 列表类型格式化 *)

  val format_construct_type : string -> string list -> string
  (** 构造类型格式化 *)

  val format_reference_type : string -> string
  (** 引用类型格式化 *)

  val format_array_type : string -> string
  (** 数组类型格式化 *)

  val format_class_type : string -> string -> string
  (** 类类型格式化 *)

  val format_tuple_type : string list -> string
  (** 元组类型格式化 *)

  val format_record_type : string -> string
  (** 记录类型格式化 *)

  val format_object_type : string -> string
  (** 对象类型格式化 *)

  val format_variant_type : string -> string
  (** 多态变体类型格式化 *)

  val format_option_type : string -> string
  (** 扩展类型格式化 *)

  val format_result_type : string -> string -> string
  val format_generic_type : string -> string list -> string
end

(** 报告格式化模块 *)
module ReportFormatting : sig
  val token_registry_stats : int -> int -> string -> string
  (** Token注册器统计报告 *)

  val category_count_item : string -> int -> string
  (** 分类统计项格式化 *)

  val token_compatibility_report : int -> string -> string
  (** Token兼容性基础报告 *)

  val detailed_token_compatibility_report : int -> string -> string
  (** 详细Token兼容性报告 *)

  val format_summary_section : string -> string list -> string
  (** 扩展报告功能 *)

  val format_metrics_table : (string * string) list -> string
  val format_comparison_report : string -> string -> string list -> string
end

(** 字符串处理基础设施格式化模块 *)
module StringProcessingFormatter : sig
  val format_error_template : string -> string -> string
  (** 错误模板格式化 *)

  val format_position_info : int -> int -> string
  (** 位置信息格式化 *)

  val format_token_info : string -> string -> string
  (** Token信息格式化 *)

  val format_report_section : string -> string -> string
  (** 报告段落格式化 *)

  val format_message_template : string -> string list -> string
  (** 消息模板格式化，支持参数替换 *)

  val format_string_operation : string -> string -> string -> string
  (** 扩展字符串处理 *)

  val format_pattern_match : string -> string -> bool -> string
  val format_encoding_info : string -> string -> string
end

(** 扩展功能模块 *)
module ExtendedFormatting : sig
  val format_version_info : int -> int -> int -> string
  (** 版本信息格式化 *)

  val format_build_info : string -> int -> string -> string

  val format_config_entry : string -> string -> string -> string
  (** 配置信息格式化 *)

  val format_config_section : string -> string list -> string

  val format_dependency : string -> string -> bool -> string
  (** 依赖信息格式化 *)

  val format_dependency_tree : int -> string -> string list -> string

  val format_environment_var : string -> string -> bool -> string
  (** 环境信息格式化 *)

  val format_system_info : string -> string -> string -> string
end
