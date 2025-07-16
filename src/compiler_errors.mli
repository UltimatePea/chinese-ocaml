(** 统一错误处理系统 - 骆言编译器

    此模块提供了编译器的统一错误处理系统，包括错误类型定义、 错误信息格式化、错误收集和处理配置等功能。 *)

type position = { filename : string; line : int; column : int } [@@deriving show, eq]
(** 通用位置类型 - 避免循环依赖 *)

(** 编译器错误类型 *)
type compiler_error =
  | LexError of string * position  (** 词法分析错误：错误信息和位置 *)
  | ParseError of string * position  (** 语法分析错误：错误信息和位置 *)
  | SyntaxError of string * position  (** 语法错误：错误信息和位置 *)
  | PoetryParseError of string * position option  (** 诗词解析错误：错误信息和可选位置 *)
  | TypeError of string * position option  (** 类型错误：错误信息和可选位置 *)
  | SemanticError of string * position option  (** 语义分析错误：错误信息和可选位置 *)
  | CodegenError of string * string  (** 代码生成错误：错误信息和上下文 *)
  | RuntimeError of string * position option  (** 运行时错误：错误信息和可选位置 *)
  | ExceptionRaised of string * position option  (** 异常抛出：错误信息和可选位置 *)
  | UnimplementedFeature of string * string  (** 未实现功能：功能名和上下文 *)
  | InternalError of string  (** 内部错误：错误信息 *)
  | IOError of string * string  (** IO错误：错误信息和文件路径 *)

(** 错误严重级别 *)
type error_severity = Warning | Error | Fatal

type error_info = {
  error : compiler_error;  (** 错误类型 *)
  severity : error_severity;  (** 错误严重级别 *)
  context : string option;  (** 错误上下文信息 *)
  suggestions : string list;  (** 修复建议列表 *)
}
(** 错误信息记录，包含错误详细信息、严重级别、上下文和建议 *)

(** 错误处理结果类型，用于表示可能失败的操作 *)
type 'a error_result = Ok of 'a | Error of error_info

val make_error_info :
  ?severity:error_severity ->
  ?context:string option ->
  ?suggestions:string list ->
  compiler_error ->
  error_info
(** 创建错误信息记录
    @param severity 错误严重级别，默认为Error
    @param context 错误上下文信息，默认为None
    @param suggestions 修复建议列表，默认为空列表
    @param error 编译器错误
    @return 错误信息记录 *)

val format_position : position -> string
(** 格式化位置信息为字符串
    @param pos 源代码位置
    @return 格式化的位置字符串 (文件名:行号:列号) *)

val format_error_message : compiler_error -> string
(** 格式化错误消息
    @param error 编译器错误
    @return 格式化的错误消息字符串 *)

val format_error_info : error_info -> string
(** 格式化完整错误信息，包含严重级别、错误消息、上下文和建议
    @param info 错误信息记录
    @return 格式化的完整错误信息字符串 *)

val print_error_info : error_info -> unit
(** 输出错误信息到标准错误流
    @param info 错误信息记录 *)

(** 常用错误创建函数 *)

val parse_error : ?suggestions:string list -> string -> position -> 'a error_result
(** 创建语法分析错误
    @param suggestions 修复建议列表，默认为空
    @param msg 错误消息
    @param pos 错误位置
    @return 错误结果 *)

val lex_error : ?suggestions:string list -> string -> position -> 'a error_result
(** 创建词法分析错误
    @param suggestions 修复建议列表，默认为空
    @param msg 错误消息
    @param pos 错误位置
    @return 错误结果 *)

val syntax_error : ?suggestions:string list -> string -> position -> 'a error_result
(** 创建语法错误
    @param suggestions 修复建议列表，默认为空
    @param msg 错误消息
    @param pos 错误位置
    @return 错误结果 *)

val poetry_parse_error : ?suggestions:string list -> string -> position option -> 'a error_result
(** 创建诗词解析错误
    @param suggestions 修复建议列表，默认为空
    @param msg 错误消息
    @param pos_opt 可选的错误位置
    @return 错误结果 *)

val type_error : ?suggestions:string list -> string -> position option -> 'a error_result
(** 创建类型错误
    @param suggestions 修复建议列表，默认为空
    @param msg 错误消息
    @param pos_opt 可选的错误位置
    @return 错误结果 *)

val semantic_error : ?suggestions:string list -> string -> position option -> 'a error_result
(** 创建语义分析错误
    @param suggestions 修复建议列表，默认为空
    @param msg 错误消息
    @param pos_opt 可选的错误位置
    @return 错误结果 *)

val codegen_error : ?suggestions:string list -> ?context:string -> string -> 'a error_result
(** 创建代码生成错误
    @param suggestions 修复建议列表，默认为空
    @param context 错误上下文，默认为"unknown"
    @param msg 错误消息
    @return 错误结果 *)

val runtime_error : ?suggestions:string list -> string -> position option -> 'a error_result
(** 创建运行时错误
    @param suggestions 修复建议列表，默认为空
    @param msg 错误消息
    @param pos_opt 可选的错误位置
    @return 错误结果 *)

val exception_raised : ?suggestions:string list -> string -> position option -> 'a error_result
(** 创建异常抛出错误
    @param suggestions 修复建议列表，默认为空
    @param msg 错误消息
    @param pos_opt 可选的错误位置
    @return 错误结果 *)

val unimplemented_feature : ?suggestions:string list -> ?context:string -> string -> 'a error_result
(** 创建未实现功能错误
    @param suggestions 额外的修复建议列表，默认为空
    @param context 错误上下文，默认为"C代码生成"
    @param feature 未实现的功能名
    @return 错误结果 *)

val internal_error : ?suggestions:string list -> string -> 'a error_result
(** 创建内部错误
    @param suggestions 额外的修复建议列表，默认为空
    @param msg 错误消息
    @return 错误结果 *)

val io_error : ?suggestions:string list -> string -> string -> 'a error_result
(** 创建IO错误
    @param suggestions 修复建议列表，默认为空
    @param msg 错误消息
    @param filepath 文件路径
    @return 错误结果 *)

(** 错误处理工具函数 *)

val map_error : ('a -> 'b) -> 'a error_result -> 'b error_result
(** 映射成功结果，错误结果保持不变
    @param f 转换函数
    @param result 错误结果
    @return 转换后的错误结果 *)

val bind_error : ('a -> 'b error_result) -> 'a error_result -> 'b error_result
(** 绑定错误结果，用于链式处理
    @param f 处理函数
    @param result 错误结果
    @return 处理后的错误结果 *)

val ( >>= ) : 'a error_result -> ('a -> 'b error_result) -> 'b error_result
(** 错误结果绑定操作符 *)

val ( >>| ) : 'a error_result -> ('a -> 'b) -> 'b error_result
(** 错误结果映射操作符 *)

type error_collector = {
  mutable errors : error_info list;  (** 错误信息列表 *)
  mutable has_fatal : bool;  (** 是否包含致命错误 *)
}
(** 错误收集器，用于收集多个错误 *)

val create_error_collector : unit -> error_collector
(** 创建新的错误收集器
    @return 空的错误收集器 *)

val add_error : error_collector -> error_info -> unit
(** 向错误收集器添加错误
    @param collector 错误收集器
    @param error_info 错误信息 *)

val has_errors : error_collector -> bool
(** 检查错误收集器是否包含错误
    @param collector 错误收集器
    @return 如果包含错误则返回true *)

val get_errors : error_collector -> error_info list
(** 获取错误收集器中的所有错误（按添加顺序）
    @param collector 错误收集器
    @return 错误信息列表 *)

val get_error_count : error_collector -> int
(** 获取错误收集器中的错误数量
    @param collector 错误收集器
    @return 错误数量 *)

type error_handling_config = {
  continue_on_error : bool;  (** 遇到错误时是否继续处理 *)
  max_errors : int;  (** 最大错误数量限制 *)
  show_suggestions : bool;  (** 是否显示修复建议 *)
  colored_output : bool;  (** 是否使用彩色输出 *)
}
(** 错误处理策略配置 *)

val get_error_config : unit -> error_handling_config
(** 获取错误处理配置 - 从统一配置系统 *)

val set_error_config : error_handling_config -> unit
(** 设置错误处理配置
    @param new_config 新的错误处理配置 *)

val should_continue : error_collector -> bool
(** 检查是否应该继续处理（基于配置和错误状态）
    @param collector 错误收集器
    @return 如果应该继续处理则返回true *)

(** 兼容性函数：异常转换 *)

exception CompilerError of error_info
(** 统一的编译器异常类型 *)

val raise_compiler_error : error_info -> 'a
(** 抛出统一的编译器异常
    @param error_info 错误信息
    @raise CompilerError 统一的编译器异常 *)

val wrap_legacy_exception : (unit -> 'a error_result) -> 'a error_result
(** 包装可能抛出旧异常的函数
    @param f 可能抛出旧异常的函数
    @return 统一的错误结果 *)

val extract_error_info : 'a error_result -> error_info
(** 从错误结果中提取错误信息
    @param result 错误结果
    @return 错误信息
    @raise Failure 如果结果不是Error *)

val safe_execute : (unit -> 'a) -> 'a error_result
(** 安全执行函数，捕获异常并转换为统一错误格式
    @param f 要执行的函数
    @return 统一的错误结果 *)
