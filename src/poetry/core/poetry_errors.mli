(** 骆言诗词错误处理模块接口 Author: Alpha, 主要工作代理 - 负责功能实现和技术债务处理

    统一的错误处理接口，提供类型化的错误管理和恢复机制。 *)

open Poetry_types

(** === 错误分类系统 === *)

type error_severity =
  | Critical  (** 严重错误 - 系统无法继续运行 *)
  | Error  (** 一般错误 - 操作失败但系统可继续 *)
  | Warning  (** 警告 - 操作成功但有潜在问题 *)
  | Info  (** 信息 - 仅供参考 *)

type error_category =
  | DataError  (** 数据相关错误 *)
  | ParseError  (** 解析错误 *)
  | ValidationError  (** 验证错误 *)
  | ConfigError  (** 配置错误 *)
  | NetworkError  (** 网络错误 *)
  | SystemError  (** 系统错误 *)

(** === 具体错误类型定义 === *)

type data_error =
  | File_Not_Found of string
  | Invalid_JSON of string * string
  | Data_Corruption of string
  | Missing_Required_Field of string * string
  | Cache_Miss of string
  | Cache_Expired of string
  | DataSourceError of string

type parse_error =
  | Invalid_Character of chinese_character * int
  | Malformed_Poem of string
  | Unknown_Rhyme_Pattern of string
  | Invalid_Meter of string

type validation_error =
  | Empty_Input
  | Text_Too_Long of int * int
  | Invalid_Poem_Form of poem_form * string
  | Rhyme_Mismatch of string * string
  | Meter_Violation of meter_pattern * string

type config_error =
  | Invalid_Config_File of string
  | Missing_Config_Value of string
  | Invalid_Cache_Size of int
  | Unsupported_Data_Source of string

type network_error =
  | Connection_Failed of string
  | Timeout of int
  | HTTP_Error of int * string
  | API_Rate_Limit

type system_error =
  | Memory_Exhausted
  | Disk_Full
  | Permission_Denied of string
  | Resource_Busy of string

(** === 统一错误类型 === *)

type poetry_error = {
  category : error_category;
  severity : error_severity;
  message : string;
  details : string option;
  timestamp : float;
  source_location : string option;
  error_chain : poetry_error list;
  recovery_suggestion : string option;
}

type specific_error =
  | Data_Error of data_error
  | Parse_Error of parse_error
  | Validation_Error of validation_error
  | Config_Error of config_error
  | Network_Error of network_error
  | System_Error of system_error

(** === 错误创建函数 === *)

val create_error :
  ?details:string option ->
  ?source_location:string option ->
  ?error_chain:poetry_error list ->
  ?recovery_suggestion:string option ->
  error_category ->
  error_severity ->
  string ->
  poetry_error
(** 创建一个新的错误对象 *)

(** === 具体错误构造函数 === *)

val data_error : data_error -> poetry_error
(** 创建数据错误 *)

val parse_error : parse_error -> poetry_error
(** 创建解析错误 *)

val validation_error : validation_error -> poetry_error
(** 创建验证错误 *)

(** === 错误处理辅助函数 === *)

val chain_error : poetry_error -> poetry_error -> poetry_error
(** 将错误链接起来，用于错误传播 *)

val is_recoverable : poetry_error -> bool
(** 判断错误是否可恢复 *)

val get_error_message : poetry_error -> string
(** 获取错误消息 *)

val get_full_error_description : poetry_error -> string
(** 获取完整的错误描述，包括详细信息和恢复建议 *)

val format_error_chain : poetry_error list -> string
(** 格式化错误链为可读字符串 *)

(** === 结果类型的错误处理 === *)

val map_error : (string -> string) -> 'a analysis_result -> 'a analysis_result
(** 对结果中的错误消息进行映射 *)

val bind_error : ('a -> 'b analysis_result) -> 'a analysis_result -> 'b analysis_result
(** 错误处理的bind操作 *)

val catch_errors : (unit -> 'a) -> 'a analysis_result
(** 捕获异常并转换为错误结果 *)

(** === 日志记录 === *)

type log_level = Debug | Info | Warn | Error | Fatal

val log_error : ?level:log_level -> poetry_error -> unit
(** 记录错误日志 *)

(** === 向后兼容性异常 === *)

exception DataSourceError of string
(** 数据源错误异常 - 为保持向后兼容性而添加 *)
