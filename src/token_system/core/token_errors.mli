(** 骆言编译器 - Token系统错误处理接口
    
    提供统一的Token错误处理机制。
    
    @author Alpha, 技术债务清理专员
    @version 2.0
    @since 2025-07-25
    @issue #1353 *)

open Token_types

(** {1 错误类型定义} *)

(** Token错误类型 *)
type token_error =
  | UnknownToken of string * position option           (** 未知Token *)
  | InvalidTokenFormat of string * string * position   (** Token格式错误 *)
  | ConversionError of string * string                 (** 转换错误 *)
  | RegistryError of string                            (** 注册表错误 *)
  | TokenMismatch of token * token * position          (** Token不匹配 *)
  | EmptyTokenStream                                   (** 空Token流 *)
  | InvalidPosition of position                        (** 无效位置信息 *)
  | ParsingError of string * position                  (** 解析错误 *)
  | TokenizationError of string * int * int            (** Token化错误 *)

(** Token操作结果类型 *)
type 'a token_result = ('a, token_error) result

(** {1 错误严重程度和上下文} *)

(** 错误严重程度 *)
type error_severity =
  | Warning   (** 警告 *)
  | Error     (** 错误 *)
  | Fatal     (** 致命错误 *)

(** 错误上下文信息 *)
type error_context = {
  source_file : string option;
  function_name : string option;
  additional_info : string option;
}

(** 完整错误信息 *)
type detailed_error = {
  error : token_error;
  severity : error_severity;
  context : error_context;
  timestamp : float;
}

(** {1 错误收集器} *)

(** 错误收集器类型 *)
type error_collector

(** 创建错误收集器
    @param max_errors 最大错误数量，默认100
    @param stop_on_fatal 遇到致命错误时是否停止，默认true
    @return 新的错误收集器 *)
val create_error_collector : ?max_errors:int -> ?stop_on_fatal:bool -> unit -> error_collector

(** 收集错误
    @param collector 错误收集器
    @param error 要收集的错误
    @param context 错误上下文
    @return (更新后的收集器, 是否应该停止处理) *)
val collect_error : error_collector -> token_error -> error_context -> error_collector * bool

(** 获取所有收集的错误
    @param collector 错误收集器
    @return 所有错误列表，按时间顺序排列 *)
val get_all_errors : error_collector -> detailed_error list

(** 获取指定严重程度的错误
    @param collector 错误收集器
    @param severity 错误严重程度
    @return 指定严重程度的错误列表 *)
val get_errors_by_severity : error_collector -> error_severity -> detailed_error list

(** 检查是否有致命错误
    @param collector 错误收集器
    @return 如果有致命错误返回true *)
val has_fatal_errors : error_collector -> bool

(** {1 错误格式化和转换} *)

(** 将错误转换为字符串
    @param error Token错误
    @return 错误的字符串描述 *)
val error_to_string : token_error -> string

(** 获取错误的严重程度
    @param error Token错误
    @return 错误的严重程度 *)
val get_error_severity : token_error -> error_severity

(** 格式化错误报告
    @param collector 错误收集器
    @return 格式化的错误报告字符串 *)
val format_error_report : error_collector -> string

(** {1 Result类型操作} *)

(** 创建错误结果
    @param error Token错误
    @return 错误结果 *)
val error_result : token_error -> 'a token_result

(** 创建成功结果
    @param value 成功值
    @return 成功结果 *)
val ok_result : 'a -> 'a token_result

(** Result的bind操作
    @param result 输入结果
    @param f 处理函数
    @return 新的结果 *)
val bind_result : 'a token_result -> ('a -> 'b token_result) -> 'b token_result

(** Result的map操作
    @param f 映射函数
    @param result 输入结果
    @return 映射后的结果 *)
val map_result : ('a -> 'b) -> 'a token_result -> 'b token_result

(** {1 错误上下文创建} *)

(** 默认错误上下文 *)
val default_context : error_context

(** 创建带函数名的错误上下文
    @param func_name 函数名
    @return 错误上下文 *)
val context_with_function : string -> error_context

(** 创建带源文件的错误上下文
    @param file_name 源文件名
    @return 错误上下文 *)
val context_with_file : string -> error_context

(** {1 安全操作模块} *)

(** 安全Token操作模块 *)
module SafeOps : sig
  
  (** 安全的Token查找
      @param text 要查找的文本
      @return Token查找结果 *)
  val safe_lookup_token : string -> token token_result
  
  (** 安全的Token文本获取
      @param token 要获取文本的token
      @return Token文本结果 *)
  val safe_get_token_text : token -> string token_result
  
  (** 安全的位置创建
      @param line 行号
      @param column 列号
      @param offset 偏移量
      @return 位置创建结果 *)
  val safe_create_position : int -> int -> int -> position token_result
  
  (** 安全的Token流处理
      @param stream Token流
      @param f 处理函数
      @return 处理结果 *)
  val safe_process_token_stream : positioned_token list -> (positioned_token list -> 'a) -> 'a token_result
  
end