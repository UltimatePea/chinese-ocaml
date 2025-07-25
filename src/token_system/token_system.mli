(** 骆言编译器 - 统一Token系统主模块接口
    
    @author Alpha, 技术债务清理专员
    @version 2.0
    @since 2025-07-25
    @issue #1353 *)

module Types = Token_system_core.Token_types
(** 核心类型和模块 *)

module Errors = Token_system_core.Token_errors
module Registry = Token_system_core.Token_registry

module Converter = Token_system_conversion.Token_converter
(** 转换器模块 *)

module KeywordConverter = Token_system_conversion.Keyword_converter
module IdentifierConverter = Token_system_conversion.Identifier_converter
module OperatorConverter = Token_system_conversion.Operator_converter

module Compatibility = Token_system_compatibility.Legacy_token_bridge
(** 兼容性模块 *)

module Utils = Token_system_utils.Token_utils
(** 工具模块 *)

val version : string
(** 系统版本信息 *)

val build_date : string
val issue_number : int

(** 转换API *)
module ConversionAPI : sig
  val string_to_token :
    ?config:Converter.converter_config -> string -> Types.token Errors.token_result

  val token_to_string :
    ?config:Converter.converter_config -> Types.token -> string Errors.token_result

  val strings_to_tokens :
    ?config:Converter.converter_config -> string list -> Types.token list Errors.token_result

  val tokens_to_strings :
    ?config:Converter.converter_config -> Types.token list -> string list Errors.token_result
end

(** 系统信息和统计 *)
module SystemInfo : sig
  val get_system_info : unit -> (string * string) list
  val generate_status_report : unit -> string
  val run_self_check : unit -> string Errors.token_result
end

(** 查找API *)
module LookupAPI : sig
  val find_token : string -> Registry.lookup_result
  val get_text : Types.token -> string option
  val is_registered : Types.token -> bool
  val get_by_category : Types.token_category -> Types.token list
end

(** 调试API *)
module DebugAPI : sig
  val print_tokens : Types.token list -> unit
  val print_token_stream : Types.token_stream -> unit
  val generate_stats : Types.token list -> (string * int) list
  val validate_syntax : Types.token_stream -> unit Errors.token_result
end

(** 批量处理API *)
module BatchAPI : sig
  val process_token_file : string -> Types.token_stream Errors.token_result
  val batch_convert_texts : string list -> Types.token list Errors.token_result
end

val init : unit -> unit Errors.token_result
(** 主初始化函数 *)
