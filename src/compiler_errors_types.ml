(** 错误类型定义 - 骆言编译器 *)

type position = { filename : string; line : int; column : int } [@@deriving show, eq]
(** 通用位置类型 - 避免循环依赖 *)

(** 编译器错误类型 *)
type compiler_error =
  | LexError of string * position  (** 词法分析错误 *)
  | ParseError of string * position  (** 语法分析错误 *)
  | SyntaxError of string * position  (** 语法错误 *)
  | PoetryParseError of string * position option  (** 诗词解析错误 *)
  | TypeError of string * position option  (** 类型错误 *)
  | SemanticError of string * position option  (** 语义分析错误 *)
  | CodegenError of string * string  (** 代码生成错误：错误信息和上下文 *)
  | RuntimeError of string * position option  (** 运行时错误 *)
  | ExceptionRaised of string * position option  (** 异常抛出 *)
  | UnimplementedFeature of string * string  (** 未实现功能：功能名和上下文 *)
  | InternalError of string  (** 内部错误 *)
  | IOError of string * string  (** IO错误：错误信息和文件路径 *)

(** 错误严重级别 *)
type error_severity = Warning | Error | Fatal

type error_info = {
  error : compiler_error;
  severity : error_severity;
  context : string option;
  suggestions : string list;
}
(** 错误信息记录 *)

(** 错误处理结果 *)
type 'a error_result = Ok of 'a | Error of error_info

type error_collector = { mutable errors : error_info list; mutable has_fatal : bool }
(** 错误收集器 - 用于收集多个错误 *)

type error_handling_config = {
  continue_on_error : bool;  (** 遇到错误时是否继续 *)
  max_errors : int;  (** 最大错误数量 *)
  show_suggestions : bool;  (** 是否显示建议 *)
  colored_output : bool;  (** 是否使用彩色输出 *)
}
(** 错误处理策略配置 *)

exception CompilerError of error_info
(** 编译器异常类型 *)
